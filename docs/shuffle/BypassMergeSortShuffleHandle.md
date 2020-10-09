# BypassMergeSortShuffleHandle &mdash; Marker Interface for Bypass Merge Sort Shuffle Handles

`BypassMergeSortShuffleHandles` is a [BaseShuffleHandle](BaseShuffleHandle.md) with no additional methods or fields and serves only to identify the choice of **bypass merge sort shuffle**.

Like [BaseShuffleHandle](BaseShuffleHandle.md), `BypassMergeSortShuffleHandles` takes `shuffleId`, `numMaps`, and a [ShuffleDependency](../rdd/ShuffleDependency.md).

`BypassMergeSortShuffleHandle` is created when `SortShuffleManager` is requested for a [ShuffleHandle](SortShuffleManager.md#registerShuffle) (for a `ShuffleDependency`).

## Demo

```text
scala> val rdd = sc.parallelize(0 to 8).groupBy(_ % 3)
rdd: org.apache.spark.rdd.RDD[(Int, Iterable[Int])] = ShuffledRDD[2] at groupBy at <console>:24

scala> rdd.dependencies
res0: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.ShuffleDependency@655875bb)

scala> rdd.getNumPartitions
res1: Int = 8

scala> import org.apache.spark.ShuffleDependency
import org.apache.spark.ShuffleDependency

scala> val shuffleDep = rdd.dependencies(0).asInstanceOf[ShuffleDependency[Int, Int, Int]]
shuffleDep: org.apache.spark.ShuffleDependency[Int,Int,Int] = org.apache.spark.ShuffleDependency@655875bb

// mapSideCombine is disabled
scala> shuffleDep.mapSideCombine
res2: Boolean = false

// aggregator defined
scala> shuffleDep.aggregator
res3: Option[org.apache.spark.Aggregator[Int,Int,Int]] = Some(Aggregator(<function1>,<function2>,<function2>))

// spark.shuffle.sort.bypassMergeThreshold == 200
// the number of reduce partitions < spark.shuffle.sort.bypassMergeThreshold
scala> shuffleDep.partitioner.numPartitions
res4: Int = 8

scala> shuffleDep.shuffleHandle
res5: org.apache.spark.shuffle.ShuffleHandle = org.apache.spark.shuffle.sort.BypassMergeSortShuffleHandle@68893394
```
