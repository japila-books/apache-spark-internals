# ExternalSorter

`ExternalSorter` is a [Spillable](Spillable.md) of `WritablePartitionedPairCollection` of pairs (of K keys and C values).

`ExternalSorter[K, V, C]` is a parameterized type of `K` keys, `V` values, and `C` combiner (partial) values.

`ExternalSorter` is used for the following:

* [SortShuffleWriter](SortShuffleWriter.md#sorter) to write records
* [BlockStoreShuffleReader](BlockStoreShuffleReader.md) to read records (with a key ordering defined)

## Creating Instance

`ExternalSorter` takes the following to be created:

* <span id="context"> [TaskContext](../scheduler/TaskContext.md)
* <span id="aggregator"> Optional [Aggregator](../rdd/Aggregator.md) (default: undefined)
* <span id="partitioner"> Optional [Partitioner](../rdd/Partitioner) (default: undefined)
* <span id="ordering"> Optional [Ordering] ([Scala]({{ scala.api }}/scala/math/Ordering.html)) for keys (default: undefined)
* <span id="serializer"> [Serializer](../serializer/Serializer.md) (default: [Serializer](../SparkEnv.md#serializer))

`ExternalSorter` is created when:

* `BlockStoreShuffleReader` is requested to [read records](BlockStoreShuffleReader.md#read) (for a reduce task)
* `SortShuffleWriter` is requested to [write records](SortShuffleWriter.md#read) (as a `ExternalSorter[K, V, C]` or `ExternalSorter[K, V, V]` based on [Map-Size Partial Aggregation Flag](../rdd/ShuffleDependency.md#mapSideCombine))

## <span id="insertAll"> Inserting Records

```scala
insertAll(
  records: Iterator[Product2[K, V]]): Unit
```

`insertAll` branches off per whether the optional [Aggregator](#aggregator) was [specified](#insertAll-shouldCombine) or [not](#insertAll-no-aggregator) (when [creating the ExternalSorter](#creating-instance)).

`insertAll` takes all records eagerly and materializes the given records iterator.

### <span id="insertAll-shouldCombine"> Map-Side Aggregator Specified

With an [Aggregator](#aggregator) given, `insertAll` creates an update function based on the [mergeValue](../rdd/Aggregator.md#mergeValue) and [createCombiner](../rdd/Aggregator.md#createCombiner) functions of the `Aggregator`.

For every record, `insertAll` [increment internal read counter](Spillable.md#addElementsRead).

`insertAll` requests the [PartitionedAppendOnlyMap](#map) to `changeValue` for the key (made up of the [partition](#getPartition) of the key of the current record and the key itself, i.e. `(partition, key)`) with the update function.

In the end, `insertAll` [spills the in-memory collection to disk if needed](#maybeSpillCollection) with the `usingMap` flag enabled (to indicate that the [PartitionedAppendOnlyMap](#map) was updated).

### <span id="insertAll-no-aggregator"> No Map-Side Aggregator Specified

With no [Aggregator](#aggregator) given, `insertAll` iterates over all the records and uses the [PartitionedPairBuffer](#buffer) instead.

For every record, `insertAll` [increment internal read counter](Spillable.md#addElementsRead).

`insertAll` requests the [PartitionedPairBuffer](#buffer) to insert with the [partition](#getPartition) of the key of the current record, the key itself and the value of the current record.

In the end, `insertAll` [spills the in-memory collection to disk if needed](#maybeSpillCollection) with the `usingMap` flag disabled (since this time the [PartitionedPairBuffer](#buffer) was updated, not the [PartitionedAppendOnlyMap](#map)).

### <span id="maybeSpillCollection"> Spilling In-Memory Collection to Disk

```scala
maybeSpillCollection(
  usingMap: Boolean): Unit
```

`maybeSpillCollection` branches per the input `usingMap` flag (to indicate which [in-memory collection](#in-memory-collection) to use, the [PartitionedAppendOnlyMap](#map) or the [PartitionedPairBuffer](#buffer)).

`maybeSpillCollection` requests the collection to estimate size (in bytes) that is tracked as the [peakMemoryUsedBytes](#peakMemoryUsedBytes) metric (for every size bigger than what is currently recorded).

`maybeSpillCollection` [spills the collection to disk if needed](Spillable.md#maybeSpill). If spilled, `maybeSpillCollection` creates a new collection (a new `PartitionedAppendOnlyMap` or a new `PartitionedPairBuffer`).

### <span id="insertAll-usage"> Usage

`insertAll` is used when:

* `SortShuffleWriter` is requested to [write records](SortShuffleWriter.md#write) (as a `ExternalSorter[K, V, C]` or `ExternalSorter[K, V, V]` based on [Map-Size Partial Aggregation Flag](../rdd/ShuffleDependency.md#mapSideCombine))
* `BlockStoreShuffleReader` is requested to [read records](BlockStoreShuffleReader.md#read) (with a key sorting defined)

## <span id="in-memory-collection"><span id="buffer"><span id="map"> In-Memory Collections of Records

`ExternalSorter` uses `PartitionedPairBuffer`s or `PartitionedAppendOnlyMap`s to store records in memory before [spilling to disk](#spill).

`ExternalSorter` uses `PartitionedPairBuffer`s when [created](#creating-instance) with no [Aggregator](#aggregator). Otherwise, `ExternalSorter` uses `PartitionedAppendOnlyMap`s.

`ExternalSorter` inserts records to the collections when [insertAll](#insertAll).

`ExternalSorter` [spills the in-memory collection to disk if needed](#maybeSpillCollection) and, [if so](Spillable.md#maybeSpill), creates a new collection.

`ExternalSorter` releases the collections (`null`s them) when requested to [forceSpill](#forceSpill) and [stop](#stop). That is when the JVM garbage collector takes care of evicting them from memory completely.

## <span id="peakMemoryUsedBytes"><span id="_peakMemoryUsedBytes"> Peak Size of In-Memory Collection

`ExternalSorter` tracks the peak size (in bytes) of the [in-memory collection](#in-memory-collection) whenever requested to [spill the in-memory collection to disk if needed](#maybeSpillCollection).

The peak size is used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](BlockStoreShuffleReader.md#read) (with an ordering defined)
* `ExternalSorter` is requested to [writePartitionedMapOutput](#writePartitionedMapOutput)

## <span id="spills"> Spills

```scala
spills: ArrayBuffer[SpilledFile]
```

`ExternalSorter` creates the `spills` internal buffer of [SpilledFile](#SpilledFile)s when [created](#creating-instance).

A new `SpilledFile` is added when `ExternalSorter` is requested to [spill](#spill).

!!! note
    No elements in `spills` indicate that there is only in-memory data.

`SpilledFile`s are deleted physically from disk and the `spills` buffer is cleared when `ExternalSorter` is requested to [stop](#stop).

`ExternalSorter` uses the `spills` buffer when requested for an [partitionedIterator](#partitionedIterator).

### <span id="numSpills"> Number of Spills

```scala
numSpills: Int
```

`numSpills` is the number of [spill files](#spills) this sorter has [spilled](#spill).

### <span id="SpilledFile"> SpilledFile

`SpilledFile` is a metadata of a spilled file:

* <span id="SpilledFile-file"> `File` ([Java]({{ java.api }}/java.base/java/io/File.html))
* <span id="SpilledFile-blockId"> [BlockId](../storage/BlockId.md)
* <span id="SpilledFile-serializerBatchSizes"> Serializer Batch Sizes (`Array[Long]`)
* <span id="SpilledFile-elementsPerPartition"> Elements per Partition (`Array[Long]`)

## <span id="spill"> Spilling Data to Disk

```scala
spill(
  collection: WritablePartitionedPairCollection[K, C]): Unit
```

`spill` is part of the [Spillable](Spillable.md#spill) abstraction.

`spill` requests the given `WritablePartitionedPairCollection` for a destructive `WritablePartitionedIterator`.

`spill` [spillMemoryIteratorToDisk](#spillMemoryIteratorToDisk) (with the destructive `WritablePartitionedIterator`) that creates a [SpilledFile](#SpilledFile).

In the end, `spill` adds the `SpilledFile` to the [spills](#spills) internal registry.

### <span id="spillMemoryIteratorToDisk"> spillMemoryIteratorToDisk

```scala
spillMemoryIteratorToDisk(
  inMemoryIterator: WritablePartitionedIterator): SpilledFile
```

`spillMemoryIteratorToDisk`...FIXME

`spillMemoryIteratorToDisk` is used when:

* `ExternalSorter` is requested to [spill](#spill)
* `SpillableIterator` is requested to `spill`

## <span id="partitionedIterator"> partitionedIterator

```scala
partitionedIterator: Iterator[(Int, Iterator[Product2[K, C]])]
```

`partitionedIterator`...FIXME

`partitionedIterator` is used when:

* `ExternalSorter` is requested for an [iterator](#iterator) and to [writePartitionedMapOutput](#writePartitionedMapOutput)

## <span id="writePartitionedMapOutput"> writePartitionedMapOutput

```scala
writePartitionedMapOutput(
  shuffleId: Int,
  mapId: Long,
  mapOutputWriter: ShuffleMapOutputWriter): Unit
```

`writePartitionedMapOutput`...FIXME

`writePartitionedMapOutput` is used when:

* `SortShuffleWriter` is requested to [write records](SortShuffleWriter.md#write)

## <span id="iterator"> Iterator

```scala
iterator: Iterator[Product2[K, C]]
```

`iterator` turns the [isShuffleSort](#isShuffleSort) flag off (`false`).

`iterator` [partitionedIterator](#partitionedIterator) and takes the combined values (the second elements) only.

`iterator` is used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](BlockStoreShuffleReader.md#read)

## <span id="stop"> Stopping ExternalSorter

```scala
stop(): Unit
```

`stop`...FIXME

`stop` is used when:

* `BlockStoreShuffleReader` is requested to [read records](BlockStoreShuffleReader.md#read) (with ordering defined)
* `SortShuffleWriter` is requested to [stop](SortShuffleWriter.md#stop)

## Logging

Enable `ALL` logging level for `org.apache.spark.util.collection.ExternalSorter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.util.collection.ExternalSorter=ALL
```

Refer to [Logging](../spark-logging.md).
