# SortShuffleManager

`SortShuffleManager` is the default and only [ShuffleManager](ShuffleManager.md) in Apache Spark (with the short name `sort` or `tungsten-sort`).

![SortShuffleManager and SparkEnv (Driver and Executors)](../images/shuffle/SortShuffleManager.png)

## Creating Instance

`SortShuffleManager` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)

`SortShuffleManager` is created when `SparkEnv` is [created](../SparkEnv.md#ShuffleManager) (on the driver and executors at the very beginning of a Spark application's lifecycle).

## <span id="getWriter"> Getting ShuffleWriter For Partition and ShuffleHandle

```scala
getWriter[K, V](
  handle: ShuffleHandle,
  mapId: Int,
  context: TaskContext): ShuffleWriter[K, V]
```

`getWriter` registers the given [ShuffleHandle](ShuffleHandle.md) (by the [shuffleId](ShuffleHandle.md#shuffleId) and [numMaps](BaseShuffleHandle.md#numMaps)) in the [numMapsForShuffle](#numMapsForShuffle) internal registry unless already done.

!!! note
    `getWriter` expects that the input `ShuffleHandle` is a [BaseShuffleHandle](BaseShuffleHandle.md). Moreover, `getWriter` expects that in two (out of three cases) it is a more specialized [IndexShuffleBlockResolver](IndexShuffleBlockResolver.md).

`getWriter` then creates a new `ShuffleWriter` based on the type of the given `ShuffleHandle`.

ShuffleHandle | ShuffleWriter
--------------|--------------
[SerializedShuffleHandle](SerializedShuffleHandle.md) | [UnsafeShuffleWriter](UnsafeShuffleWriter.md)
[BypassMergeSortShuffleHandle](BypassMergeSortShuffleHandle.md) | [BypassMergeSortShuffleWriter](BypassMergeSortShuffleWriter.md)
[BaseShuffleHandle](BaseShuffleHandle.md) | [SortShuffleWriter](SortShuffleWriter.md)

`getWriter` is part of the [ShuffleManager](ShuffleManager.md#getWriter) abstraction.

== [[MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE]] Maximum Number of Partition Identifiers

SortShuffleManager allows for `(1 << 24)` partition identifiers that can be encoded (i.e. `16777216`).

== [[numMapsForShuffle]] numMapsForShuffle

Lookup table with the number of mappers producing the output for a shuffle (as {java-javadoc-url}/java/util/concurrent/ConcurrentHashMap.html[java.util.concurrent.ConcurrentHashMap])

== [[shuffleBlockResolver]] IndexShuffleBlockResolver

[source, scala]
----
shuffleBlockResolver: ShuffleBlockResolver
----

shuffleBlockResolver is an shuffle:IndexShuffleBlockResolver.md[IndexShuffleBlockResolver] that is created immediately when SortShuffleManager is.

shuffleBlockResolver is used when SortShuffleManager is requested for a <<getWriter, ShuffleWriter for a given partition>>, to <<unregisterShuffle, unregister a shuffle metadata>> and <<stop, stop>>.

shuffleBlockResolver is part of the shuffle:ShuffleManager.md#shuffleBlockResolver[ShuffleManager] abstraction.

== [[unregisterShuffle]] Unregistering Shuffle

[source, scala]
----
unregisterShuffle(
  shuffleId: Int): Boolean
----

unregisterShuffle tries to remove the given `shuffleId` from the <<numMapsForShuffle, numMapsForShuffle>> internal registry.

If the given `shuffleId` was registered, unregisterShuffle requests the <<shuffleBlockResolver, IndexShuffleBlockResolver>> to <<IndexShuffleBlockResolver.md#removeDataByMap, remove the shuffle index and data files>> one by one (up to the number of mappers producing the output for the shuffle).

unregisterShuffle is part of the shuffle:ShuffleManager.md#unregisterShuffle[ShuffleManager] abstraction.

== [[registerShuffle]] Creating ShuffleHandle (For ShuffleDependency)

[source, scala]
----
registerShuffle[K, V, C](
  shuffleId: Int,
  numMaps: Int,
  dependency: ShuffleDependency[K, V, C]): ShuffleHandle
----

CAUTION: FIXME Copy the conditions

`registerShuffle` returns a new `ShuffleHandle` that can be one of the following:

1. shuffle:BypassMergeSortShuffleHandle.md[BypassMergeSortShuffleHandle] (with `ShuffleDependency[K, V, V]`) when shuffle:SortShuffleWriter.md#shouldBypassMergeSort[shouldBypassMergeSort] condition holds.

2. shuffle:SerializedShuffleHandle.md[SerializedShuffleHandle] (with `ShuffleDependency[K, V, V]`) when <<canUseSerializedShuffle, canUseSerializedShuffle condition holds>>.

3. shuffle:spark-shuffle-BaseShuffleHandle.md[BaseShuffleHandle]

registerShuffle is part of the shuffle:ShuffleManager.md#registerShuffle[ShuffleManager] abstraction.

== [[getReader]] Creating BlockStoreShuffleReader For ShuffleHandle And Reduce Partitions

[source, scala]
----
getReader[K, C](
  handle: ShuffleHandle,
  startPartition: Int,
  endPartition: Int,
  context: TaskContext): ShuffleReader[K, C]
----

getReader returns a new shuffle:BlockStoreShuffleReader.md[BlockStoreShuffleReader] passing all the input parameters on to it.

getReader assumes that the input `ShuffleHandle` is of type shuffle:spark-shuffle-BaseShuffleHandle.md[BaseShuffleHandle].

getReader is part of the shuffle:ShuffleManager.md#getReader[ShuffleManager] abstraction.

== [[stop]] Stopping SortShuffleManager

[source, scala]
----
stop(): Unit
----

stop simply requests the <<shuffleBlockResolver, IndexShuffleBlockResolver>> to shuffle:IndexShuffleBlockResolver.md#stop[stop] (which actually does nothing).

stop is part of the shuffle:ShuffleManager.md#stop[ShuffleManager] abstraction.

== [[canUseSerializedShuffle]] Requirements of SerializedShuffleHandle (as ShuffleHandle)

[source, scala]
----
canUseSerializedShuffle(
  dependency: ShuffleDependency[_, _, _]): Boolean
----

canUseSerializedShuffle returns `true` when all of the following hold:

. rdd:ShuffleDependency.md#serializer[Serializer] (of the given rdd:ShuffleDependency.md[ShuffleDependency]) serializer:Serializer.md#supportsRelocationOfSerializedObjects[supports relocation of serialized objects]

. No map-side aggregation (the rdd:ShuffleDependency.md#mapSideCombine[mapSideCombine] flag of the given rdd:ShuffleDependency.md[ShuffleDependency] is off)

. rdd:Partitioner.md#numPartitions[Number of partitions] (of the rdd:ShuffleDependency.md#partitioner[Partitioner] of the given rdd:ShuffleDependency.md[ShuffleDependency]) is not greater than the <<MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE, supported maximum number>> (i.e. `(1 << 24) - 1`, i.e. `16777215`)

canUseSerializedShuffle prints out the following DEBUG message to the logs:

[source,plaintext]
----
Can use serialized shuffle for shuffle [shuffleId]
----

Otherwise, canUseSerializedShuffle does not hold and prints out one of the following DEBUG messages:

[source,plaintext]
----
Can't use serialized shuffle for shuffle [id] because the serializer, [name], does not support object relocation

Can't use serialized shuffle for shuffle [id] because an aggregator is defined

Can't use serialized shuffle for shuffle [id] because it has more than [number] partitions
----

shouldBypassMergeSort is used when SortShuffleManager is requested to shuffle:SortShuffleManager.md#registerShuffle[register a shuffle (and creates a ShuffleHandle)].

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.shuffle.sort.SortShuffleManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.shuffle.sort.SortShuffleManager=ALL
----

Refer to ROOT:spark-logging.md[Logging].
