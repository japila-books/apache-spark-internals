# ShuffleReader

`ShuffleReader` is a <<contract, contract>> of <<implementations, shuffle readers>> to <<read, read combined key-value records for a reduce task>>.

[[contract]]
[source, scala]
----
package org.apache.spark.shuffle

trait ShuffleReader[K, C] {
  def read(): Iterator[Product2[K, C]]
}
----

NOTE: `ShuffleReader` is a `private[spark]` contract.

.ShuffleReader Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `read`
a| [[read]] Reading combined key-value records for a reduce task

Used when:

* [CoGroupedRDD](../rdd/CoGroupedRDD.md#compute), [ShuffledRDD](../rdd/ShuffledRDD.md#compute), and [SubtractedRDD](../rdd/SubtractedRDD.md#compute) are requested to compute a partition (for a `ShuffleDependency` dependency)

* Spark SQL's `ShuffledRowRDD` is requested to `compute` a partition
|===

[[implementations]]
NOTE: shuffle:BlockStoreShuffleReader.md[BlockStoreShuffleReader] is the one and only known <<contract, ShuffleReader>> in Apache Spark.
