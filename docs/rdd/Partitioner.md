# Partitioner

`Partitioner` is an [abstraction](#contract) of [partitioners](#implementations) that define how the elements in a key-value pair RDD are partitioned by key.

`Partitioner` [maps keys to partition IDs](#getPartition) (from 0 to [numPartitions](#numPartitions) exclusive).

`Partitioner` ensures that records with the same key are in the same partition.

`Partitioner` is a Java `Serializable`.

## Contract

### <span id="getPartition"> Partition for Key

```scala
getPartition(
  key: Any): Int
```

Partition ID for the given key

### <span id="numPartitions"> Number of Partitions

```scala
numPartitions: Int
```

## Implementations

* CoalescedPartitioner (Spark SQL)
* [HashPartitioner](HashPartitioner.md)
* [RangePartitioner](RangePartitioner.md)
