# PairRDDFunctions

`PairRDDFunctions` is an extension of [RDD](RDD.md) API for additional high-level operators to work with key-value RDDs (`RDD[(K, V)]`).

`PairRDDFunctions` is available in RDDs of key-value pairs via Scala implicit conversion.

The gist of `PairRDDFunctions` is [combineByKeyWithClassTag](#combineByKeyWithClassTag).

## <span id="aggregateByKey"> aggregateByKey

```scala
aggregateByKey[U: ClassTag](
  zeroValue: U)(
  seqOp: (U, V) => U,
  combOp: (U, U) => U): RDD[(K, U)] // (1)!
aggregateByKey[U: ClassTag](
  zeroValue: U,
  numPartitions: Int)(seqOp: (U, V) => U,
  combOp: (U, U) => U): RDD[(K, U)] // (2)!
aggregateByKey[U: ClassTag](
  zeroValue: U,
  partitioner: Partitioner)(
  seqOp: (U, V) => U,
  combOp: (U, U) => U): RDD[(K, U)]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Creates a [HashPartitioner](HashPartitioner.md) with the given `numPartitions` partitions

`aggregateByKey`...FIXME

## <span id="combineByKey"> combineByKey

```scala
combineByKey[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C): RDD[(K, C)]
combineByKey[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C,
  numPartitions: Int): RDD[(K, C)]
combineByKey[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C,
  partitioner: Partitioner,
  mapSideCombine: Boolean = true,
  serializer: Serializer = null): RDD[(K, C)]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Creates a [HashPartitioner](HashPartitioner.md) with the given `numPartitions` partitions

`combineByKey`...FIXME

## <span id="combineByKeyWithClassTag"> combineByKeyWithClassTag

```scala
combineByKeyWithClassTag[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C)(implicit ct: ClassTag[C]): RDD[(K, C)] // (1)!
combineByKeyWithClassTag[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C,
  numPartitions: Int)(implicit ct: ClassTag[C]): RDD[(K, C)] // (2)!
combineByKeyWithClassTag[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C,
  partitioner: Partitioner,
  mapSideCombine: Boolean = true,
  serializer: Serializer = null)(implicit ct: ClassTag[C]): RDD[(K, C)]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Uses a [HashPartitioner](HashPartitioner.md) (with the given `numPartitions`)

`combineByKeyWithClassTag` creates an [Aggregator](Aggregator.md) for the given aggregation functions.

`combineByKeyWithClassTag` branches off per the given [Partitioner](Partitioner.md).

If the input partitioner and the RDD's are the same, `combineByKeyWithClassTag` simply [mapPartitions](spark-rdd-transformations.md#mapPartitions) on the RDD with the following arguments:

* Iterator of the [Aggregator](Aggregator.md#combineValuesByKey)

* `preservesPartitioning` flag turned on

If the input partitioner is different than the RDD's, `combineByKeyWithClassTag` creates a [ShuffledRDD](ShuffledRDD.md) (with the `Serializer`, the `Aggregator`, and the `mapSideCombine` flag).

### <span id="combineByKeyWithClassTag-usage"> Usage

`combineByKeyWithClassTag` lays the foundation for the following high-level RDD key-value pair transformations:

* [aggregateByKey](#aggregateByKey)
* [combineByKey](#combineByKey)
* [countApproxDistinctByKey](#countApproxDistinctByKey)
* [foldByKey](#foldByKey)
* [groupByKey](#groupByKey)
* [reduceByKey](#reduceByKey)

### <span id="combineByKeyWithClassTag-requirements"> Requirements

`combineByKeyWithClassTag` requires that the `mergeCombiners` is defined (not-``null``) or throws an `IllegalArgumentException`:

```text
mergeCombiners must be defined
```

`combineByKeyWithClassTag` throws a `SparkException` for the keys being of type array with the `mapSideCombine` flag enabled:

```text
Cannot use map-side combining with array keys.
```

`combineByKeyWithClassTag` throws a `SparkException` for the keys being of type `array` with the partitioner being a [HashPartitioner](HashPartitioner.md):

```text
HashPartitioner cannot partition array keys.
```

### <span id="combineByKeyWithClassTag-example"> Example

```text
val nums = sc.parallelize(0 to 9, numSlices = 4)
val groups = nums.keyBy(_ % 2)
def createCombiner(n: Int) = {
  println(s"createCombiner($n)")
  n
}
def mergeValue(n1: Int, n2: Int) = {
  println(s"mergeValue($n1, $n2)")
  n1 + n2
}
def mergeCombiners(c1: Int, c2: Int) = {
  println(s"mergeCombiners($c1, $c2)")
  c1 + c2
}
val countByGroup = groups.combineByKeyWithClassTag(
  createCombiner,
  mergeValue,
  mergeCombiners)
println(countByGroup.toDebugString)
/*
(4) ShuffledRDD[3] at combineByKeyWithClassTag at <console>:31 []
 +-(4) MapPartitionsRDD[1] at keyBy at <console>:25 []
    |  ParallelCollectionRDD[0] at parallelize at <console>:24 []
*/
```

## <span id="countApproxDistinctByKey"> countApproxDistinctByKey

```scala
countApproxDistinctByKey(
  relativeSD: Double = 0.05): RDD[(K, Long)] // (1)!
countApproxDistinctByKey(
  relativeSD: Double,
  numPartitions: Int): RDD[(K, Long)] // (2)!
countApproxDistinctByKey(
  relativeSD: Double,
  partitioner: Partitioner): RDD[(K, Long)]
countApproxDistinctByKey(
  p: Int,
  sp: Int,
  partitioner: Partitioner): RDD[(K, Long)]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Creates a [HashPartitioner](HashPartitioner.md) with the given `numPartitions` partitions

`countApproxDistinctByKey`...FIXME

## <span id="foldByKey"> foldByKey

```scala
foldByKey(
  zeroValue: V)(
  func: (V, V) => V): RDD[(K, V)] // (1)!
foldByKey(
  zeroValue: V,
  numPartitions: Int)(
  func: (V, V) => V): RDD[(K, V)] // (2)!
foldByKey(
  zeroValue: V,
  partitioner: Partitioner)(
  func: (V, V) => V): RDD[(K, V)]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Creates a [HashPartitioner](HashPartitioner.md) with the given `numPartitions` partitions

`foldByKey`...FIXME

---

`foldByKey` is used when:

* [RDD.treeAggregate](RDD.md#treeAggregate) high-level operator is used

## <span id="groupByKey"> groupByKey

```scala
groupByKey(): RDD[(K, Iterable[V])] // (1)!
groupByKey(
  numPartitions: Int): RDD[(K, Iterable[V])] // (2)!
groupByKey(
  partitioner: Partitioner): RDD[(K, Iterable[V])]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Creates a [HashPartitioner](HashPartitioner.md) with the given `numPartitions` partitions

`groupByKey`...FIXME

---

`groupByKey` is used when:

* [RDD.groupBy](RDD.md#groupBy) high-level operator is used

## <span id="partitionBy"> partitionBy

```scala
partitionBy(
  partitioner: Partitioner): RDD[(K, V)]
```

`partitionBy`...FIXME

## <span id="reduceByKey"> reduceByKey

```scala
reduceByKey(
  func: (V, V) => V): RDD[(K, V)] // (1)!
reduceByKey(
  func: (V, V) => V,
  numPartitions: Int): RDD[(K, V)] // (2)!
reduceByKey(
  partitioner: Partitioner,
  func: (V, V) => V): RDD[(K, V)]
```

1. Uses the [default Partitioner](Partitioner.md#defaultPartitioner)
2. Creates a [HashPartitioner](HashPartitioner.md) with the given `numPartitions` partitions

`reduceByKey` is sort of a particular case of [aggregateByKey](#aggregateByKey).

---

`reduceByKey` is used when:

* [RDD.distinct](RDD.md#distinct) high-level operator is used

## <span id="saveAsNewAPIHadoopFile"> saveAsNewAPIHadoopFile

```scala
saveAsNewAPIHadoopFile(
  path: String,
  keyClass: Class[_],
  valueClass: Class[_],
  outputFormatClass: Class[_ <: NewOutputFormat[_, _]],
  conf: Configuration = self.context.hadoopConfiguration): Unit
saveAsNewAPIHadoopFile[F <: NewOutputFormat[K, V]](
  path: String)(implicit fm: ClassTag[F]): Unit
```

`saveAsNewAPIHadoopFile` creates a new `Job` ([Hadoop MapReduce]({{ hadoop.api }}/org/apache/hadoop/mapreduce/Job.html)) for the given `Configuration` ([Hadoop]({{ hadoop.api }}/org/apache/hadoop/conf/Configuration.html)).

`saveAsNewAPIHadoopFile` configures the `Job` (with the given `keyClass`, `valueClass` and `outputFormatClass`).

`saveAsNewAPIHadoopFile` sets `mapreduce.output.fileoutputformat.outputdir` configuration property to be the given `path` and [saveAsNewAPIHadoopDataset](#saveAsNewAPIHadoopDataset).

## <span id="saveAsNewAPIHadoopDataset"> saveAsNewAPIHadoopDataset

```scala
saveAsNewAPIHadoopDataset(
  conf: Configuration): Unit
```

`saveAsNewAPIHadoopDataset` creates a new [HadoopMapReduceWriteConfigUtil](../HadoopMapReduceWriteConfigUtil.md) (with the given `Configuration`) and [writes the RDD out](../SparkHadoopWriter.md#write).

`Configuration` should have all the relevant output params set (an [output format]({{ hadoop.api }}/org/apache/hadoop/mapreduce/OutputFormat.html), output paths, e.g. a table name to write to) in the same way as it would be configured for a Hadoop MapReduce job.
