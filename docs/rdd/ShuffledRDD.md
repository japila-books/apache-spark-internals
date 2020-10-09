= [[ShuffledRDD]] ShuffledRDD

*ShuffledRDD* is an RDD.md[RDD] of key-value pairs that represents a *shuffle step* in a spark-rdd-lineage.md[RDD lineage].

ShuffledRDD is given an <<prev, RDD>> of key-value pairs of K and V types, respectively, when <<creating-instance, created>> and <<compute, computes>> key-value pairs of K and C types, respectively.

ShuffledRDD is <<creating-instance, created>> for the following RDD transformations:

* spark-rdd-OrderedRDDFunctions.md#sortByKey[OrderedRDDFunctions.sortByKey] and spark-rdd-OrderedRDDFunctions.md#repartitionAndSortWithinPartitions[OrderedRDDFunctions.repartitionAndSortWithinPartitions]

* PairRDDFunctions.md#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] and PairRDDFunctions.md#partitionBy[PairRDDFunctions.partitionBy]

* spark-rdd-transformations.md#coalesce[RDD.coalesce] (with `shuffle` flag enabled)

ShuffledRDD uses custom <<ShuffledRDDPartition, ShuffledRDDPartition>> partitions.

[[isBarrier]]
ShuffledRDD has RDD.md#isBarrier[isBarrier] flag always disabled (`false`).

== [[creating-instance]] Creating Instance

ShuffledRDD takes the following to be created:

* [[prev]] Previous RDD.md[RDD] of key-value pairs (`RDD[_ <: Product2[K, V]]`)
* [[part]] Partitioner.md[Partitioner]

== [[mapSideCombine]][[setMapSideCombine]] Map-Side Combine Flag

ShuffledRDD uses a *map-side combine* flag to create a [ShuffleDependency](ShuffleDependency.md) when requested for the <<getDependencies, dependencies>> (there is always only one).

The flag is disabled (`false`) by default and can be changed using setMapSideCombine method.

[source,scala]
----
setMapSideCombine(
  mapSideCombine: Boolean): ShuffledRDD[K, V, C]
----

setMapSideCombine is used for PairRDDFunctions.md#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] transformation (which defaults to the flag enabled).

== [[compute]] Computing Partition

[source, scala]
----
compute(
  split: Partition,
  context: TaskContext): Iterator[(K, C)]
----

compute requests the only RDD.md#dependencies[dependency] (that is assumed a [ShuffleDependency](ShuffleDependency.md)) for the [ShuffleHandle](ShuffleDependency.md#shuffleHandle).

compute uses the [SparkEnv](../SparkEnv.md) to access the [ShuffleManager](../SparkEnv.md#shuffleManager).

compute requests the shuffle:ShuffleManager.md#shuffleManager[ShuffleManager] for the shuffle:ShuffleManager.md#getReader[ShuffleReader] (for the ShuffleHandle, the spark-rdd-Partition.md[partition]).

In the end, compute requests the ShuffleReader to shuffle:spark-shuffle-ShuffleReader.md#read[read] the combined key-value pairs (of type `(K, C)`).

compute is part of the RDD.md#compute[RDD] abstraction.

== [[getPreferredLocations]] Placement Preferences of Partition

[source, scala]
----
getPreferredLocations(
  partition: Partition): Seq[String]
----

getPreferredLocations requests `MapOutputTrackerMaster` for the scheduler:MapOutputTrackerMaster.md#getPreferredLocationsForShuffle[preferred locations] of the given spark-rdd-Partition.md[partition] (storage:BlockManager.md[BlockManagers] with the most map outputs).

getPreferredLocations uses SparkEnv to access the current core:SparkEnv.md#mapOutputTracker[MapOutputTrackerMaster].

getPreferredLocations is part of the RDD.md#compute[RDD] abstraction.

== [[getDependencies]] Dependencies

[source, scala]
----
getDependencies: Seq[Dependency[_]]
----

getDependencies uses the <<userSpecifiedSerializer, user-specified Serializer>> if defined or requests the current serializer:SerializerManager.md[SerializerManager] for serializer:SerializerManager.md#getSerializer[one].

getDependencies uses the <<mapSideCombine, mapSideCombine>> internal flag for the types of the keys and values (i.e. `K` and `C` or `K` and `V` when the flag is enabled or not, respectively).

In the end, getDependencies returns a single [ShuffleDependency](ShuffleDependency.md) (with the <<prev, previous RDD>>, the <<part, Partitioner>>, and the Serializer).

getDependencies is part of the RDD.md#getDependencies[RDD] abstraction.

== [[ShuffledRDDPartition]] ShuffledRDDPartition

ShuffledRDDPartition gets an `index` to be created (that in turn is the index of partitions as calculated by the Partitioner.md[Partitioner] of a <<ShuffledRDD, ShuffledRDD>>).

== Demos

=== Demo: ShuffledRDD and coalesce

[source,plaintext]
----
val data = sc.parallelize(0 to 9)
val coalesced = data.coalesce(numPartitions = 4, shuffle = true)
scala> println(coalesced.toDebugString)
(4) MapPartitionsRDD[9] at coalesce at <pastie>:75 []
 |  CoalescedRDD[8] at coalesce at <pastie>:75 []
 |  ShuffledRDD[7] at coalesce at <pastie>:75 []
 +-(16) MapPartitionsRDD[6] at coalesce at <pastie>:75 []
    |   ParallelCollectionRDD[5] at parallelize at <pastie>:74 []
----

=== Demo: ShuffledRDD and sortByKey

[source,plaintext]
----
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
----

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| userSpecifiedSerializer
a| [[userSpecifiedSerializer]] User-specified [Serializer](../serializer/Serializer.md) for the single [ShuffleDependency](ShuffleDependency.md) dependency

[source, scala]
----
userSpecifiedSerializer: Option[Serializer] = None
----

`userSpecifiedSerializer` is undefined (`None`) by default and can be changed using `setSerializer` method (that is used for PairRDDFunctions.md#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] transformation).

|===
