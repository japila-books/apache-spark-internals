# RDDBarrier

`RDDBarrier` is a wrapper around [RDD](#rdd) with two custom map transformations:

* [mapPartitions](#mapPartitions)
* [mapPartitionsWithIndex](#mapPartitionsWithIndex)

Unlike regular [RDD.mapPartitions](../rdd/RDD.md#mapPartitions) transformations, `RDDBarrier` transformations create a [MapPartitionsRDD](../rdd/MapPartitionsRDD.md) with [isFromBarrier](../rdd/MapPartitionsRDD.md#isFromBarrier) flag enabled.

`RDDBarrier` (of `T` records) marks the current stage as a [barrier stage](index.md#barrier-stage) in [Barrier Execution Mode](index.md).

## Creating Instance

`RDDBarrier` takes the following to be created:

* <span id="rdd"> [RDD](../rdd/RDD.md) (of `T` records)

`RDDBarrier` is created when:

* [RDD.barrier](../rdd/RDD.md#barrier) transformation is used
