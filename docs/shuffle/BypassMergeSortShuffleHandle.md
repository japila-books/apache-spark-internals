# BypassMergeSortShuffleHandle

`BypassMergeSortShuffleHandle` is a [BaseShuffleHandle](BaseShuffleHandle.md) that `SortShuffleManager` uses when [can avoid merge-sorting data](SortShuffleWriter.md#shouldBypassMergeSort) (when requested to [register a shuffle](SortShuffleManager.md#registerShuffle)).

`SerializedShuffleHandle` tells `SortShuffleManager` to use [BypassMergeSortShuffleWriter](BypassMergeSortShuffleWriter.md) when requested for a [ShuffleWriter](SortShuffleManager.md#getWriter).

## Creating Instance

`BypassMergeSortShuffleHandle` takes the following to be created:

* <span id="shuffleId"> Shuffle ID
* <span id="dependency"> [ShuffleDependency](../rdd/ShuffleDependency.md)

`BypassMergeSortShuffleHandle` is created when:

* `SortShuffleManager` is requested for a [ShuffleHandle](SortShuffleManager.md#registerShuffle) (for the [ShuffleDependency](#dependency))

## Demo

```scala
val rdd = sc.parallelize(0 to 8).groupBy(_ % 3)

assert(rdd.dependencies.length == 1)

import org.apache.spark.ShuffleDependency
val shuffleDep = rdd.dependencies.head.asInstanceOf[ShuffleDependency[Int, Int, Int]]

assert(shuffleDep.mapSideCombine == false, "mapSideCombine should be disabled")
assert(shuffleDep.aggregator.isDefined)
```

```scala
// Use ':paste -raw' mode to paste the code
package org.apache.spark
object open {
  import org.apache.spark.SparkContext
  def bypassMergeThreshold(sc: SparkContext) = {
    import org.apache.spark.internal.config.SHUFFLE_SORT_BYPASS_MERGE_THRESHOLD
    sc.getConf.get(SHUFFLE_SORT_BYPASS_MERGE_THRESHOLD)
  }
}
```

```scala
import org.apache.spark.open
val bypassMergeThreshold = open.bypassMergeThreshold(sc)

assert(shuffleDep.partitioner.numPartitions < bypassMergeThreshold)
```

```scala
import org.apache.spark.shuffle.sort.BypassMergeSortShuffleHandle
// BypassMergeSortShuffleHandle is private[spark]
// so the following won't work :(
// assert(shuffleDep.shuffleHandle.isInstanceOf[BypassMergeSortShuffleHandle[Int, Int]])
assert(shuffleDep.shuffleHandle.toString.contains("BypassMergeSortShuffleHandle"))
```
