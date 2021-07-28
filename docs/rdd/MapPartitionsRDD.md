# MapPartitionsRDD

`MapPartitionsRDD` is an [RDD](RDD.md) that has exactly [one-to-one narrow dependency](NarrowDependency.md#OneToOneDependency) on the <<prev, parent RDD>> and "describes" a distributed computation of the given <<f, function>> to every RDD partition.

`MapPartitionsRDD` is <<creating-instance, created>> when:

* `PairRDDFunctions` (`RDD[(K, V)]`) is requested to rdd:PairRDDFunctions.md#mapValues[mapValues] and rdd:PairRDDFunctions.md#flatMapValues[flatMapValues] (with the <<preservesPartitioning, preservesPartitioning>> flag enabled)

* `RDD[T]` is requested to <<spark-rdd-transformations.md#map, map>>, <<spark-rdd-transformations.md#flatMap, flatMap>>, <<spark-rdd-transformations.md#filter, filter>>, <<spark-rdd-transformations.md#glom, glom>>, <<spark-rdd-transformations.md#mapPartitions, mapPartitions>>, <<spark-rdd-transformations.md#mapPartitionsWithIndexInternal, mapPartitionsWithIndexInternal>>, <<spark-rdd-transformations.md#mapPartitionsInternal, mapPartitionsInternal>>, and <<spark-rdd-transformations.md#mapPartitionsWithIndex, mapPartitionsWithIndex>>

* `RDDBarrier[T]` is requested to <<spark-RDDBarrier.md#mapPartitions, mapPartitions>> (with the <<isFromBarrier, isFromBarrier>> flag enabled)

By default, it does not preserve partitioning -- the last input parameter `preservesPartitioning` is `false`. If it is `true`, it retains the original RDD's partitioning.

`MapPartitionsRDD` is the result of the following transformations:

* `filter`
* `glom`
* spark-rdd-transformations.md#mapPartitions[mapPartitions]
* `mapPartitionsWithIndex`
* rdd:PairRDDFunctions.md#mapValues[PairRDDFunctions.mapValues]
* rdd:PairRDDFunctions.md#flatMapValues[PairRDDFunctions.flatMapValues]

[[isBarrier_]]
When requested for the rdd:RDD.md#isBarrier_[isBarrier_] flag, `MapPartitionsRDD` gives the <<isFromBarrier, isFromBarrier>> flag or check whether any of the RDDs of the rdd:RDD.md#dependencies[RDD dependencies] are rdd:RDD.md#isBarrier[barrier-enabled].

=== [[creating-instance]] Creating MapPartitionsRDD Instance

`MapPartitionsRDD` takes the following to be created:

* [[prev]] Parent rdd:RDD.md[RDD] (`RDD[T]`)
* [[f]] Function to execute on partitions
+
```
(TaskContext, partitionID, Iterator[T]) => Iterator[U]
```
* [[preservesPartitioning]] `preservesPartitioning` flag (default: `false`)
* [[isFromBarrier]] `isFromBarrier` flag for <<spark-barrier-execution-mode.md#, Barrier Execution Mode>> (default: `false`)
* [[isOrderSensitive]] `isOrderSensitive` flag (default: `false`)
