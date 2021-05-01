# ShuffleDependency

`ShuffleDependency` is a [Dependency](Dependency.md) on the output of a [ShuffleMapStage](../scheduler/ShuffleMapStage.md) of a [key-value RDD](#rdd).

`ShuffleDependency` uses the [RDD](#rdd) to know the number of (map-side/pre-shuffle) partitions and the [Partitioner](#partitioner) for the number of (reduce-size/post-shuffle) partitions.

```scala
ShuffleDependency[K: ClassTag, V: ClassTag, C: ClassTag]
```

## Creating Instance

`ShuffleDependency` takes the following to be created:

* <span id="_rdd"> [RDD](RDD.md) of key-value pairs (`RDD[_ <: Product2[K, V]]`)
* [Partitioner](#partitioner)
* <span id="serializer"> [Serializer](../serializer/Serializer.md) (default: [SparkEnv.get.serializer](../SparkEnv.md#serializer))
* <span id="keyOrdering"> Optional Key Ordering (default: undefined)
* Optional [Aggregator](#aggregator)
* [mapSideCombine](#mapSideCombine)
* <span id="shuffleWriterProcessor"> [ShuffleWriteProcessor](../shuffle/ShuffleWriteProcessor.md)

`ShuffleDependency` is created when:

* `CoGroupedRDD` is requested for the [dependencies](CoGroupedRDD.md#getDependencies) (for RDDs with different partitioners)
* `ShuffledRDD` is requested for the [dependencies](ShuffledRDD.md#getDependencies)
* `SubtractedRDD` is requested for the [dependencies](SubtractedRDD.md#getDependencies) (for an RDD with different partitioner)
* `ShuffleExchangeExec` ([Spark SQL]({{ book.spark_sql }}/physical-operators/ShuffleExchangeExec)) physical operator is requested to prepare a `ShuffleDependency`

When created, `ShuffleDependency` gets the [shuffle id](../SparkContext.md#nextShuffleId).

`ShuffleDependency` [registers itself with the ShuffleManager](../shuffle/ShuffleManager.md#registerShuffle) and gets a `ShuffleHandle` (available as [shuffleHandle](#shuffleHandle)). `ShuffleDependency` uses [SparkEnv](../SparkEnv.md#shuffleManager) to access the [ShuffleManager](../shuffle/ShuffleManager.md).

In the end, `ShuffleDependency` registers itself with the [ContextCleaner](../core/ContextCleaner.md#registerShuffleForCleanup) (if configured) and the [ShuffleDriverComponents](../shuffle/ShuffleDriverComponents.md#registerShuffle).

## <span id="aggregator"> Aggregator

```scala
aggregator: Option[Aggregator[K, V, C]]
```

`ShuffleDependency` may be given a [map/reduce-side Aggregator](Aggregator.md) when [created](#creating-instance).

`ShuffleDependency` asserts (when [created](#creating-instance)) that an `Aggregator` is defined when the [mapSideCombine](#mapSideCombine) flag is enabled.

`aggregator` is used when:

* `SortShuffleWriter` is requested to [write records](../shuffle/SortShuffleWriter.md#write) (for mapper tasks)
* `BlockStoreShuffleReader` is requested to [read records](../shuffle/BlockStoreShuffleReader.md#read) (for reducer tasks)

## <span id="shuffleId"> Shuffle ID

```scala
shuffleId: Int
```

`ShuffleDependency` is identified uniquely by an application-wide **shuffle ID** (that is requested from [SparkContext](../SparkContext.md#newShuffleId) when [created](#creating-instance)).

## <span id="partitioner"> Partitioner

`ShuffleDependency` is given a [Partitioner](Partitioner.md) (when [created](#creating-instance)).

`ShuffleDependency` uses the `Partitioner` to partition the shuffle output.

The `Partitioner` is used when:

* `SortShuffleWriter` is requested to [write records](../shuffle/SortShuffleWriter.md#write) (and create an [ExternalSorter](../shuffle/ExternalSorter.md))
* _others_ (FIXME)

## <span id="shuffleHandle"> ShuffleHandle

`ShuffleDependency` [registers itself](../shuffle/ShuffleManager.md#registerShuffle) with the [ShuffleManager](../shuffle/ShuffleManager.md) when [created](#creating-instance).

The `ShuffleHandle` is used when:

* [CoGroupedRDDs](CoGroupedRDD.md#compute), [ShuffledRDD](ShuffledRDD.md#compute), [SubtractedRDD](SubtractedRDD.md#compute), and `ShuffledRowRDD` ([Spark SQL]({{ book.spark_sql }}/ShuffledRowRDD)) are requested to compute a partition (to get a [ShuffleReader](../shuffle/ShuffleReader.md) for a `ShuffleDependency`)
* `ShuffleMapTask` is requested to [run](../scheduler/ShuffleMapTask.md#runTask) (to get a `ShuffleWriter` for a ShuffleDependency).

## <span id="mapSideCombine"> Map-Size Partial Aggregation Flag

`ShuffleDependency` uses a `mapSideCombine` flag that controls whether to perform **map-side partial aggregation** (_map-side combine_) using the [Aggregator](#aggregator).

`mapSideCombine` is disabled (`false`) by default and can be enabled (`true`) for some uses of [ShuffledRDD](ShuffledRDD.md#mapSideCombine).

`ShuffleDependency` requires that the optional [Aggregator](#aggregator) is actually defined for the flag enabled.

`mapSideCombine` is used when:

* `BlockStoreShuffleReader` is requested to [read combined records for a reduce task](../shuffle/BlockStoreShuffleReader.md#read)
* `SortShuffleManager` is requested to [register a shuffle](../shuffle/SortShuffleManager.md#registerShuffle)
* `SortShuffleWriter` is requested to [write records](../shuffle/SortShuffleWriter.md#write)
