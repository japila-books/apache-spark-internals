= SparkListener

*SparkListener* is a mechanism in Spark to intercept events from the Spark scheduler that are emitted over the course of execution of a Spark application.

SparkListener extends <<SparkListenerInterface, SparkListenerInterface>> with all the _callback methods_ being no-op/do-nothing.

Spark <<builtin-implementations, relies on `SparkListeners` internally>> to manage communication between internal components in the distributed environment for a Spark application, e.g. spark-webui.md[web UI], spark-history-server:EventLoggingListener.md[event persistence] (for History Server), spark-ExecutorAllocationManager.md[dynamic allocation of executors], spark-HeartbeatReceiver.md[keeping track of executors (using `HeartbeatReceiver`)] and others.

You can develop your own custom SparkListener and register it using ROOT:SparkContext.md#addSparkListener[SparkContext.addSparkListener] method or ROOT:configuration-properties.md#spark.extraListeners[spark.extraListeners] configuration property.

With SparkListener you can focus on Spark events of your liking and process a subset of all scheduling events.

[TIP]
====
Enable `INFO` logging level for `org.apache.spark.SparkContext` logger to see when custom Spark listeners are registered.

```
INFO SparkContext: Registered listener org.apache.spark.scheduler.StatsReportListener
```

See ROOT:SparkContext.md[].
====

== [[SparkListenerInterface]] SparkListenerInterface -- Internal Contract for Spark Listeners

`SparkListenerInterface` is an `private[spark]` contract for Spark listeners to intercept events from the Spark scheduler.

NOTE: <<SparkListener, SparkListener>> and <<SparkFirehoseListener, SparkFirehoseListener>> Spark listeners are direct implementations of `SparkListenerInterface` contract to help developing more sophisticated Spark listeners.

.SparkListenerInterface Methods
[cols="1,1,2",options="header",width="100%"]
|===
| Method
| Event
| Reason

| `onApplicationEnd`
| [[SparkListenerApplicationEnd]] `SparkListenerApplicationEnd` | `SparkContext` does `postApplicationEnd`

| [[onApplicationStart]] `onApplicationStart`
| [[SparkListenerApplicationStart]] `SparkListenerApplicationStart`
| `SparkContext` does `postApplicationStart`

| [[onBlockManagerAdded]] `onBlockManagerAdded`
| [[SparkListenerBlockManagerAdded]] `SparkListenerBlockManagerAdded`
| `BlockManagerMasterEndpoint` storage:BlockManagerMasterEndpoint.md#register[has registered a `BlockManager`].

| [[onBlockManagerRemoved]] `onBlockManagerRemoved`
| [[SparkListenerBlockManagerRemoved]] `SparkListenerBlockManagerRemoved`
| `BlockManagerMasterEndpoint` storage:BlockManagerMasterEndpoint.md#removeBlockManager[has removed a `BlockManager`] (which is when...FIXME)

| [[onBlockUpdated]] `onBlockUpdated`
| [[SparkListenerBlockUpdated]] `SparkListenerBlockUpdated`
| `BlockManagerMasterEndpoint` receives a storage:BlockManagerMasterEndpoint.md#UpdateBlockInfo[UpdateBlockInfo] event (which is when `BlockManager` storage:BlockManager.md#tryToReportBlockStatus[reports a block status update to driver]).

| `onEnvironmentUpdate`
| [[SparkListenerEnvironmentUpdate]] `SparkListenerEnvironmentUpdate`
| `SparkContext` does `postEnvironmentUpdate`.

| `onExecutorMetricsUpdate`
| [[SparkListenerExecutorMetricsUpdate]] `SparkListenerExecutorMetricsUpdate`
|

| `onExecutorAdded`
| [[SparkListenerExecutorAdded]] `SparkListenerExecutorAdded`
| [[onExecutorAdded]] `DriverEndpoint` RPC endpoint (of `CoarseGrainedSchedulerBackend`) scheduler:CoarseGrainedSchedulerBackend-DriverEndpoint.md#RegisterExecutor[receives `RegisterExecutor` message], `MesosFineGrainedSchedulerBackend` does `resourceOffers`, and `LocalSchedulerBackendEndpoint` starts.

| [[onExecutorBlacklisted]] `onExecutorBlacklisted`
| [[SparkListenerExecutorBlacklisted]] `SparkListenerExecutorBlacklisted`
| FIXME

| [[onExecutorRemoved]] `onExecutorRemoved`
| [[SparkListenerExecutorRemoved]] `SparkListenerExecutorRemoved`
| `DriverEndpoint` RPC endpoint (of `CoarseGrainedSchedulerBackend`) does
scheduler:CoarseGrainedSchedulerBackend-DriverEndpoint.md#removeExecutor[removeExecutor] and `MesosFineGrainedSchedulerBackend` does `removeExecutor`.

| [[onExecutorUnblacklisted]] `onExecutorUnblacklisted`
| [[SparkListenerExecutorUnblacklisted]] `SparkListenerExecutorUnblacklisted`
| FIXME

