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

## <span id="shuffleExecutorComponents"> ShuffleExecutorComponents

```scala
shuffleExecutorComponents: ShuffleExecutorComponents
```

`SortShuffleManager` defines the `shuffleExecutorComponents` internal registry for a [ShuffleExecutorComponents](ShuffleExecutorComponents.md).

`shuffleExecutorComponents` is used when:

* `SortShuffleManager` is requested for the [ShuffleWriter](#getWriter)

### <span id="loadShuffleExecutorComponents"> loadShuffleExecutorComponents

```scala
loadShuffleExecutorComponents(
  conf: SparkConf): ShuffleExecutorComponents
```

`loadShuffleExecutorComponents` [loads the ShuffleDataIO](ShuffleDataIOUtils.md#loadShuffleDataIO) that is then requested for the [ShuffleExecutorComponents](ShuffleDataIO.md#executor).

`loadShuffleExecutorComponents` requests the `ShuffleExecutorComponents` to [initialize](ShuffleExecutorComponents.md#initializeExecutor) before returning it.

## <span id="registerShuffle"> Creating ShuffleHandle for ShuffleDependency

```scala
registerShuffle[K, V, C](
  shuffleId: Int,
  dependency: ShuffleDependency[K, V, C]): ShuffleHandle
```

`registerShuffle` is part of the [ShuffleManager](ShuffleManager.md#registerShuffle) abstraction.

`registerShuffle` creates a new [ShuffleHandle](ShuffleHandle.md) (for the given [ShuffleDependency](../rdd/ShuffleDependency.md)) that is one of the following:

1. [BypassMergeSortShuffleHandle](BypassMergeSortShuffleHandle.md) (with `ShuffleDependency[K, V, V]`) when [shouldBypassMergeSort](SortShuffleWriter.md#shouldBypassMergeSort) condition holds

2. [SerializedShuffleHandle](SerializedShuffleHandle.md) (with `ShuffleDependency[K, V, V]`) when [canUseSerializedShuffle](#canUseSerializedShuffle) condition holds

3. [BaseShuffleHandle](BaseShuffleHandle.md)

### <span id="canUseSerializedShuffle"> SerializedShuffleHandle Requirements

```scala
canUseSerializedShuffle(
  dependency: ShuffleDependency[_, _, _]): Boolean
```

`canUseSerializedShuffle` is `true` when all of the following hold for the given [ShuffleDependency](../rdd/ShuffleDependency.md):

1. [Serializer](../rdd/ShuffleDependency.md#serializer) (of the given `ShuffleDependency`) [supports relocation of serialized objects](../serializer/Serializer.md#supportsRelocationOfSerializedObjects)

1. [mapSideCombine](../rdd/ShuffleDependency.md#mapSideCombine) flag (of the given `ShuffleDependency`) is `false`

1. [Number of partitions](../rdd/Partitioner.md#numPartitions) (of the [Partitioner](../rdd/ShuffleDependency.md#partitioner) of the given `ShuffleDependency`) is not greater than the [supported maximum number](#MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE)

With all of the above positive, `canUseSerializedShuffle` prints out the following DEBUG message to the logs:

```text
Can use serialized shuffle for shuffle [shuffleId]
```

Otherwise, `canUseSerializedShuffle` is `false` and prints out one of the following DEBUG messages based on the failed requirement:

```text
Can't use serialized shuffle for shuffle [id] because the serializer, [name], does not support object relocation
```

```text
Can't use serialized shuffle for shuffle [id] because we need to do map-side aggregation
```

```text
Can't use serialized shuffle for shuffle [id] because it has more than [number] partitions
```

`canUseSerializedShuffle` is used when:

* `SortShuffleManager` is requested to [register a shuffle (and creates a ShuffleHandle)](#registerShuffle)

## Logging

Enable `ALL` logging level for `org.apache.spark.shuffle.sort.SortShuffleManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.shuffle.sort.SortShuffleManager=ALL
```

Refer to [Logging](../spark-logging.md).

## Review Me

== [[MAX_SHUFFLE_OUTPUT_PARTITIONS_FOR_SERIALIZED_MODE]] Maximum Number of Partition Identifiers

SortShuffleManager allows for `(1 << 24)` partition identifiers that can be encoded (i.e. `16777216`).

== [[numMapsForShuffle]] numMapsForShuffle

Lookup table with the number of mappers producing the output for a shuffle (as {java-javadoc-url}/java/util/concurrent/ConcurrentHashMap.html[java.util.concurrent.ConcurrentHashMap])

== [[shuffleBlockResolver]] IndexShuffleBlockResolver

[source, scala]
----
shuffleBlockResolver: ShuffleBlockResolver
----

shuffleBlockResolver is an IndexShuffleBlockResolver.md[IndexShuffleBlockResolver] that is created immediately when SortShuffleManager is.

shuffleBlockResolver is used when SortShuffleManager is requested for a <<getWriter, ShuffleWriter for a given partition>>, to <<unregisterShuffle, unregister a shuffle metadata>> and <<stop, stop>>.

shuffleBlockResolver is part of the ShuffleManager.md#shuffleBlockResolver[ShuffleManager] abstraction.

== [[unregisterShuffle]] Unregistering Shuffle

[source, scala]
----
unregisterShuffle(
  shuffleId: Int): Boolean
----

unregisterShuffle tries to remove the given `shuffleId` from the <<numMapsForShuffle, numMapsForShuffle>> internal registry.

If the given `shuffleId` was registered, unregisterShuffle requests the <<shuffleBlockResolver, IndexShuffleBlockResolver>> to <<IndexShuffleBlockResolver.md#removeDataByMap, remove the shuffle index and data files>> one by one (up to the number of mappers producing the output for the shuffle).

unregisterShuffle is part of the ShuffleManager.md#unregisterShuffle[ShuffleManager] abstraction.

== [[getReader]] Creating BlockStoreShuffleReader For ShuffleHandle And Reduce Partitions

[source, scala]
----
getReader[K, C](
  handle: ShuffleHandle,
  startPartition: Int,
  endPartition: Int,
  context: TaskContext): ShuffleReader[K, C]
----

getReader returns a new BlockStoreShuffleReader.md[BlockStoreShuffleReader] passing all the input parameters on to it.

getReader assumes that the input `ShuffleHandle` is of type BaseShuffleHandle.md[BaseShuffleHandle].

getReader is part of the ShuffleManager.md#getReader[ShuffleManager] abstraction.

== [[stop]] Stopping SortShuffleManager

[source, scala]
----
stop(): Unit
----

stop simply requests the <<shuffleBlockResolver, IndexShuffleBlockResolver>> to IndexShuffleBlockResolver.md#stop[stop] (which actually does nothing).

stop is part of the ShuffleManager.md#stop[ShuffleManager] abstraction.
