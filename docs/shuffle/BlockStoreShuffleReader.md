== [[BlockStoreShuffleReader]] BlockStoreShuffleReader

`BlockStoreShuffleReader` is the one and only known spark-shuffle-ShuffleReader.md[ShuffleReader] that <<read, reads the combined key-values for the reduce task>> (for a range of <<startPartition, start>> and <<endPartition, end>> reduce partitions) from a shuffle by requesting them from block managers.

`BlockStoreShuffleReader` is <<creating-instance, created>> exclusively when `SortShuffleManager` is requested for the SortShuffleManager.md#getReader[ShuffleReader] for a range of reduce partitions.

=== [[read]] Reading Combined Records For Reduce Task

[source, scala]
----
read(): Iterator[Product2[K, C]]
----

NOTE: `read` is part of spark-shuffle-ShuffleReader.md#read[ShuffleReader Contract].

Internally, `read` first storage:ShuffleBlockFetcherIterator.md#creating-instance[creates a `ShuffleBlockFetcherIterator`] (passing in the values of <<spark_reducer_maxSizeInFlight, spark.reducer.maxSizeInFlight>>, <<spark_reducer_maxReqsInFlight, spark.reducer.maxReqsInFlight>> and <<spark_shuffle_detectCorrupt, spark.shuffle.detectCorrupt>> Spark properties).

NOTE: `read` uses storage:BlockManager.md#shuffleClient[`BlockManager` to access `ShuffleClient`] to create `ShuffleBlockFetcherIterator`.

NOTE: `read` uses scheduler:MapOutputTracker.md#getMapSizesByExecutorId[`MapOutputTracker` to find the BlockManagers with the shuffle blocks and sizes] to create `ShuffleBlockFetcherIterator`.

`read` creates a new serializer:SerializerInstance.md[SerializerInstance] (using rdd:ShuffleDependency.md#serializer[`Serializer` from ShuffleDependency]).

`read` creates a key/value iterator by `deserializeStream` every shuffle block stream.

`read` updates the spark-TaskContext.md#taskMetrics[context task metrics] for each record read.

NOTE: `read` uses `CompletionIterator` (to count the records read) and spark-InterruptibleIterator.md[InterruptibleIterator] (to support task cancellation).

If the rdd:ShuffleDependency.md#aggregator[`ShuffleDependency` has an `Aggregator` defined], `read` wraps the current iterator inside an iterator defined by rdd:Aggregator.md#combineCombinersByKey[Aggregator.combineCombinersByKey] (for rdd:ShuffleDependency.md#mapSideCombine[`mapSideCombine` enabled]) or rdd:Aggregator.md#combineValuesByKey[Aggregator.combineValuesByKey] otherwise.

NOTE: `run` reports an exception when rdd:ShuffleDependency.md#aggregator[`ShuffleDependency` has no `Aggregator` defined] with rdd:ShuffleDependency.md#mapSideCombine[`mapSideCombine` flag enabled].

For rdd:ShuffleDependency.md#keyOrdering[`keyOrdering` defined in `ShuffleDependency`], `run` does the following:

1. shuffle:ExternalSorter.md#creating-instance[Creates an `ExternalSorter`]
2. shuffle:ExternalSorter.md#insertAll[Inserts all the records] into the `ExternalSorter`
3. Updates context `TaskMetrics`
4. Returns a `CompletionIterator` for the `ExternalSorter`

=== [[settings]] Settings

.Spark Properties
[cols="1,1,2",options="header",width="100%"]
|===
| Spark Property
| Default Value
| Description

| [[spark_reducer_maxSizeInFlight]] `spark.reducer.maxSizeInFlight`
| `48m`
| Maximum size (in bytes) of map outputs to fetch simultaneously from each reduce task.

Since each output requires a new buffer to receive it, this represents a fixed memory overhead per reduce task, so keep it small unless you have a large amount of memory.

Used when <<read, `BlockStoreShuffleReader` creates a `ShuffleBlockFetcherIterator` to read records>>.

| [[spark_reducer_maxReqsInFlight]] `spark.reducer.maxReqsInFlight`
| (unlimited)
| The maximum number of remote requests to fetch blocks at any given point.

When the number of hosts in the cluster increases, it might lead to very large number of in-bound connections to one or more nodes, causing the workers to fail under load. By allowing it to limit the number of fetch requests, this scenario can be mitigated.

Used when <<read, `BlockStoreShuffleReader` creates a `ShuffleBlockFetcherIterator` to read records>>.

| [[spark_shuffle_detectCorrupt]] `spark.shuffle.detectCorrupt`
| `true`
| Controls whether to detect any corruption in fetched blocks.

Used when <<read, `BlockStoreShuffleReader` creates a `ShuffleBlockFetcherIterator` to read records>>.

|===

=== [[creating-instance]] Creating BlockStoreShuffleReader Instance

`BlockStoreShuffleReader` takes the following when created:

* [[handle]] spark-shuffle-BaseShuffleHandle.md[BaseShuffleHandle]
* [[startPartition]] Reduce start partition index
* [[endPartition]] Reduce end partition index
* [[context]] spark-TaskContext.md[TaskContext]
* [[serializerManager]] serializer:SerializerManager.md[SerializerManager]
* [[blockManager]] storage:BlockManager.md[BlockManager]
* [[mapOutputTracker]] scheduler:MapOutputTracker.md[MapOutputTracker]

`BlockStoreShuffleReader` initializes the <<internal-registries, internal registries and counters>>.

NOTE: `BlockStoreShuffleReader` uses `SparkEnv` to access the <<serializerManager, SerializerManager>>, <<blockManager, BlockManager>> and <<mapOutputTracker, MapOutputTracker>>.
