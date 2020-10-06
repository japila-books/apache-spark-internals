= [[DAGScheduler]] DAGScheduler

[NOTE]
====
The introduction that follows was highly influenced by the scaladoc of https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala[org.apache.spark.scheduler.DAGScheduler]. As DAGScheduler is a private class it does not appear in the official API documentation. You are strongly encouraged to read https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala[the sources] and only then read this and the related pages afterwards.
====

== [[introduction]] Introduction

*DAGScheduler* is the scheduling layer of Apache Spark that implements *stage-oriented scheduling*.

DAGScheduler transforms a *logical execution plan* (i.e. rdd:spark-rdd-lineage.md[RDD lineage] of dependencies built using rdd:spark-rdd-transformations.md[RDD transformations]) to a *physical execution plan* (using scheduler:Stage.md[stages]).

.DAGScheduler Transforming RDD Lineage Into Stage DAG
image::dagscheduler-rdd-lineage-stage-dag.png[align="center"]

After an rdd:spark-rdd-actions.md[action] has been called, ROOT:SparkContext.md[SparkContext] hands over a logical plan to DAGScheduler that it in turn translates to a set of stages that are submitted as scheduler:TaskSet.md[TaskSets] for execution.

.Executing action leads to new ResultStage and ActiveJob in DAGScheduler
image::dagscheduler-rdd-partitions-job-resultstage.png[align="center"]

The fundamental concepts of DAGScheduler are *jobs* and *stages* (refer to scheduler:spark-scheduler-ActiveJob.md[Jobs] and scheduler:Stage.md[Stages] respectively) that it tracks through <<internal-registries, internal registries and counters>>.

DAGScheduler works solely on the driver and is created as part of ROOT:SparkContext.md#creating-instance[SparkContext's initialization] (right after scheduler:TaskScheduler.md[TaskScheduler] and scheduler:SchedulerBackend.md[SchedulerBackend] are ready).

.DAGScheduler as created by SparkContext with other services
image::dagscheduler-new-instance.png[align="center"]

DAGScheduler does three things in Spark (thorough explanations follow):

* Computes an *execution DAG*, i.e. DAG of stages, for a job.
* Determines the <<preferred-locations, preferred locations>> to run each task on.
* Handles failures due to *shuffle output files* being lost.

DAGScheduler computes https://en.wikipedia.org/wiki/Directed_acyclic_graph[a directed acyclic graph (DAG)] of stages for each job, keeps track of which RDDs and stage outputs are materialized, and finds a minimal schedule to run jobs. It then submits stages to scheduler:TaskScheduler.md[TaskScheduler].

.DAGScheduler.submitJob
image::dagscheduler-submitjob.png[align="center"]

In addition to coming up with the execution DAG, DAGScheduler also determines the preferred locations to run each task on, based on the current cache status, and passes the information to scheduler:TaskScheduler.md[TaskScheduler].

DAGScheduler tracks which rdd:spark-rdd-caching.md[RDDs are cached (or persisted)] to avoid "recomputing" them, i.e. redoing the map side of a shuffle. DAGScheduler remembers what scheduler:ShuffleMapStage.md[ShuffleMapStage]s have already produced output files (that are stored in storage:BlockManager.md[BlockManager]s).

DAGScheduler is only interested in cache location coordinates, i.e. host and executor id, per partition of a RDD.

Furthermore, it handles failures due to shuffle output files being lost, in which case old stages may need to be resubmitted. Failures within a stage that are not caused by shuffle file loss are handled by the TaskScheduler itself, which will retry each task a small number of times before cancelling the whole stage.

DAGScheduler uses an *event queue architecture* in which a thread can post `DAGSchedulerEvent` events, e.g. a new job or stage being submitted, that DAGScheduler reads and executes sequentially. See the section <<event-loop, Internal Event Loop - dag-scheduler-event-loop>>.

DAGScheduler runs stages in topological order.

DAGScheduler uses ROOT:SparkContext.md[SparkContext], scheduler:TaskScheduler.md[TaskScheduler], scheduler:LiveListenerBus.md[], scheduler:MapOutputTracker.md[MapOutputTracker] and storage:BlockManager.md[BlockManager] for its services. However, at the very minimum, DAGScheduler takes a `SparkContext` only (and requests `SparkContext` for the other services).

When DAGScheduler schedules a job as a result of rdd:index.md#actions[executing an action on a RDD] or ROOT:SparkContext.md#runJob[calling SparkContext.runJob() method directly], it spawns parallel tasks to compute (partial) results per partition.

== [[creating-instance]][[initialization]] Creating Instance

DAGScheduler takes the following to be created:

* [[sc]] ROOT:SparkContext.md[]
* <<taskScheduler, TaskScheduler>>
* [[listenerBus]] scheduler:LiveListenerBus.md[]
* [[mapOutputTracker]] scheduler:MapOutputTrackerMaster.md[MapOutputTrackerMaster]
* [[blockManagerMaster]] storage:BlockManagerMaster.md[BlockManagerMaster]
* [[env]] core:SparkEnv.md[]
* [[clock]] Clock (default: SystemClock)

While being created, DAGScheduler scheduler:TaskScheduler.md#setDAGScheduler[associates itself] with the <<taskScheduler, TaskScheduler>> and starts <<eventProcessLoop, DAGScheduler Event Bus>>.

== [[event-loop]][[eventProcessLoop]] DAGScheduler Event Bus

DAGScheduler uses an scheduler:DAGSchedulerEventProcessLoop.md[event bus] to process scheduling-related events on a separate thread (one by one and asynchronously).

DAGScheduler starts the event bus when created and stops it when requested to <<stop, stop>>.

DAGScheduler defines <<event-posting-methods, event-posting methods>> that allow posting DAGSchedulerEvent events to the event bus.

[[event-posting-methods]]
.DAGScheduler Event Posting Methods
[cols="20m,20m,60",options="header",width="100%"]
|===
| Method
| Event Posted
| Trigger

| [[cancelAllJobs]] cancelAllJobs
| scheduler:DAGSchedulerEvent.md#AllJobsCancelled[AllJobsCancelled]
| SparkContext is requested to ROOT:SparkContext.md#cancelAllJobs[cancel all running or scheduled Spark jobs]

| [[cancelJob]] cancelJob
| scheduler:DAGSchedulerEvent.md#JobCancelled[JobCancelled]
| ROOT:SparkContext.md#cancelJob[SparkContext] or scheduler:spark-scheduler-JobWaiter.md[JobWaiter] are requested to cancel a Spark job

| [[cancelJobGroup]] cancelJobGroup
| scheduler:DAGSchedulerEvent.md#JobGroupCancelled[JobGroupCancelled]
| SparkContext is requested to ROOT:SparkContext.md#cancelJobGroup[cancel a job group]

| [[cancelStage]] cancelStage
| scheduler:DAGSchedulerEvent.md#StageCancelled[StageCancelled]
| SparkContext is requested to ROOT:SparkContext.md#cancelStage[cancel a stage]

| [[executorAdded]] executorAdded
| scheduler:DAGSchedulerEvent.md#ExecutorAdded[ExecutorAdded]
| TaskSchedulerImpl is requested to scheduler:TaskSchedulerImpl.md#resourceOffers[handle resource offers] (and a new executor is found in the resource offers)

