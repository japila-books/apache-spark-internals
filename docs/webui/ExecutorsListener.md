== [[ExecutorsListener]] ExecutorsListener Spark Listener

`ExecutorsListener` is a ROOT:SparkListener.md[] that tracks <<internal-registries, executors and their tasks>> in a Spark application for spark-webui-StagePage.md[Stage Details] page, spark-webui-jobs.md[Jobs] tab and `/allexecutors` REST endpoint.

[[SparkListener-callbacks]]
.ExecutorsListener's SparkListener Callbacks (in alphabetical order)
[cols="1,2",options="header",width="100%"]
|===
| Event Handler
| Description

| <<onApplicationStart, onApplicationStart>>
| May create an entry for the driver in <<executorToTaskSummary, executorToTaskSummary>> registry

| <<onExecutorAdded, onExecutorAdded>>
| May create an entry in <<executorToTaskSummary, executorToTaskSummary>> registry. It also makes sure that the number of entries for dead executors does not exceed spark-webui-properties.md#spark.ui.retainedDeadExecutors[spark.ui.retainedDeadExecutors] and removes excess.

Adds an entry to <<executorEvents, executorEvents>> registry and optionally removes the oldest if the number of entries exceeds spark-webui-properties.md#spark.ui.timeline.executors.maximum[spark.ui.timeline.executors.maximum].

| <<onExecutorBlacklisted, onExecutorBlacklisted>>
| FIXME

| <<onExecutorRemoved, onExecutorRemoved>>
| Marks an executor dead in <<executorToTaskSummary, executorToTaskSummary>> registry.

Adds an entry to <<executorEvents, executorEvents>> registry and optionally removes the oldest if the number of entries exceeds spark-webui-properties.md#spark.ui.timeline.executors.maximum[spark.ui.timeline.executors.maximum].

| <<onExecutorUnblacklisted, onExecutorUnblacklisted>>
| FIXME

| <<onNodeBlacklisted, onNodeBlacklisted>>
| FIXME

| <<onNodeUnblacklisted, onNodeUnblacklisted>>
| FIXME

| <<onTaskStart, onTaskStart>>
| May create an entry for an executor in <<executorToTaskSummary, executorToTaskSummary>> registry.

| <<onTaskEnd, onTaskEnd>>
| May create an entry for an executor in <<executorToTaskSummary, executorToTaskSummary>> registry.
|===

`ExecutorsListener` requires a spark-webui-StorageStatusListener.md[StorageStatusListener] and ROOT:SparkConf.md[SparkConf].

[[internal-registries]]
.ExecutorsListener's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Registry
| Description

| [[executorToTaskSummary]] `executorToTaskSummary`
| The lookup table for `ExecutorTaskSummary` per executor id.

Used to build a `ExecutorSummary` for `/allexecutors` REST endpoint, to display stdout and stderr logs in spark-webui-StagePage.md#tasks[Tasks] and spark-webui-StagePage.md#aggregated-metrics-by-executor[Aggregated Metrics by Executor] sections in spark-webui-StagePage.md[Stage Details] page.

| [[executorEvents]] `executorEvents`
| A collection of ROOT:SparkListener.md#SparkListenerEvent[SparkListenerEvent]s.

Used to build the event timeline in spark-webui-AllJobsPage.md[AllJobsPage] and spark-webui-jobs.md#JobPage[Details for Job] pages.
|===

=== [[updateExecutorBlacklist]] `updateExecutorBlacklist` Method

CAUTION: FIXME

=== [[onExecutorBlacklisted]] Intercepting Executor Was Blacklisted Events -- `onExecutorBlacklisted` Callback

CAUTION: FIXME

=== [[onExecutorUnblacklisted]] Intercepting Executor Is No Longer Blacklisted Events -- `onExecutorUnblacklisted` Callback

CAUTION: FIXME

=== [[onNodeBlacklisted]] Intercepting Node Was Blacklisted Events -- `onNodeBlacklisted` Callback

CAUTION: FIXME

=== [[onNodeUnblacklisted]] Intercepting Node Is No Longer Blacklisted Events -- `onNodeUnblacklisted` Callback

CAUTION: FIXME

=== [[onApplicationStart]] Intercepting Application Started Events -- `onApplicationStart` Callback

[source, scala]
----
onApplicationStart(applicationStart: SparkListenerApplicationStart): Unit
----

NOTE: `onApplicationStart` is part of ROOT:SparkListener.md#onApplicationStart[SparkListener contract] to announce that a Spark application has been started.

`onApplicationStart` takes `driverLogs` property from the input `applicationStart` (if defined) and finds the driver's active spark-blockmanager-StorageStatus.md[StorageStatus] (using the current spark-webui-StorageStatusListener.md[StorageStatusListener]). `onApplicationStart` then uses the driver's spark-blockmanager-StorageStatus.md[StorageStatus] (if defined) to set `executorLogs`.

.ExecutorTaskSummary and ExecutorInfo Attributes
[options="header",width="100%"]
|===
| ExecutorTaskSummary Attribute | SparkListenerApplicationStart Attribute
| `executorLogs` | `driverLogs` (if defined)
|===

=== [[onExecutorAdded]] Intercepting Executor Added Events -- `onExecutorAdded` Callback

[source, scala]
----
onExecutorAdded(executorAdded: SparkListenerExecutorAdded): Unit
----

NOTE: `onExecutorAdded` is part of ROOT:SparkListener.md#onExecutorAdded[SparkListener contract] to announce that a new executor has been registered with the Spark application.

