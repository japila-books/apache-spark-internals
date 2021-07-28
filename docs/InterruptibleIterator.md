== [[InterruptibleIterator]] InterruptibleIterator -- Iterator With Support For Task Cancellation

`InterruptibleIterator` is a custom Scala https://www.scala-lang.org/api/2.11.x/index.html#scala.collection.Iterator[Iterator] that supports task cancellation, i.e. <<hasNext, stops iteration when a task was interrupted (cancelled)>>.

Quoting the official Scala https://www.scala-lang.org/api/2.11.x/index.html#scala.collection.Iterator[Iterator] documentation:

> *Iterators* are data structures that allow to iterate over a sequence of elements. They have a `hasNext` method for checking if there is a next element available, and a `next` method which returns the next element and discards it from the iterator.

`InterruptibleIterator` is <<creating-instance, created>> when:

* `RDD` is requested to rdd:RDD.md#getOrCompute[get or compute a RDD partition]

* [CoGroupedRDD](rdd/CoGroupedRDD.md#compute), rdd:HadoopRDD.md#compute[HadoopRDD], rdd:NewHadoopRDD.md#compute[NewHadoopRDD], rdd:ParallelCollectionRDD.md#compute[ParallelCollectionRDD] are requested to `compute` a partition

* `BlockStoreShuffleReader` is requested to shuffle:BlockStoreShuffleReader.md#read[read combined key-value records for a reduce task]

* `PairRDDFunctions` is requested to rdd:PairRDDFunctions.md#combineByKeyWithClassTag[combineByKeyWithClassTag]

* Spark SQL's `DataSourceRDD` and `JDBCRDD` are requested to `compute` a partition

* Spark SQL's `RangeExec` physical operator is requested to `doExecute`

* PySpark's `BasePythonRunner` is requested to `compute`

[[creating-instance]]
`InterruptibleIterator` takes the following when created:

* [[context]] [TaskContext](scheduler/TaskContext.md)
* [[delegate]] Scala `Iterator[T]`

NOTE: `InterruptibleIterator` is a Developer API which is a lower-level, unstable API intended for Spark developers that may change or be removed in minor versions of Apache Spark.

=== [[hasNext]] `hasNext` Method

[source, scala]
----
hasNext: Boolean
----

NOTE: `hasNext` is part of ++https://www.scala-lang.org/api/2.11.x/index.html#scala.collection.Iterator@hasNext:Boolean++[Iterator Contract] to test whether this iterator can provide another element.

`hasNext` requests the <<context, TaskContext>> to [kill the task if interrupted](scheduler/TaskContext.md#killTaskIfInterrupted) (that simply throws a `TaskKilledException` that in turn breaks the task execution).

In the end, `hasNext` requests the <<delegate, delegate Iterator>> to `hasNext`.

=== [[next]] `next` Method

[source, scala]
----
next(): T
----

NOTE: `next` is part of ++https://www.scala-lang.org/api/2.11.x/index.html#scala.collection.Iterator@next():A++[Iterator Contract] to produce the next element of this iterator.

`next` simply requests the <<delegate, delegate Iterator>> to `next`.
