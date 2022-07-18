# RangePartitioner

`RangePartitioner` is a [Partitioner](Partitioner.md) that partitions sortable records by range into roughly equal ranges (that can be used for **bucketed partitioning**).

`RangePartitioner` is used for [sortByKey](OrderedRDDFunctions.md#sortByKey) operator (_mostly_).

## Creating Instance

`RangePartitioner` takes the following to be created:

* <span id="partitions"> Hint for the number of partitions
* <span id="rdd"> Key-Value [RDD](RDD.md) (`RDD[_ <: Product2[K, V]]`)
* <span id="ascending"> `ascending` flag (default: `true`)
* <span id="samplePointsPerPartitionHint"> samplePointsPerPartitionHint (default: `20`)

## <span id="numPartitions"> Number of Partitions

```scala
numPartitions: Int
```

`numPartitions` is part of the [Partitioner](Partitioner.md#numPartitions) abstraction.

---

`numPartitions` is 1 more than the length of the [range bounds](#rangeBounds) (since the number of [range bounds](#rangeBounds) is 0 for 0 or 1 partitions).

## <span id="getPartition"> Partition for Key

```scala
getPartition(
  key: Any): Int
```

`getPartition` is part of the [Partitioner](Partitioner.md#getPartition) abstraction.

---

`getPartition` branches off based on the length of the [range bounds](#rangeBounds).

For up to 128 range bounds, `getPartition` is either the first range bound (from the [rangeBounds](#rangeBounds)) for which the `key` value is greater than the value of the range bound or 128 (if no value was found among the [rangeBounds](#rangeBounds)). `getPartition` starts finding a candidate partition number from `0` and walks over the [rangeBounds](#rangeBounds) until a range bound for which the given `key` value is greater than the value of the range bound is found or there are no more [rangeBounds](#rangeBounds). `getPartition` increments the candidate partition candidate every iteration.

For the number of the [rangeBounds](#rangeBounds) above 128, `getPartition`...FIXME

In the end, `getPartition` returns the candidate partition number for the [ascending](#ascending) enabled, or flips it (to be the number of the [rangeBounds](#rangeBounds) minus the candidate partition number), otheriwse.

## <span id="rangeBounds"> Range Bounds

```scala
rangeBounds: Array[K]
```

`rangeBounds` is an array of upper bounds.

For the [number of partitions](#partitions) up to and including 1, `rangeBounds` is an empty array.

For more than 1 [partitions](#partitions), `rangeBounds` determines the sample size per partitions. The total sample size is the [samplePointsPerPartitionHint](#samplePointsPerPartitionHint) multiplied by the [number of partitions](#partitions) capped by `1e6`. `rangeBounds` allows for 3x over-sample per partition.

`rangeBounds` [sketches](#sketch) the keys of the [input rdd](#rdd) (with the `sampleSizePerPartition`).

!!! note
    There is more going on in `rangeBounds`.

In the end, `rangeBounds` [determines the bounds](#determineBounds).

### <span id="determineBounds"> determineBounds

```scala
determineBounds[K: Ordering](
  candidates: ArrayBuffer[(K, Float)],
  partitions: Int): Array[K]
```

`determineBounds`...FIXME
