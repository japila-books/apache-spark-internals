# BaseShuffleHandle

`BaseShuffleHandle` is a fall-back [ShuffleHandle](ShuffleHandle.md) that is used to capture the parameters when `SortShuffleManager` is requested for a [ShuffleHandle](SortShuffleManager.md#registerShuffle) (and other `ShuffleHandle`s could not be used):

* <span id="shuffleId"> Shuffle ID
* <span id="dependency"> [ShuffleDependency](../rdd/ShuffleDependency.md)

## Demo

```text
// Start a Spark application, e.g. spark-shell, with the Spark properties to trigger selection of BaseShuffleHandle:
// 1. spark.shuffle.spill.numElementsForceSpillThreshold=1
// 2. spark.shuffle.sort.bypassMergeThreshold=1

// numSlices > spark.shuffle.sort.bypassMergeThreshold
scala> val rdd = sc.parallelize(0 to 4, numSlices = 2).groupBy(_ % 2)
rdd: org.apache.spark.rdd.RDD[(Int, Iterable[Int])] = ShuffledRDD[2] at groupBy at <console>:24

scala> rdd.dependencies
DEBUG SortShuffleManager: Can't use serialized shuffle for shuffle 0 because an aggregator is defined
res0: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.ShuffleDependency@1160c54b)

scala> rdd.getNumPartitions
res1: Int = 2

scala> import org.apache.spark.ShuffleDependency
import org.apache.spark.ShuffleDependency

scala> val shuffleDep = rdd.dependencies(0).asInstanceOf[ShuffleDependency[Int, Int, Int]]
shuffleDep: org.apache.spark.ShuffleDependency[Int,Int,Int] = org.apache.spark.ShuffleDependency@1160c54b

// mapSideCombine is disabled
scala> shuffleDep.mapSideCombine
res2: Boolean = false

// aggregator defined
scala> shuffleDep.aggregator
res3: Option[org.apache.spark.Aggregator[Int,Int,Int]] = Some(Aggregator(<function1>,<function2>,<function2>))

// the number of reduce partitions < spark.shuffle.sort.bypassMergeThreshold
scala> shuffleDep.partitioner.numPartitions
res4: Int = 2

scala> shuffleDep.shuffleHandle
res5: org.apache.spark.shuffle.ShuffleHandle = org.apache.spark.shuffle.BaseShuffleHandle@22b0fe7e
```
