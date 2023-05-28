# RDDBarrier

`RDDBarrier` (of `T` records) marks the current stage as a [barrier stage](index.md#barrier-stage) in [Barrier Execution Mode](index.md).

## Creating Instance

`RDDBarrier` takes the following to be created:

* <span id="rdd"> [RDD](../rdd/RDD.md) (of `T` records)

`RDDBarrier` is created when:

* [RDD.barrier](../rdd/RDD.md#barrier) transformation is used

## Demo

```text
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
