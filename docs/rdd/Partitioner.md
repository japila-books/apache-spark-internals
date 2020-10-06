= Partitioner

Partitioner is an abstraction to define how the elements in a key-value pair RDD are partitioned by key. Partitioner <<getPartition, maps keys to partition IDs>> (from 0 to <<numPartitions, numPartitions>> - 1).

Partitioner is used to ensure that records for a given key have to reside on a single partition.

== [[implementations]] Available Partitioners

[cols="30,70",options="header",width="100%"]
|===
| Partitioner
| Description

| rdd:HashPartitioner.md[HashPartitioner]
| [[HashPartitioner]] Hash-based partitioning

| rdd:RangePartitioner.md[RangePartitioner]
| [[RangePartitioner]]

|===

== [[numPartitions]] numPartitions Method

[source, scala]
----
numPartitions: Int
----

numPartitions is the number of partition to use for <<getPartition, mapping keys to partition IDs>>.

numPartitions is used when...FIXME

== [[getPartition]] getPartition Method

[source, scala]
----
getPartition(key: Any): Int
----

getPartition maps a given key to a partition ID (from 0 to <<numPartitions, numPartitions>> - 1)

getPartition is used when...FIXME

== [[defaultPartitioner]] defaultPartitioner Method

[source, scala]
----
defaultPartitioner(
  rdd: RDD[_],
  others: RDD[_]*): Partitioner
----

defaultPartitioner...FIXME

defaultPartitioner is used when...FIXME
