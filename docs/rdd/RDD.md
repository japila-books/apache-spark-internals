---
title: RDD
subtitle: Resilient Distributed Dataset
---

# RDD &mdash; Description of Distributed Computation

`RDD[T]` is an [abstraction](#contract) of [fault-tolerant resilient distributed datasets](#implementations) that are mere descriptions of computations over a distributed collection of records (of type `T`).

## Contract

### Computing Partition { #compute }

```scala
compute(
  split: Partition,
  context: TaskContext): Iterator[T]
```

Computes the input [Partition](Partition.md) (with the [TaskContext](../scheduler/TaskContext.md)) to produce values (of type `T`)

See:

* [LocalCheckpointRDD](LocalCheckpointRDD.md#compute)
* [MapPartitionsRDD](MapPartitionsRDD.md#compute)
* [ReliableCheckpointRDD](ReliableCheckpointRDD.md#compute)
* [ShuffledRDD](ShuffledRDD.md#compute)

Used when:

* `RDD` is requested to [computeOrReadCheckpoint](#computeOrReadCheckpoint)

### Partitions { #getPartitions }

```scala
getPartitions: Array[Partition]
```

[Partition](Partition.md)s of this `RDD`

See:

* [LocalCheckpointRDD](LocalCheckpointRDD.md#getPartitions)
* [MapPartitionsRDD](MapPartitionsRDD.md#getPartitions)
* [ReliableCheckpointRDD](ReliableCheckpointRDD.md#getPartitions)
* [ShuffledRDD](ShuffledRDD.md#getPartitions)

Used when:

* `RDD` is requested for the [partitions](#partitions)

## Implementations

* [CheckpointRDD](CheckpointRDD.md)
* [CoalescedRDD](CoalescedRDD.md)
* [CoGroupedRDD](CoGroupedRDD.md)
* [HadoopRDD](HadoopRDD.md)
* [MapPartitionsRDD](MapPartitionsRDD.md)
* [NewHadoopRDD](NewHadoopRDD.md)
* [ParallelCollectionRDD](ParallelCollectionRDD.md)
* [ReliableCheckpointRDD](ReliableCheckpointRDD.md)
* [ShuffledRDD](ShuffledRDD.md)
* _others_

## Creating Instance

`RDD` takes the following to be created:

* <span id="_sc"> [SparkContext](../SparkContext.md)
* <span id="deps"> [Dependencies](Dependency.md) (**Parent RDDs** that should be computed successfully before this RDD)

??? note "Abstract Class"
    `RDD` is an abstract class and cannot be created directly. It is created indirectly for the [concrete RDDs](#implementations).

## Barrier RDD

**Barrier RDD** is a `RDD` with the [isBarrier](#isBarrier) flag enabled.

[ShuffledRDD](ShuffledRDD.md) can never be a barrier RDD as it overrides [isBarrier](ShuffledRDD.md#isBarrier) method to be always disabled (`false`).

### isBarrier { #isBarrier }

```scala
isBarrier(): Boolean
```

`isBarrier` is the value of [isBarrier_](#isBarrier_).

---

`isBarrier` is used when:

* `DAGScheduler` is requested to [submitMissingTasks](../scheduler/DAGScheduler.md#submitMissingTasks) (that are either [ShuffleMapStage](../scheduler/ShuffleMapStage.md)s to create [ShuffleMapTask](../scheduler/ShuffleMapTask.md#isBarrier)s or [ResultStage](../scheduler/ResultStage.md) to create [ResultTask](../scheduler/ResultTask.md#isBarrier)s)
* `RDDInfo` is [created](../storage/RDDInfo.md#isBarrier)
* `ShuffleDependency` is requested to [canShuffleMergeBeEnabled](ShuffleDependency.md#canShuffleMergeBeEnabled)
* `DAGScheduler` is requested to [checkBarrierStageWithRDDChainPattern](../scheduler/DAGScheduler.md#checkBarrierStageWithRDDChainPattern), [checkBarrierStageWithDynamicAllocation](../scheduler/DAGScheduler.md#checkBarrierStageWithDynamicAllocation), [checkBarrierStageWithNumSlots](../scheduler/DAGScheduler.md#checkBarrierStageWithNumSlots), [handleTaskCompletion](../scheduler/DAGScheduler.md#handleTaskCompletion) (`FetchFailed` case to mark a map stage as broken)

### isBarrier\_ { #isBarrier_ }

```scala
isBarrier_ : Boolean // (1)!
```

1. `@transient protected lazy val`

`isBarrier_` is enabled (`true`) when there is at least one [barrier RDD](#isBarrier) among the [parent RDDs](Dependency.md#rdd) (excluding [ShuffleDependency](ShuffleDependency.md)ies).

!!! note
    `isBarrier_` is overriden by `PythonRDD` and [MapPartitionsRDD](MapPartitionsRDD.md#isBarrier_) that both accept `isFromBarrier` flag.

## ResourceProfile (Stage-Level Scheduling) { #resourceProfile }

`RDD` can be assigned a [ResourceProfile](../stage-level-scheduling/ResourceProfile.md) using [RDD.withResources](#withResources) method.

```scala
val rdd: RDD[_] = ...
rdd
  .withResources(...) // request resources for a computation
  .mapPartitions(...) // the computation
```

`RDD` uses `resourceProfile` internal registry for the [ResourceProfile](../stage-level-scheduling/ResourceProfile.md) that is undefined initially.

The `ResourceProfile` is available using [RDD.getResourceProfile](#getResourceProfile) method.

### withResources { #withResources }

```scala
withResources(
  rp: ResourceProfile): this.type
```

`withResources` sets the given [ResourceProfile](../stage-level-scheduling/ResourceProfile.md) as the [resourceProfile](#resourceProfile) and requests the [ResourceProfileManager](../SparkContext.md#resourceProfileManager) to [add the resource profile](../stage-level-scheduling/ResourceProfileManager.md#addResourceProfile).

### getResourceProfile { #getResourceProfile }

```scala
getResourceProfile(): ResourceProfile
```

`getResourceProfile` returns the [resourceProfile](#resourceProfile) (if defined) or `null`.

---

`getResourceProfile` is used when:

* `DAGScheduler` is requested for the [ShuffleDependencies and ResourceProfiles of an RDD](../scheduler/DAGScheduler.md#getShuffleDependenciesAndResourceProfiles)

## Preferred Locations (Placement Preferences of Partition) { #preferredLocations }

```scala
preferredLocations(
  split: Partition): Seq[String]
```

??? note "Final Method"
    `preferredLocations` is a Scala **final method** and may not be overridden in [subclasses](#implementations).

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#final).

`preferredLocations` requests the [CheckpointRDD](#checkpointRDD) for the [preferred locations](#getPreferredLocations) for the given [Partition](Partition.md) if this `RDD` is checkpointed or[getPreferredLocations](#getPreferredLocations).

---

`preferredLocations` is a template method that uses [getPreferredLocations](#getPreferredLocations) that custom `RDD`s can override to specify placement preferences on their own.

---

`preferredLocations` is used when:

* `DAGScheduler` is requested for [preferred locations](../scheduler/DAGScheduler.md#getPreferredLocs)

## Partitions

```scala
partitions: Array[Partition]
```

??? note "Final Method"
    `partitions` is a Scala **final method** and may not be overridden in [subclasses](#implementations).

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#final).

`partitions` requests the [CheckpointRDD](#checkpointRDD) for the partitions if this `RDD` is checkpointed.

Otherwise, when this `RDD` is not checkpointed, `partitions` [getPartitions](#getPartitions) (and caches it in the [partitions_](#partitions_)).

!!! note
    `getPartitions` is an abstract method that custom `RDD`s are required to provide.

---

`partitions` has the property that their internal index should be equal to their position in this `RDD`.

---

`partitions` is used when:

* `DAGScheduler` is requested to [getPreferredLocsInternal](../scheduler/DAGScheduler.md#getPreferredLocsInternal)
* `SparkContext` is requested to [run a job](../SparkContext.md#runJob)
* _others_

## dependencies

```scala
dependencies: Seq[Dependency[_]]
```

??? note "Final Method"
    `dependencies` is a Scala **final method** and may not be overridden in [subclasses](#implementations).

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#final).

`dependencies` branches off based on [checkpointRDD](#checkpointRDD) (and availability of [CheckpointRDD](#CheckpointRDD)).

With [CheckpointRDD](#CheckpointRDD) available (this `RDD` is checkpointed), `dependencies` returns a [OneToOneDependency](Dependency.md#OneToOneDependency) with the `CheckpointRDD`.

Otherwise, when this `RDD` is not checkpointed, `dependencies` [getDependencies](#getDependencies) (and caches it in the [dependencies_](#dependencies_)).

!!! note
    `getDependencies` is an abstract method that custom `RDD`s are required to provide.

## Reliable Checkpointing { #checkpoint }

```scala
checkpoint(): Unit
```

!!! note "Public API"
    `checkpoint` is part of the public API.

??? warning "Procedure"
    `checkpoint` is a procedure (returns `Unit`) so _what happens inside stays inside_ (paraphrasing the [former advertising slogan of Las Vegas, Nevada](https://idioms.thefreedictionary.com/what+happens+in+Vegas+stays+in+Vegas)).

`checkpoint` creates a new [ReliableRDDCheckpointData](ReliableRDDCheckpointData.md) (with this `RDD`) and saves it in [checkpointData](#checkpointData) registry.

`checkpoint` does nothing when the [checkpointData](#checkpointData) registry has already been defined.

`checkpoint` throws a `SparkException` when the [checkpoint directory](../SparkContext.md#checkpointDir) is not specified:

```text
Checkpoint directory has not been set in the SparkContext
```

## RDDCheckpointData { #checkpointData }

```scala
checkpointData: Option[RDDCheckpointData[T]]
```

`RDD` defines `checkpointData` internal registry for a [RDDCheckpointData[T]](RDDCheckpointData.md) (of `T` type of this `RDD`).

The `checkpointData` registry is undefined (`None`) initially when this `RDD` is [created](#creating-instance) and can hold a value after the following `RDD` API operators:

RDD Operator | RDDCheckpointData
-------------|------------------
 [RDD.checkpoint](#checkpoint) | [ReliableRDDCheckpointData](ReliableRDDCheckpointData.md)
 [RDD.localCheckpoint](#localCheckpoint) | [LocalRDDCheckpointData](LocalRDDCheckpointData.md)

`checkpointData` is used when:

* [isCheckpointedAndMaterialized](#isCheckpointedAndMaterialized)
* [isLocallyCheckpointed](#isLocallyCheckpointed)
* [isReliablyCheckpointed](#isReliablyCheckpointed)
* [getCheckpointFile](#getCheckpointFile)
* [doCheckpoint](#doCheckpoint)

### <span id="CheckpointRDD"> CheckpointRDD { #checkpointRDD }

```scala
checkpointRDD: Option[CheckpointRDD[T]]
```

`checkpointRDD` returns the [CheckpointRDD](RDDCheckpointData.md#checkpointRDD) of the [RDDCheckpointData](#checkpointData) (if defined and so this `RDD` checkpointed).

---

`checkpointRDD` is used when:

* `RDD` is requested for the [dependencies](#dependencies), [partitions](#partitions) and [preferred locations](#preferredLocations) (all using _final_ methods!)

## doCheckpoint { #doCheckpoint }

```scala
doCheckpoint(): Unit
```

!!! note "RDD.doCheckpoint, SparkContext.runJob and Dataset.checkpoint"
    `doCheckpoint` is called every time a Spark job is submitted (using [SparkContext.runJob](../SparkContext.md#runJob)).

    I found it quite interesting at the very least.

    `doCheckpoint` is triggered when `Dataset.checkpoint` operator ([Spark SQL]({{ book.spark_sql }}/Dataset/#checkpoint)) is executed (with `eager` flag on) which will likely trigger one or more Spark jobs on the underlying RDD anyway.

??? warning "Procedure"
    `doCheckpoint` is a procedure (returns `Unit`) so _what happens inside stays inside_ (paraphrasing the [former advertising slogan of Las Vegas, Nevada](https://idioms.thefreedictionary.com/what+happens+in+Vegas+stays+in+Vegas)).

??? note "Does nothing unless checkpointData is defined"
    My understanding is that `doCheckpoint` does nothing (_noop_) unless the [RDDCheckpointData](#checkpointData) is defined.

`doCheckpoint` executes all the following in [checkpoint](RDDOperationScope.md#withScope) scope.

`doCheckpoint` turns the [doCheckpointCalled](#doCheckpointCalled) flag on (to prevent multiple executions).

`doCheckpoint` branches off based on whether a [RDDCheckpointData](#checkpointData) is defined or not:

1. With the `RDDCheckpointData` defined, `doCheckpoint` checks out the [checkpointAllMarkedAncestors](#checkpointAllMarkedAncestors) flag and if enabled, `doCheckpoint` requests the [Dependencies](#dependencies) for the [RDD](Dependency.md#rdd) that are in turn requested to [doCheckpoint](#doCheckpoint) themselves. Otherwise, `doCheckpoint` requests the [RDDCheckpointData](#checkpointData) to [checkpoint](RDDCheckpointData.md#checkpoint).

1. With the [RDDCheckpointData](#checkpointData) undefined, `doCheckpoint` requests the [Dependencies](#dependencies) (of this RDD) for their [RDD](Dependency.md#rdd)s that are in turn requested to [doCheckpoint](#doCheckpoint) themselves (recursively).

!!! note
    With the `RDDCheckpointData` defined, requesting [doCheckpoint](#doCheckpoint) of the [Dependencies](#dependencies) is guarded by [checkpointAllMarkedAncestors](#checkpointAllMarkedAncestors) flag.

`doCheckpoint` skips execution if [called earlier](#doCheckpointCalled).

!!! note "CheckpointRDD"
    [CheckpointRDD](CheckpointRDD.md) is not checkpoint again (and does nothing when requested to do so).

---

`doCheckpoint` is used when:

* `SparkContext` is requested to [run a job synchronously](../SparkContext.md#runJob)

## <span id="iterator"> iterator

```scala
iterator(
  split: Partition,
  context: TaskContext): Iterator[T]
```

`iterator`...FIXME

!!! note "Final Method"
    `iterator` is a `final` method and may not be overridden in subclasses. See [5.2.6 final]({{ scala.spec }}/05-classes-and-objects.html) in the [Scala Language Specification]({{ scala.spec }}).

### <span id="getOrCompute"> getOrCompute

```scala
getOrCompute(
  partition: Partition,
  context: TaskContext): Iterator[T]
```

`getOrCompute`...FIXME

### <span id="computeOrReadCheckpoint"> computeOrReadCheckpoint

```scala
computeOrReadCheckpoint(
  split: Partition,
  context: TaskContext): Iterator[T]
```

`computeOrReadCheckpoint`...FIXME

## <span id="toDebugString"> Debugging Recursive Dependencies

```scala
toDebugString: String
```

`toDebugString` returns a [RDD Lineage Graph](lineage.md).

```text
val wordCount = sc.textFile("README.md")
  .flatMap(_.split("\\s+"))
  .map((_, 1))
  .reduceByKey(_ + _)

scala> println(wordCount.toDebugString)
(2) ShuffledRDD[21] at reduceByKey at <console>:24 []
 +-(2) MapPartitionsRDD[20] at map at <console>:24 []
    |  MapPartitionsRDD[19] at flatMap at <console>:24 []
    |  README.md MapPartitionsRDD[18] at textFile at <console>:24 []
    |  README.md HadoopRDD[17] at textFile at <console>:24 []
```

`toDebugString` uses indentations to indicate a shuffle boundary.

The numbers in round brackets show the level of parallelism at each stage, e.g. `(2)` in the above output.

```text
scala> println(wordCount.getNumPartitions)
2
```

With [spark.logLineage](../configuration-properties.md#spark.logLineage) enabled, `toDebugString` is printed out when executing an action.

```text
$ ./bin/spark-shell --conf spark.logLineage=true

scala> sc.textFile("README.md", 4).count
...
15/10/17 14:46:42 INFO SparkContext: Starting job: count at <console>:25
15/10/17 14:46:42 INFO SparkContext: RDD's recursive dependencies:
(4) MapPartitionsRDD[1] at textFile at <console>:25 []
 |  README.md HadoopRDD[0] at textFile at <console>:25 []
```

## <span id="coalesce"> coalesce

```scala
coalesce(
  numPartitions: Int,
  shuffle: Boolean = false,
  partitionCoalescer: Option[PartitionCoalescer] = Option.empty)
  (implicit ord: Ordering[T] = null): RDD[T]
```

`coalesce`...FIXME

---

`coalesce` is used when:

* [RDD.repartition](#repartition) high-level operator is used

## Implicit Methods

### <span id="rddToOrderedRDDFunctions"> rddToOrderedRDDFunctions

```scala
rddToOrderedRDDFunctions[K : Ordering : ClassTag, V: ClassTag](
  rdd: RDD[(K, V)]): OrderedRDDFunctions[K, V, (K, V)]
```

`rddToOrderedRDDFunctions` is an Scala implicit method that creates an [OrderedRDDFunctions](OrderedRDDFunctions.md).

`rddToOrderedRDDFunctions` is used (implicitly) when:

* [RDD.sortBy](spark-rdd-transformations.md#sortBy)
* [PairRDDFunctions.combineByKey](PairRDDFunctions.md#combineByKey)

## withScope { #withScope }

```scala
withScope[U](
  body: => U): U
```

`withScope` [withScope](RDDOperationScope.md#withScope) with this [SparkContext](#sc).

!!! note
    `withScope` is used for most (if not all) `RDD` API operators.

<!---
## Review Me

== [[storageLevel]][[getStorageLevel]] StorageLevel

RDD can have a storage:StorageLevel.md[StorageLevel] specified. The default StorageLevel is storage:StorageLevel.md#NONE[NONE].

storageLevel can be specified using <<persist, persist>> method.

storageLevel becomes NONE again after <<unpersist, unpersisting>>.

The current StorageLevel is available using `getStorageLevel` method.

[source, scala]
----
getStorageLevel: StorageLevel
----

== [[id]] Unique Identifier

[source, scala]
----
id: Int
----

id is an *unique identifier* (aka *RDD ID*) in the given <<_sc, SparkContext>>.

id requests the <<sc, SparkContext>> for SparkContext.md#newRddId[newRddId] right when RDD is created.

== [[getOrCompute]] Getting Or Computing RDD Partition

[source, scala]
----
getOrCompute(
  partition: Partition,
  context: TaskContext): Iterator[T]
----

`getOrCompute` creates a storage:BlockId.md#RDDBlockId[RDDBlockId] for the <<id, RDD id>> and the [partition index](Partition.md#index).

`getOrCompute` requests the `BlockManager` to storage:BlockManager.md#getOrElseUpdate[getOrElseUpdate] for the block ID (with the <<storageLevel, storage level>> and the `makeIterator` function).

NOTE: `getOrCompute` uses core:SparkEnv.md#get[SparkEnv] to access the current core:SparkEnv.md#blockManager[BlockManager].

[[getOrCompute-readCachedBlock]]
`getOrCompute` records whether...FIXME (readCachedBlock)

`getOrCompute` branches off per the response from the storage:BlockManager.md#getOrElseUpdate[BlockManager] and whether the internal `readCachedBlock` flag is now on or still off. In either case, `getOrCompute` creates an spark-InterruptibleIterator.md[InterruptibleIterator].

NOTE: spark-InterruptibleIterator.md[InterruptibleIterator] simply delegates to a wrapped internal `Iterator`, but allows for [task killing functionality](../scheduler/TaskContext.md#isInterrupted).

For a `BlockResult` available and `readCachedBlock` flag on, `getOrCompute`...FIXME

For a `BlockResult` available and `readCachedBlock` flag off, `getOrCompute`...FIXME

NOTE: The `BlockResult` could be found in a local block manager or fetched from a remote block manager. It may also have been stored (persisted) just now. In either case, the `BlockResult` is available (and storage:BlockManager.md#getOrElseUpdate[BlockManager.getOrElseUpdate] gives a `Left` value with the `BlockResult`).

For `Right(iter)` (regardless of the value of `readCachedBlock` flag since...FIXME), `getOrCompute`...FIXME

NOTE: storage:BlockManager.md#getOrElseUpdate[BlockManager.getOrElseUpdate] gives a `Right(iter)` value to indicate an error with a block.

NOTE: `getOrCompute` is used on Spark executors.

NOTE: `getOrCompute` is used exclusively when RDD is requested for the <<iterator, iterator over values in a partition>>.

== [[checkpointRDD]] Getting CheckpointRDD

[source, scala]
----
checkpoint Option[CheckpointRDD[T]]
----

checkpointRDD gives the CheckpointRDD from the <<checkpointData, checkpointData>> internal registry if available (if the RDD was checkpointed).

checkpointRDD is used when RDD is requested for the <<dependencies, dependencies>>, <<partitions, partitions>> and <<preferredLocations, preferredLocations>>.

== [[isCheckpointedAndMaterialized]] isCheckpointedAndMaterialized Method

[source, scala]
----
isCheckpointedAndMaterialized: Boolean
----

isCheckpointedAndMaterialized...FIXME

isCheckpointedAndMaterialized is used when RDD is requested to <<computeOrReadCheckpoint, computeOrReadCheckpoint>>, <<localCheckpoint, localCheckpoint>> and <<isCheckpointed, isCheckpointed>>.

== [[getNarrowAncestors]] getNarrowAncestors Method

[source, scala]
----
getNarrowAncestors: Seq[RDD[_]]
----

getNarrowAncestors...FIXME

getNarrowAncestors is used when StageInfo is requested to [fromStage](../scheduler/StageInfo.md#fromStage).

== [[persist]] Persisting RDD

[source, scala]
----
persist(): this.type
persist(
  newLevel: StorageLevel): this.type
----

Refer to spark-rdd-caching.md#persist[Persisting RDD].

== [[persist-internal]] persist Internal Method

[source, scala]
----
persist(
  newLevel: StorageLevel,
  allowOverride: Boolean): this.type
----

persist...FIXME

persist (private) is used when RDD is requested to <<persist, persist>> and <<localCheckpoint, localCheckpoint>>.

== [[computeOrReadCheckpoint]] Computing Partition or Reading From Checkpoint

[source, scala]
----
computeOrReadCheckpoint(
  split: Partition,
  context: TaskContext): Iterator[T]
----

computeOrReadCheckpoint reads `split` partition from a checkpoint (<<isCheckpointedAndMaterialized, if available already>>) or <<compute, computes it>> yourself.

computeOrReadCheckpoint is used when RDD is requested to <<iterator, compute records for a partition>> or <<getOrCompute, getOrCompute>>.
-->
