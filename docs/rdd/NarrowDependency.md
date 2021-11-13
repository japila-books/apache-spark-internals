---
tags:
  - DeveloperApi
---

# NarrowDependency

`NarrowDependency[T]` is an [extension](#contract) of the [Dependency](Dependency.md) abstraction for [narrow dependencies](#implementations) (of [RDD[T]](#rdd)s) where [each partition of the child RDD depends on a small number of partitions of the parent RDD](#getParents).

## Contract

### <span id="getParents"> getParents

```scala
getParents(
  partitionId: Int): Seq[Int]
```

The parent partitions for a given child partition

Used when:

* `DAGScheduler` is requested for the [preferred locations](../scheduler/DAGScheduler.md#getPreferredLocsInternal) (of a partition of an `RDD`)

## Implementations

### <span id="OneToOneDependency"> OneToOneDependency

`OneToOneDependency` is a `NarrowDependency` with [getParents](#getParents) returning a single-element collection with the given `partitionId`.

```text
val myRdd = sc.parallelize(0 to 9).map((_, 1))

scala> :type myRdd
org.apache.spark.rdd.RDD[(Int, Int)]

scala> myRdd.dependencies.foreach(println)
org.apache.spark.OneToOneDependency@801fe56

import org.apache.spark.OneToOneDependency
val dep = myRdd.dependencies.head.asInstanceOf[OneToOneDependency[(_, _)]]

scala> println(dep.getParents(0))
List(0)

scala> println(dep.getParents(1))
List(1)
```

### <span id="PruneDependency"> PruneDependency

`PruneDependency` is a `NarrowDependency` that represents a dependency between the `PartitionPruningRDD` and the parent RDD (with a subset of partitions of the parents).

### <span id="RangeDependency"> RangeDependency

`RangeDependency` is a `NarrowDependency` that represents a one-to-one dependency between ranges of partitions in the parent and child RDDs.

Used in `UnionRDD` (`SparkContext.union`).

```text
val r1 = sc.range(0, 4)
val r2 = sc.range(5, 9)

val unioned = sc.union(r1, r2)

scala> unioned.dependencies.foreach(println)
org.apache.spark.RangeDependency@76b0e1d9
org.apache.spark.RangeDependency@3f3e51e0

import org.apache.spark.RangeDependency
val dep = unioned.dependencies.head.asInstanceOf[RangeDependency[(_, _)]]

scala> println(dep.getParents(0))
List(0)
```

## Creating Instance

`NarrowDependency` takes the following to be created:

* <span id="_rdd"><span id="rdd"> [RDD[T]](RDD.md)

!!! note "Abstract Class"
    `NarrowDependency` is an abstract class and cannot be created directly. It is created indirectly for the [concrete NarrowDependencies](#implementations).
