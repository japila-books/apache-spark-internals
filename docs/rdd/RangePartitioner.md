= RangePartitioner

RangePartitioner is a rdd:Partitioner.md[Partitioner] for...FIXME

[[ordering]]
`RangePartitioner[K : Ordering : ClassTag, V]` is a parameterized type of `K` keys that can be sorted (_ordered_) and `V` values.

RangePartitioner is used for rdd:spark-rdd-OrderedRDDFunctions.md#sortByKey[sortByKey] operator.

== [[creating-instance]] Creating Instance

RangePartitioner takes the following to be created:

* [[partitions]] Number of partitions
* [[rdd]] rdd:RDD.md[RDD] (`RDD[_ <: Product2[K, V]]`)
* [[ascending]] ascending flag (default: `true`)
* [[samplePointsPerPartitionHint]] samplePointsPerPartitionHint (default: 20)

== [[rangeBounds]] rangeBounds Array

RangePartitioner uses rangeBounds registry (of type `Array[K]`) when requested for <<getPartition, getPartition>> and <<hashCode, hashCode>>, <<numPartitions, number of partitions>>.

== [[numPartitions]] Number of Partitions

[source,scala]
----
numPartitions: Int
----

numPartitions is simply one more than the length of the <<rangeBounds, rangeBounds>> array.

numPartitions is part of the rdd:Partitioner.md#numPartitions[Partitioner] abstraction.

== [[getPartition]] Finding Partition ID for Key

[source, scala]
----
getPartition(key: Any): Int
----

getPartition...FIXME

getPartition is part of the rdd:Partitioner.md#getPartition[Partitioner] abstraction.
