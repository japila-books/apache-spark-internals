# HashPartitioner

`HashPartitioner` is a [Partitioner](Partitioner.md) for **hash-based partitioning**.

!!! important
    `HashPartitioner` [places null keys in 0th partition](#getPartition).

`HashPartitioner` is used as the [default Partitioner](Partitioner.md#defaultPartitioner).

## Creating Instance

`HashPartitioner` takes the following to be created:

* <span id="partitions"> Number of partitions

## <span id="numPartitions"> Number of Partitions

```scala
numPartitions: Int
```

`numPartitions` returns the given [number of partitions](#partitions).

`numPartitions` is part of the [Partitioner](Partitioner.md#numPartitions) abstraction.

## <span id="getPartition"> Partition for Key

```scala
getPartition(
  key: Any): Int
```

For `null` keys `getPartition` simply returns `0`.

For non-`null` keys, `getPartition` uses the [Object.hashCode]({{ java.api }}/java.base/java/lang/Object.html#hashCode()) of the key  modulo the [number of partitions](#numPartitions). For negative results, `getPartition` adds the number of partitions to make it non-negative.

`getPartition` is part of the [Partitioner](Partitioner.md#getPartition) abstraction.
