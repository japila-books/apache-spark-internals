# Aggregator

`Aggregator` is a set of <<aggregation-functions, aggregation functions>> used to aggregate data using rdd:PairRDDFunctions.md#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] transformation.

`Aggregator[K, V, C]` is a parameterized type of `K` keys, `V` values, and `C` combiner (partial) values.

[[creating-instance]][[aggregation-functions]]
Aggregator transforms an `RDD[(K, V)]` into an `RDD[(K, C)]` (for a "combined type" C) using the functions:

* [[createCombiner]] `createCombiner: V => C`
* [[mergeValue]] `mergeValue: (C, V) => C`
* [[mergeCombiners]] `mergeCombiners: (C, C) => C`

Aggregator is used to create a [ShuffleDependency](ShuffleDependency.md) and [ExternalSorter](../shuffle/ExternalSorter.md).

== [[combineValuesByKey]] combineValuesByKey Method

[source, scala]
----
combineValuesByKey(
  iter: Iterator[_ <: Product2[K, V]],
  context: TaskContext): Iterator[(K, C)]
----

combineValuesByKey creates a new shuffle:ExternalAppendOnlyMap.md[ExternalAppendOnlyMap] (with the <<aggregation-functions, aggregation functions>>).

combineValuesByKey requests the ExternalAppendOnlyMap to shuffle:ExternalAppendOnlyMap.md#insertAll[insert all key-value pairs] from the given iterator (that is the values of a partition).

combineValuesByKey <<updateMetrics, updates the task metrics>>.

In the end, combineValuesByKey requests the ExternalAppendOnlyMap for an shuffle:ExternalAppendOnlyMap.md#iterator[iterator of "combined" pairs].

combineValuesByKey is used when:

* rdd:PairRDDFunctions.md#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] transformation is used (with the same Partitioner as the RDD's)

* BlockStoreShuffleReader is requested to shuffle:BlockStoreShuffleReader.md#read[read combined records for a reduce task] (with the [Map-Size Partial Aggregation Flag](ShuffleDependency.md#mapSideCombine) off)

== [[combineCombinersByKey]] combineCombinersByKey Method

[source, scala]
----
combineCombinersByKey(
  iter: Iterator[_ <: Product2[K, C]],
  context: TaskContext): Iterator[(K, C)]
----

combineCombinersByKey...FIXME

combineCombinersByKey is used when BlockStoreShuffleReader is requested to shuffle:BlockStoreShuffleReader.md#read[read combined records for a reduce task] (with the [Map-Size Partial Aggregation Flag](ShuffleDependency.md#mapSideCombine) on).

== [[updateMetrics]] Updating Task Metrics

[source, scala]
----
updateMetrics(
  context: TaskContext,
  map: ExternalAppendOnlyMap[_, _, _]): Unit
----

updateMetrics requests the input [TaskContext](../scheduler/TaskContext.md) for the [TaskMetrics](../scheduler/TaskContext.md#taskMetrics) to update the metrics based on the metrics of the input [ExternalAppendOnlyMap](../shuffle/ExternalAppendOnlyMap.md):

* executor:TaskMetrics.md#incMemoryBytesSpilled[Increment memory bytes spilled]

* executor:TaskMetrics.md#incDiskBytesSpilled[Increment disk bytes spilled]

* executor:TaskMetrics.md#incPeakExecutionMemory[Increment peak execution memory]

updateMetrics is used when Aggregator is requested to <<combineValuesByKey, combineValuesByKey>> and <<combineCombinersByKey, combineCombinersByKey>>.
