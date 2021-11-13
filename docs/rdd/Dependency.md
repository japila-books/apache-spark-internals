---
tags:
  - DeveloperApi
---

# Dependency

`Dependency[T]` is an [abstraction](#contract) of [dependencies](#implementations) between `RDD`s.

Any time an RDD transformation (e.g. `map`, `flatMap`) is used (and [RDD lineage graph](lineage.md) is built), `Dependency`ies are the edges.

## Contract

### <span id="rdd"> RDD

```scala
rdd: RDD[T]
```

Used when:

* `DAGScheduler` is requested for the [shuffle dependencies and ResourceProfiles](../scheduler/DAGScheduler.md#getShuffleDependenciesAndResourceProfiles) (of an `RDD`)
* `RDD` is requested to [getNarrowAncestors](RDD.md#getNarrowAncestors), [cleanShuffleDependencies](RDD.md#cleanShuffleDependencies), [firstParent](RDD.md#firstParent), [parent](RDD.md#parent), [toDebugString](RDD.md#toDebugString), [getOutputDeterministicLevel](RDD.md#getOutputDeterministicLevel)

## Implementations

* [NarrowDependency](NarrowDependency.md)
* [ShuffleDependency](ShuffleDependency.md)

## Demo

The dependencies of an `RDD` are available using `RDD.dependencies` method.

```scala
val myRdd = sc.parallelize(0 to 9).groupBy(_ % 2)
```

```text
scala> myRdd.dependencies.foreach(println)
org.apache.spark.ShuffleDependency@41e38d89
```

```text
scala> myRdd.dependencies.map(_.rdd).foreach(println)
MapPartitionsRDD[6] at groupBy at <console>:39
```

[RDD.toDebugString](RDD.md#toDebugString) is used to print out the RDD lineage in a developer-friendly way.

```text
scala> println(myRdd.toDebugString)
(16) ShuffledRDD[7] at groupBy at <console>:39 []
 +-(16) MapPartitionsRDD[6] at groupBy at <console>:39 []
    |   ParallelCollectionRDD[5] at parallelize at <console>:39 []
```
