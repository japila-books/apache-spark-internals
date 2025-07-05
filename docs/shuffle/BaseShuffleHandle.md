# BaseShuffleHandle

`BaseShuffleHandle` is a [ShuffleHandle](ShuffleHandle.md) that is used to capture the parameters when `SortShuffleManager` is requested for a [ShuffleHandle](SortShuffleManager.md#registerShuffle) (and the other specialized [ShuffleHandles](#extensions) could not be selected):

* <span id="shuffleId"> Shuffle ID
* <span id="dependency"> [ShuffleDependency](../rdd/ShuffleDependency.md)

## Extensions

* [BypassMergeSortShuffleHandle](BypassMergeSortShuffleHandle.md)
* [SerializedShuffleHandle](SerializedShuffleHandle.md)

## Demo

Start a Spark application (e.g., spark-shell) with the following Spark properties to trigger selection of `BaseShuffleHandle`:

* `spark.shuffle.spill.numElementsForceSpillThreshold=1`
* `spark.shuffle.sort.bypassMergeThreshold=1`

```bash
./bin/spark-shell \
    --conf spark.shuffle.spill.numElementsForceSpillThreshold=1 \
    --conf spark.shuffle.sort.bypassMergeThreshold=1
```

Create an RDD with the number of partitions (`numSlices`) greater than the value of [spark.shuffle.sort.bypassMergeThreshold](../configuration-properties.md#spark.shuffle.sort.bypassMergeThreshold) configuration property.

```scala
val rdd = sc.parallelize(0 to 4, numSlices = 2).groupBy(_ % 2)
```

```scala
assert(rdd.getNumPartitions == 2)
```

```text
scala> rdd.dependencies
DEBUG SortShuffleManager: Can't use serialized shuffle for shuffle 0 because an aggregator is defined
res0: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.ShuffleDependency@1160c54b)
```

```scala
import org.apache.spark.ShuffleDependency
val shuffleDep = rdd.dependencies(0).asInstanceOf[ShuffleDependency[Int, Int, Int]]
```

```scala
// mapSideCombine is disabled
assert(shuffleDep.mapSideCombine == false)
```

```scala
// aggregator defined
assert(shuffleDep.aggregator.isDefined)
```

```text
scala> shuffleDep.aggregator.get.getClass
val res11: Class[_ <: org.apache.spark.Aggregator[Int,Int,Int]] = class org.apache.spark.Aggregator
```

Note the number of reduce partitions that is smaller than [spark.shuffle.sort.bypassMergeThreshold](../configuration-properties.md#spark.shuffle.sort.bypassMergeThreshold) configuration property.

```scala
assert(shuffleDep.partitioner.numPartitions == 2)
```

```text
scala> print(shuffleDep.shuffleHandle)
org.apache.spark.shuffle.sort.SerializedShuffleHandle@2b648069
```
