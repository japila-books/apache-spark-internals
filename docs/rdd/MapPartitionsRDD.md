# MapPartitionsRDD

`MapPartitionsRDD[U, T]` is a [RDD](RDD.md) that transforms (_maps_) input `T` records into `U`s using [partition function](#f).

`MapPartitionsRDD` is a [RDD](RDD.md) that has exactly [one-to-one narrow dependency](NarrowDependency.md#OneToOneDependency) on the [parent RDD](#prev).

## Creating Instance

`MapPartitionsRDD` takes the following to be created:

* <span id="prev"> Parent [RDD](RDD.md) (`RDD[T]`)
* <span id="f"> Partition Function
* <span id="preservesPartitioning"> `preservesPartitioning` flag
* [isFromBarrier Flag](#isFromBarrier)
* <span id="isOrderSensitive"> `isOrderSensitive` flag

`MapPartitionsRDD` is created when:

* `PairRDDFunctions` is requested to [mapValues](PairRDDFunctions.md#mapValues) and [flatMapValues](PairRDDFunctions.md#flatMapValues)
* `RDD` is requested to [map](RDD.md#map), [flatMap](RDD.md#flatMap), [filter](RDD.md#filter), [glom](RDD.md#glom), [mapPartitions](RDD.md#mapPartitions), [mapPartitionsWithIndexInternal](RDD.md#mapPartitionsWithIndexInternal), [mapPartitionsInternal](RDD.md#mapPartitionsInternal), [mapPartitionsWithIndex](RDD.md#mapPartitionsWithIndex)
* `RDDBarrier` is requested to [mapPartitions](../barrier-execution-mode/RDDBarrier.md#mapPartitions), [mapPartitionsWithIndex](../barrier-execution-mode/RDDBarrier.md#mapPartitionsWithIndex)

## Barrier RDD

`MapPartitionsRDD` can be a [barrier RDD](RDD.md#isBarrier) in [Barrier Execution Mode](../barrier-execution-mode/index.md).

### isFromBarrier Flag { #isFromBarrier }

`MapPartitionsRDD` can be given `isFromBarrier` flag when [created](#creating-instance).

`isFromBarrier` flag is assumed disabled (`false`) and can only be enabled (`true`) using [RDDBarrier](../barrier-execution-mode/RDDBarrier.md) transformations:

* [RDDBarrier.mapPartitions](../barrier-execution-mode/RDDBarrier.md#mapPartitions)
* [RDDBarrier.mapPartitionsWithIndex](../barrier-execution-mode/RDDBarrier.md#mapPartitionsWithIndex)

### isBarrier_ { #isBarrier_ }

??? note "RDD"

    ```scala
    isBarrier_ : Boolean
    ```

    `isBarrier_` is part of the [RDD](RDD.md#isBarrier_) abstraction.

`isBarrier_` is enabled (`true`) when either this `MapPartitionsRDD` is [isFromBarrier](#isFromBarrier) or any of the [parent RDDs](Dependency.md#rdd) is [isBarrier](RDD.md#isBarrier). Otherwise, `isBarrier_` is disabled (`false`).
