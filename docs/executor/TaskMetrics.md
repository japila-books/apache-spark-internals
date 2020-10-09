# TaskMetrics

`TaskMetrics` is a <<metrics, collection of metrics>> (as <<spark-accumulators.md#, AccumulatorV2s>>) tracked during execution of a scheduler:Task.md[Task].

TaskMetrics is <<creating-instance, created>> when:

* `Stage` is requested to scheduler:Stage.md#makeNewStageAttempt[create a new stage attempt] (when `DAGScheduler` is requested to scheduler:DAGScheduler.md#submitMissingTasks[submit the missing tasks of a stage])

* TaskMetrics utility is requested to <<empty, empty>>, <<fromAccumulatorInfos, fromAccumulatorInfos>>, and <<fromAccumulators, fromAccumulators>>

[[creating-instance]]
TaskMetrics takes no arguments to be created.

TaskMetrics is available using <<spark-TaskContext.md#taskMetrics, TaskContext.taskMetrics>>.

TIP: Use ROOT:SparkListener.md#onTaskEnd[SparkListener.onTaskEnd] to intercept ROOT:SparkListener.md#SparkListenerTaskEnd[SparkListenerTaskEnd] events to access the <<TaskMetrics, TaskMetrics>> of a task that has finished successfully.

TIP: Use <<spark-SparkListener-StatsReportListener.md#, StatsReportListener>> for summary statistics at runtime (after a stage completes).

TIP: Use spark-history-server:EventLoggingListener.md[EventLoggingListener] for post-execution (history) statistics.

TaskMetrics uses spark-accumulators.md[accumulators] to represent the metrics and offers "increment" methods to increment them.

NOTE: The local values of the accumulators for a scheduler:Task.md[task] (as accumulated while the scheduler:Task.md#run[task runs]) are sent from the executor to the driver when the task completes (and <<fromAccumulators, `DAGScheduler` re-creates TaskMetrics>>).

[[metrics]]
.Metrics
[cols="1,1,1,2",options="header",width="100%"]
|===
| Property
| Name
| Type
| Description

| [[_memoryBytesSpilled]] `_memoryBytesSpilled`
| `internal.metrics.memoryBytesSpilled`
| `LongAccumulator`
| Used in <<memoryBytesSpilled, memoryBytesSpilled>>, <<incMemoryBytesSpilled, incMemoryBytesSpilled>>

| [[_updatedBlockStatuses]] `_updatedBlockStatuses`
| `internal.metrics.updatedBlockStatuses`
| `CollectionAccumulator[(BlockId, BlockStatus)]`
| Used in <<updatedBlockStatuses, updatedBlockStatuses>>, <<incUpdatedBlockStatuses, recording updated `BlockStatus` for a `Block`>>, <<setUpdatedBlockStatuses, setUpdatedBlockStatuses>>

|===

[[internal-registries]]
.TaskMetrics's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[nameToAccums]] `nameToAccums`
| Internal spark-accumulators.md[accumulators] indexed by their names.

Used when TaskMetrics <<fromAccumulators, re-creates TaskMetrics from `AccumulatorV2s`>>, ...FIXME

NOTE: `nameToAccums` is a `transient` and `lazy` value.

| [[internalAccums]] `internalAccums`
| Collection of internal spark-accumulators.md[AccumulatorV2] objects.

Used when...FIXME

NOTE: `internalAccums` is a `transient` and `lazy` value.

| [[externalAccums]] `externalAccums`
| Collection of external spark-accumulators.md[AccumulatorV2] objects.

Used when TaskMetrics <<fromAccumulators, re-creates TaskMetrics from `AccumulatorV2s`>>, ...FIXME

NOTE: `externalAccums` is a `transient` and `lazy` value.
|===

== [[accumulators]] `accumulators` Method

CAUTION: FIXME

== [[mergeShuffleReadMetrics]] `mergeShuffleReadMetrics` Method

CAUTION: FIXME

== [[memoryBytesSpilled]] `memoryBytesSpilled` Method

CAUTION: FIXME

== [[updatedBlockStatuses]] `updatedBlockStatuses` Method

CAUTION: FIXME

== [[setExecutorCpuTime]] `setExecutorCpuTime` Method

CAUTION: FIXME

== [[setResultSerializationTime]] `setResultSerializationTime` Method

CAUTION: FIXME

== [[setJvmGCTime]] `setJvmGCTime` Method

CAUTION: FIXME

== [[setExecutorRunTime]] `setExecutorRunTime` Method

CAUTION: FIXME

== [[setExecutorDeserializeCpuTime]] `setExecutorDeserializeCpuTime` Method

CAUTION: FIXME

== [[setExecutorDeserializeTime]] `setExecutorDeserializeTime` Method

CAUTION: FIXME

== [[setUpdatedBlockStatuses]] `setUpdatedBlockStatuses` Method

CAUTION: FIXME

== [[fromAccumulators]] Re-Creating TaskMetrics From AccumulatorV2s -- `fromAccumulators` Method

[source, scala]
----
fromAccumulators(accums: Seq[AccumulatorV2[_, _]]): TaskMetrics
----

`fromAccumulators` creates a new TaskMetrics and registers `accums` as internal and external task metrics (using <<nameToAccums, nameToAccums>> internal registry).

Internally, `fromAccumulators` creates a new TaskMetrics. It then splits `accums` into internal and external task metrics collections (using <<nameToAccums, nameToAccums>> internal registry).

For every internal task metrics, `fromAccumulators` finds the metrics in <<nameToAccums, nameToAccums>> internal registry (of the new TaskMetrics instance), copies spark-accumulators.md#metadata[metadata], and spark-accumulators.md#merge[merges state].

In the end, `fromAccumulators` <<externalAccums, adds the external accumulators to the new TaskMetrics instance>>.

NOTE: `fromAccumulators` is used exclusively when scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion[`DAGScheduler` gets notified that a task has finished] (and re-creates TaskMetrics).

== [[incMemoryBytesSpilled]] Increasing Memory Bytes Spilled -- `incMemoryBytesSpilled` Method

[source, scala]
----
incMemoryBytesSpilled(v: Long): Unit
----

`incMemoryBytesSpilled` adds `v` to <<_memoryBytesSpilled, _memoryBytesSpilled>> task metrics.

[NOTE]
====
`incMemoryBytesSpilled` is used when:

1. rdd:Aggregator.md#updateMetrics[`Aggregator` updates task metrics]

2. `CoGroupedRDD` is requested to [compute a partition](../rdd/CoGroupedRDD.md#compute)

3. shuffle:BlockStoreShuffleReader.md#read[`BlockStoreShuffleReader` reads combined key-value records for a reduce task]

4. shuffle:ShuffleExternalSorter.md#spill[`ShuffleExternalSorter` frees execution memory by spilling to disk]

5. shuffle:ExternalSorter.md#writePartitionedFile[`ExternalSorter` writes the records into a temporary partitioned file in the disk store]

6. `UnsafeExternalSorter` spills current records due to memory pressure

7. `SpillableIterator` spills records to disk

8. spark-history-server:JsonProtocol.md#taskMetricsFromJson[`JsonProtocol` creates TaskMetrics from JSON]
====

== [[incUpdatedBlockStatuses]] Recording Updated BlockStatus For Block -- `incUpdatedBlockStatuses` Method

[source, scala]
----
incUpdatedBlockStatuses(v: (BlockId, BlockStatus)): Unit
----

`incUpdatedBlockStatuses` adds `v` in <<_updatedBlockStatuses, _updatedBlockStatuses>> internal registry.

NOTE: `incUpdatedBlockStatuses` is used exclusively when storage:BlockManager.md#addUpdatedBlockStatusToTaskMetrics[`BlockManager` does `addUpdatedBlockStatusToTaskMetrics`].

== [[register]] Registering Internal Accumulators -- `register` Method

[source, scala]
----
register(sc: SparkContext): Unit
----

`register` spark-accumulators.md#register[registers the internal accumulators] (from <<nameToAccums, nameToAccums>> internal registry) with `countFailedValues` enabled (`true`).

NOTE: `register` is used exclusively when scheduler:Stage.md#makeNewStageAttempt[`Stage` is requested for its new attempt].

== [[empty]] `empty` Factory Method

[source, scala]
----
empty: TaskMetrics
----

`empty`...FIXME

[NOTE]
====
`empty` is used when:

* `TaskContextImpl` is <<spark-TaskContextImpl.md#taskMetrics, created>>

* TaskMetrics utility is requested to <<registered, registered>>

* JsonProtocol utility is requested to spark-history-server:JsonProtocol.md#taskMetricsFromJson[taskMetricsFromJson]
====

== [[registered]] `registered` Factory Method

[source, scala]
----
registered: TaskMetrics
----

`registered`...FIXME

NOTE: `registered` is used exclusively when `Task` is scheduler:Task.md#serializedTaskMetrics[created].

== [[fromAccumulatorInfos]] `fromAccumulatorInfos` Factory Method

[source, scala]
----
fromAccumulatorInfos(infos: Seq[AccumulableInfo]): TaskMetrics
----

`fromAccumulatorInfos`...FIXME

NOTE: `fromAccumulatorInfos` is used exclusively when `AppStatusListener` is requested to core:AppStatusListener.md#onExecutorMetricsUpdate[onExecutorMetricsUpdate] (for spark-history-server:index.md[Spark History Server] only).

== [[fromAccumulators]] `fromAccumulators` Factory Method

[source, scala]
----
fromAccumulators(accums: Seq[AccumulatorV2[_, _]]): TaskMetrics
----

`fromAccumulators`...FIXME

NOTE: `fromAccumulators` is used exclusively when `DAGScheduler` is requested to scheduler:DAGScheduler.md#postTaskEnd[postTaskEnd].
