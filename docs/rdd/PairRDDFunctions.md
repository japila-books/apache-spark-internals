# PairRDDFunctions

`PairRDDFunctions` is an extension of [RDD](RDD.md) API for extra methods for key-value RDDs (`RDD[(K, V)]`).

`PairRDDFunctions` is available in RDDs of key-value pairs via Scala implicit conversion.

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

## <span id="reduceByKey"><span id="groupByKey"> groupByKey and reduceByKey

```scala
reduceByKey(
  func: (V, V) => V): RDD[(K, V)]
reduceByKey(
  func: (V, V) => V,
  numPartitions: Int): RDD[(K, V)]
reduceByKey(
  partitioner: Partitioner,
  func: (V, V) => V): RDD[(K, V)]
```

`reduceByKey` is sort of a particular case of [aggregateByKey](#aggregateByKey).

You may want to look at the number of partitions from another angle.

It may often not be important to have a given number of partitions upfront (at RDD creation time upon spark-data-sources.md[loading data from data sources]), so only "regrouping" the data by key after it is an RDD might be...the key (_pun not intended_).

You can use `groupByKey` or another `PairRDDFunctions` method to have a key in one processing flow.

```scala
groupByKey(): RDD[(K, Iterable[V])]
groupByKey(
  numPartitions: Int): RDD[(K, Iterable[V])]
groupByKey(
  partitioner: Partitioner): RDD[(K, Iterable[V])]
```

You could use `partitionBy` that is available for RDDs to be RDDs of tuples, i.e. `PairRDD`:

```scala
rdd.keyBy(_.kind)
  .partitionBy(new HashPartitioner(PARTITIONS))
  .foreachPartition(...)
```

Think of situations where `kind` has low cardinality or highly skewed distribution and using the technique for partitioning might be not an optimal solution.

You could do as follows:

```scala
rdd.keyBy(_.kind).reduceByKey(....)
```

or `mapValues` or plenty of other solutions. _FIXME_

## <span id="combineByKeyWithClassTag"> combineByKeyWithClassTag

```scala
combineByKeyWithClassTag[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C)(implicit ct: ClassTag[C]): RDD[(K, C)] // <1>
combineByKeyWithClassTag[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C,
  numPartitions: Int)(implicit ct: ClassTag[C]): RDD[(K, C)] // <2>
combineByKeyWithClassTag[C](
  createCombiner: V => C,
  mergeValue: (C, V) => C,
  mergeCombiners: (C, C) => C,
  partitioner: Partitioner,
  mapSideCombine: Boolean = true,
  serializer: Serializer = null)(implicit ct: ClassTag[C]): RDD[(K, C)]
```

`combineByKeyWithClassTag` creates an [Aggregator](Aggregator.md) for the given aggregation functions.

`combineByKeyWithClassTag` branches off per the given [Partitioner](Partitioner.md).

If the input partitioner and the RDD's are the same, `combineByKeyWithClassTag` simply [mapPartitions](spark-rdd-transformations.md#mapPartitions) on the RDD with the following arguments:

* Iterator of the [Aggregator](Aggregator.md#combineValuesByKey)

* `preservesPartitioning` flag turned on

If the input partitioner is different than the RDD's, `combineByKeyWithClassTag` creates a [ShuffledRDD](ShuffledRDD.md) (with the `Serializer`, the `Aggregator`, and the `mapSideCombine` flag).

### <span id="combineByKeyWithClassTag-usage"> Usage

`combineByKeyWithClassTag` lays the foundation for the following transformations:

* aggregateByKey
* combineByKey
* countApproxDistinctByKey
* foldByKey
* groupByKey
* reduceByKey

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
