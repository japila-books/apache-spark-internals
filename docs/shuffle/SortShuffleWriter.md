# SortShuffleWriter &mdash; Fallback ShuffleWriter

`SortShuffleWriter` is a "fallback" [ShuffleWriter](ShuffleWriter.md) (when `SortShuffleManager` is requested for a [ShuffleWriter](SortShuffleManager.md#getWriter) and the more specialized [BypassMergeSortShuffleWriter](BypassMergeSortShuffleWriter.md) and [UnsafeShuffleWriter](UnsafeShuffleWriter.md) could not be used).

`SortShuffleWriter[K, V, C]` is a parameterized type with `K` keys, `V` values, and `C` combiner values.

## Creating Instance

`SortShuffleWriter` takes the following to be created:

* <span id="shuffleBlockResolver"> [IndexShuffleBlockResolver](IndexShuffleBlockResolver.md) (unused)
* <span id="handle"> [BaseShuffleHandle](BaseShuffleHandle.md)
* <span id="mapId"> Map ID
* <span id="context"> [TaskContext](../scheduler/TaskContext.md)
* <span id="shuffleExecutorComponents"> [ShuffleExecutorComponents](ShuffleExecutorComponents.md)

`SortShuffleWriter` is created when:

* `SortShuffleManager` is requested for a [ShuffleWriter](SortShuffleManager.md#getWriter) (for a given [ShuffleHandle](ShuffleHandle.md))

## <span id="mapStatus"> MapStatus

`SortShuffleWriter` uses `mapStatus` internal registry for a [MapStatus](../scheduler/MapStatus.md) after [writing records](#write).

[Writing records](#write) itself does not return a value and `SortShuffleWriter` uses the registry when requested to [stop](#stop) (which allows returning a `MapStatus`).

## <span id="write"> Writing Records (Into Shuffle Partitioned File In Disk Store)

```scala
write(
  records: Iterator[Product2[K, V]]): Unit
```

`write` is part of the [ShuffleWriter](ShuffleWriter.md#write) abstraction.

`write` creates an [ExternalSorter](ExternalSorter.md) based on the [ShuffleDependency](BaseShuffleHandle.md#dependency) (of the [BaseShuffleHandle](#handle)), namely the [Map-Size Partial Aggregation](../rdd/ShuffleDependency.md#mapSideCombine) flag. The `ExternalSorter` uses the aggregator and key ordering when the flag is enabled.

`write` requests the `ExternalSorter` to [insert all the given records](ExternalSorter.md#insertAll).

`write`...FIXME

## <span id="stop"> Stopping SortShuffleWriter (and Calculating MapStatus)

```scala
stop(
  success: Boolean): Option[MapStatus]
```

`stop` is part of the [ShuffleWriter](ShuffleWriter.md#stop) abstraction.

`stop` turns the [stopping](#stopping) flag on and returns the internal [mapStatus](#mapStatus) if the input `success` is enabled.

Otherwise, when [stopping](#stopping) flag is already enabled or the input `success` is disabled, `stop` returns no `MapStatus` (i.e. `None`).

In the end, `stop` requests the `ExternalSorter` to [stop](ExternalSorter.md#stop) and increments the shuffle write time task metrics.

## <span id="shouldBypassMergeSort"> Requirements of BypassMergeSortShuffleHandle (as ShuffleHandle)

```scala
shouldBypassMergeSort(
  conf: SparkConf,
  dep: ShuffleDependency[_, _, _]): Boolean
```

`shouldBypassMergeSort` returns `true` when all of the following hold:

1. No map-side aggregation (the [mapSideCombine](../rdd/ShuffleDependency.md#mapSideCombine) flag of the given [ShuffleDependency](../rdd/ShuffleDependency.md) is off)

1. [Number of partitions](../rdd/Partitioner.md#numPartitions) (of the [Partitioner](../rdd/ShuffleDependency.md#partitioner) of the given [ShuffleDependency](../rdd/ShuffleDependency.md)) is not greater than [spark.shuffle.sort.bypassMergeThreshold](../configuration-properties.md#spark.shuffle.sort.bypassMergeThreshold) configuration property

Otherwise, `shouldBypassMergeSort` does not hold (`false`).

`shouldBypassMergeSort` is used when:

* `SortShuffleManager` is requested to [register a shuffle (and creates a ShuffleHandle)](SortShuffleManager.md#registerShuffle)

## <span id="stopping"> stopping Flag

`SortShuffleWriter` uses `stopping` internal flag to indicate whether or not this `SortShuffleWriter` has been [stopped](#stop).

## Logging

Enable `ALL` logging level for `org.apache.spark.shuffle.sort.SortShuffleWriter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.shuffle.sort.SortShuffleWriter=ALL
```

Refer to [Logging](../spark-logging.md).