| [[executorLost]] executorLost
| scheduler:DAGSchedulerEvent.md#ExecutorLost[ExecutorLost]
| TaskSchedulerImpl is requested to scheduler:TaskSchedulerImpl.md#statusUpdate[handle a task status update] (and a task gets lost which is used to indicate that the executor got broken and hence should be considered lost) or scheduler:TaskSchedulerImpl.md#executorLost[executorLost]

| [[runApproximateJob]] runApproximateJob
| scheduler:DAGSchedulerEvent.md#JobSubmitted[JobSubmitted]
| SparkContext is requested to ROOT:SparkContext.md#runApproximateJob[run an approximate job]

| [[speculativeTaskSubmitted]] speculativeTaskSubmitted
| scheduler:DAGSchedulerEvent.md#SpeculativeTaskSubmitted[SpeculativeTaskSubmitted]
|

| [[submitJob]] submitJob
| scheduler:DAGSchedulerEvent.md#JobSubmitted[JobSubmitted]
a|

* SparkContext is requested to ROOT:SparkContext.md#submitJob[submits a job]

* DAGScheduler is requested to <<runJob, run a job>>

| [[submitMapStage]] submitMapStage
| scheduler:DAGSchedulerEvent.md#MapStageSubmitted[MapStageSubmitted]
| SparkContext is requested to ROOT:SparkContext.md#submitMapStage[submit a MapStage for execution].

| [[taskEnded]] taskEnded
| scheduler:DAGSchedulerEvent.md#CompletionEvent[CompletionEvent]
| TaskSetManager is requested to scheduler:TaskSetManager.md#handleSuccessfulTask[handleSuccessfulTask], scheduler:TaskSetManager.md#handleFailedTask[handleFailedTask], and scheduler:TaskSetManager.md#executorLost[executorLost]

| [[taskGettingResult]] taskGettingResult
| scheduler:DAGSchedulerEvent.md#GettingResultEvent[GettingResultEvent]
| TaskSetManager is requested to scheduler:TaskSetManager.md#handleTaskGettingResult[handle a task fetching result]

| [[taskSetFailed]] taskSetFailed
| scheduler:DAGSchedulerEvent.md#TaskSetFailed[TaskSetFailed]
| TaskSetManager is requested to scheduler:TaskSetManager.md#abort[abort]

| [[taskStarted]] taskStarted
| scheduler:DAGSchedulerEvent.md#BeginEvent[BeginEvent]
| TaskSetManager is requested to scheduler:TaskSetManager.md#resourceOffer[start a task]

| [[workerRemoved]] workerRemoved
| scheduler:DAGSchedulerEvent.md#WorkerRemoved[WorkerRemoved]
| TaskSchedulerImpl is requested to scheduler:TaskSchedulerImpl.md#workerRemoved[handle a removed worker event]

|===

== [[taskScheduler]] DAGScheduler and TaskScheduler

DAGScheduler is given a scheduler:TaskScheduler.md[TaskScheduler] when <<creating-instance, created>>.

DAGScheduler uses the TaskScheduler for the following:

* <<submitMissingTasks, Submitting missing tasks of a stage>>

* <<handleTaskCompletion, Handling task completion (CompletionEvent)>>

* <<killTaskAttempt, Killing a task>>

* <<failJobAndIndependentStages, Failing a job and all other independent single-job stages>>

* <<stop, Stopping itself>>

== [[runJob]] Running Job

[source, scala]
----
runJob[T, U](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int],
  callSite: CallSite,
  resultHandler: (Int, U) => Unit,
  properties: Properties): Unit
----

runJob submits an action job to the DAGScheduler and waits for a result.

Internally, runJob executes <<submitJob, submitJob>> and then waits until a result comes using scheduler:spark-scheduler-JobWaiter.md[JobWaiter].

When the job succeeds, you should see the following INFO message in the logs:

```
Job [jobId] finished: [callSite], took [time] s
```

When the job fails, you should see the following INFO message in the logs and the exception (that led to the failure) is thrown.

```
Job [jobId] failed: [callSite], took [time] s
```

runJob is used when SparkContext is requested to ROOT:SparkContext.md#runJob[run a job].

== [[cacheLocs]][[clearCacheLocs]] Partition Placement Preferences

DAGScheduler keeps track of block locations per RDD and partition.

DAGScheduler uses scheduler:TaskLocation.md[TaskLocation] that includes a host name and an executor id on that host (as `ExecutorCacheTaskLocation`).

The keys are RDDs (their ids) and the values are arrays indexed by partition numbers.

Each entry is a set of block locations where a RDD partition is cached, i.e. the storage:BlockManager.md[BlockManager]s of the blocks.

Initialized empty when <<creating-instance, DAGScheduler is created>>.

Used when DAGScheduler is requested for the <<getCacheLocs, locations of the cache blocks of a RDD>> or <<clearCacheLocs, clear them>>.

== [[activeJobs]] ActiveJobs

DAGScheduler tracks scheduler:spark-scheduler-ActiveJob.md[ActiveJobs]:

* Adds a new ActiveJob when requested to handle <<handleJobSubmitted, JobSubmitted>> or <<handleMapStageSubmitted, MapStageSubmitted>> events

* Removes an ActiveJob when requested to <<cleanupStateForJobAndIndependentStages, clean up after an ActiveJob and independent stages>>.

* Removes all ActiveJobs when requested to <<doCancelAllJobs, doCancelAllJobs>>.

DAGScheduler uses ActiveJobs registry when requested to handle <<handleJobGroupCancelled, JobGroupCancelled>> or <<handleTaskCompletion, TaskCompletion>> events, to <<cleanUpAfterSchedulerStop, cleanUpAfterSchedulerStop>> and to <<abortStage, abort a stage>>.

The number of ActiveJobs is available using metrics:spark-scheduler-DAGSchedulerSource.md#job.activeJobs[job.activeJobs] performance metric.

== [[createResultStage]] Creating ResultStage for RDD

[source, scala]
----
createResultStage(
  rdd: RDD[_],
  func: (TaskContext, Iterator[_]) => _,
  partitions: Array[Int],
  jobId: Int,
  callSite: CallSite): ResultStage
----

createResultStage...FIXME

createResultStage is used when DAGScheduler is requested to <<handleJobSubmitted, handle a JobSubmitted event>>.

== [[createShuffleMapStage]] Creating ShuffleMapStage for ShuffleDependency

[source, scala]
----
createShuffleMapStage(
  shuffleDep: ShuffleDependency[_, _, _],
  jobId: Int): ShuffleMapStage
----

createShuffleMapStage creates a scheduler:ShuffleMapStage.md[ShuffleMapStage] for the given rdd:ShuffleDependency.md[ShuffleDependency] as follows:

* Stage ID is generated based on <<nextStageId, nextStageId>> internal counter

* RDD is taken from the given rdd:ShuffleDependency.md#rdd[ShuffleDependency]

* Number of tasks is the number of rdd:RDD.md#partitions[partitions] of the RDD

* <<getOrCreateParentStages, Parent RDDs>>

* <<mapOutputTracker, MapOutputTrackerMaster>>

createShuffleMapStage registers the ShuffleMapStage in the <<stageIdToStage, stageIdToStage>> and <<shuffleIdToMapStage, shuffleIdToMapStage>> internal registries.

createShuffleMapStage <<updateJobIdStageIdMaps, updateJobIdStageIdMaps>>.

