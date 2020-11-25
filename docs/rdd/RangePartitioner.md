# RangePartitioner

`RangePartitioner` is a [Partitioner](Partitioner.md) for **bucketed partitioning**.

`RangePartitioner` is used for [sortByKey](OrderedRDDFunctions.md#sortByKey) operator (among other uses).

## Creating Instance

`RangePartitioner` takes the following to be created:

* <span id="partitions"> Number of Partitions
* <span id="rdd"> Key-Value [RDD](RDD.md) (`RDD[_ <: Product2[K, V]]`)
* <span id="ascending"> `ascending` flag (default: `true`)
* <span id="samplePointsPerPartitionHint"> samplePointsPerPartitionHint (default: `20`)

## <span id="numPartitions"> Number of Partitions

```scala
numPartitions: Int
```

`numPartitions` is the length of the [rangeBounds](#rangeBounds) array plus `1`.

`numPartitions` is part of the [Partitioner](Partitioner.md#numPartitions) abstraction.

## <span id="getPartition"> Partition for Key

```scala
getPartition(
  key: Any): Int
```

`getPartition`...FIXME

`getPartition` is part of the [Partitioner](Partitioner.md#getPartition) abstraction.

## <span id="rangeBounds"> Range Bounds

```scala
rangeBounds: Array[K]
```

`rangeBounds` is an `Array[K]`...FIXME

### <span id="determineBounds"> determineBounds Utility

```scala
determineBounds[K : Ordering : ClassTag](
  candidates: ArrayBuffer[(K, Float)],
  partitions: Int): Array[K]
```

`determineBounds`...FIXME
