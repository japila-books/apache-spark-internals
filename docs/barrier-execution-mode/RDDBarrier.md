# RDDBarrier

`RDDBarrier` is a wrapper around [RDD](#rdd) with two custom map transformations:

* [mapPartitions](#mapPartitions)
* [mapPartitionsWithIndex](#mapPartitionsWithIndex)

Unlike regular [RDD.mapPartitions](../rdd/RDD.md#mapPartitions) transformations, `RDDBarrier` transformations create a [MapPartitionsRDD](../rdd/MapPartitionsRDD.md) with [isFromBarrier](../rdd/MapPartitionsRDD.md#isFromBarrier) flag enabled.

`RDDBarrier` (of `T` records) marks the current stage as a [barrier stage](index.md#barrier-stage) in [Barrier Execution Mode](index.md).

## Creating Instance

`RDDBarrier` takes the following to be created:

* <span id="rdd"> [RDD](../rdd/RDD.md) (of `T` records)

`RDDBarrier` is created when:

* [RDD.barrier](../rdd/RDD.md#barrier) transformation is used

## Demo

```scala
val rdd = sc.parallelize(seq = 0 until 9, numSlices = 3)

assert(rdd.getNumPartitions == 3)

import org.apache.spark.rdd.RDDBarrier
assert(rdd.barrier.isInstanceOf[RDDBarrier[_]])
```

```scala
import org.apache.spark.TaskContext
rdd
  .mapPartitions { it => Iterator.single((TaskContext.get.partitionId, it.size)) }
  .foreachPartition { it => println(it.next) }
```

```scala
val barrierRdd = rdd
  .barrier
  .mapPartitions(identity)

import org.apache.spark.rdd.RDD
assert(barrierRdd.isInstanceOf[RDD[_]])
```

```text
scala> println(barrierRdd.toDebugString)
(3) MapPartitionsRDD[2] at mapPartitions at <pastie>:3 []
 |  ParallelCollectionRDD[0] at parallelize at <pastie>:1 []
```

```scala
// MapPartitionsRDD is private[spark]
// so is RDD.isBarrier
// Use org.apache.spark package then
// :paste -raw the following code in spark-shell / Scala REPL
// BEGIN
package org.apache.spark
object IsBarrier {
  import org.apache.spark.rdd.RDD
  implicit class BypassPrivateSpark[T](rdd: RDD[T]) {
    def isBarrier = rdd.isBarrier
  }
}
// END
```

```scala
import org.apache.spark.IsBarrier._
assert(barrierRdd.isBarrier)
```

```scala
barrierRdd.count()
```

Open up [web UI](http://localhost:4040/) and explore the execution plans.