createShuffleMapStage requests the <<mapOutputTracker, MapOutputTrackerMaster>> to scheduler:MapOutputTrackerMaster.md#containsShuffle[check whether it contains the shuffle ID or not].

If not, createShuffleMapStage prints out the following INFO message to the logs and requests the <<mapOutputTracker, MapOutputTrackerMaster>> to scheduler:MapOutputTrackerMaster.md#registerShuffle[register the shuffle].

[source,plaintext]
----
Registering RDD [id] ([creationSite]) as input to shuffle [shuffleId]
----

.DAGScheduler Asks `MapOutputTrackerMaster` Whether Shuffle Map Output Is Already Tracked
image::DAGScheduler-MapOutputTrackerMaster-containsShuffle.png[align="center"]

createShuffleMapStage is used when DAGScheduler is requested to <<getOrCreateShuffleMapStage, find or create a ShuffleMapStage for a given ShuffleDependency>>.

== [[cleanupStateForJobAndIndependentStages]] Cleaning Up After Job and Independent Stages

[source, scala]
----
cleanupStateForJobAndIndependentStages(
  job: ActiveJob): Unit
----

cleanupStateForJobAndIndependentStages cleans up the state for `job` and any stages that are _not_ part of any other job.

cleanupStateForJobAndIndependentStages looks the `job` up in the internal <<jobIdToStageIds, jobIdToStageIds>> registry.

If no stages are found, the following ERROR is printed out to the logs:

```
No stages registered for job [jobId]
```

Oterwise, cleanupStateForJobAndIndependentStages uses <<stageIdToStage, stageIdToStage>> registry to find the stages (the real objects not ids!).

For each stage, cleanupStateForJobAndIndependentStages reads the jobs the stage belongs to.

If the `job` does not belong to the jobs of the stage, the following ERROR is printed out to the logs:

```
Job [jobId] not registered for stage [stageId] even though that stage was registered for the job
```

If the `job` was the only job for the stage, the stage (and the stage id) gets cleaned up from the registries, i.e. <<runningStages, runningStages>>, <<shuffleIdToMapStage, shuffleIdToMapStage>>, <<waitingStages, waitingStages>>, <<failedStages, failedStages>> and <<stageIdToStage, stageIdToStage>>.

While removing from <<runningStages, runningStages>>, you should see the following DEBUG message in the logs:

```
Removing running stage [stageId]
```

While removing from <<waitingStages, waitingStages>>, you should see the following DEBUG message in the logs:

```
Removing stage [stageId] from waiting set.
```

While removing from <<failedStages, failedStages>>, you should see the following DEBUG message in the logs:

```
Removing stage [stageId] from failed set.
```

After all cleaning (using <<stageIdToStage, stageIdToStage>> as the source registry), if the stage belonged to the one and only `job`, you should see the following DEBUG message in the logs:

```
After removal of stage [stageId], remaining stages = [stageIdToStage.size]
```

The `job` is removed from <<jobIdToStageIds, jobIdToStageIds>>, <<jobIdToActiveJob, jobIdToActiveJob>>, <<activeJobs, activeJobs>> registries.

The final stage of the `job` is removed, i.e. scheduler:ResultStage.md#removeActiveJob[ResultStage] or scheduler:ShuffleMapStage.md#removeActiveJob[ShuffleMapStage].

cleanupStateForJobAndIndependentStages is used in scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion-Success-ResultTask[handleTaskCompletion when a `ResultTask` has completed successfully], <<failJobAndIndependentStages, failJobAndIndependentStages>> and <<markMapStageJobAsFinished, markMapStageJobAsFinished>>.

== [[markMapStageJobAsFinished]] Marking ShuffleMapStage Job Finished

[source, scala]
----
markMapStageJobAsFinished(
  job: ActiveJob,
  stats: MapOutputStatistics): Unit
----

markMapStageJobAsFinished marks the active `job` finished and notifies Spark listeners.

Internally, markMapStageJobAsFinished marks the zeroth partition finished and increases the number of tasks finished in `job`.

The scheduler:spark-scheduler-JobListener.md#taskSucceeded[`job` listener is notified about the 0th task succeeded].

The <<cleanupStateForJobAndIndependentStages, state of the `job` and independent stages are cleaned up>>.

Ultimately, ROOT:SparkListener.md#SparkListenerJobEnd[SparkListenerJobEnd] is posted to scheduler:LiveListenerBus.md[] (as <<listenerBus, listenerBus>>) for the `job`, the current time (in millis) and `JobSucceeded` job result.

markMapStageJobAsFinished is used in scheduler:DAGSchedulerEventProcessLoop.md#handleMapStageSubmitted[handleMapStageSubmitted] and scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion[handleTaskCompletion].

== [[getOrCreateParentStages]] Finding Or Creating Missing Direct Parent ShuffleMapStages (For ShuffleDependencies) of RDD

[source, scala]
----
getOrCreateParentStages(
  rdd: RDD[_],
  firstJobId: Int): List[Stage]
----

getOrCreateParentStages <<getShuffleDependencies, finds all direct parent `ShuffleDependencies`>> of the input `rdd` and then <<getOrCreateShuffleMapStage, finds `ShuffleMapStage` stages>> for each rdd:ShuffleDependency.md[ShuffleDependency].

getOrCreateParentStages is used when DAGScheduler is requested to create a <<createShuffleMapStage, ShuffleMapStage>> or a <<createResultStage, ResultStage>>.

== [[markStageAsFinished]] Marking Stage Finished

[source, scala]
----
markStageAsFinished(
  stage: Stage,
  errorMessage: Option[String] = None,
  willRetry: Boolean = false): Unit
----

markStageAsFinished...FIXME

markStageAsFinished is used when...FIXME

== [[getOrCreateShuffleMapStage]] Finding or Creating ShuffleMapStage for ShuffleDependency

[source, scala]
----
getOrCreateShuffleMapStage(
  shuffleDep: ShuffleDependency[_, _, _],
  firstJobId: Int): ShuffleMapStage
----

getOrCreateShuffleMapStage finds the scheduler:ShuffleMapStage.md[ShuffleMapStage] in the <<shuffleIdToMapStage, shuffleIdToMapStage>> internal registry and returns it if available.

If not found, getOrCreateShuffleMapStage <<getMissingAncestorShuffleDependencies, finds all the missing ancestor shuffle dependencies>> and <<createShuffleMapStage, creates the ShuffleMapStage stages>> (including one for the input ShuffleDependency).

getOrCreateShuffleMapStage is used when DAGScheduler is requested to <<getOrCreateParentStages, find or create missing direct parent ShuffleMapStages of an RDD>>, <<getMissingParentStages, find missing parent ShuffleMapStages for a stage>>, <<handleMapStageSubmitted, handle a MapStageSubmitted event>>, and <<stageDependsOn, check out stage dependency on a stage>>.

== [[getMissingAncestorShuffleDependencies]] Finding Missing ShuffleDependencies For RDD

[source, scala]
----
getMissingAncestorShuffleDependencies(
  rdd: RDD[_]): Stack[ShuffleDependency[_, _, _]]
----

getMissingAncestorShuffleDependencies finds all missing rdd:ShuffleDependency.md[shuffle dependencies] for the given rdd:index.md[RDD] traversing its rdd:spark-rdd-lineage.md[RDD lineage].

