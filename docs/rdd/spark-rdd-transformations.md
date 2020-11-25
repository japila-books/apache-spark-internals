# Transformations -- Lazy Operations on RDD (to Create One or More RDDs)

**Transformations** are lazy operations on an rdd:RDD.md[RDD] that create one or many new RDDs.

```scala
// T and U are Scala types
transformation: RDD[T] => RDD[U]
transformation: RDD[T] => Seq[RDD[U]]
```

In other words, transformations are *functions* that take an RDD as the input and produce one or many RDDs as the output. Transformations do not change the input RDD (since rdd:index.md#introduction[RDDs are immutable] and hence cannot be modified), but produce one or more new RDDs by applying the computations they represent.

[[methods]]
.(Subset of) RDD Transformations (Public API)
[cols="1m,3",options="header",width="100%"]
|===
| Method
| Description

| aggregate
a| [[aggregate]]

[source, scala]
----
aggregate[U](zeroValue: U)(
  seqOp:  (U, T) => U,
  combOp: (U, U) => U): U
----

| barrier
a| [[barrier]]

[source, scala]
----
barrier(): RDDBarrier[T]
----

(*New in 2.4.0*) Marks the current stage as a <<spark-barrier-execution-mode.md#barrier-stage, barrier stage>> in <<spark-barrier-execution-mode.md#, Barrier Execution Mode>>, where Spark must launch all tasks together

Internally, `barrier` creates a <<spark-RDDBarrier.md#, RDDBarrier>> over the RDD

| cache
a| [[cache]]

[source, scala]
----
cache(): this.type
----

Persists the RDD with the storage:StorageLevel.md#MEMORY_ONLY[MEMORY_ONLY] storage level

Synonym of <<persist, persist>>

| coalesce
a| [[coalesce]]

[source, scala]
----
coalesce(
  numPartitions: Int,
  shuffle: Boolean = false,
  partitionCoalescer: Option[PartitionCoalescer] = Option.empty)
  (implicit ord: Ordering[T] = null): RDD[T]
----

| filter
a| [[filter]]

[source, scala]
----
filter(f: T => Boolean): RDD[T]
----

| flatMap
a| [[flatMap]]

[source, scala]
----
flatMap[U](f: T => TraversableOnce[U]): RDD[U]
----

| map
a| [[map]]

[source, scala]
----
map[U](f: T => U): RDD[U]
----

| mapPartitions
a| [[mapPartitions]]

[source, scala]
----
mapPartitions[U](
  f: Iterator[T] => Iterator[U],
  preservesPartitioning: Boolean = false): RDD[U]
----

| mapPartitionsWithIndex
a| [[mapPartitionsWithIndex]]

[source, scala]
----
mapPartitionsWithIndex[U](
  f: (Int, Iterator[T]) => Iterator[U],
  preservesPartitioning: Boolean = false): RDD[U]
----

| randomSplit
a| [[randomSplit]]

[source, scala]
----
randomSplit(
  weights: Array[Double],
  seed: Long = Utils.random.nextLong): Array[RDD[T]]
----

| union
a| [[union]]

[source, scala]
----
++(other: RDD[T]): RDD[T]
union(other: RDD[T]): RDD[T]
----

| persist
a| [[persist]]

[source, scala]
----
persist(): this.type
persist(newLevel: StorageLevel): this.type
----

|===

By applying transformations you incrementally build a spark-rdd-lineage.md[RDD lineage] with all the parent RDDs of the final RDD(s).

Transformations are lazy, i.e. are not executed immediately. Only after calling an action are transformations executed.

After executing a transformation, the result RDD(s) will always be different from their parents and can be smaller (e.g. `filter`, `count`, `distinct`, `sample`), bigger (e.g. `flatMap`, `union`, `cartesian`) or the same size (e.g. `map`).

CAUTION: There are transformations that may trigger jobs, e.g. `sortBy`, <<zipWithIndex, zipWithIndex>>, etc.

.From SparkContext by transformations to the result
image::rdd-sparkcontext-transformations-action.png[align="center"]

Certain transformations can be *pipelined* which is an optimization that Spark uses to improve performance of computations.

[source,scala]
----
scala> val file = sc.textFile("README.md")
file: org.apache.spark.rdd.RDD[String] = MapPartitionsRDD[54] at textFile at <console>:24

scala> val allWords = file.flatMap(_.split("\\W+"))
allWords: org.apache.spark.rdd.RDD[String] = MapPartitionsRDD[55] at flatMap at <console>:26

scala> val words = allWords.filter(!_.isEmpty)
words: org.apache.spark.rdd.RDD[String] = MapPartitionsRDD[56] at filter at <console>:28

scala> val pairs = words.map((_,1))
pairs: org.apache.spark.rdd.RDD[(String, Int)] = MapPartitionsRDD[57] at map at <console>:30

scala> val reducedByKey = pairs.reduceByKey(_ + _)
reducedByKey: org.apache.spark.rdd.RDD[(String, Int)] = ShuffledRDD[59] at reduceByKey at <console>:32

scala> val top10words = reducedByKey.takeOrdered(10)(Ordering[Int].reverse.on(_._2))
INFO SparkContext: Starting job: takeOrdered at <console>:34
...
INFO DAGScheduler: Job 18 finished: takeOrdered at <console>:34, took 0.074386 s
top10words: Array[(String, Int)] = Array((the,21), (to,14), (Spark,13), (for,11), (and,10), (##,8), (a,8), (run,7), (can,6), (is,6))
----

There are two kinds of transformations:

* <<narrow-transformations, narrow transformations>>
* <<wide-transformations, wide transformations>>

=== [[narrow-transformations]] Narrow Transformations

*Narrow transformations* are the result of `map`, `filter` and such that is from the data from a single partition only, i.e. it is self-sustained.

An output RDD has partitions with records that originate from a single partition in the parent RDD. Only a limited subset of partitions used to calculate the result.

Spark groups narrow transformations as a stage which is called *pipelining*.

=== [[wide-transformations]] Wide Transformations

*Wide transformations* are the result of `groupByKey` and `reduceByKey`. The data required to compute the records in a single partition may reside in many partitions of the parent RDD.

NOTE: Wide transformations are also called shuffle transformations as they may or may not depend on a shuffle.

All of the tuples with the same key must end up in the same partition, processed by the same task. To satisfy these operations, Spark must execute spark-rdd-shuffle.md[RDD shuffle], which transfers data across cluster and results in a new stage with a new set of partitions.

=== [[zipWithIndex]] zipWithIndex

[source, scala]
----
zipWithIndex(): RDD[(T, Long)]
----

`zipWithIndex` zips this `RDD[T]` with its element indices.

[CAUTION]
====
If the number of partitions of the source RDD is greater than 1, it will submit an additional job to calculate start indices.

[source, scala]
----
val onePartition = sc.parallelize(0 to 9, 1)

scala> onePartition.partitions.length
res0: Int = 1

// no job submitted
onePartition.zipWithIndex

val eightPartitions = sc.parallelize(0 to 9, 8)

scala> eightPartitions.partitions.length
res1: Int = 8

// submits a job
eightPartitions.zipWithIndex
----

.Spark job submitted by zipWithIndex transformation
image::spark-transformations-zipWithIndex-webui.png[align="center"]
====
