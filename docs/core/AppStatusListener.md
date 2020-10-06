= AppStatusListener

*AppStatusListener* is a ROOT:SparkListener.md[].

== [[creating-instance]] Creating Instance

AppStatusListener takes the following to be created:

* [[kvstore]] core:ElementTrackingStore.md[]
* [[conf]] ROOT:SparkConf.md[]
* <<live, live Flag>>
* [[lastUpdateTime]] Optional lastUpdateTime (default: `None`)

AppStatusListener is created when:

* AppStatusStore is requested to core:AppStatusStore.md#createLiveStore[createLiveStore] (with the <<live, live>> flag enabled)

* FsHistoryProvider is requested to spark-history-server:FsHistoryProvider.md#rebuildAppStore[rebuildAppStore] (with the <<live, live>> flag disabled)

== [[live]] live Flag

AppStatusListener is given a flag that indicates whether it is created for a live Spark application (for core:AppStatusStore.md[]) or when replaying Spark applications for spark-history-server:index.md[] (for spark-history-server:FsHistoryProvider.md[]).

== [[event-handlers]] Event Handlers

[width="100%",cols="1m,1",options="header"]
|===
| Event
| Handler

| SparkListenerApplicationStart
| <<onApplicationStart, onApplicationStart>>

| SparkListenerApplicationEnd
| <<onApplicationEnd, onApplicationEnd>>

| SparkListenerBlockManagerAdded
| <<onBlockManagerAdded, onBlockManagerAdded>>

| SparkListenerBlockManagerRemoved
| <<onBlockManagerRemoved, onBlockManagerRemoved>>

| SparkListenerBlockUpdated
| <<onBlockUpdated, onBlockUpdated>>

| SparkListenerEnvironmentUpdate
| <<onEnvironmentUpdate, onEnvironmentUpdate>>

| SparkListenerEvent
| <<onOtherEvent, onOtherEvent>>

| SparkListenerExecutorAdded
| <<onExecutorAdded, onExecutorAdded>>

| SparkListenerExecutorBlacklisted
| <<onExecutorBlacklisted, onExecutorBlacklisted>>

| SparkListenerExecutorMetricsUpdate
| <<onExecutorMetricsUpdate, onExecutorMetricsUpdate>>

| SparkListenerExecutorRemoved
| <<onExecutorRemoved, onExecutorRemoved>>

| SparkListenerExecutorUnblacklisted
| <<onExecutorUnblacklisted, onExecutorUnblacklisted>>

| SparkListenerJobStart
| <<onJobStart, onJobStart>>

| SparkListenerJobEnd
| <<onJobEnd, onJobEnd>>

| SparkListenerNodeBlacklisted
| <<onNodeBlacklisted, onNodeBlacklisted>>

| SparkListenerNodeUnblacklisted
| <<onNodeUnblacklisted, onNodeUnblacklisted>>

| SparkListenerStageCompleted
| <<onStageCompleted, onStageCompleted>>

| SparkListenerStageSubmitted
| <<onStageSubmitted, onStageSubmitted>>

| SparkListenerTaskEnd
| <<onTaskEnd, onTaskEnd>>

| SparkListenerTaskGettingResult
| <<onTaskGettingResult, onTaskGettingResult>>

| SparkListenerTaskStart
| <<onTaskStart, onTaskStart>>

| SparkListenerUnpersistRDD
| <<onUnpersistRDD, onUnpersistRDD>>
|===

== [[onStageSubmitted]] `onStageSubmitted` Method

[source, scala]
----
onStageSubmitted(event: SparkListenerStageSubmitted): Unit
----

NOTE: `onStageSubmitted` is part of ROOT:SparkListener.md#onStageSubmitted[SparkListener Contract] to...FIXME.

`onStageSubmitted`...FIXME

== [[update]] `update` Internal Method

[source, scala]
----
update(entity: LiveEntity, now: Long, last: Boolean = false): Unit
----

`update` simply requests the `LiveEntity` to spark-core-LiveEntity.md#write[write] (with the <<kvstore, ElementTrackingStore>> as the store and the `last` flag as `checkTriggers` flag).

