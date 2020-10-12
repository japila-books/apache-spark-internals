= [[DAGSchedulerEventProcessLoop]] DAGSchedulerEventProcessLoop

*DAGSchedulerEventProcessLoop* is an event processing thread to handle scheduler:DAGSchedulerEvent.md[DAGSchedulerEvents] asynchronously and serially (one by one).

DAGSchedulerEventProcessLoop is registered under the name of *dag-scheduler-event-loop*.

The purpose of the DAGSchedulerEventProcessLoop is to have a separate thread to process events asynchronously alongside scheduler:DAGScheduler.md[DAGScheduler].

[[dagScheduler]]
When created, DAGSchedulerEventProcessLoop gets the reference to the owning scheduler:DAGScheduler.md[DAGScheduler] that it uses to call event handler methods on.

DAGSchedulerEventProcessLoop uses {java-javadoc-url}/java/util/concurrent/LinkedBlockingDeque.html[java.util.concurrent.LinkedBlockingDeque] blocking deque that grows indefinitely (up to {java-javadoc-url}/java/lang/Integer.html#MAX_VALUE[Integer.MAX_VALUE] events).

.DAGSchedulerEvents and Event Handlers
[width="100%",cols="1,1,2",options="header"]
|===
| DAGSchedulerEvent | Event Handler | Trigger

| <<AllJobsCancelled, AllJobsCancelled>> | | DAGScheduler was requested to scheduler:DAGScheduler.md#cancelAllJobs[cancel all running or waiting jobs].

| <<BeginEvent, BeginEvent>> | <<handleBeginEvent, handleBeginEvent>> | scheduler:TaskSetManager.md[TaskSetManager] informs DAGScheduler that a task is starting (through scheduler:DAGScheduler.md#taskStarted[taskStarted]).

| [[CompletionEvent]] `CompletionEvent`
|
a| Posted exclusively when DAGScheduler is requested to <<taskEnded, taskEnded>>

Event handler: <<handleTaskCompletion, handleTaskCompletion>>

`CompletionEvent` holds the following:

* [[CompletionEvent-task]] scheduler:Task.md[Task]
* [[CompletionEvent-reason]] `TaskEndReason`
* [[CompletionEvent-result]] Result of executing the task
* [[CompletionEvent-accumUpdates]] <<spark-accumulators.md#, AccumulatorV2s>>
* [[CompletionEvent-taskInfo]] <<spark-scheduler-TaskInfo.md#, TaskInfo>>

| <<ExecutorAdded, ExecutorAdded>> | <<handleExecutorAdded, handleExecutorAdded>> | DAGScheduler was informed (through scheduler:DAGScheduler.md#executorAdded[executorAdded]) that an executor was spun up on a host.

| [[ExecutorLost]] `ExecutorLost`
| <<handleExecutorLost, handleExecutorLost>>
| Posted to notify scheduler:DAGScheduler.md#executorLost[DAGScheduler that an executor was lost].

`ExecutorLost` conveys the following information:

1. `execId`

2. `ExecutorLossReason`

NOTE: The input `filesLost` for <<handleExecutorLost, handleExecutorLost>> is enabled when `ExecutorLossReason` is `SlaveLost` with `workerLost` enabled (it is disabled by default).

NOTE: <<handleExecutorLost, handleExecutorLost>> is also called when DAGScheduler is informed that a <<handleTaskCompletion-FetchFailed, task has failed due to `FetchFailed` exception>>.

| <<GettingResultEvent, GettingResultEvent>> | |  scheduler:TaskSetManager.md[TaskSetManager] informs DAGScheduler (through scheduler:DAGScheduler.md#taskGettingResult[taskGettingResult]) that a task has completed and results are being fetched remotely.

| <<JobCancelled, JobCancelled>> | <<handleJobCancellation, handleJobCancellation>> | DAGScheduler was requested to scheduler:DAGScheduler.md#cancelJob[cancel a job].

| <<JobGroupCancelled, JobGroupCancelled>> | <<handleJobGroupCancelled, handleJobGroupCancelled>> | DAGScheduler was requested to scheduler:DAGScheduler.md#cancelJobGroup[cancel a job group].

| [[MapStageSubmitted]] `MapStageSubmitted`
| <<handleMapStageSubmitted, handleMapStageSubmitted>>
| Posted to inform DAGScheduler that ROOT:SparkContext.md#submitMapStage[`SparkContext` submitted a `MapStage` for execution] (through scheduler:DAGScheduler.md#submitMapStage[submitMapStage]).

`MapStageSubmitted` conveys the following information:

1. A job identifier (as `jobId`)

2. The [ShuffleDependency](../rdd/ShuffleDependency.md)

3. A `CallSite` (as `callSite`)

4. The [JobListener](JobListener.md) to inform about the status of the stage.

5. `Properties` of the execution

| <<ResubmitFailedStages, ResubmitFailedStages>> | <<resubmitFailedStages, resubmitFailedStages>> | DAGScheduler was informed that a scheduler:DAGScheduler.md#handleTaskCompletion-FetchFailed[task has failed due to `FetchFailed` exception].

| <<StageCancelled, StageCancelled>> | <<handleStageCancellation, handleStageCancellation>> | DAGScheduler was requested to scheduler:DAGScheduler.md#cancelStage[cancel a stage].

| <<TaskSetFailed, TaskSetFailed>> | <<handleTaskSetFailed, handleTaskSetFailed>> | DAGScheduler was requested to scheduler:DAGScheduler.md#taskSetFailed[cancel a `TaskSet`]

|===

== [[GettingResultEvent]] `GettingResultEvent` Event and `handleGetTaskResult` Handler

[source, scala]
----
GettingResultEvent(taskInfo: TaskInfo) extends DAGSchedulerEvent
----

`GettingResultEvent` is a `DAGSchedulerEvent` that triggers <<handleGetTaskResult, handleGetTaskResult>> (on a separate thread).

NOTE: `GettingResultEvent` is posted to inform DAGScheduler (through scheduler:DAGScheduler.md#taskGettingResult[taskGettingResult]) that a scheduler:TaskSetManager.md#handleTaskGettingResult[task fetches results].

=== [[handleGetTaskResult]] `handleGetTaskResult` Handler

[source, scala]
----
handleGetTaskResult(taskInfo: TaskInfo): Unit
----

`handleGetTaskResult` merely posts ROOT:SparkListener.md#SparkListenerTaskGettingResult[SparkListenerTaskGettingResult] (to scheduler:DAGScheduler.md#listenerBus[`LiveListenerBus` Event Bus]).

== [[BeginEvent]] `BeginEvent` Event and `handleBeginEvent` Handler

[source, scala]
----
BeginEvent(task: Task[_], taskInfo: TaskInfo) extends DAGSchedulerEvent
----

`BeginEvent` is a `DAGSchedulerEvent` that triggers <<handleBeginEvent, handleBeginEvent>> (on a separate thread).

NOTE: `BeginEvent` is posted to inform DAGScheduler (through scheduler:DAGScheduler.md#taskStarted[taskStarted]) that a scheduler:TaskSetManager.md#resourceOffer[`TaskSetManager` starts a task].

== [[JobGroupCancelled]] `JobGroupCancelled` Event and `handleJobGroupCancelled` Handler

[source, scala]
----
JobGroupCancelled(groupId: String) extends DAGSchedulerEvent
----

`JobGroupCancelled` is a `DAGSchedulerEvent` that triggers <<handleJobGroupCancelled, handleJobGroupCancelled>> (on a separate thread).

NOTE: `JobGroupCancelled` is posted when DAGScheduler is informed (through scheduler:DAGScheduler.md#cancelJobGroup[cancelJobGroup]) that ROOT:SparkContext.md#cancelJobGroup[`SparkContext` was requested to cancel a job group].

=== [[handleJobGroupCancelled]] `handleJobGroupCancelled` Handler

[source, scala]
----
handleJobGroupCancelled(groupId: String): Unit
----

`handleJobGroupCancelled` finds active jobs in a group and cancels them.

Internally, `handleJobGroupCancelled` computes all the active jobs (registered in the internal scheduler:DAGScheduler.md#activeJobs[collection of active jobs]) that have `spark.jobGroup.id` scheduling property set to `groupId`.

`handleJobGroupCancelled` then <<handleJobCancellation, cancels every active job>> in the group one by one and the cancellation reason: "part of cancelled job group [groupId]".

== [[handleMapStageSubmitted]] Getting Notified that ShuffleDependency Was Submitted -- handleMapStageSubmitted Handler

[source, scala]
----
handleMapStageSubmitted(
  jobId: Int,
  dependency: ShuffleDependency[_, _, _],
  callSite: CallSite,
  listener: JobListener,
  properties: Properties): Unit
----

.`MapStageSubmitted` Event Handling
image::scheduler-handlemapstagesubmitted.png[align="center"]

handleMapStageSubmitted scheduler:DAGScheduler.md#getOrCreateShuffleMapStage[finds or creates a new `ShuffleMapStage`] for the input [ShuffleDependency](../rdd/ShuffleDependency.md) and `jobId`.

handleMapStageSubmitted creates an spark-scheduler-ActiveJob.md[ActiveJob] (with the input `jobId`, `callSite`, `listener` and `properties`, and the `ShuffleMapStage`).

handleMapStageSubmitted scheduler:DAGScheduler.md#clearCacheLocs[clears the internal cache of RDD partition locations].

CAUTION: FIXME Why is this clearing here so important?

You should see the following INFO messages in the logs:

```text
Got map stage job [id] ([callSite]) with [number] output partitions
Final stage: [stage] ([name])
Parents of final stage: [parents]
Missing parents: [missingStages]
```

handleMapStageSubmitted registers the new job in scheduler:DAGScheduler.md#jobIdToActiveJob[jobIdToActiveJob] and scheduler:DAGScheduler.md#activeJobs[activeJobs] internal registries, and scheduler:ShuffleMapStage.md#addActiveJob[with the final `ShuffleMapStage`].

NOTE: `ShuffleMapStage` can have multiple ``ActiveJob``s registered.

handleMapStageSubmitted scheduler:DAGScheduler.md#jobIdToStageIds[finds all the registered stages for the input `jobId`] and collects scheduler:Stage.md#latestInfo[their latest `StageInfo`].

In the end, handleMapStageSubmitted posts ROOT:SparkListener.md#SparkListenerJobStart[SparkListenerJobStart] message to scheduler:LiveListenerBus.md[] and scheduler:DAGScheduler.md#submitStage[submits the `ShuffleMapStage`].

In case the scheduler:ShuffleMapStage.md#isAvailable[`ShuffleMapStage` could be available] already, handleMapStageSubmitted scheduler:DAGScheduler.md#markMapStageJobAsFinished[marks the job finished].

NOTE: DAGScheduler scheduler:MapOutputTracker.md#getStatistics[requests `MapOutputTrackerMaster` for statistics for `ShuffleDependency`] that it uses for handleMapStageSubmitted.

NOTE: `MapOutputTrackerMaster` is passed in when scheduler:DAGScheduler.md#creating-instance[DAGScheduler is created].

When handleMapStageSubmitted could not find or create a `ShuffleMapStage`, you should see the following WARN message in the logs.

```
WARN Creating new stage failed due to exception - job: [id]
```

handleMapStageSubmitted notifies [`listener` about the job failure](JobListener.md#jobFailed) and exits.

NOTE: `MapStageSubmitted` event processing is very similar to <<JobSubmitted, JobSubmitted>> events.

[TIP]
====
The difference between <<handleMapStageSubmitted, handleMapStageSubmitted>> and <<handleJobSubmitted, handleJobSubmitted>>:

* handleMapStageSubmitted has a [ShuffleDependency](../rdd/ShuffleDependency.md) among the input parameters while handleJobSubmitted has `finalRDD`, `func`, and `partitions`.
* handleMapStageSubmitted initializes `finalStage` as `getShuffleMapStage(dependency, jobId)` while handleJobSubmitted as `finalStage = newResultStage(finalRDD, func, partitions, jobId, callSite)`
* handleMapStageSubmitted INFO logs `Got map stage job %s (%s) with %d output partitions` with `dependency.rdd.partitions.length` while handleJobSubmitted does `Got job %s (%s) with %d output partitions` with `partitions.length`.
* FIXME: Could the above be cut to `ActiveJob.numPartitions`?
* handleMapStageSubmitted adds a new job with `finalStage.addActiveJob(job)` while handleJobSubmitted sets with `finalStage.setActiveJob(job)`.
* handleMapStageSubmitted checks if the final stage has already finished, tells the listener and removes it using the code:
+
[source, scala]
----
if (finalStage.isAvailable) {
  markMapStageJobAsFinished(job, mapOutputTracker.getStatistics(dependency))
}
----
====

== [[resubmitFailedStages]] `resubmitFailedStages` Handler

[source, scala]
----
resubmitFailedStages(): Unit
----

`resubmitFailedStages` iterates over the internal scheduler:DAGScheduler.md#failedStages[collection of failed stages] and scheduler:DAGScheduler.md#submitStage[submits] them.

NOTE: `resubmitFailedStages` does nothing when there are no scheduler:DAGScheduler.md#failedStages[failed stages reported].

You should see the following INFO message in the logs:

```
INFO Resubmitting failed stages
```

`resubmitFailedStages` scheduler:DAGScheduler.md#clearCacheLocs[clears the internal cache of RDD partition locations] first. It then makes a copy of the scheduler:DAGScheduler.md#failedStages[collection of failed stages] so DAGScheduler can track failed stages afresh.

NOTE: At this point DAGScheduler has no failed stages reported.

The previously-reported failed stages are sorted by the corresponding job ids in incremental order and scheduler:DAGScheduler.md#submitStage[resubmitted].

== [[handleExecutorLost]] Getting Notified that Executor Is Lost -- `handleExecutorLost` Handler

[source, scala]
----
handleExecutorLost(
  execId: String,
  filesLost: Boolean,
  maybeEpoch: Option[Long] = None): Unit
----

`handleExecutorLost` checks whether the input optional `maybeEpoch` is defined and if not requests the scheduler:MapOutputTracker.md#getEpoch[current epoch from `MapOutputTrackerMaster`].

NOTE: `MapOutputTrackerMaster` is passed in (as `mapOutputTracker`) when scheduler:DAGScheduler.md#creating-instance[DAGScheduler is created].

CAUTION: FIXME When is `maybeEpoch` passed in?

.DAGScheduler.handleExecutorLost
image::dagscheduler-handleExecutorLost.png[align="center"]

Recurring `ExecutorLost` events lead to the following repeating DEBUG message in the logs:

```
DEBUG Additional executor lost message for [execId] (epoch [currentEpoch])
```

NOTE: `handleExecutorLost` handler uses `DAGScheduler`'s `failedEpoch` and FIXME internal registries.

Otherwise, when the executor `execId` is not in the scheduler:DAGScheduler.md#failedEpoch[list of executor lost] or the executor failure's epoch is smaller than the input `maybeEpoch`, the executor's lost event is recorded in scheduler:DAGScheduler.md#failedEpoch[`failedEpoch` internal registry].

CAUTION: FIXME Describe the case above in simpler non-technical words. Perhaps change the order, too.

You should see the following INFO message in the logs:

```
INFO Executor lost: [execId] (epoch [epoch])
```

storage:BlockManagerMaster.md#removeExecutor[`BlockManagerMaster` is requested to remove the lost executor `execId`].

CAUTION: FIXME Review what's `filesLost`.

`handleExecutorLost` exits unless the `ExecutorLost` event was for a map output fetch operation (and the input `filesLost` is `true`) or deploy:ExternalShuffleService.md[external shuffle service] is _not_ used.

In such a case, you should see the following INFO message in the logs:

```
INFO Shuffle files lost for executor: [execId] (epoch [epoch])
```

`handleExecutorLost` walks over all scheduler:ShuffleMapStage.md[ShuffleMapStage]s in scheduler:DAGScheduler.md#shuffleToMapStage[DAGScheduler's `shuffleToMapStage` internal registry] and do the following (in order):

1. `ShuffleMapStage.removeOutputsOnExecutor(execId)` is called
2. scheduler:MapOutputTrackerMaster.md#registerMapOutputs[MapOutputTrackerMaster.registerMapOutputs(shuffleId, stage.outputLocInMapOutputTrackerFormat(), changeEpoch = true)] is called.

In case scheduler:DAGScheduler.md#shuffleToMapStage[DAGScheduler's `shuffleToMapStage` internal registry] has no shuffles registered,  scheduler:MapOutputTrackerMaster.md#incrementEpoch[`MapOutputTrackerMaster` is requested to increment epoch].

Ultimatelly, DAGScheduler scheduler:DAGScheduler.md#clearCacheLocs[clears the internal cache of RDD partition locations].

== [[handleJobCancellation]] `handleJobCancellation` Handler

[source, scala]
----
handleJobCancellation(jobId: Int, reason: String = "")
----

`handleJobCancellation` first makes sure that the input `jobId` has been registered earlier (using scheduler:DAGScheduler.md#jobIdToStageIds[jobIdToStageIds] internal registry).

If the input `jobId` is not known to DAGScheduler, you should see the following DEBUG message in the logs:

```
DEBUG DAGScheduler: Trying to cancel unregistered job [jobId]
```

Otherwise, `handleJobCancellation` scheduler:DAGScheduler.md#failJobAndIndependentStages[fails the active job and all independent stages] (by looking up the active job using scheduler:DAGScheduler.md#jobIdToActiveJob[jobIdToActiveJob]) with failure reason:

```
Job [jobId] cancelled [reason]
```

== [[handleTaskCompletion]] Getting Notified That Task Has Finished -- `handleTaskCompletion` Handler

[source, scala]
----
handleTaskCompletion(event: CompletionEvent): Unit
----

.DAGScheduler and CompletionEvent
image::dagscheduler-tasksetmanager.png[align="center"]

NOTE: `CompletionEvent` holds contextual information about the completed task.

.`CompletionEvent` Properties
[width="100%",cols="1,2",options="header"]
|===
| Property | Description

| `task`
| Completed scheduler:Task.md[Task] instance for a stage, partition and stage attempt.

| `reason`
| `TaskEndReason`...FIXME

| `result`
| Result of the task

| `accumUpdates`
| spark-accumulators.md[Accumulators] with...FIXME

| `taskInfo`
| spark-scheduler-TaskInfo.md[TaskInfo]
|===

`handleTaskCompletion` starts by scheduler:OutputCommitCoordinator.md#taskCompleted[notifying `OutputCommitCoordinator` that a task completed].

`handleTaskCompletion` executor:TaskMetrics.md#fromAccumulators[re-creates `TaskMetrics`] (using <<CompletionEvent-accumUpdates, `accumUpdates` accumulators of the input `event`>>).

NOTE: executor:TaskMetrics.md[] can be empty when the task has failed.

`handleTaskCompletion` announces task completion application-wide (by posting a ROOT:SparkListener.md#SparkListenerTaskEnd[SparkListenerTaskEnd] to scheduler:LiveListenerBus.md[]).

`handleTaskCompletion` checks the stage of the task out in the scheduler:DAGScheduler.md#stageIdToStage[`stageIdToStage` internal registry] and if not found, it simply exits.

`handleTaskCompletion` branches off per `TaskEndReason` (as `event.reason`).

.`handleTaskCompletion` Branches per `TaskEndReason`
[cols="1,2",options="header",width="100%"]
|===
| TaskEndReason
| Description

| <<handleTaskCompletion-Success, Success>>
| Acts according to the type of the task that completed, i.e. <<handleTaskCompletion-Success-ShuffleMapTask, ShuffleMapTask>> and <<handleTaskCompletion-Success-ResultTask, ResultTask>>.

| <<handleTaskCompletion-Resubmitted, Resubmitted>>
|

| <<handleTaskCompletion-FetchFailed, FetchFailed>>
|

| `ExceptionFailure`
| scheduler:DAGScheduler.md#updateAccumulators[Updates accumulators] (with partial values from the task).

| `ExecutorLostFailure`
| Does nothing

| `TaskCommitDenied`
| Does nothing

| `TaskKilled`
| Does nothing

| `TaskResultLost`
| Does nothing

| `UnknownReason`
| Does nothing
|===

=== [[handleTaskCompletion-Success]] Handling Successful Task Completion

When a task has finished successfully (i.e. `Success` end reason), `handleTaskCompletion` marks the partition as no longer pending (i.e. the partition the task worked on is removed from `pendingPartitions` of the stage).

NOTE: A `Stage` tracks its own pending partitions using scheduler:Stage.md#pendingPartitions[`pendingPartitions` property].

`handleTaskCompletion` branches off given the type of the task that completed, i.e. <<handleTaskCompletion-Success-ShuffleMapTask, ShuffleMapTask>> and <<handleTaskCompletion-Success-ResultTask, ResultTask>>.

==== [[handleTaskCompletion-Success-ResultTask]] Handling Successful `ResultTask` Completion

For scheduler:ResultTask.md[ResultTask], the stage is assumed a scheduler:ResultStage.md[ResultStage].

`handleTaskCompletion` finds the `ActiveJob` associated with the `ResultStage`.

NOTE: scheduler:ResultStage.md[ResultStage] tracks the optional `ActiveJob` as scheduler:ResultStage.md#activeJob[`activeJob` property]. There could only be one active job for a `ResultStage`.

If there is _no_ job for the `ResultStage`, you should see the following INFO message in the logs:

```
Ignoring result from [task] because its job has finished
```

Otherwise, when the `ResultStage` has a `ActiveJob`, `handleTaskCompletion` checks the status of the partition output for the partition the `ResultTask` ran for.

NOTE: `ActiveJob` tracks task completions in `finished` property with flags for every partition in a stage. When the flag for a partition is enabled (i.e. `true`), it is assumed that the partition has been computed (and no results from any `ResultTask` are expected and hence simply ignored).

CAUTION: FIXME Describe why could a partition has more `ResultTask` running.

`handleTaskCompletion` ignores the `CompletionEvent` when the partition has already been marked as completed for the stage and simply exits.

`handleTaskCompletion` scheduler:DAGScheduler.md#updateAccumulators[updates accumulators].

The partition for the `ActiveJob` (of the `ResultStage`) is marked as computed and the number of partitions calculated increased.

NOTE: `ActiveJob` tracks what partitions have already been computed and their number.

If the `ActiveJob` has finished (when the number of partitions computed is exactly the number of partitions in a stage) `handleTaskCompletion` does the following (in order):

1. scheduler:DAGScheduler.md#markStageAsFinished[Marks `ResultStage` computed].
2. scheduler:DAGScheduler.md#cleanupStateForJobAndIndependentStages[Cleans up after `ActiveJob` and independent stages].
3. Announces the job completion application-wide (by posting a ROOT:SparkListener.md#SparkListenerJobEnd[SparkListenerJobEnd] to scheduler:LiveListenerBus.md[]).

In the end, `handleTaskCompletion` [notifies `JobListener` of the `ActiveJob` that the task succeeded](JobListener.md#taskSucceeded).

NOTE: A task succeeded notification holds the output index and the result.

When the notification throws an exception (because it runs user code), `handleTaskCompletion` [notifies `JobListener` about the failure](JobListener.md#jobFailed) (wrapping it inside a `SparkDriverExecutionException` exception).

==== [[handleTaskCompletion-Success-ShuffleMapTask]] Handling Successful `ShuffleMapTask` Completion

For scheduler:ShuffleMapTask.md[ShuffleMapTask], the stage is assumed a  scheduler:ShuffleMapStage.md[ShuffleMapStage].

`handleTaskCompletion` scheduler:DAGScheduler.md#updateAccumulators[updates accumulators].

The task's result is assumed scheduler:MapStatus.md[MapStatus] that knows the executor where the task has finished.

You should see the following DEBUG message in the logs:

```
DEBUG DAGScheduler: ShuffleMapTask finished on [execId]
```

If the executor is registered in scheduler:DAGScheduler.md#failedEpoch[`failedEpoch` internal registry] and the epoch of the completed task is not greater than that of the executor (as in `failedEpoch` registry), you should see the following INFO message in the logs:

```
INFO DAGScheduler: Ignoring possibly bogus [task] completion from executor [executorId]
```

Otherwise, `handleTaskCompletion` scheduler:ShuffleMapStage.md#addOutputLoc[registers the `MapStatus` result for the partition with the stage] (of the completed task).

`handleTaskCompletion` does more processing only if the `ShuffleMapStage` is registered as still running (in scheduler:DAGScheduler.md#runningStages[`runningStages` internal registry]) and the scheduler:Stage.md#pendingPartitions[`ShuffleMapStage` stage has no pending partitions to compute].

The `ShuffleMapStage` is <<markStageAsFinished, marked as finished>>.

You should see the following INFO messages in the logs:

```
INFO DAGScheduler: looking for newly runnable stages
INFO DAGScheduler: running: [runningStages]
INFO DAGScheduler: waiting: [waitingStages]
INFO DAGScheduler: failed: [failedStages]
```

`handleTaskCompletion` scheduler:MapOutputTrackerMaster.md#registerMapOutputs[registers the shuffle map outputs of the `ShuffleDependency` with `MapOutputTrackerMaster`] (with the epoch incremented) and scheduler:DAGScheduler.md#clearCacheLocs[clears internal cache of the stage's RDD block locations].

NOTE: scheduler:MapOutputTrackerMaster.md[MapOutputTrackerMaster] is given when scheduler:DAGScheduler.md#creating-instance[DAGScheduler is created].

If the scheduler:ShuffleMapStage.md#isAvailable[`ShuffleMapStage` stage is ready], all scheduler:ShuffleMapStage.md#mapStageJobs[active jobs of the stage] (aka _map-stage jobs_) are scheduler:DAGScheduler.md#markMapStageJobAsFinished[marked as finished] (with scheduler:MapOutputTrackerMaster.md#getStatistics[`MapOutputStatistics` from `MapOutputTrackerMaster` for the `ShuffleDependency`]).

NOTE: A `ShuffleMapStage` stage is ready (aka _available_) when all partitions have shuffle outputs, i.e. when their tasks have completed.

Eventually, `handleTaskCompletion` scheduler:DAGScheduler.md#submitWaitingChildStages[submits waiting child stages (of the ready `ShuffleMapStage`)].

If however the `ShuffleMapStage` is _not_ ready, you should see the following INFO message in the logs:

```
INFO DAGScheduler: Resubmitting [shuffleStage] ([shuffleStage.name]) because some of its tasks had failed: [missingPartitions]
```

In the end, `handleTaskCompletion` scheduler:DAGScheduler.md#submitStage[submits the `ShuffleMapStage` for execution].

=== [[handleTaskCompletion-Resubmitted]] TaskEndReason: Resubmitted

For `Resubmitted` case, you should see the following INFO message in the logs:

```
INFO Resubmitted [task], so marking it as still running
```

The task (by `task.partitionId`) is added to the collection of pending partitions of the stage (using `stage.pendingPartitions`).

TIP: A stage knows how many partitions are yet to be calculated. A task knows about the partition id for which it was launched.

=== [[handleTaskCompletion-FetchFailed]] Task Failed with `FetchFailed` Exception -- TaskEndReason: FetchFailed

[source, scala]
----
FetchFailed(
  bmAddress: BlockManagerId,
  shuffleId: Int,
  mapId: Int,
  reduceId: Int,
  message: String)
extends TaskFailedReason
----

.`FetchFailed` Properties
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `bmAddress`
| storage:BlockManagerId.md[]

| `shuffleId`
| Used when...

| `mapId`
| Used when...

| `reduceId`
| Used when...

| `failureMessage`
| Used when...
|===

NOTE: A task knows about the id of the stage it belongs to.

When `FetchFailed` happens, `stageIdToStage` is used to access the failed stage (using `task.stageId` and the `task` is available in `event` in `handleTaskCompletion(event: CompletionEvent)`). `shuffleToMapStage` is used to access the map stage (using `shuffleId`).

If `failedStage.latestInfo.attemptId != task.stageAttemptId`, you should see the following INFO in the logs:

```
INFO Ignoring fetch failure from [task] as it's from [failedStage] attempt [task.stageAttemptId] and there is a more recent attempt for that stage (attempt ID [failedStage.latestInfo.attemptId]) running
```

CAUTION: FIXME What does `failedStage.latestInfo.attemptId != task.stageAttemptId` mean?

And the case finishes. Otherwise, the case continues.

If the failed stage is in `runningStages`, the following INFO message shows in the logs:

```
INFO Marking [failedStage] ([failedStage.name]) as failed due to a fetch failure from [mapStage] ([mapStage.name])
```

`markStageAsFinished(failedStage, Some(failureMessage))` is called.

CAUTION: FIXME What does `markStageAsFinished` do?

If the failed stage is not in `runningStages`, the following DEBUG message shows in the logs:

```
DEBUG Received fetch failure from [task], but its from [failedStage] which is no longer running
```

When `disallowStageRetryForTest` is set, `abortStage(failedStage, "Fetch failure will not retry stage due to testing config", None)` is called.

CAUTION: FIXME Describe `disallowStageRetryForTest` and `abortStage`.

If the scheduler:Stage.md#failedOnFetchAndShouldAbort[number of fetch failed attempts for the stage exceeds the allowed number], the scheduler:DAGScheduler.md#abortStage[failed stage is aborted] with the reason:

```
[failedStage] ([name]) has failed the maximum allowable number of times: 4. Most recent failure reason: [failureMessage]
```

If there are no failed stages reported (scheduler:DAGScheduler.md#failedStages[DAGScheduler.failedStages] is empty), the following INFO shows in the logs:

```
INFO Resubmitting [mapStage] ([mapStage.name]) and [failedStage] ([failedStage.name]) due to fetch failure
```

And the following code is executed:

```
messageScheduler.schedule(
  new Runnable {
    override def run(): Unit = eventProcessLoop.post(ResubmitFailedStages)
  }, DAGScheduler.RESUBMIT_TIMEOUT, TimeUnit.MILLISECONDS)
```

CAUTION: FIXME What does the above code do?

For all the cases, the failed stage and map stages are both added to the internal scheduler:DAGScheduler.md#failedStages[registry of failed stages].

If `mapId` (in the `FetchFailed` object for the case) is provided, the map stage output is cleaned up (as it is broken) using `mapStage.removeOutputLoc(mapId, bmAddress)` and scheduler:MapOutputTracker.md#unregisterMapOutput[MapOutputTrackerMaster.unregisterMapOutput(shuffleId, mapId, bmAddress)] methods.

CAUTION: FIXME What does `mapStage.removeOutputLoc` do?

If `BlockManagerId` (as `bmAddress` in the `FetchFailed` object) is defined, `handleTaskCompletion` <<handleExecutorLost, notifies DAGScheduler that an executor was lost>> (with `filesLost` enabled and `maybeEpoch` from the scheduler:Task.md#epoch[Task] that completed).