NOTE: A *missing shuffle dependency* of a RDD is a dependency not registered in <<shuffleIdToMapStage, `shuffleIdToMapStage` internal registry>>.

Internally, getMissingAncestorShuffleDependencies <<getShuffleDependencies, finds direct parent shuffle dependencies>> of the input RDD and collects the ones that are not registered in <<shuffleIdToMapStage, `shuffleIdToMapStage` internal registry>>. It repeats the process for the RDDs of the parent shuffle dependencies.

getMissingAncestorShuffleDependencies is used when DAGScheduler is requested to <<getOrCreateShuffleMapStage, find all ShuffleMapStage stages for a ShuffleDependency>>.

== [[getShuffleDependencies]] Finding Direct Parent Shuffle Dependencies of RDD

[source, scala]
----
getShuffleDependencies(
  rdd: RDD[_]): HashSet[ShuffleDependency[_, _, _]]
----

getShuffleDependencies finds direct parent rdd:ShuffleDependency.md[shuffle dependencies] for the given rdd:index.md[RDD].

.getShuffleDependencies Finds Direct Parent ShuffleDependencies (shuffle1 and shuffle2)
image::spark-DAGScheduler-getShuffleDependencies.png[align="center"]

Internally, getShuffleDependencies takes the direct rdd:index.md#dependencies[shuffle dependencies of the input RDD] and direct shuffle dependencies of all the parent non-``ShuffleDependencies`` in the rdd:spark-rdd-lineage.md[dependency chain] (aka _RDD lineage_).

getShuffleDependencies is used when DAGScheduler is requested to <<getOrCreateParentStages, find or create missing direct parent ShuffleMapStages>> (for ShuffleDependencies of a RDD) and <<getMissingAncestorShuffleDependencies, find all missing shuffle dependencies for a given RDD>>.

== [[failJobAndIndependentStages]] Failing Job and Independent Single-Job Stages

[source, scala]
----
failJobAndIndependentStages(
  job: ActiveJob,
  failureReason: String,
  exception: Option[Throwable] = None): Unit
----

failJobAndIndependentStages fails the input `job` and all the stages that are only used by the job.

Internally, failJobAndIndependentStages uses <<jobIdToStageIds, `jobIdToStageIds` internal registry>> to look up the stages registered for the job.

If no stages could be found, you should see the following ERROR message in the logs:

```
No stages registered for job [id]
```

Otherwise, for every stage, failJobAndIndependentStages finds the job ids the stage belongs to.

If no stages could be found or the job is not referenced by the stages, you should see the following ERROR message in the logs:

```
Job [id] not registered for stage [id] even though that stage was registered for the job
```

Only when there is exactly one job registered for the stage and the stage is in RUNNING state (in `runningStages` internal registry), scheduler:TaskScheduler.md#contract[`TaskScheduler` is requested to cancel the stage's tasks] and <<markStageAsFinished, marks the stage finished>>.

NOTE: failJobAndIndependentStages uses <<jobIdToStageIds, jobIdToStageIds>>, <<stageIdToStage, stageIdToStage>>, and <<runningStages, runningStages>> internal registries.

failJobAndIndependentStages is used when...FIXME

== [[abortStage]] Aborting Stage

[source, scala]
----
abortStage(
  failedStage: Stage,
  reason: String,
  exception: Option[Throwable]): Unit
----

abortStage is an internal method that finds all the active jobs that depend on the `failedStage` stage and fails them.

Internally, abortStage looks the `failedStage` stage up in the internal <<stageIdToStage, stageIdToStage>> registry and exits if there the stage was not registered earlier.

If it was, abortStage finds all the active jobs (in the internal <<activeJobs, activeJobs>> registry) with the <<stageDependsOn, final stage depending on the `failedStage` stage>>.