NOTE: `update` is used in event handlers (i.e. `onApplicationStart`, `onExecutorRemoved`, `onJobEnd`, `onStageSubmitted`, `onTaskEnd`, `onStageCompleted`), <<liveUpdate, liveUpdate>>, <<maybeUpdate, maybeUpdate>>, <<flush, flush>> and <<updateRDDBlock, updateRDDBlock>>.

== [[flush]] `flush` Internal Method

[source, scala]
----
flush(): Unit
----

`flush`...FIXME

NOTE: `flush` is used when...FIXME

== [[maybeUpdate]] `maybeUpdate` Internal Method

[source, scala]
----
maybeUpdate(entity: LiveEntity, now: Long): Unit
----

`maybeUpdate`...FIXME

NOTE: `maybeUpdate` is used when...FIXME

== [[liveUpdate]] `liveUpdate` Internal Method

[source, scala]
----
liveUpdate(entity: LiveEntity, now: Long): Unit
----

`liveUpdate`...FIXME

NOTE: `liveUpdate` is used when...FIXME

== [[updateStreamBlock]] `updateStreamBlock` Internal Method

[source, scala]
----
updateStreamBlock(event: SparkListenerBlockUpdated, stream: StreamBlockId): Unit
----

`updateStreamBlock`...FIXME

NOTE: `updateStreamBlock` is used exclusively when AppStatusListener is requested to <<onBlockUpdated, handle a SparkListenerBlockUpdated event>> (for a storage:BlockId.md#StreamBlockId[StreamBlockId]).

== [[onBlockUpdated]] Intercepting SparkListenerBlockUpdated Events -- `onBlockUpdated` Handler Method

[source, scala]
----
onBlockUpdated(event: SparkListenerBlockUpdated): Unit
----

NOTE: `onBlockUpdated` is part of ROOT:SparkListener.md#onBlockUpdated[SparkListener Contract] to...FIXME.

`onBlockUpdated` simply dispatches to the following event-specific handlers (per storage:BlockId.md[] type):

* <<updateRDDBlock, updateRDDBlock>> for storage:BlockId.md#RDDBlockId[RDDBlockIds]

* <<updateStreamBlock, updateStreamBlock>> for storage:BlockId.md#StreamBlockId[StreamBlockIds]

* Ignores (_swallows_) the `SparkListenerBlockUpdated` event for the other types

== [[updateRDDBlock]] `updateRDDBlock` Internal Method

[source, scala]
----
updateRDDBlock(
  event: SparkListenerBlockUpdated,
  block: RDDBlockId): Unit
----

`updateRDDBlock`...FIXME

NOTE: `updateRDDBlock` is used exclusively when AppStatusListener is requested to <<onBlockUpdated, handle a SparkListenerBlockUpdated event>> (for a storage:BlockId.md#RDDBlockId[RDDBlockId]).

== [[updateBroadcastBlock]] `updateBroadcastBlock` Internal Method

[source, scala]
----
updateBroadcastBlock(
  event: SparkListenerBlockUpdated,
  broadcast: BroadcastBlockId): Unit
----

`updateBroadcastBlock`...FIXME

NOTE: `updateBroadcastBlock` is used...FIXME

== [[internal-properties]] Internal Properties

[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `appInfo`
| [[appInfo]] `v1.ApplicationInfo`

| `appSummary`
| [[appSummary]] `AppSummary`

| `liveUpdatePeriodNs`
| [[liveUpdatePeriodNs]]

| `coresPerTask`
| [[coresPerTask]]

Default: `1`

| `liveRDDs`
| [[liveRDDs]] webui:spark-core-LiveRDD.md[LiveRDDs] by RDD ID

| `liveStages`
| [[liveStages]] `LiveStages` by `(Int, Int)`

| `liveTasks`
| [[liveTasks]] `LiveTask` by task ID

| `liveJobs`
| [[liveJobs]] `LiveJob` by job ID

| `liveExecutors`
| [[liveExecutors]] `LiveExecutor` by executor ID

| `pools`
| [[pools]] `SchedulerPool` by FIXME

| `activeExecutorCount`
| [[activeExecutorCount]] Number of active executors
|===
