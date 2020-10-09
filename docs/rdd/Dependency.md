# RDD Dependencies

`Dependency` class is the base (abstract) class to model a dependency relationship between two or more RDDs.

[[rdd]]
`Dependency` has a single method `rdd` to access the RDD that is behind a dependency.

[source, scala]
----
def rdd: RDD[T]
----

Whenever you apply a spark-rdd-transformations.md[transformation] (e.g. `map`, `flatMap`) to a RDD you build the so-called spark-rdd-lineage.md[RDD lineage graph]. ``Dependency``-ies represent the edges in a lineage graph.

NOTE: [NarrowDependency](NarrowDependency.md) and [ShuffleDependency](ShuffleDependency.md) are the two top-level subclasses of `Dependency` abstract class.

.Kinds of Dependencies
[cols="1,2",options="header",width="100%"]
|===
| Name | Description
| [NarrowDependency](NarrowDependency.md) |
| [ShuffleDependency](ShuffleDependency.md) |
| [OneToOneDependency](NarrowDependency.md#OneToOneDependency) |
| [PruneDependency](NarrowDependency.md#PruneDependency) |
| [RangeDependency](NarrowDependency.md#RangeDependency) |
|===

[NOTE]
====
The dependencies of a RDD are available using rdd:index.md#dependencies[dependencies] method.

```
// A demo RDD
scala> val myRdd = sc.parallelize(0 to 9).groupBy(_ % 2)
myRdd: org.apache.spark.rdd.RDD[(Int, Iterable[Int])] = ShuffledRDD[8] at groupBy at <console>:24

scala> myRdd.foreach(println)
(0,CompactBuffer(0, 2, 4, 6, 8))
(1,CompactBuffer(1, 3, 5, 7, 9))

scala> myRdd.dependencies
res5: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.ShuffleDependency@27ace619)

// Access all RDDs in the demo RDD lineage
scala> myRdd.dependencies.map(_.rdd).foreach(println)
MapPartitionsRDD[7] at groupBy at <console>:24
```

You use spark-rdd-lineage.md#toDebugString[toDebugString] method to print out the RDD lineage in a user-friendly way.

```
scala> myRdd.toDebugString
res6: String =
(8) ShuffledRDD[8] at groupBy at <console>:24 []
 +-(8) MapPartitionsRDD[7] at groupBy at <console>:24 []
    |  ParallelCollectionRDD[6] at parallelize at <console>:24 []
```
====