| `onJobEnd`
| [[SparkListenerJobEnd]] `SparkListenerJobEnd`
| `DAGScheduler` does `cleanUpAfterSchedulerStop`, `handleTaskCompletion`, `failJobAndIndependentStages`, and markMapStageJobAsFinished.

| [[onJobStart]] `onJobStart`
| [[SparkListenerJobStart]] `SparkListenerJobStart`
| `DAGScheduler` handles scheduler:DAGSchedulerEventProcessLoop.md#handleJobSubmitted[JobSubmitted] and scheduler:DAGSchedulerEventProcessLoop.md#handleMapStageSubmitted[MapStageSubmitted] messages

| [[onNodeBlacklisted]] `onNodeBlacklisted`
| [[SparkListenerNodeBlacklisted]] `SparkListenerNodeBlacklisted`
| FIXME

| [[onNodeUnblacklisted]] `onNodeUnblacklisted`
| [[SparkListenerNodeUnblacklisted]] `SparkListenerNodeUnblacklisted`
| FIXME

| [[onStageCompleted]] `onStageCompleted`
| [[SparkListenerStageCompleted]] `SparkListenerStageCompleted`
| `DAGScheduler` scheduler:DAGScheduler.md#markStageAsFinished[marks a stage as finished].

| [[onStageSubmitted]] `onStageSubmitted`
| [[SparkListenerStageSubmitted]] `SparkListenerStageSubmitted`
| `DAGScheduler` scheduler:DAGScheduler.md#submitMissingTasks[submits the missing tasks of a stage (in a Spark job)].

| [[onTaskEnd]] `onTaskEnd`
| [[SparkListenerTaskEnd]] `SparkListenerTaskEnd`
| `DAGScheduler` scheduler:DAGScheduler.md#handleTaskCompletion[handles a task completion]

| `onTaskGettingResult`
| [[SparkListenerTaskGettingResult]] `SparkListenerTaskGettingResult`
| `DAGScheduler` scheduler:DAGSchedulerEventProcessLoop.md#handleGetTaskResult[handles `GettingResultEvent` event]

| [[onTaskStart]] `onTaskStart`
| [[SparkListenerTaskStart]] `SparkListenerTaskStart`
| `DAGScheduler` is informed that a scheduler:DAGSchedulerEventProcessLoop.md#handleBeginEvent[task is about to start].

| [[onUnpersistRDD]] `onUnpersistRDD`
| [[SparkListenerUnpersistRDD]] `SparkListenerUnpersistRDD`
| `SparkContext` ROOT:SparkContext.md#unpersistRDD[unpersists an RDD], i.e. removes RDD blocks from `BlockManagerMaster` (that can be triggered ROOT:SparkContext.md#unpersist[explicitly] or core:ContextCleaner.md#doCleanupRDD[implicitly]).

| [[onOtherEvent]] `onOtherEvent`
| [[SparkListenerEvent]] `SparkListenerEvent`
| Catch-all callback that is often used in Spark SQL to handle custom events.
|===

== [[builtin-implementations]] Built-In Spark Listeners

.Built-In Spark Listeners
[cols="1,2",options="header",width="100%"]
|===
| Spark Listener | Description
| spark-history-server:EventLoggingListener.md[EventLoggingListener] | Logs JSON-encoded events to a file that can later be read by spark-history-server:index.md[History Server]
| spark-SparkListener-StatsReportListener.md[StatsReportListener] |
| [[SparkFirehoseListener]] `SparkFirehoseListener` | Allows users to receive all <<SparkListenerEvent, SparkListenerEvent>> events by overriding the single `onEvent` method only.
| spark-SparkListener-ExecutorAllocationListener.md[ExecutorAllocationListener] |
| spark-HeartbeatReceiver.md[HeartbeatReceiver] |
| spark-streaming/spark-streaming-streaminglisteners.md#StreamingJobProgressListener[StreamingJobProgressListener] |
| spark-webui-executors-ExecutorsListener.md[ExecutorsListener] | Prepares information for spark-webui-executors.md[Executors tab] in spark-webui.md[web UI]
| spark-webui-StorageStatusListener.md[StorageStatusListener], spark-webui-RDDOperationGraphListener.md[RDDOperationGraphListener], spark-webui-EnvironmentListener.md[EnvironmentListener], spark-webui-BlockStatusListener.md[BlockStatusListener] and spark-webui-StorageListener.md[StorageListener] | For spark-webui.md[web UI]
| `SpillListener` |
| `ApplicationEventListener` |
| spark-sql-streaming-StreamingQueryListenerBus.md[StreamingQueryListenerBus] |
| spark-sql-SQLListener.md[SQLListener] / spark-history-server:SQLHistoryListener.md[SQLHistoryListener] | Support for spark-history-server:index.md[History Server]
| spark-streaming/spark-streaming-jobscheduler.md#StreamingListenerBus[StreamingListenerBus] |
| spark-webui-JobProgressListener.md[JobProgressListener] |
|===
