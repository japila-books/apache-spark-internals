# Partition

`Partition` is a <<contract, contract>> of a <<index, partition index>> of a RDD.

NOTE: A partition is *missing* when it has not be computed yet.

[[contract]]
[[index]]
`Partition` is identified by an *partition index* that is a unique identifier of a partition of a RDD.

[source, scala]
----
index: Int
----
