= [[Aggregator]] Aggregator

*Aggregator* is a set of <<aggregation-functions, aggregation functions>> used to aggregate data using xref:rdd:PairRDDFunctions.adoc#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] transformation.

`Aggregator[K, V, C]` is a parameterized type of `K` keys, `V` values, and `C` combiner (partial) values.

[[creating-instance]][[aggregation-functions]]
Aggregator transforms an `RDD[(K, V)]` into an `RDD[(K, C)]` (for a "combined type" C) using the functions:

* [[createCombiner]] `createCombiner: V => C`
* [[mergeValue]] `mergeValue: (C, V) => C`
* [[mergeCombiners]] `mergeCombiners: (C, C) => C`

Aggregator is used to create a xref:rdd:ShuffleDependency.adoc[ShuffleDependency] and xref:shuffle:ExternalSorter.adoc[ExternalSorter].

== [[combineValuesByKey]] combineValuesByKey Method

[source, scala]
----
combineValuesByKey(
  iter: Iterator[_ <: Product2[K, V]],
  context: TaskContext): Iterator[(K, C)]
----

combineValuesByKey creates a new xref:shuffle:ExternalAppendOnlyMap.adoc[ExternalAppendOnlyMap] (with the <<aggregation-functions, aggregation functions>>).

combineValuesByKey requests the ExternalAppendOnlyMap to xref:shuffle:ExternalAppendOnlyMap.adoc#insertAll[insert all key-value pairs] from the given iterator (that is the values of a partition).

combineValuesByKey <<updateMetrics, updates the task metrics>>.

In the end, combineValuesByKey requests the ExternalAppendOnlyMap for an xref:shuffle:ExternalAppendOnlyMap.adoc#iterator[iterator of "combined" pairs].

combineValuesByKey is used when:

* xref:rdd:PairRDDFunctions.adoc#combineByKeyWithClassTag[PairRDDFunctions.combineByKeyWithClassTag] transformation is used (with the same Partitioner as the RDD's)

* BlockStoreShuffleReader is requested to xref:shuffle:BlockStoreShuffleReader.adoc#read[read combined records for a reduce task] (with the xref:rdd:ShuffleDependency.adoc#mapSideCombine[Map-Size Partial Aggregation Flag] off)

== [[combineCombinersByKey]] combineCombinersByKey Method

[source, scala]
----
combineCombinersByKey(
  iter: Iterator[_ <: Product2[K, C]],
  context: TaskContext): Iterator[(K, C)]
----

combineCombinersByKey...FIXME

combineCombinersByKey is used when BlockStoreShuffleReader is requested to xref:shuffle:BlockStoreShuffleReader.adoc#read[read combined records for a reduce task] (with the xref:rdd:ShuffleDependency.adoc#mapSideCombine[Map-Size Partial Aggregation Flag] on).

== [[updateMetrics]] Updating Task Metrics

[source, scala]
----
updateMetrics(
  context: TaskContext,
  map: ExternalAppendOnlyMap[_, _, _]): Unit
----

updateMetrics requests the input xref:scheduler:spark-TaskContext.adoc[TaskContext] for the xref:scheduler:spark-TaskContext.adoc#taskMetrics[TaskMetrics] to update the metrics based on the metrics of the input xref:shuffle:ExternalAppendOnlyMap.adoc[ExternalAppendOnlyMap]:

* xref:executor:TaskMetrics.adoc#incMemoryBytesSpilled[Increment memory bytes spilled]

* xref:executor:TaskMetrics.adoc#incDiskBytesSpilled[Increment disk bytes spilled]

* xref:executor:TaskMetrics.adoc#incPeakExecutionMemory[Increment peak execution memory]

updateMetrics is used when Aggregator is requested to <<combineValuesByKey, combineValuesByKey>> and <<combineCombinersByKey, combineCombinersByKey>>.
