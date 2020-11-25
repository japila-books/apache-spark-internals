# OrderedRDDFunctions

```scala
class OrderedRDDFunctions[
  K: Ordering : ClassTag,
  V: ClassTag,
  P <: Product2[K, V] : ClassTag]
```

`OrderedRDDFunctions` adds extra operators to RDDs of (key, value) pairs (`RDD[(K, V)]`) where the `K` key is sortable (i.e. any key type `K` that has an implicit `Ordering[K]` in scope).

!!! tip
    Learn more about [Ordering]({{ scala.api }}/scala/math/Ordering.html) in the [Scala Standard Library]({{ scala.api }}/) documentation.

## Creating Instance

`OrderedRDDFunctions` takes the following to be created:

* <span id="self"> [RDD](RDD.md) of `P`s

`OrderedRDDFunctions` is created using [RDD.rddToOrderedRDDFunctions](RDD.md#rddToOrderedRDDFunctions) implicit method.

## <span id="filterByRange"> filterByRange

```scala
filterByRange(
  lower: K,
  upper: K): RDD[P]
```

`filterByRange`...FIXME

## <span id="repartitionAndSortWithinPartitions"> repartitionAndSortWithinPartitions

```scala
repartitionAndSortWithinPartitions(
  partitioner: Partitioner): RDD[(K, V)]
```

`repartitionAndSortWithinPartitions` creates a [ShuffledRDD](ShuffledRDD.md) with the given [Partitioner](Partitioner.md).

!!! note
    `repartitionAndSortWithinPartitions` is a generalization of [sortByKey](#sortByKey) operator.

`repartitionAndSortWithinPartitions` is used when...FIXME

## <span id="sortByKey"> sortByKey

```scala
sortByKey(
  ascending: Boolean = true,
  numPartitions: Int = self.partitions.length): RDD[(K, V)]
```

`sortByKey` creates a [ShuffledRDD](ShuffledRDD.md) (with the [RDD](#self) and a [RangePartitioner](RangePartitioner.md)).

!!! note
    `sortByKey` is a specialization of [repartitionAndSortWithinPartitions](#repartitionAndSortWithinPartitions) operator.

!!! note
    Spark uses `sortByKey` for [RDD.sortBy](spark-rdd-transformations.md#sortBy) operator.
