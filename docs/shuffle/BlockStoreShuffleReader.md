# BlockStoreShuffleReader

`BlockStoreShuffleReader[K, C]` is a [ShuffleReader](ShuffleReader.md) of `K` keys and `C` values.

## Creating Instance

`BlockStoreShuffleReader` takes the following to be created:

* <span id="handle"> [BaseShuffleHandle](BaseShuffleHandle.md)
* <span id="blocksByAddress"> [Block](../storage/BlockId.md)s by [Address](../storage/BlockManagerId.md) (`Iterator[(BlockManagerId, Seq[(BlockId, Long, Int)])]`)
* <span id="context"> [TaskContext](../scheduler/TaskContext.md)
* <span id="readMetrics"> [ShuffleReadMetricsReporter](ShuffleReadMetricsReporter.md)
* <span id="serializerManager"> [SerializerManager](../serializer/SerializerManager.md)
* <span id="blockManager"> [BlockManager](../storage/BlockManager.md)
* <span id="mapOutputTracker"> [MapOutputTracker](../scheduler/MapOutputTracker.md)
* <span id="shouldBatchFetch"> `shouldBatchFetch` flag (default: `false`)

`BlockStoreShuffleReader` is created when:

* `SortShuffleManager` is requested for a [ShuffleReader](SortShuffleManager.md#getReader) (for a `ShuffleHandle` and a range of reduce partitions)

## Reading Combined Records (for Reduce Task) { #read }

??? note "ShuffleReader"

    ```scala
    read(): Iterator[Product2[K, C]]
    ```

    `read` is part of the [ShuffleReader](ShuffleReader.md#read) abstraction.

`read` creates a [ShuffleBlockFetcherIterator](../storage/ShuffleBlockFetcherIterator.md).

`read`...FIXME

### fetchContinuousBlocksInBatch { #fetchContinuousBlocksInBatch }

```scala
fetchContinuousBlocksInBatch: Boolean
```

`fetchContinuousBlocksInBatch` reads the following configuration properties to determine whether continuous shuffle block fetching could be used or not:

* [spark.io.encryption.enabled](../configuration-properties.md#spark.io.encryption.enabled)
* [spark.shuffle.compress](../configuration-properties.md#spark.shuffle.compress)
* [spark.shuffle.useOldFetchProtocol](../configuration-properties.md#spark.shuffle.useOldFetchProtocol)
* [supportsRelocationOfSerializedObjects](../serializer/Serializer.md#supportsRelocationOfSerializedObjects) (of the [Serializer](../rdd/ShuffleDependency.md#serializer) of the [ShuffleDependency](BaseShuffleHandle.md#dependency) of this [BaseShuffleHandle](#handle))

`fetchContinuousBlocksInBatch` prints out the following DEBUG message when continuous shuffle block fetching is requested yet not satisfied by the configuration:

```text
The feature tag of continuous shuffle block fetching is set to true, but
we can not enable the feature because other conditions are not satisfied.
Shuffle compress: [compressed], serializer relocatable: [serializerRelocatable],
codec concatenation: [codecConcatenation], use old shuffle fetch protocol:
[useOldFetchProtocol], io encryption: [ioEncryption].
```

<!---
## Review Me

=== [[read]] Reading Combined Records For Reduce Task

Internally, `read` first storage:ShuffleBlockFetcherIterator.md#creating-instance[creates a `ShuffleBlockFetcherIterator`] (passing in the values of <<spark_reducer_maxSizeInFlight, spark.reducer.maxSizeInFlight>>, <<spark_reducer_maxReqsInFlight, spark.reducer.maxReqsInFlight>> and <<spark_shuffle_detectCorrupt, spark.shuffle.detectCorrupt>> Spark properties).

NOTE: `read` uses scheduler:MapOutputTracker.md#getMapSizesByExecutorId[`MapOutputTracker` to find the BlockManagers with the shuffle blocks and sizes] to create `ShuffleBlockFetcherIterator`.

`read` creates a new serializer:SerializerInstance.md[SerializerInstance] (using [`Serializer` from ShuffleDependency](../rdd/ShuffleDependency.md#serializer)).

`read` creates a key/value iterator by `deserializeStream` every shuffle block stream.

`read` updates the [context task metrics](../scheduler/TaskContext.md#taskMetrics) for each record read.

NOTE: `read` uses `CompletionIterator` (to count the records read) and spark-InterruptibleIterator.md[InterruptibleIterator] (to support task cancellation).

If the [`ShuffleDependency` has an `Aggregator` defined](../rdd/ShuffleDependency.md#aggregator), `read` wraps the current iterator inside an iterator defined by [Aggregator.combineCombinersByKey](../rdd/Aggregator.md#combineCombinersByKey) (for [`mapSideCombine` enabled](../rdd/ShuffleDependency.md#mapSideCombine)) or [Aggregator.combineValuesByKey](../rdd/Aggregator.md#combineValuesByKey) otherwise.

NOTE: `run` reports an exception when [`ShuffleDependency` has no `Aggregator` defined](../rdd/ShuffleDependency.md#aggregator) with [`mapSideCombine` flag enabled](../rdd/ShuffleDependency.md#mapSideCombine).

For [keyOrdering](../rdd/ShuffleDependency.md#keyOrdering) defined in the `ShuffleDependency`, `run` does the following:

1. shuffle:ExternalSorter.md#creating-instance[Creates an `ExternalSorter`]
2. shuffle:ExternalSorter.md#insertAll[Inserts all the records] into the `ExternalSorter`
3. Updates context `TaskMetrics`
4. Returns a `CompletionIterator` for the `ExternalSorter`
-->
