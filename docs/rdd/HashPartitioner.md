= HashPartitioner

*HashPartitioner* is a rdd:Partitioner.md[Partitioner] for hash-based partitioning.

HashPartitioner is used as the default Partitioner.

== [[partitions]][[numPartitions]] Number of Partitions

HashPartitioner takes a number of partitions to be created.

HashPartitioner uses the number of partitions to find the <<getPartition, partition ID for a given key>> (of a key-value record).

== [[getPartition]] Finding Partition ID for Key

[source, scala]
----
getPartition(key: Any): Int
----

getPartition returns 0 as the partition ID for `null` keys.

For non-``null`` keys, getPartition uses the key's {java-javadoc-url}/java/lang/Object.html#++hashCode--++[Object.hashCode] modulo the configured <<numPartitions, number of partitions>>. For a negative result, getPartition adds the <<numPartitions, number of partitions>> (used for the modulo operator) to make it positive.

getPartition is part of the rdd:Partitioner.md#getPartition[Partitioner] abstraction.

== [[equals]] equals Method

[source, scala]
----
equals(other: Any): Boolean
----

Two HashPartitioners are considered equal when the <<numPartitions, number of partitions>> are the same.

== [[hashCode]] hashCode Method

[source, scala]
----
hashCode: Int
----

hashCode is the <<numPartitions, number of partitions>>.