`onExecutorAdded` finds the executor (using the input `executorAdded`) in the internal <<executorToTaskSummary, `executorToTaskSummary` registry>> and sets the attributes. If not found, `onExecutorAdded` creates a new entry.

.ExecutorTaskSummary and ExecutorInfo Attributes
[options="header",width="100%"]
|===
| ExecutorTaskSummary Attribute | ExecutorInfo Attribute
| `executorLogs` | `logUrlMap`
| `totalCores` | `totalCores`
| `tasksMax` | `totalCores` / ROOT:configuration-properties.md#spark.task.cpus[spark.task.cpus]
|===

`onExecutorAdded` adds the input `executorAdded` to <<executorEvents, `executorEvents` collection>>. If the number of elements in `executorEvents` collection is greater than spark-webui-properties.md#spark.ui.timeline.executors.maximum[spark.ui.timeline.executors.maximum] configuration property, the first/oldest event is removed.

`onExecutorAdded` removes the oldest dead executor from <<executorToTaskSummary, `executorToTaskSummary` lookup table>> if their number is greater than spark-webui-properties.md#spark.ui.retainedDeadExecutors[spark.ui.retainedDeadExecutors].

=== [[onExecutorRemoved]] Intercepting Executor Removed Events -- `onExecutorRemoved` Callback

[source, scala]
----
onExecutorRemoved(executorRemoved: SparkListenerExecutorRemoved): Unit
----

NOTE: `onExecutorRemoved` is part of ROOT:SparkListener.md#onExecutorRemoved[SparkListener contract] to announce that an executor has been unregistered with the Spark application.

`onExecutorRemoved` adds the input `executorRemoved` to <<executorEvents, `executorEvents` collection>>. It then removes the oldest event if the number of elements in `executorEvents` collection is greater than spark-webui-properties.md#spark.ui.timeline.executors.maximum[spark.ui.timeline.executors.maximum] configuration property.

The executor is marked as removed/inactive in <<executorToTaskSummary, `executorToTaskSummary` lookup table>>.

=== [[onTaskStart]] Intercepting Task Started Events -- `onTaskStart` Callback

[source, scala]
----
onTaskStart(taskStart: SparkListenerTaskStart): Unit
----

NOTE: `onTaskStart` is part of ROOT:SparkListener.md#onTaskStart[SparkListener contract] to announce that a task has been started.

`onTaskStart` increments `tasksActive` for the executor (using the input `SparkListenerTaskStart`).

.ExecutorTaskSummary and SparkListenerTaskStart Attributes
[options="header",width="100%"]
|===
| ExecutorTaskSummary Attribute | Description
| `tasksActive` | Uses `taskStart.taskInfo.executorId`.
|===

=== [[onTaskEnd]] Intercepting Task End Events -- `onTaskEnd` Callback

[source, scala]
----
onTaskEnd(taskEnd: SparkListenerTaskEnd): Unit
----

NOTE: `onTaskEnd` is part of ROOT:SparkListener.md#onTaskEnd[SparkListener contract] to announce that a task has ended.

`onTaskEnd` takes spark-scheduler-TaskInfo.md[TaskInfo] from the input `taskEnd` (if available).

Depending on the reason for `SparkListenerTaskEnd` `onTaskEnd` does the following:

.`onTaskEnd` Behaviour per `SparkListenerTaskEnd` Reason
[cols="1,2",options="header",width="100%"]
|===
| `SparkListenerTaskEnd` Reason | `onTaskEnd` Behaviour
| `Resubmitted` | Does nothing
| `ExceptionFailure` | Increment `tasksFailed`
| _anything_ | Increment `tasksComplete`
|===

`tasksActive` is decremented but only when the number of active tasks for the executor is greater than `0`.

.ExecutorTaskSummary and `onTaskEnd` Behaviour
[options="header",width="100%"]
|===
| ExecutorTaskSummary Attribute | Description
| `tasksActive` | Decremented if greater than 0.
| `duration` | Uses `taskEnd.taskInfo.duration`
|===

If the `TaskMetrics` (in the input `taskEnd`) is available, the metrics are added to the `taskSummary` for the task's executor.

.Task Metrics and Task Summary
[cols="1,2",options="header",width="100%"]
|===
| Task Summary | Task Metric
| `inputBytes` | `inputMetrics.bytesRead`
| `inputRecords` | `inputMetrics.recordsRead`
| `outputBytes` | `outputMetrics.bytesWritten`
| `outputRecords` | `outputMetrics.recordsWritten`
| `shuffleRead` | `shuffleReadMetrics.remoteBytesRead`
| `shuffleWrite` | executor:ShuffleWriteMetrics.md#bytesWritten[shuffleWriteMetrics.bytesWritten]
| `jvmGCTime` | `metrics.jvmGCTime`
|===

=== [[activeStorageStatusList]] Finding Active BlockManagers -- `activeStorageStatusList` Method

[source, scala]
----
activeStorageStatusList: Seq[StorageStatus]
----

`activeStorageStatusList` requests <<storageStatusListener, StorageStatusListener>> for spark-webui-StorageStatusListener.md#storageStatusList[active BlockManagers (on executors)].

[NOTE]
====
`activeStorageStatusList` is used when:

* FIXME

* `AllExecutorListResource` does `executorList`
* `ExecutorListResource` does `executorList`
* `ExecutorsListener` gets informed that the <<onApplicationStart, Spark application has started>>, <<onNodeBlacklisted, onNodeBlacklisted>>, and <<onNodeUnblacklisted, onNodeUnblacklisted>>
====