At this time, the `completionTime` property (of the failed stage's scheduler:spark-scheduler-StageInfo.md[StageInfo]) is assigned to the current time (millis).

All the active jobs that depend on the failed stage (as calculated above) and the stages that do not belong to other jobs (aka _independent stages_) are <<failJobAndIndependentStages, failed>> (with the failure reason being "Job aborted due to stage failure: [reason]" and the input `exception`).

If there are no jobs depending on the failed stage, you should see the following INFO message in the logs:

[source,plaintext]
----
Ignoring failure of [failedStage] because all jobs depending on it are done
----

abortStage is used when DAGScheduler is requested to <<handleTaskSetFailed, handle a TaskSetFailed event>>, <<submitStage, submit a stage>>, <<submitMissingTasks, submit missing tasks of a stage>>, <<handleTaskCompletion, handle a TaskCompletion event>>.

== [[stageDependsOn]] Checking Out Stage Dependency on Given Stage

[source, scala]
----
stageDependsOn(
  stage: Stage,
  target: Stage): Boolean
----

stageDependsOn compares two stages and returns whether the `stage` depends on `target` stage (i.e. `true`) or not (i.e. `false`).

NOTE: A stage `A` depends on stage `B` if `B` is among the ancestors of `A`.

Internally, stageDependsOn walks through the graph of RDDs of the input `stage`. For every RDD in the RDD's dependencies (using `RDD.dependencies`) stageDependsOn adds the RDD of a rdd:spark-rdd-NarrowDependency.md[NarrowDependency] to a stack of RDDs to visit while for a rdd:ShuffleDependency.md[ShuffleDependency] it <<getOrCreateShuffleMapStage, finds `ShuffleMapStage` stages for a `ShuffleDependency`>> for the dependency and the ``stage``'s first job id that it later adds to a stack of RDDs to visit if the map stage is ready, i.e. all the partitions have shuffle outputs.

After all the RDDs of the input `stage` are visited, stageDependsOn checks if the ``target``'s RDD is among the RDDs of the `stage`, i.e. whether the `stage` depends on `target` stage.

stageDependsOn is used when DAGScheduler is requested to <<abortStage, abort a stage>>.

== [[submitWaitingChildStages]] Submitting Waiting Child Stages for Execution

[source, scala]
----
submitWaitingChildStages(
  parent: Stage): Unit
----

submitWaitingChildStages submits for execution all waiting stages for which the input `parent` scheduler:Stage.md[Stage] is the direct parent.

NOTE: *Waiting stages* are the stages registered in <<waitingStages, `waitingStages` internal registry>>.

When executed, you should see the following `TRACE` messages in the logs:

```
Checking if any dependencies of [parent] are now runnable
running: [runningStages]
waiting: [waitingStages]
failed: [failedStages]
```

submitWaitingChildStages finds child stages of the input `parent` stage, removes them from `waitingStages` internal registry, and <<submitStage, submits>> one by one sorted by their job ids.

submitWaitingChildStages is used when DAGScheduler is requested to <<submitMissingTasks, submits missing tasks for a stage>> and <<handleTaskCompletion, handles a successful ShuffleMapTask completion>>.

== [[submitStage]] Submitting Stage (with Missing Parents) for Execution

[source, scala]
----
submitStage(
  stage: Stage): Unit
----

submitStage submits the input `stage` or its missing parents (if there any stages not computed yet before the input `stage` could).

NOTE: submitStage is also used to scheduler:DAGSchedulerEventProcessLoop.md#resubmitFailedStages[resubmit failed stages].

submitStage recursively submits any missing parents of the `stage`.

Internally, submitStage first finds the earliest-created job id that needs the `stage`.

NOTE: A stage itself tracks the jobs (their ids) it belongs to (using the internal `jobIds` registry).

The following steps depend on whether there is a job or not.

If there are no jobs that require the `stage`, submitStage <<abortStage, aborts it>> with the reason:

```
No active job for stage [id]
```

If however there is a job for the `stage`, you should see the following DEBUG message in the logs:

```
submitStage([stage])
```

submitStage checks the status of the `stage` and continues when it was not recorded in <<waitingStages, waiting>>, <<runningStages, running>> or <<failedStages, failed>> internal registries. It simply exits otherwise.

With the `stage` ready for submission, submitStage calculates the <<getMissingParentStages, list of missing parent stages of the `stage`>> (sorted by their job ids). You should see the following DEBUG message in the logs:

```
missing: [missing]
```

When the `stage` has no parent stages missing, you should see the following INFO message in the logs:

```
Submitting [stage] ([stage.rdd]), which has no missing parents
```

submitStage <<submitMissingTasks, submits the `stage`>> (with the earliest-created job id) and finishes.

If however there are missing parent stages for the `stage`, submitStage <<submitStage, submits all the parent stages>>, and the `stage` is recorded in the internal <<waitingStages, waitingStages>> registry.

submitStage is used recursively for missing parents of the given stage and when DAGScheduler is requested for the following:

* <<resubmitFailedStages, resubmitFailedStages>> (ResubmitFailedStages event)

* <<submitWaitingChildStages, submitWaitingChildStages>> (CompletionEvent event)

* Handle <<handleJobSubmitted, JobSubmitted>>, <<handleMapStageSubmitted, MapStageSubmitted>> and <<handleTaskCompletion, TaskCompletion>> events

== [[stage-attempts]] Stage Attempts

A single stage can be re-executed in multiple *attempts* due to fault recovery. The number of attempts is configured (FIXME).

If `TaskScheduler` reports that a task failed because a map output file from a previous stage was lost, the DAGScheduler resubmits the lost stage. This is detected through a scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion-FetchFailed[`CompletionEvent` with `FetchFailed`], or an <<ExecutorLost, ExecutorLost>> event. DAGScheduler will wait a small amount of time to see whether other nodes or tasks fail, then resubmit `TaskSets` for any lost stage(s) that compute the missing tasks.

Please note that tasks from the old attempts of a stage could still be running.

A stage object tracks multiple scheduler:spark-scheduler-StageInfo.md[StageInfo] objects to pass to Spark listeners or the web UI.

The latest `StageInfo` for the most recent attempt for a stage is accessible through `latestInfo`.

== [[preferred-locations]] Preferred Locations

DAGScheduler computes where to run each task in a stage based on the rdd:index.md#getPreferredLocations[preferred locations of its underlying RDDs], or <<getCacheLocs, the location of cached or shuffle data>>.

== [[adaptive-query-planning]] Adaptive Query Planning / Adaptive Scheduling

See https://issues.apache.org/jira/browse/SPARK-9850[SPARK-9850 Adaptive execution in Spark] for the design document. The work is currently in progress.

https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala#L661[DAGScheduler.submitMapStage] method is used for adaptive query planning, to run map stages and look at statistics about their outputs before submitting downstream stages.

== ScheduledExecutorService daemon services

DAGScheduler uses the following ScheduledThreadPoolExecutors (with the policy of removing cancelled tasks from a work queue at time of cancellation):

* `dag-scheduler-message` - a daemon thread pool using `j.u.c.ScheduledThreadPoolExecutor` with core pool size `1`. It is used to post a scheduler:DAGSchedulerEventProcessLoop.md#ResubmitFailedStages[ResubmitFailedStages] event when scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion-FetchFailed[`FetchFailed` is reported].

They are created using `ThreadUtils.newDaemonSingleThreadScheduledExecutor` method that uses Guava DSL to instantiate a ThreadFactory.

== [[getMissingParentStages]] Finding Missing Parent ShuffleMapStages For Stage

[source, scala]
----
getMissingParentStages(
  stage: Stage): List[Stage]
----

getMissingParentStages finds missing parent scheduler:ShuffleMapStage.md[ShuffleMapStage]s in the dependency graph of the input `stage` (using the https://en.wikipedia.org/wiki/Breadth-first_search[breadth-first search algorithm]).

Internally, getMissingParentStages starts with the ``stage``'s RDD and walks up the tree of all parent RDDs to find <<getCacheLocs, uncached partitions>>.

NOTE: A `Stage` tracks the associated RDD using scheduler:Stage.md#rdd[`rdd` property].

NOTE: An *uncached partition* of a RDD is a partition that has `Nil` in the <<cacheLocs, internal registry of partition locations per RDD>> (which results in no RDD blocks in any of the active storage:BlockManager.md[BlockManager]s on executors).

getMissingParentStages traverses the rdd:index.md#dependencies[parent dependencies of the RDD] and acts according to their type, i.e. rdd:ShuffleDependency.md[ShuffleDependency] or rdd:spark-rdd-NarrowDependency.md[NarrowDependency].

NOTE: rdd:ShuffleDependency.md[ShuffleDependency] and rdd:spark-rdd-NarrowDependency.md[NarrowDependency] are the main top-level rdd:spark-rdd-Dependency.md[Dependencies].

For each `NarrowDependency`, getMissingParentStages simply marks the corresponding RDD to visit and moves on to a next dependency of a RDD or works on another unvisited parent RDD.

NOTE: rdd:spark-rdd-NarrowDependency.md[NarrowDependency] is a RDD dependency that allows for pipelined execution.

getMissingParentStages focuses on `ShuffleDependency` dependencies.

NOTE: rdd:ShuffleDependency.md[ShuffleDependency] is a RDD dependency that represents a dependency on the output of a scheduler:ShuffleMapStage.md[ShuffleMapStage], i.e. *shuffle map stage*.

For each `ShuffleDependency`, getMissingParentStages <<getOrCreateShuffleMapStage, finds `ShuffleMapStage` stages>>. If the `ShuffleMapStage` is not _available_, it is added to the set of missing (map) stages.

NOTE: A `ShuffleMapStage` is *available* when all its partitions are computed, i.e. results are available (as blocks).

CAUTION: FIXME...IMAGE with ShuffleDependencies queried

getMissingParentStages is used when DAGScheduler is requested to <<submitStage, submit a stage>> and handle <<handleJobSubmitted, JobSubmitted>> and <<handleMapStageSubmitted, MapStageSubmitted>> events.

== [[submitMissingTasks]] Submitting Missing Tasks of Stage

[source, scala]
----
submitMissingTasks(
  stage: Stage,
  jobId: Int): Unit
----

submitMissingTasks prints out the following DEBUG message to the logs:

```
submitMissingTasks([stage])
```

submitMissingTasks requests the given scheduler:Stage.md[Stage] for the scheduler:Stage.md#findMissingPartitions[missing partitions] (partitions that need to be computed).

submitMissingTasks adds the stage to the <<runningStages, runningStages>> internal registry.

submitMissingTasks notifies the <<outputCommitCoordinator, OutputCommitCoordinator>> that scheduler:OutputCommitCoordinator.md#stageStart[stage execution started].

[[submitMissingTasks-taskIdToLocations]]
submitMissingTasks <<getPreferredLocs, determines preferred locations>> (_task locality preferences_) of the missing partitions.

submitMissingTasks requests the stage for a scheduler:Stage.md#makeNewStageAttempt[new stage attempt].

submitMissingTasks requests the <<listenerBus, LiveListenerBus>> to scheduler:LiveListenerBus.md#post[post] a ROOT:SparkListener.md#SparkListenerStageSubmitted[SparkListenerStageSubmitted] event.

submitMissingTasks uses the <<closureSerializer, closure Serializer>> to serializer:Serializer.md#serialize[serialize] the stage and create a so-called task binary. submitMissingTasks serializes the RDD (of the stage) and either the ShuffleDependency or the compute function based on the type of the stage, i.e. ShuffleMapStage and ResultStage, respectively.

submitMissingTasks creates a ROOT:SparkContext.md#broadcast[broadcast variable] for the task binary.

NOTE: That shows how important ROOT:Broadcast.md[]s are for Spark itself to distribute data among executors in a Spark application in the most efficient way.

submitMissingTasks creates scheduler:Task.md[tasks] for every missing partition:

* scheduler:ShuffleMapTask.md[ShuffleMapTasks] for a scheduler:ShuffleMapStage.md[ShuffleMapStage]

* scheduler:ResultTask.md[ResultTasks] for a scheduler:ResultStage.md[ResultStage]

If there are tasks to submit for execution (i.e. there are missing partitions in the stage), submitMissingTasks prints out the following INFO message to the logs:

```
Submitting [size] missing tasks from [stage] ([rdd]) (first 15 tasks are for partitions [partitionIds])
```

submitMissingTasks requests the <<taskScheduler, TaskScheduler>> to scheduler:TaskScheduler.md#submitTasks[submit the tasks for execution] (as a new scheduler:TaskSet.md[TaskSet]).

With no tasks to submit for execution, submitMissingTasks <<markStageAsFinished, marks the stage as finished successfully>>.

submitMissingTasks prints out the following DEBUG messages based on the type of the stage:

```
Stage [stage] is actually done; (available: [isAvailable],available outputs: [numAvailableOutputs],partitions: [numPartitions])
```

or

```
Stage [stage] is actually done; (partitions: [numPartitions])
```

for `ShuffleMapStage` and `ResultStage`, respectively.

In the end, with no tasks to submit for execution, submitMissingTasks <<submitWaitingChildStages, submits waiting child stages for execution>> and exits.

submitMissingTasks is used when DAGScheduler is requested to <<submitStage, submit a stage for execution>>.

== [[getPreferredLocs]] Finding Preferred Locations for Missing Partitions

[source, scala]
----
getPreferredLocs(
  rdd: RDD[_],
  partition: Int): Seq[TaskLocation]
----

getPreferredLocs is simply an alias for the internal (recursive) <<getPreferredLocsInternal, getPreferredLocsInternal>>.

getPreferredLocs is used when...FIXME

== [[getCacheLocs]] Finding BlockManagers (Executors) for Cached RDD Partitions (aka Block Location Discovery)

[source, scala]
----
getCacheLocs(
  rdd: RDD[_]): IndexedSeq[Seq[TaskLocation]]
----

getCacheLocs gives scheduler:TaskLocation.md[TaskLocations] (block locations) for the partitions of the input `rdd`. getCacheLocs caches lookup results in <<cacheLocs, cacheLocs>> internal registry.

NOTE: The size of the collection from getCacheLocs is exactly the number of partitions in `rdd` RDD.

NOTE: The size of every scheduler:TaskLocation.md[TaskLocation] collection (i.e. every entry in the result of getCacheLocs) is exactly the number of blocks managed using storage:BlockManager.md[BlockManagers] on executors.

Internally, getCacheLocs finds `rdd` in the <<cacheLocs, cacheLocs>> internal registry (of partition locations per RDD).

If `rdd` is not in <<cacheLocs, cacheLocs>> internal registry, getCacheLocs branches per its storage:StorageLevel.md[storage level].

For `NONE` storage level (i.e. no caching), the result is an empty locations (i.e. no location preference).

For other non-``NONE`` storage levels, getCacheLocs storage:BlockManagerMaster.md#getLocations-block-array[requests `BlockManagerMaster` for block locations] that are then mapped to scheduler:TaskLocation.md[TaskLocations] with the hostname of the owning `BlockManager` for a block (of a partition) and the executor id.

NOTE: getCacheLocs uses <<blockManagerMaster, BlockManagerMaster>> that was defined when <<creating-instance, DAGScheduler was created>>.

getCacheLocs records the computed block locations per partition (as scheduler:TaskLocation.md[TaskLocation]) in <<cacheLocs, cacheLocs>> internal registry.

NOTE: getCacheLocs requests locations from `BlockManagerMaster` using storage:BlockId.md#RDDBlockId[RDDBlockId] with the RDD id and the partition indices (which implies that the order of the partitions matters to request proper blocks).

NOTE: DAGScheduler uses scheduler:TaskLocation.md[TaskLocations] (with host and executor) while storage:BlockManagerMaster.md[BlockManagerMaster] uses storage:BlockManagerId.md[] (to track similar information, i.e. block locations).

getCacheLocs is used when DAGScheduler is requested to finds <<getMissingParentStages, missing parent MapStages>> and <<getPreferredLocsInternal, getPreferredLocsInternal>>.

== [[getPreferredLocsInternal]] Finding Placement Preferences for RDD Partition (recursively)

[source, scala]
----
getPreferredLocsInternal(
  rdd: RDD[_],
  partition: Int,
  visited: HashSet[(RDD[_], Int)]): Seq[TaskLocation]
----

getPreferredLocsInternal first <<getCacheLocs, finds the `TaskLocations` for the `partition` of the `rdd`>> (using <<cacheLocs, cacheLocs>> internal cache) and returns them.

Otherwise, if not found, getPreferredLocsInternal rdd:index.md#preferredLocations[requests `rdd` for the preferred locations of `partition`] and returns them.

NOTE: Preferred locations of the partitions of a RDD are also called *placement preferences* or *locality preferences*.

Otherwise, if not found, getPreferredLocsInternal finds the first parent rdd:spark-rdd-NarrowDependency.md[NarrowDependency] and (recursively) <<getPreferredLocsInternal, finds `TaskLocations`>>.

If all the attempts fail to yield any non-empty result, getPreferredLocsInternal returns an empty collection of scheduler:TaskLocation.md[TaskLocations].

getPreferredLocsInternal is used when DAGScheduler is requested for the <<getPreferredLocs, preferred locations for missing partitions>>.

== [[stop]] Stopping DAGScheduler

[source, scala]
----
stop(): Unit
----

stop stops the internal `dag-scheduler-message` thread pool, <<event-loop, dag-scheduler-event-loop>>, and scheduler:TaskScheduler.md#stop[TaskScheduler].

stop is used when...FIXME

== [[updateAccumulators]] Updating Accumulators with Partial Values from Completed Tasks

[source, scala]
----
updateAccumulators(
  event: CompletionEvent): Unit
----

updateAccumulators merges the partial values of accumulators from a completed task into their "source" accumulators on the driver.

NOTE: It is called by <<handleTaskCompletion, handleTaskCompletion>>.

For each ROOT:spark-accumulators.md#AccumulableInfo[AccumulableInfo] in the `CompletionEvent`, a partial value from a task is obtained (from `AccumulableInfo.update`) and added to the driver's accumulator (using `Accumulable.++=` method).

For named accumulators with the update value being a non-zero value, i.e. not `Accumulable.zero`:

* `stage.latestInfo.accumulables` for the `AccumulableInfo.id` is set
* `CompletionEvent.taskInfo.accumulables` has a new ROOT:spark-accumulators.md#AccumulableInfo[AccumulableInfo] added.

CAUTION: FIXME Where are `Stage.latestInfo.accumulables` and `CompletionEvent.taskInfo.accumulables` used?

updateAccumulators is used when DAGScheduler is requested to <<handleTaskCompletion, handle a task completion>>.

== [[checkBarrierStageWithNumSlots]] checkBarrierStageWithNumSlots Method

[source, scala]
----
checkBarrierStageWithNumSlots(
  rdd: RDD[_]): Unit
----

checkBarrierStageWithNumSlots...FIXME

checkBarrierStageWithNumSlots is used when DAGScheduler is requested to create <<createShuffleMapStage, ShuffleMapStage>> and <<createResultStage, ResultStage>> stages.

== [[killTaskAttempt]] Killing Task

[source, scala]
----
killTaskAttempt(
  taskId: Long,
  interruptThread: Boolean,
  reason: String): Boolean
----

killTaskAttempt requests the <<taskScheduler, TaskScheduler>> to scheduler:TaskScheduler.md#killTaskAttempt[kill a task].

killTaskAttempt is used when SparkContext is requested to ROOT:SparkContext.md#killTaskAttempt[kill a task].

== [[cleanUpAfterSchedulerStop]] cleanUpAfterSchedulerStop Method

[source, scala]
----
cleanUpAfterSchedulerStop(): Unit
----

cleanUpAfterSchedulerStop...FIXME

cleanUpAfterSchedulerStop is used when DAGSchedulerEventProcessLoop is requested to scheduler:DAGSchedulerEventProcessLoop.md#onStop[onStop].

== [[removeExecutorAndUnregisterOutputs]] removeExecutorAndUnregisterOutputs Method

[source, scala]
----
removeExecutorAndUnregisterOutputs(
  execId: String,
  fileLost: Boolean,
  hostToUnregisterOutputs: Option[String],
  maybeEpoch: Option[Long] = None): Unit
----

removeExecutorAndUnregisterOutputs...FIXME

removeExecutorAndUnregisterOutputs is used when DAGScheduler is requested to handle <<handleTaskCompletion, task completion>> (due to a fetch failure) and <<handleExecutorLost, executor lost>> events.

== [[markMapStageJobsAsFinished]] markMapStageJobsAsFinished Method

[source, scala]
----
markMapStageJobsAsFinished(
  shuffleStage: ShuffleMapStage): Unit
----

markMapStageJobsAsFinished...FIXME

markMapStageJobsAsFinished is used when DAGScheduler is requested to <<submitMissingTasks, submit missing tasks>> (of a ShuffleMapStage that has just been computed) and <<handleTaskCompletion, handle a task completion>> (of a ShuffleMapStage).

== [[updateJobIdStageIdMaps]] updateJobIdStageIdMaps Method

[source, scala]
----
updateJobIdStageIdMaps(
  jobId: Int,
  stage: Stage): Unit
----

updateJobIdStageIdMaps...FIXME

updateJobIdStageIdMaps is used when DAGScheduler is requested to create <<createShuffleMapStage, ShuffleMapStage>> and <<createResultStage, ResultStage>> stages.

== [[executorHeartbeatReceived]] executorHeartbeatReceived Method

[source, scala]
----
executorHeartbeatReceived(
  execId: String,
                // (taskId, stageId, stageAttemptId, accumUpdates)
  accumUpdates: Array[(Long, Int, Int, Seq[AccumulableInfo])],
  blockManagerId: BlockManagerId): Boolean
----

executorHeartbeatReceived posts a ROOT:SparkListener.md#SparkListenerExecutorMetricsUpdate[SparkListenerExecutorMetricsUpdate] (to <<listenerBus, listenerBus>>) and informs storage:BlockManagerMaster.md[BlockManagerMaster] that `blockManagerId` block manager is alive (by posting storage:BlockManagerMaster.md#BlockManagerHeartbeat[BlockManagerHeartbeat]).

executorHeartbeatReceived is used when TaskSchedulerImpl is requested to scheduler:TaskSchedulerImpl.md#executorHeartbeatReceived[handle an executor heartbeat].

== [[postTaskEnd]] postTaskEnd Method

[source, scala]
----
postTaskEnd(
  event: CompletionEvent): Unit
----

postTaskEnd...FIXME

postTaskEnd is used when DAGScheduler is requested to <<handleTaskCompletion, handle a task completion>>.

== Event Handlers

=== [[doCancelAllJobs]] AllJobsCancelled Event Handler

[source, scala]
----
doCancelAllJobs(): Unit
----

doCancelAllJobs...FIXME

doCancelAllJobs is used when DAGSchedulerEventProcessLoop is requested to handle an scheduler:DAGSchedulerEventProcessLoop.md#AllJobsCancelled[AllJobsCancelled] event and scheduler:DAGSchedulerEventProcessLoop.md#onError[onError].

=== [[handleBeginEvent]] BeginEvent Event Handler

[source, scala]
----
handleBeginEvent(
  task: Task[_],
  taskInfo: TaskInfo): Unit
----

handleBeginEvent...FIXME

handleBeginEvent is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#BeginEvent[BeginEvent] event.

=== [[handleTaskCompletion]] CompletionEvent Event Handler

[source, scala]
----
handleTaskCompletion(
  event: CompletionEvent): Unit
----

handleTaskCompletion...FIXME

handleTaskCompletion is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#CompletionEvent[CompletionEvent] event.

=== [[handleExecutorAdded]] ExecutorAdded Event Handler

[source, scala]
----
handleExecutorAdded(
  execId: String,
  host: String): Unit
----

handleExecutorAdded...FIXME

handleExecutorAdded is used when DAGSchedulerEventProcessLoop is requested to handle an scheduler:DAGSchedulerEvent.md#ExecutorAdded[ExecutorAdded] event.

=== [[handleExecutorLost]] ExecutorLost Event Handler

[source, scala]
----
handleExecutorLost(
  execId: String,
  workerLost: Boolean): Unit
----

handleExecutorLost...FIXME

handleExecutorLost is used when DAGSchedulerEventProcessLoop is requested to handle an scheduler:DAGSchedulerEvent.md#ExecutorLost[ExecutorLost] event.

=== [[handleGetTaskResult]] GettingResultEvent Event Handler

[source, scala]
----
handleGetTaskResult(
  taskInfo: TaskInfo): Unit
----

handleGetTaskResult...FIXME

handleGetTaskResult is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#GettingResultEvent[GettingResultEvent] event.

=== [[handleJobCancellation]] JobCancelled Event Handler

[source, scala]
----
handleJobCancellation(
  jobId: Int,
  reason: Option[String]): Unit
----

handleJobCancellation...FIXME

handleJobCancellation is used when DAGScheduler is requested to handle a scheduler:DAGSchedulerEvent.md#JobCancelled[JobCancelled] event, <<doCancelAllJobs, doCancelAllJobs>>, <<handleJobGroupCancelled, handleJobGroupCancelled>>, <<handleStageCancellation, handleStageCancellation>>.

=== [[handleJobGroupCancelled]] JobGroupCancelled Event Handler

[source, scala]
----
handleJobGroupCancelled(
  groupId: String): Unit
----

handleJobGroupCancelled...FIXME

handleJobGroupCancelled is used when DAGScheduler is requested to handle scheduler:DAGSchedulerEvent.md#JobGroupCancelled[JobGroupCancelled] event.

=== [[handleJobSubmitted]] JobSubmitted Event Handler

[source, scala]
----
handleJobSubmitted(
  jobId: Int,
  finalRDD: RDD[_],
  func: (TaskContext, Iterator[_]) => _,
  partitions: Array[Int],
  callSite: CallSite,
  listener: JobListener,
  properties: Properties): Unit
----

handleJobSubmitted scheduler:DAGScheduler.md#createResultStage[creates a new `ResultStage`] (as `finalStage` in the picture below) given the input `finalRDD`, `func`, `partitions`, `jobId` and `callSite`.

.`DAGScheduler.handleJobSubmitted` Method
image::dagscheduler-handleJobSubmitted.png[align="center"]

handleJobSubmitted creates an scheduler:spark-scheduler-ActiveJob.md[ActiveJob] (with the input `jobId`, `callSite`, `listener`, `properties`, and the scheduler:ResultStage.md[ResultStage]).

handleJobSubmitted scheduler:DAGScheduler.md#clearCacheLocs[clears the internal cache of RDD partition locations].

CAUTION: FIXME Why is this clearing here so important?

You should see the following INFO messages in the logs:

```
Got job [id] ([callSite]) with [number] output partitions
Final stage: [stage] ([name])
Parents of final stage: [parents]
Missing parents: [missingStages]
```

handleJobSubmitted then registers the new job in scheduler:DAGScheduler.md#jobIdToActiveJob[jobIdToActiveJob] and scheduler:DAGScheduler.md#activeJobs[activeJobs] internal registries, and scheduler:ResultStage.md#setActiveJob[with the final `ResultStage`].

NOTE: `ResultStage` can only have one `ActiveJob` registered.

handleJobSubmitted scheduler:DAGScheduler.md#jobIdToStageIds[finds all the registered stages for the input `jobId`] and collects scheduler:Stage.md#latestInfo[their latest `StageInfo`].

In the end, handleJobSubmitted posts  ROOT:SparkListener.md#SparkListenerJobStart[SparkListenerJobStart] message to scheduler:LiveListenerBus.md[] and scheduler:DAGScheduler.md#submitStage[submits the stage].

handleJobSubmitted is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#JobSubmitted[JobSubmitted] event.

=== [[handleMapStageSubmitted]] MapStageSubmitted Event Handler

[source, scala]
----
handleMapStageSubmitted(
  jobId: Int,
  dependency: ShuffleDependency[_, _, _],
  callSite: CallSite,
  listener: JobListener,
  properties: Properties): Unit
----

handleMapStageSubmitted...FIXME

handleMapStageSubmitted is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#MapStageSubmitted[MapStageSubmitted] event.

=== [[resubmitFailedStages]] ResubmitFailedStages Event Handler

[source, scala]
----
resubmitFailedStages(): Unit
----

resubmitFailedStages...FIXME

resubmitFailedStages is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#ResubmitFailedStages[ResubmitFailedStages] event.

=== [[handleSpeculativeTaskSubmitted]] SpeculativeTaskSubmitted Event Handler

[source, scala]
----
handleSpeculativeTaskSubmitted(): Unit
----

handleSpeculativeTaskSubmitted...FIXME

handleSpeculativeTaskSubmitted is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#SpeculativeTaskSubmitted[SpeculativeTaskSubmitted] event.

=== [[handleStageCancellation]] StageCancelled Event Handler

[source, scala]
----
handleStageCancellation(): Unit
----

handleStageCancellation...FIXME

handleStageCancellation is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#StageCancelled[StageCancelled] event.

=== [[handleTaskSetFailed]] TaskSetFailed Event Handler

[source, scala]
----
handleTaskSetFailed(): Unit
----

handleTaskSetFailed...FIXME

handleTaskSetFailed is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#TaskSetFailed[TaskSetFailed] event.

=== [[handleWorkerRemoved]] WorkerRemoved Event Handler

[source, scala]
----
handleWorkerRemoved(
  workerId: String,
  host: String,
  message: String): Unit
----

handleWorkerRemoved...FIXME

handleWorkerRemoved is used when DAGSchedulerEventProcessLoop is requested to handle a scheduler:DAGSchedulerEvent.md#WorkerRemoved[WorkerRemoved] event.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.DAGScheduler` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.scheduler.DAGScheduler=ALL
----

Refer to ROOT:spark-logging.md[Logging].

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| failedEpoch
| [[failedEpoch]] The lookup table of lost executors and the epoch of the event.

| failedStages
| [[failedStages]] Stages that failed due to fetch failures (when a scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion-FetchFailed[task fails with `FetchFailed` exception]).

| jobIdToActiveJob
| [[jobIdToActiveJob]] The lookup table of ``ActiveJob``s per job id.

| jobIdToStageIds
| [[jobIdToStageIds]] The lookup table of all stages per `ActiveJob` id

| metricsSource
| [[metricsSource]] metrics:spark-scheduler-DAGSchedulerSource.md[DAGSchedulerSource]

| nextJobId
| [[nextJobId]] The next job id counting from `0`.

Used when DAGScheduler <<submitJob, submits a job>> and <<submitMapStage, a map stage>>, and <<runApproximateJob, runs an approximate job>>.

| nextStageId
| [[nextStageId]] The next stage id counting from `0`.

Used when DAGScheduler creates a <<createShuffleMapStage, shuffle map stage>> and a <<createResultStage, result stage>>. It is the key in <<stageIdToStage, stageIdToStage>>.

| runningStages
| [[runningStages]] The set of stages that are currently "running".

A stage is added when <<submitMissingTasks, submitMissingTasks>> gets executed (without first checking if the stage has not already been added).

| shuffleIdToMapStage
| [[shuffleIdToMapStage]] The lookup table of scheduler:ShuffleMapStage.md[ShuffleMapStage]s per rdd:ShuffleDependency.md[ShuffleDependency].

| stageIdToStage
| [[stageIdToStage]] The lookup table for stages per their ids.

Used when DAGScheduler <<createShuffleMapStage, creates a shuffle map stage>>, <<createResultStage, creates a result stage>>, <<cleanupStateForJobAndIndependentStages, cleans up job state and independent stages>>, is informed that scheduler:DAGSchedulerEventProcessLoop.md#handleBeginEvent[a task is started], scheduler:DAGSchedulerEventProcessLoop.md#handleTaskSetFailed[a taskset has failed], scheduler:DAGSchedulerEventProcessLoop.md#handleJobSubmitted[a job is submitted (to compute a `ResultStage`)], scheduler:DAGSchedulerEventProcessLoop.md#handleMapStageSubmitted[a map stage was submitted], scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion[a task has completed] or scheduler:DAGSchedulerEventProcessLoop.md#handleStageCancellation[a stage was cancelled], <<updateAccumulators, updates accumulators>>, <<abortStage, aborts a stage>> and <<failJobAndIndependentStages, fails a job and independent stages>>.

| waitingStages
| [[waitingStages]] The stages with parents to be computed

|===
