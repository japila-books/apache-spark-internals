# ShuffledRDD

`ShuffledRDD` is an [RDD](RDD.md) of key-value pairs that represents a **shuffle step** in a [RDD lineage](spark-rdd-lineage.md).

## Creating Instance

`ShuffledRDD` takes the following to be created:

* <span id="prev"> [RDD](RDD.md) (of `K` keys and `V` values)
* <span id="part"> [Partitioner](Partitioner.md)

`ShuffledRDD` is created for the following RDD operators:

* [OrderedRDDFunctions.sortByKey](OrderedRDDFunctions.md#sortByKey) and [OrderedRDDFunctions.repartitionAndSortWithinPartitions](OrderedRDDFunctions.md#repartitionAndSortWithinPartitions)

* [PairRDDFunctions.combineByKeyWithClassTag](PairRDDFunctions.md#combineByKeyWithClassTag) and [PairRDDFunctions.partitionBy](PairRDDFunctions.md#partitionBy)

* [RDD.coalesce](spark-rdd-transformations.md#coalesce) (with `shuffle` flag enabled)

## Key, Value and Combiner Types

```scala
class ShuffledRDD[K: ClassTag, V: ClassTag, C: ClassTag]
```

`ShuffledRDD` is given an [RDD](#prev) of `K` keys and `V` values to be [created](#creating-instance).

When [computed](#compute), `ShuffledRDD` produces pairs of `K` keys and `C` values.

## <span id="isBarrier"> isBarrier Flag

`ShuffledRDD` has [isBarrier](RDD.md#isBarrier) flag always disabled (`false`).

## <span id="mapSideCombine"><span id="setMapSideCombine"> Map-Side Combine Flag

`ShuffledRDD` uses a **map-side combine** flag to create a [ShuffleDependency](ShuffleDependency.md) when requested for the [dependencies](#getDependencies) (there is always only one).

The flag is disabled (`false`) by default and can be changed using `setMapSideCombine` method.

```scala
setMapSideCombine(
  mapSideCombine: Boolean): ShuffledRDD[K, V, C]
```

`setMapSideCombine` is used for [PairRDDFunctions.combineByKeyWithClassTag](PairRDDFunctions.md#combineByKeyWithClassTag) transformation (which defaults to the flag enabled).

## <span id="compute"> Computing Partition

```scala
compute(
  split: Partition,
  context: TaskContext): Iterator[(K, C)]
```

`compute` requests the only [dependency](RDD.md#dependencies) (that is assumed a [ShuffleDependency](ShuffleDependency.md)) for the [ShuffleHandle](ShuffleDependency.md#shuffleHandle).

`compute` uses the [SparkEnv](../SparkEnv.md) to access the [ShuffleManager](../SparkEnv.md#shuffleManager).

`compute` requests the [ShuffleManager](../shuffle/ShuffleManager.md#shuffleManager) for the [ShuffleReader](../shuffle/ShuffleManager.md#getReader) (for the `ShuffleHandle` and the [partition](Partition.md)).

In the end, `compute` requests the `ShuffleReader` to [read](../shuffle/ShuffleReader.md#read) the combined key-value pairs (of type `(K, C)`).

`compute` is part of the [RDD](RDD.md#compute) abstraction.

## <span id="getPreferredLocations"> Placement Preferences of Partition

```scala
getPreferredLocations(
  partition: Partition): Seq[String]
```

`getPreferredLocations` requests `MapOutputTrackerMaster` for the [preferred locations](../scheduler/MapOutputTrackerMaster.md#getPreferredLocationsForShuffle) of the given [partition](Partition.md) ([BlockManagers](../storage/BlockManager.md) with the most map outputs).

`getPreferredLocations` uses `SparkEnv` to access the current [MapOutputTrackerMaster](../SparkEnv.md#mapOutputTracker).

`getPreferredLocations` is part of the [RDD](RDD.md#compute) abstraction.

## <span id="getDependencies"> Dependencies

```scala
getDependencies: Seq[Dependency[_]]
```

`getDependencies` uses the [user-specified Serializer](#userSpecifiedSerializer) if defined or requests the current [SerializerManager](../serializer/SerializerManager.md) for [one](../serializer/SerializerManager.md#getSerializer).

`getDependencies` uses the [mapSideCombine](#mapSideCombine) internal flag for the types of the keys and values (i.e. `K` and `C` or `K` and `V` when the flag is enabled or not, respectively).

In the end, `getDependencies` returns a single [ShuffleDependency](ShuffleDependency.md) (with the [previous RDD](#prev), the [Partitioner](#part), and the `Serializer`).

`getDependencies` is part of the [RDD](RDD.md#getDependencies) abstraction.

## <span id="ShuffledRDDPartition"> ShuffledRDDPartition

`ShuffledRDDPartition` gets an `index` to be created (that in turn is the index of partitions as calculated by the [Partitioner](#part)).

## <span id="userSpecifiedSerializer"> User-Specified Serializer

User-specified [Serializer](../serializer/Serializer.md) for the single [ShuffleDependency](ShuffleDependency.md) dependency

```scala
userSpecifiedSerializer: Option[Serializer] = None
```

`userSpecifiedSerializer` is undefined (`None`) by default and can be changed using `setSerializer` method (that is used for [PairRDDFunctions.combineByKeyWithClassTag](PairRDDFunctions.md#combineByKeyWithClassTag) transformation).

## Demos

### ShuffledRDD and coalesce

```text
val data = sc.parallelize(0 to 9)
val coalesced = data.coalesce(numPartitions = 4, shuffle = true)
scala> println(coalesced.toDebugString)
(4) MapPartitionsRDD[9] at coalesce at <pastie>:75 []
 |  CoalescedRDD[8] at coalesce at <pastie>:75 []
 |  ShuffledRDD[7] at coalesce at <pastie>:75 []
 +-(16) MapPartitionsRDD[6] at coalesce at <pastie>:75 []
    |   ParallelCollectionRDD[5] at parallelize at <pastie>:74 []
```

### ShuffledRDD and sortByKey

```text
val data = sc.parallelize(0 to 9)
val grouped = rdd.groupBy(_ % 2)
val sorted = grouped.sortByKey(numPartitions = 2)
scala> println(sorted.toDebugString)
(2) ShuffledRDD[15] at sortByKey at <console>:74 []
 +-(4) ShuffledRDD[12] at groupBy at <console>:74 []
    +-(4) MapPartitionsRDD[11] at groupBy at <console>:74 []
       |  MapPartitionsRDD[9] at coalesce at <pastie>:75 []
       |  CoalescedRDD[8] at coalesce at <pastie>:75 []
       |  ShuffledRDD[7] at coalesce at <pastie>:75 []
       +-(16) MapPartitionsRDD[6] at coalesce at <pastie>:75 []
          |   ParallelCollectionRDD[5] at parallelize at <pastie>:74 []
```
