---
tags:
  - DeveloperApi
---

# ShuffledRDD

`ShuffledRDD` is an [RDD](RDD.md) of key-value pairs that represents a **shuffle step** in a [RDD lineage](lineage.md) (and indicates start of a new stage).

When requested to [compute a partition](#compute), `ShuffledRDD` uses the one and only [ShuffleDependency](#getDependencies) for a [ShuffleHandle](ShuffleDependency.md#shuffleHandle) for a [ShuffleReader](../shuffle/ShuffleManager.md#getReader) (from the system [ShuffleManager](../shuffle/ShuffleManager.md)) that is used to [read](../shuffle/ShuffleReader.md#read) the (combined) key-value pairs.

## Creating Instance

`ShuffledRDD` takes the following to be created:

* <span id="prev"> [RDD](RDD.md) (of `K` keys and `V` values)
* [Partitioner](#part)

`ShuffledRDD` is created for the following RDD operators:

* [OrderedRDDFunctions.sortByKey](OrderedRDDFunctions.md#sortByKey) and [OrderedRDDFunctions.repartitionAndSortWithinPartitions](OrderedRDDFunctions.md#repartitionAndSortWithinPartitions)

* [PairRDDFunctions.combineByKeyWithClassTag](PairRDDFunctions.md#combineByKeyWithClassTag) and [PairRDDFunctions.partitionBy](PairRDDFunctions.md#partitionBy)

* [RDD.coalesce](spark-rdd-transformations.md#coalesce) (with `shuffle` flag enabled)

### <span id="part"> Partitioner

`ShuffledRDD` is given a [Partitioner](Partitioner.md) when [created](#creating-instance):

* [RangePartitioner](RangePartitioner.md) for [sortByKey](OrderedRDDFunctions.md#sortByKey)
* [HashPartitioner](HashPartitioner.md) for [coalesce](RDD.md#coalesce)
* Whatever passed in to the following high-level RDD operators when different from the current `Partitioner` (of the RDD):
    * [repartitionAndSortWithinPartitions](OrderedRDDFunctions.md#repartitionAndSortWithinPartitions)
    * [combineByKeyWithClassTag](PairRDDFunctions.md#combineByKeyWithClassTag)
    * [partitionBy](PairRDDFunctions.md#partitionBy)

The given `Partitioner` is the [partitioner](#partitioner) of this `ShuffledRDD`.

The `Partitioner` is also used when:

* [getDependencies](#getDependencies) (to create the only [ShuffleDependency](ShuffleDependency.md#partitioner))
* [getPartitions](#getPartitions) (to create as many `ShuffledRDDPartition`s as the [numPartitions](Partitioner.md#numPartitions) of the `Partitioner`)

## <span id="getDependencies"> Dependencies

??? note "Signature"

    ```scala
    getDependencies: Seq[Dependency[_]]
    ```

    `getDependencies` is part of the [RDD](RDD.md#getDependencies) abstraction.

`getDependencies` uses the [user-specified Serializer](#userSpecifiedSerializer), if defined, or requests the current [SerializerManager](../serializer/SerializerManager.md) for [one](../serializer/SerializerManager.md#getSerializer).

`getDependencies` uses the [mapSideCombine](#mapSideCombine) internal flag for the types of the keys and values (i.e. `K` and `C` or `K` and `V` when the flag is enabled or not, respectively).

In the end, `getDependencies` creates a single [ShuffleDependency](ShuffleDependency.md) (with the [previous RDD](#prev), the [Partitioner](#part), and the `Serializer`).

## <span id="compute"> Computing Partition

??? note "Signature"

    ```scala
    compute(
      split: Partition,
      context: TaskContext): Iterator[(K, C)]
    ```

    `compute` is part of the [RDD](RDD.md#compute) abstraction.

`compute` assumes that [ShuffleDependency](ShuffleDependency.md) is the first dependency among the [dependencies](RDD.md#dependencies) (and the only one per [getDependencies](#getDependencies)).

`compute` uses the [SparkEnv](../SparkEnv.md) to access the [ShuffleManager](../SparkEnv.md#shuffleManager). `compute` requests the [ShuffleManager](../shuffle/ShuffleManager.md) for the [ShuffleReader](../shuffle/ShuffleManager.md#getReader) based on the following:

ShuffleReader | Value
--------------|------
 [ShuffleHandle](../shuffle/ShuffleHandle.md) | [ShuffleHandle](ShuffleDependency.md#shuffleHandle) of the `ShuffleDependency`
 `startPartition` | The [index](Partition.md#index) of the given `split` partition
 `endPartition` | `index + 1`

In the end, `compute` requests the `ShuffleReader` to [read](../shuffle/ShuffleReader.md#read) the (combined) key-value pairs (of type `(K, C)`).

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

## <span id="getPreferredLocations"> Placement Preferences of Partition

??? note "Signature"

    ```scala
    getPreferredLocations(
      partition: Partition): Seq[String]
    ```

    `getPreferredLocations` is part of the [RDD](RDD.md#compute) abstraction.

`getPreferredLocations` requests `MapOutputTrackerMaster` for the [preferred locations](../scheduler/MapOutputTrackerMaster.md#getPreferredLocationsForShuffle) of the given [partition](Partition.md) ([BlockManagers](../storage/BlockManager.md) with the most map outputs).

`getPreferredLocations` uses `SparkEnv` to access the current [MapOutputTrackerMaster](../SparkEnv.md#mapOutputTracker).

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
