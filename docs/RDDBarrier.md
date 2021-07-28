== [[RDDBarrier]] RDDBarrier

`RDDBarrier` is used to mark the current stage as a <<spark-barrier-execution-mode.md#barrier-stage, barrier stage>> in <<spark-barrier-execution-mode.md#, Barrier Execution Mode>>.

`RDDBarrier` is <<creating-instance, created>> exclusively as the result of <<spark-rdd-transformations.md#barrier, RDD.barrier>> transformation (which is *new in Spark 2.4.0*).

[source, scala]
----
barrier(): RDDBarrier[T]
----

[[creating-instance]]
[[rdd]]
`RDDBarrier` takes a single rdd:RDD.md[RDD] to be created and gives the single <<mapPartitions, mapPartitions>> transformation (on the `RDD`) that simply changes the regular rdd:spark-rdd-transformations.md#mapPartitions[RDD.mapPartitions] transformation to create a rdd:MapPartitionsRDD.md[MapPartitionsRDD] with the rdd:MapPartitionsRDD.md#isFromBarrier[isFromBarrier] flag enabled.

[[mapPartitions]]
[source, scala]
----
mapPartitions[S: ClassTag](
  f: Iterator[T] => Iterator[S],
  preservesPartitioning: Boolean = false): RDD[S]
----

[[example]]
```
val rdd = sc.parallelize(0 to 3, 1)

scala> :type rdd.barrier
org.apache.spark.rdd.RDDBarrier[Int]

val barrierRdd = rdd
  .barrier
  .mapPartitions(identity)
scala> :type barrierRdd
org.apache.spark.rdd.RDD[Int]

scala> println(barrierRdd.toDebugString)
(1) MapPartitionsRDD[5] at mapPartitions at <console>:26 []
 |  ParallelCollectionRDD[3] at parallelize at <console>:25 []

// MapPartitionsRDD is private[spark]
// so is RDD.isBarrier
// Use org.apache.spark package then
// :paste -raw the following code in spark-shell / Scala REPL
// BEGIN
package org.apache.spark
object IsBarrier {
  import org.apache.spark.rdd.RDD
  implicit class BypassPrivateSpark[T](rdd: RDD[T]) {
    def myIsBarrier = rdd.isBarrier
  }
}
// END

import org.apache.spark.IsBarrier._
assert(barrierRdd.myIsBarrier)
```
