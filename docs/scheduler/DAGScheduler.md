# DAGScheduler

!!! note
    The introduction that follows was highly influenced by the scaladoc of [org.apache.spark.scheduler.DAGScheduler](https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala). As `DAGScheduler` is a `private class` it does not appear in the official API documentation. You are strongly encouraged to read [the sources](https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala) and only then read this and the related pages afterwards.

## Introduction

`DAGScheduler` is the scheduling layer of Apache Spark that implements **stage-oriented scheduling** using [Jobs](ActiveJob.md) and [Stages](Stage.md).

`DAGScheduler` transforms a **logical execution plan** ([RDD lineage](../rdd/spark-rdd-lineage.md) of dependencies built using [RDD transformations](../rdd/spark-rdd-transformations.md)) to a **physical execution plan** (using [stages](Stage.md)).

![DAGScheduler Transforming RDD Lineage Into Stage DAG](../images/scheduler/dagscheduler-rdd-lineage-stage-dag.png)

After an [action](../rdd/spark-rdd-actions.md) has been called on an `RDD`, [SparkContext](../SparkContext.md) hands over a logical plan to `DAGScheduler` that it in turn translates to a set of stages that are submitted as [TaskSets](TaskSet.md) for execution.

![Executing action leads to new ResultStage and ActiveJob in DAGScheduler](../images/scheduler/dagscheduler-rdd-partitions-job-resultstage.png)

`DAGScheduler` works solely on the driver and is created as part of [SparkContext's initialization](../SparkContext.md) (right after [TaskScheduler](TaskScheduler.md) and [SchedulerBackend](SchedulerBackend.md) are ready).

![DAGScheduler as created by SparkContext with other services](../images/scheduler/dagscheduler-new-instance.png)

`DAGScheduler` does three things in Spark:

* Computes an **execution DAG** (DAG of stages) for a job
* Determines the [preferred locations](#preferred-locations) to run each task on
* Handles failures due to **shuffle output files** being lost

DAGScheduler computes [a directed acyclic graph (DAG)](https://en.wikipedia.org/wiki/Directed_acyclic_graph) of stages for each job, keeps track of which RDDs and stage outputs are materialized, and finds a minimal schedule to run jobs. It then submits stages to [TaskScheduler](TaskScheduler.md).

![DAGScheduler.submitJob](../images/scheduler/dagscheduler-submitjob.png)

In addition to coming up with the execution DAG, DAGScheduler also determines the preferred locations to run each task on, based on the current cache status, and passes the information to [TaskScheduler](TaskScheduler.md).

DAGScheduler tracks which rdd/spark-rdd-caching.md[RDDs are cached (or persisted)] to avoid "recomputing" them, i.e. redoing the map side of a shuffle. DAGScheduler remembers what ShuffleMapStage.md[ShuffleMapStage]s have already produced output files (that are stored in [BlockManager](../storage/BlockManager.md)s).

`DAGScheduler` is only interested in cache location coordinates, i.e. host and executor id, per partition of a RDD.

Furthermore, it handles failures due to shuffle output files being lost, in which case old stages may need to be resubmitted. Failures within a stage that are not caused by shuffle file loss are handled by the TaskScheduler itself, which will retry each task a small number of times before cancelling the whole stage.

DAGScheduler uses an **event queue architecture** in which a thread can post `DAGSchedulerEvent` events, e.g. a new job or stage being submitted, that DAGScheduler reads and executes sequentially. See the section <<event-loop, Internal Event Loop - dag-scheduler-event-loop>>.

DAGScheduler runs stages in topological order.

DAGScheduler uses [SparkContext](../SparkContext.md), [TaskScheduler](TaskScheduler.md), LiveListenerBus.md[], MapOutputTracker.md[MapOutputTracker] and storage:BlockManager.md[BlockManager] for its services. However, at the very minimum, DAGScheduler takes a `SparkContext` only (and requests `SparkContext` for the other services).

When DAGScheduler schedules a job as a result of rdd/index.md#actions[executing an action on a RDD] or [calling SparkContext.runJob() method directly](../SparkContext.md#runJob), it spawns parallel tasks to compute (partial) results per partition.

## Creating Instance

`DAGScheduler` takes the following to be created:

* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="taskScheduler"> [TaskScheduler](TaskScheduler.md)
* <span id="listenerBus"> [LiveListenerBus](LiveListenerBus.md)
* <span id="mapOutputTracker"> [MapOutputTrackerMaster](MapOutputTrackerMaster.md)
* <span id="blockManagerMaster"> [BlockManagerMaster](../storage/BlockManagerMaster.md)
* <span id="env"> [SparkEnv](../SparkEnv.md)
* <span id="clock"> `Clock`

`DAGScheduler` is created when [SparkContext](../SparkContext.md) is created.

While being created, `DAGScheduler` requests the [TaskScheduler](#taskScheduler) to [associate itself with](TaskScheduler.md#setDAGScheduler) and requests [DAGScheduler Event Bus](#eventProcessLoop) to start accepting events.

## <span id="metricsSource"><span id="DAGSchedulerSource"> DAGSchedulerSource

`DAGScheduler` uses [DAGSchedulerSource](DAGSchedulerSource.md) for performance metrics.

## <span id="event-loop"><span id="eventProcessLoop"> DAGScheduler Event Bus

`DAGScheduler` uses an [event bus](DAGSchedulerEventProcessLoop.md) to process scheduling events on a separate thread (one by one and asynchronously).

`DAGScheduler` requests the event bus to start right when [created](#creating-instance) and stops it when requested to [stop](#stop).

`DAGScheduler` defines [event-posting methods](#event-posting-methods) for posting [DAGSchedulerEvent](DAGSchedulerEvent.md) events to the event bus.

## <span id="taskScheduler"> TaskScheduler

`DAGScheduler` is given a [TaskScheduler](TaskScheduler.md) when [created](#creating-instance).

`TaskScheduler` is used for the following:

* [Submitting missing tasks of a stage](#submitMissingTasks)
* [Handling task completion (CompletionEvent)](#handleTaskCompletion)
* [Killing a task](#killTaskAttempt)
* [Failing a job and all other independent single-job stages](#failJobAndIndependentStages)
* [Stopping itself](#stop)

## <span id="runJob"> Running Job

```scala
runJob[T, U](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int],
  callSite: CallSite,
  resultHandler: (Int, U) => Unit,
  properties: Properties): Unit
```

`runJob` [submits a job](#submitJob) and waits until a result is available.

`runJob` prints out the following INFO message to the logs when the job has finished successfully:

```text
Job [jobId] finished: [callSite], took [time] s
```

`runJob` prints out the following INFO message to the logs when the job has failed:

```text
Job [jobId] failed: [callSite], took [time] s
```

`runJob` is used when:

* `SparkContext` is requested to [run a job](../SparkContext.md#runJob)

## <span id="submitJob"> Submitting Job

```scala
submitJob[T, U](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int],
  callSite: CallSite,
  resultHandler: (Int, U) => Unit,
  properties: Properties): JobWaiter[U]
```

`submitJob` increments the [nextJobId](#nextJobId) internal counter.

`submitJob` creates a [JobWaiter](JobWaiter.md) for the (number of) partitions and the given `resultHandler` function.

`submitJob` requests the [DAGSchedulerEventProcessLoop](#eventProcessLoop) to post a [JobSubmitted](DAGSchedulerEvent.md#JobSubmitted).

In the end, `submitJob` returns the `JobWaiter`.

For empty partitions (no partitions to compute), `submitJob` requests the [LiveListenerBus](#listenerBus) to post a [SparkListenerJobStart](../SparkListenerEvent.md#SparkListenerJobStart) and [SparkListenerJobEnd](../SparkListenerEvent.md#SparkListenerJobEnd) (with `JobSucceeded` result marker) events and returns a [JobWaiter](JobWaiter.md) with no tasks to wait for.

`submitJob` throws an `IllegalArgumentException` when the partitions indices are not among the [partitions](../rdd/RDD.md#partitions) of the given `RDD`:

```text
Attempting to access a non-existent partition: [p]. Total number of partitions: [maxPartitions]
```

`submitJob` is used when:

* `SparkContext` is requested to [submit a job](../SparkContext.md#submitJob)
* `DAGScheduler` is requested to [run a job](#runJob)

## <span id="cacheLocs"><span id="clearCacheLocs"> Partition Placement Preferences

`DAGScheduler` keeps track of block locations per RDD and partition.

`DAGScheduler` uses [TaskLocation](TaskLocation.md) that includes a host name and an executor id on that host (as `ExecutorCacheTaskLocation`).

The keys are RDDs (their ids) and the values are arrays indexed by partition numbers.

Each entry is a set of block locations where a RDD partition is cached, i.e. the [BlockManager](../storage/BlockManager.md)s of the blocks.

Initialized empty when `DAGScheduler` is [created](#creating-instance).

Used when `DAGScheduler` is requested for the [locations of the cache blocks of a RDD](#getCacheLocs).

## <span id="activeJobs"> ActiveJobs

`DAGScheduler` tracks [ActiveJob](ActiveJob.md)s:

* Adds a new `ActiveJob` when requested to handle [JobSubmitted](#handleJobSubmitted) or [MapStageSubmitted](#handleMapStageSubmitted) events

* Removes an `ActiveJob` when requested to [clean up after an ActiveJob and independent stages](#cleanupStateForJobAndIndependentStages).

* Removes all `ActiveJobs` when requested to [doCancelAllJobs](#doCancelAllJobs).

`DAGScheduler` uses `ActiveJobs` registry when requested to handle [JobGroupCancelled](#handleJobGroupCancelled) or [TaskCompletion](#handleTaskCompletion) events, to [cleanUpAfterSchedulerStop](#cleanUpAfterSchedulerStop) and to [abort a stage](#abortStage).

The number of ActiveJobs is available using [job.activeJobs](DAGSchedulerSource.md#job.activeJobs) performance metric.

## <span id="createResultStage"> Creating ResultStage for RDD

```scala
createResultStage(
  rdd: RDD[_],
  func: (TaskContext, Iterator[_]) => _,
  partitions: Array[Int],
  jobId: Int,
  callSite: CallSite): ResultStage
```

`createResultStage`...FIXME

`createResultStage` is used when `DAGScheduler` is requested to [handle a JobSubmitted event](#handleJobSubmitted).

## <span id="createShuffleMapStage"> Creating ShuffleMapStage for ShuffleDependency

```scala
createShuffleMapStage(
  shuffleDep: ShuffleDependency[_, _, _],
  jobId: Int): ShuffleMapStage
```

`createShuffleMapStage` creates a [ShuffleMapStage](ShuffleMapStage.md) for the given [ShuffleDependency](../rdd/ShuffleDependency.md) as follows:

* Stage ID is generated based on [nextStageId](#nextStageId) internal counter

* RDD is taken from the given [ShuffleDependency](../rdd/ShuffleDependency.md#rdd)

* Number of tasks is the number of [partitions](../rdd/RDD.md#partitions) of the RDD

* [Parent RDDs](#getOrCreateParentStages)

* [MapOutputTrackerMaster](#mapOutputTracker)

`createShuffleMapStage` registers the `ShuffleMapStage` in the [stageIdToStage](#stageIdToStage) and [shuffleIdToMapStage](#shuffleIdToMapStage) internal registries.

`createShuffleMapStage` [updateJobIdStageIdMaps](#updateJobIdStageIdMaps).

`createShuffleMapStage` requests the [MapOutputTrackerMaster](#mapOutputTracker) to [check whether it contains the shuffle ID or not](MapOutputTrackerMaster.md#containsShuffle).

If not, `createShuffleMapStage` prints out the following INFO message to the logs and requests the [MapOutputTrackerMaster](#mapOutputTracker) to [register the shuffle](MapOutputTrackerMaster.md#registerShuffle).

```text
Registering RDD [id] ([creationSite]) as input to shuffle [shuffleId]
```

![DAGScheduler Asks `MapOutputTrackerMaster` Whether Shuffle Map Output Is Already Tracked](../images/scheduler/DAGScheduler-MapOutputTrackerMaster-containsShuffle.png)

`createShuffleMapStage` is used when:

* `DAGScheduler` is requested to [find or create a ShuffleMapStage for a given ShuffleDependency](#getOrCreateShuffleMapStage)

## <span id="cleanupStateForJobAndIndependentStages"> Cleaning Up After Job and Independent Stages

```scala
cleanupStateForJobAndIndependentStages(
  job: ActiveJob): Unit
```

`cleanupStateForJobAndIndependentStages` cleans up the state for `job` and any stages that are _not_ part of any other job.

`cleanupStateForJobAndIndependentStages` looks the `job` up in the internal <<jobIdToStageIds, jobIdToStageIds>> registry.

If no stages are found, the following ERROR is printed out to the logs:

```text
No stages registered for job [jobId]
```

Oterwise, `cleanupStateForJobAndIndependentStages` uses <<stageIdToStage, stageIdToStage>> registry to find the stages (the real objects not ids!).

For each stage, `cleanupStateForJobAndIndependentStages` reads the jobs the stage belongs to.

If the `job` does not belong to the jobs of the stage, the following ERROR is printed out to the logs:

```text
Job [jobId] not registered for stage [stageId] even though that stage was registered for the job
```

If the `job` was the only job for the stage, the stage (and the stage id) gets cleaned up from the registries, i.e. <<runningStages, runningStages>>, <<shuffleIdToMapStage, shuffleIdToMapStage>>, <<waitingStages, waitingStages>>, <<failedStages, failedStages>> and <<stageIdToStage, stageIdToStage>>.

While removing from <<runningStages, runningStages>>, you should see the following DEBUG message in the logs:

```text
Removing running stage [stageId]
```

While removing from <<waitingStages, waitingStages>>, you should see the following DEBUG message in the logs:

```text
Removing stage [stageId] from waiting set.
```

While removing from <<failedStages, failedStages>>, you should see the following DEBUG message in the logs:

```text
Removing stage [stageId] from failed set.
```

After all cleaning (using <<stageIdToStage, stageIdToStage>> as the source registry), if the stage belonged to the one and only `job`, you should see the following DEBUG message in the logs:

```text
After removal of stage [stageId], remaining stages = [stageIdToStage.size]
```

The `job` is removed from <<jobIdToStageIds, jobIdToStageIds>>, <<jobIdToActiveJob, jobIdToActiveJob>>, <<activeJobs, activeJobs>> registries.

The final stage of the `job` is removed, i.e. [ResultStage](ResultStage.md#removeActiveJob) or [ShuffleMapStage](ShuffleMapStage.md#removeActiveJob).

`cleanupStateForJobAndIndependentStages` is used in [handleTaskCompletion when a `ResultTask` has completed successfully](DAGSchedulerEventProcessLoop.md#handleTaskCompletion-Success-ResultTask), [failJobAndIndependentStages](#failJobAndIndependentStages) and [markMapStageJobAsFinished](#markMapStageJobAsFinished).

## <span id="markMapStageJobAsFinished"> Marking ShuffleMapStage Job Finished

```scala
markMapStageJobAsFinished(
  job: ActiveJob,
  stats: MapOutputStatistics): Unit
```

`markMapStageJobAsFinished` marks the active `job` finished and notifies Spark listeners.

Internally, `markMapStageJobAsFinished` marks the zeroth partition finished and increases the number of tasks finished in `job`.

The [`job` listener is notified about the 0th task succeeded](JobListener.md#taskSucceeded).

The <<cleanupStateForJobAndIndependentStages, state of the `job` and independent stages are cleaned up>>.

Ultimately, [SparkListenerJobEnd](../SparkListener.md#SparkListenerJobEnd) is posted to [LiveListenerBus](LiveListenerBus.md) (as <<listenerBus, listenerBus>>) for the `job`, the current time (in millis) and `JobSucceeded` job result.

`markMapStageJobAsFinished` is used in [handleMapStageSubmitted](DAGSchedulerEventProcessLoop.md#handleMapStageSubmitted) and [handleTaskCompletion](DAGSchedulerEventProcessLoop.md#handleTaskCompletion).

## <span id="getOrCreateParentStages"> Finding Or Creating Missing Direct Parent ShuffleMapStages (For ShuffleDependencies) of RDD

```scala
getOrCreateParentStages(
  rdd: RDD[_],
  firstJobId: Int): List[Stage]
```

`getOrCreateParentStages` <<getShuffleDependencies, finds all direct parent `ShuffleDependencies`>> of the input `rdd` and then <<getOrCreateShuffleMapStage, finds `ShuffleMapStage` stages>> for each [ShuffleDependency](../rdd/ShuffleDependency.md).

`getOrCreateParentStages` is used when `DAGScheduler` is requested to create a [ShuffleMapStage](#createShuffleMapStage) or a [ResultStage](#createResultStage).

## <span id="markStageAsFinished"> Marking Stage Finished

```scala
markStageAsFinished(
  stage: Stage,
  errorMessage: Option[String] = None,
  willRetry: Boolean = false): Unit
```

`markStageAsFinished`...FIXME

`markStageAsFinished` is used when...FIXME

## <span id="getOrCreateShuffleMapStage"> Finding or Creating ShuffleMapStage for ShuffleDependency

```scala
getOrCreateShuffleMapStage(
  shuffleDep: ShuffleDependency[_, _, _],
  firstJobId: Int): ShuffleMapStage
```

`getOrCreateShuffleMapStage` finds a [ShuffleMapStage](ShuffleMapStage.md) by the [shuffleId](../rdd/ShuffleDependency.md#shuffleId) of the given [ShuffleDependency](../rdd/ShuffleDependency.md) in the [shuffleIdToMapStage](#shuffleIdToMapStage) internal registry and returns it if available.

If not found, `getOrCreateShuffleMapStage` [finds all the missing ancestor shuffle dependencies](#getMissingAncestorShuffleDependencies) and [creates the missing ShuffleMapStage stages](#createShuffleMapStage) (including one for the input `ShuffleDependency`).

`getOrCreateShuffleMapStage` is used when:

* `DAGScheduler` is requested to [find or create missing direct parent ShuffleMapStages of an RDD](#getOrCreateParentStages), [find missing parent ShuffleMapStages for a stage](#getMissingParentStages), [handle a MapStageSubmitted event](#handleMapStageSubmitted), and [check out stage dependency on a stage](#stageDependsOn)

## <span id="getMissingAncestorShuffleDependencies"> Finding Missing ShuffleDependencies For RDD

```scala
getMissingAncestorShuffleDependencies(
   rdd: RDD[_]): Stack[ShuffleDependency[_, _, _]]
```

`getMissingAncestorShuffleDependencies` finds all missing [shuffle dependencies](../rdd/ShuffleDependency.md) for the given [RDD](../rdd/index.md) traversing its rdd/spark-rdd-lineage.md[RDD lineage].

NOTE: A *missing shuffle dependency* of a RDD is a dependency not registered in <<shuffleIdToMapStage, `shuffleIdToMapStage` internal registry>>.

Internally, `getMissingAncestorShuffleDependencies` <<getShuffleDependencies, finds direct parent shuffle dependencies>> of the input RDD and collects the ones that are not registered in <<shuffleIdToMapStage, `shuffleIdToMapStage` internal registry>>. It repeats the process for the RDDs of the parent shuffle dependencies.

`getMissingAncestorShuffleDependencies` is used when `DAGScheduler` is requested to [find all ShuffleMapStage stages for a ShuffleDependency](#getOrCreateShuffleMapStage).

## <span id="getShuffleDependencies"> Finding Direct Parent Shuffle Dependencies of RDD

```scala
getShuffleDependencies(
   rdd: RDD[_]): HashSet[ShuffleDependency[_, _, _]]
```

`getShuffleDependencies` finds direct parent [shuffle dependencies](../rdd/ShuffleDependency.md) for the given [RDD](../rdd/index.md).

![getShuffleDependencies Finds Direct Parent ShuffleDependencies (shuffle1 and shuffle2)](../images/scheduler/spark-DAGScheduler-getShuffleDependencies.png)

Internally, `getShuffleDependencies` takes the direct rdd/index.md#dependencies[shuffle dependencies of the input RDD] and direct shuffle dependencies of all the parent non-``ShuffleDependencies`` in the [dependency chain](../rdd/spark-rdd-lineage.md) (aka _RDD lineage_).

`getShuffleDependencies` is used when `DAGScheduler` is requested to [find or create missing direct parent ShuffleMapStages](#getOrCreateParentStages) (for ShuffleDependencies of a RDD) and [find all missing shuffle dependencies for a given RDD](#getMissingAncestorShuffleDependencies).

## <span id="failJobAndIndependentStages"> Failing Job and Independent Single-Job Stages

```scala
failJobAndIndependentStages(
  job: ActiveJob,
  failureReason: String,
  exception: Option[Throwable] = None): Unit
```

`failJobAndIndependentStages` fails the input `job` and all the stages that are only used by the job.

Internally, `failJobAndIndependentStages` uses <<jobIdToStageIds, `jobIdToStageIds` internal registry>> to look up the stages registered for the job.

If no stages could be found, you should see the following ERROR message in the logs:

```
No stages registered for job [id]
```

Otherwise, for every stage, `failJobAndIndependentStages` finds the job ids the stage belongs to.

If no stages could be found or the job is not referenced by the stages, you should see the following ERROR message in the logs:

```
Job [id] not registered for stage [id] even though that stage was registered for the job
```

Only when there is exactly one job registered for the stage and the stage is in RUNNING state (in `runningStages` internal registry), TaskScheduler.md#contract[`TaskScheduler` is requested to cancel the stage's tasks] and <<markStageAsFinished, marks the stage finished>>.

NOTE: `failJobAndIndependentStages` uses <<jobIdToStageIds, jobIdToStageIds>>, <<stageIdToStage, stageIdToStage>>, and <<runningStages, runningStages>> internal registries.

`failJobAndIndependentStages` is used when...FIXME

## <span id="abortStage"> Aborting Stage

```scala
abortStage(
  failedStage: Stage,
  reason: String,
  exception: Option[Throwable]): Unit
```

`abortStage` is an internal method that finds all the active jobs that depend on the `failedStage` stage and fails them.

Internally, `abortStage` looks the `failedStage` stage up in the internal <<stageIdToStage, stageIdToStage>> registry and exits if there the stage was not registered earlier.

If it was, `abortStage` finds all the active jobs (in the internal <<activeJobs, activeJobs>> registry) with the <<stageDependsOn, final stage depending on the `failedStage` stage>>.

At this time, the `completionTime` property (of the failed stage's [StageInfo](StageInfo.md)) is assigned to the current time (millis).

All the active jobs that depend on the failed stage (as calculated above) and the stages that do not belong to other jobs (aka _independent stages_) are <<failJobAndIndependentStages, failed>> (with the failure reason being "Job aborted due to stage failure: [reason]" and the input `exception`).

If there are no jobs depending on the failed stage, you should see the following INFO message in the logs:

```text
Ignoring failure of [failedStage] because all jobs depending on it are done
```

`abortStage` is used when `DAGScheduler` is requested to [handle a TaskSetFailed event](#handleTaskSetFailed), [submit a stage](#submitStage), [submit missing tasks of a stage](#submitMissingTasks), [handle a TaskCompletion event](#handleTaskCompletion).

## <span id="stageDependsOn"> Checking Out Stage Dependency on Given Stage

```scala
stageDependsOn(
  stage: Stage,
  target: Stage): Boolean
```

`stageDependsOn` compares two stages and returns whether the `stage` depends on `target` stage (i.e. `true`) or not (i.e. `false`).

NOTE: A stage `A` depends on stage `B` if `B` is among the ancestors of `A`.

Internally, `stageDependsOn` walks through the graph of RDDs of the input `stage`. For every RDD in the RDD's dependencies (using `RDD.dependencies`) `stageDependsOn` adds the RDD of a [NarrowDependency](../rdd/NarrowDependency.md) to a stack of RDDs to visit while for a [ShuffleDependency](../rdd/ShuffleDependency.md) it <<getOrCreateShuffleMapStage, finds `ShuffleMapStage` stages for a `ShuffleDependency`>> for the dependency and the ``stage``'s first job id that it later adds to a stack of RDDs to visit if the map stage is ready, i.e. all the partitions have shuffle outputs.

After all the RDDs of the input `stage` are visited, `stageDependsOn` checks if the ``target``'s RDD is among the RDDs of the `stage`, i.e. whether the `stage` depends on `target` stage.

`stageDependsOn` is used when `DAGScheduler` is requested to [abort a stage](#abortStage).

## <span id="submitWaitingChildStages"> Submitting Waiting Child Stages for Execution

```scala
submitWaitingChildStages(
  parent: Stage): Unit
```

`submitWaitingChildStages` submits for execution all waiting stages for which the input `parent` Stage.md[Stage] is the direct parent.

NOTE: *Waiting stages* are the stages registered in <<waitingStages, `waitingStages` internal registry>>.

When executed, you should see the following `TRACE` messages in the logs:

```text
Checking if any dependencies of [parent] are now runnable
running: [runningStages]
waiting: [waitingStages]
failed: [failedStages]
```

`submitWaitingChildStages` finds child stages of the input `parent` stage, removes them from `waitingStages` internal registry, and <<submitStage, submits>> one by one sorted by their job ids.

`submitWaitingChildStages` is used when `DAGScheduler` is requested to [submits missing tasks for a stage](#submitMissingTasks) and [handles a successful ShuffleMapTask completion](#handleTaskCompletion).

## <span id="submitStage"> Submitting Stage (with Missing Parents) for Execution

```scala
submitStage(
  stage: Stage): Unit
```

`submitStage` submits the input `stage` or its missing parents (if there any stages not computed yet before the input `stage` could).

NOTE: `submitStage` is also used to DAGSchedulerEventProcessLoop.md#resubmitFailedStages[resubmit failed stages].

`submitStage` recursively submits any missing parents of the `stage`.

Internally, `submitStage` first finds the earliest-created job id that needs the `stage`.

NOTE: A stage itself tracks the jobs (their ids) it belongs to (using the internal `jobIds` registry).

The following steps depend on whether there is a job or not.

If there are no jobs that require the `stage`, `submitStage` <<abortStage, aborts it>> with the reason:

```text
No active job for stage [id]
```

If however there is a job for the `stage`, you should see the following DEBUG message in the logs:

```text
submitStage([stage])
```

`submitStage` checks the status of the `stage` and continues when it was not recorded in <<waitingStages, waiting>>, <<runningStages, running>> or <<failedStages, failed>> internal registries. It simply exits otherwise.

With the `stage` ready for submission, `submitStage` calculates the <<getMissingParentStages, list of missing parent stages of the `stage`>> (sorted by their job ids). You should see the following DEBUG message in the logs:

```text
missing: [missing]
```

When the `stage` has no parent stages missing, you should see the following INFO message in the logs:

```
Submitting [stage] ([stage.rdd]), which has no missing parents
```

`submitStage` <<submitMissingTasks, submits the `stage`>> (with the earliest-created job id) and finishes.

If however there are missing parent stages for the `stage`, `submitStage` <<submitStage, submits all the parent stages>>, and the `stage` is recorded in the internal <<waitingStages, waitingStages>> registry.

`submitStage` is used recursively for missing parents of the given stage and when DAGScheduler is requested for the following:

* [resubmitFailedStages](#resubmitFailedStages) (ResubmitFailedStages event)

* [submitWaitingChildStages](#submitWaitingChildStages) (CompletionEvent event)

* Handle [JobSubmitted](#handleJobSubmitted), [MapStageSubmitted](#handleMapStageSubmitted) and [TaskCompletion](#handleTaskCompletion) events

## <span id="stage-attempts"> Stage Attempts

A single stage can be re-executed in multiple *attempts* due to fault recovery. The number of attempts is configured (FIXME).

If `TaskScheduler` reports that a task failed because a map output file from a previous stage was lost, the DAGScheduler resubmits the lost stage. This is detected through a DAGSchedulerEventProcessLoop.md#handleTaskCompletion-FetchFailed[`CompletionEvent` with `FetchFailed`], or an <<ExecutorLost, ExecutorLost>> event. DAGScheduler will wait a small amount of time to see whether other nodes or tasks fail, then resubmit `TaskSets` for any lost stage(s) that compute the missing tasks.

Please note that tasks from the old attempts of a stage could still be running.

A stage object tracks multiple [StageInfo](StageInfo.md) objects to pass to Spark listeners or the web UI.

The latest `StageInfo` for the most recent attempt for a stage is accessible through `latestInfo`.

## <span id="preferred-locations"> Preferred Locations

DAGScheduler computes where to run each task in a stage based on the rdd/index.md#getPreferredLocations[preferred locations of its underlying RDDs], or <<getCacheLocs, the location of cached or shuffle data>>.

## <span id="adaptive-query-planning"> Adaptive Query Planning / Adaptive Scheduling

See [SPARK-9850 Adaptive execution in Spark](https://issues.apache.org/jira/browse/SPARK-9850) for the design document. The work is currently in progress.

[DAGScheduler.submitMapStage](https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/scheduler/DAGScheduler.scala#L661) method is used for adaptive query planning, to run map stages and look at statistics about their outputs before submitting downstream stages.

## ScheduledExecutorService daemon services

DAGScheduler uses the following ScheduledThreadPoolExecutors (with the policy of removing cancelled tasks from a work queue at time of cancellation):

* `dag-scheduler-message` - a daemon thread pool using `j.u.c.ScheduledThreadPoolExecutor` with core pool size `1`. It is used to post a DAGSchedulerEventProcessLoop.md#ResubmitFailedStages[ResubmitFailedStages] event when DAGSchedulerEventProcessLoop.md#handleTaskCompletion-FetchFailed[`FetchFailed` is reported].

They are created using `ThreadUtils.newDaemonSingleThreadScheduledExecutor` method that uses Guava DSL to instantiate a ThreadFactory.

## <span id="getMissingParentStages"> Finding Missing Parent ShuffleMapStages For Stage

```scala
getMissingParentStages(
  stage: Stage): List[Stage]
```

`getMissingParentStages` finds missing parent [ShuffleMapStage](ShuffleMapStage.md)s in the dependency graph of the input `stage` (using the [breadth-first search algorithm](https://en.wikipedia.org/wiki/Breadth-first_search)).

Internally, `getMissingParentStages` starts with the ``stage``'s RDD and walks up the tree of all parent RDDs to find <<getCacheLocs, uncached partitions>>.

NOTE: A `Stage` tracks the associated RDD using Stage.md#rdd[`rdd` property].

NOTE: An *uncached partition* of a RDD is a partition that has `Nil` in the <<cacheLocs, internal registry of partition locations per RDD>> (which results in no RDD blocks in any of the active storage:BlockManager.md[BlockManager]s on executors).

`getMissingParentStages` traverses the rdd/index.md#dependencies[parent dependencies of the RDD] and acts according to their type, i.e. [ShuffleDependency](../rdd/ShuffleDependency.md) or [NarrowDependency](../rdd/NarrowDependency.md).

NOTE: [ShuffleDependency](../rdd/ShuffleDependency.md) and [NarrowDependency](../rdd/NarrowDependency.md) are the main top-level [Dependencies](../rdd/Dependency.md).

For each `NarrowDependency`, `getMissingParentStages` simply marks the corresponding RDD to visit and moves on to a next dependency of a RDD or works on another unvisited parent RDD.

NOTE: [NarrowDependency](../rdd/NarrowDependency.md) is a RDD dependency that allows for pipelined execution.

`getMissingParentStages` focuses on `ShuffleDependency` dependencies.

NOTE: [ShuffleDependency](../rdd/ShuffleDependency.md) is a RDD dependency that represents a dependency on the output of a [ShuffleMapStage](ShuffleMapStage.md), i.e. **shuffle map stage**.

For each `ShuffleDependency`, `getMissingParentStages` <<getOrCreateShuffleMapStage, finds `ShuffleMapStage` stages>>. If the `ShuffleMapStage` is not _available_, it is added to the set of missing (map) stages.

NOTE: A `ShuffleMapStage` is *available* when all its partitions are computed, i.e. results are available (as blocks).

CAUTION: FIXME...IMAGE with ShuffleDependencies queried

`getMissingParentStages` is used when `DAGScheduler` is requested to [submit a stage](#submitStage) and handle [JobSubmitted](#handleJobSubmitted) and [MapStageSubmitted](#handleMapStageSubmitted) events.

## <span id="submitMissingTasks"> Submitting Missing Tasks of Stage

```scala
submitMissingTasks(
  stage: Stage,
  jobId: Int): Unit
```

`submitMissingTasks` prints out the following DEBUG message to the logs:

```text
submitMissingTasks([stage])
```

`submitMissingTasks` requests the given [Stage](Stage.md) for the [missing partitions](Stage.md#findMissingPartitions) (partitions that need to be computed).

`submitMissingTasks` adds the stage to the [runningStages](#runningStages) internal registry.

`submitMissingTasks` notifies the [OutputCommitCoordinator](#outputCommitCoordinator) that [stage execution started](../OutputCommitCoordinator.md#stageStart).

<span id="submitMissingTasks-taskIdToLocations">
`submitMissingTasks` [determines preferred locations](#getPreferredLocs) (_task locality preferences_) of the missing partitions.

`submitMissingTasks` requests the stage for a [new stage attempt](Stage.md#makeNewStageAttempt).

`submitMissingTasks` requests the [LiveListenerBus](#listenerBus) to [post](LiveListenerBus.md#post) a [SparkListenerStageSubmitted](../SparkListener.md#SparkListenerStageSubmitted) event.

`submitMissingTasks` uses the [closure Serializer](#closureSerializer) to [serialize](serializer:Serializer.md#serialize) the stage and create a so-called task binary. `submitMissingTasks` serializes the RDD (of the stage) and either the `ShuffleDependency` or the compute function based on the type of the stage (`ShuffleMapStage` or `ResultStage`, respectively).

`submitMissingTasks` creates a [broadcast variable](../SparkContext.md#broadcast) for the task binary.

!!! note
    That shows how important [broadcast variable](../broadcast-variables/index.md)s are for Spark itself to distribute data among executors in a Spark application in the most efficient way.

`submitMissingTasks` creates [tasks](Task.md) for every missing partition:

* [ShuffleMapTasks](ShuffleMapTask.md) for a [ShuffleMapStage](ShuffleMapStage.md)

* [ResultTasks](ResultTask.md) for a [ResultStage](ResultStage.md)

If there are tasks to submit for execution (i.e. there are missing partitions in the stage), submitMissingTasks prints out the following INFO message to the logs:

```text
Submitting [size] missing tasks from [stage] ([rdd]) (first 15 tasks are for partitions [partitionIds])
```

`submitMissingTasks` requests the <<taskScheduler, TaskScheduler>> to TaskScheduler.md#submitTasks[submit the tasks for execution] (as a new TaskSet.md[TaskSet]).

With no tasks to submit for execution, `submitMissingTasks` <<markStageAsFinished, marks the stage as finished successfully>>.

`submitMissingTasks` prints out the following DEBUG messages based on the type of the stage:

```text
Stage [stage] is actually done; (available: [isAvailable],available outputs: [numAvailableOutputs],partitions: [numPartitions])
```

or

```text
Stage [stage] is actually done; (partitions: [numPartitions])
```

for `ShuffleMapStage` and `ResultStage`, respectively.

In the end, with no tasks to submit for execution, `submitMissingTasks` <<submitWaitingChildStages, submits waiting child stages for execution>> and exits.

`submitMissingTasks` is used when `DAGScheduler` is requested to [submit a stage for execution](#submitStage).

## <span id="getPreferredLocs"> Finding Preferred Locations for Missing Partitions

```scala
getPreferredLocs(
   rdd: RDD[_],
  partition: Int): Seq[TaskLocation]
```

`getPreferredLocs` is simply an alias for the internal (recursive) <<getPreferredLocsInternal, getPreferredLocsInternal>>.

`getPreferredLocs` is used when...FIXME

## <span id="getCacheLocs"> Finding BlockManagers (Executors) for Cached RDD Partitions (aka Block Location Discovery)

```scala
getCacheLocs(
   rdd: RDD[_]): IndexedSeq[Seq[TaskLocation]]
```

`getCacheLocs` gives [TaskLocations](TaskLocation.md) (block locations) for the partitions of the input `rdd`. `getCacheLocs` caches lookup results in <<cacheLocs, cacheLocs>> internal registry.

NOTE: The size of the collection from `getCacheLocs` is exactly the number of partitions in `rdd` RDD.

NOTE: The size of every [TaskLocation](TaskLocation.md) collection (i.e. every entry in the result of `getCacheLocs`) is exactly the number of blocks managed using storage:BlockManager.md[BlockManagers] on executors.

Internally, `getCacheLocs` finds `rdd` in the <<cacheLocs, cacheLocs>> internal registry (of partition locations per RDD).

If `rdd` is not in <<cacheLocs, cacheLocs>> internal registry, `getCacheLocs` branches per its storage:StorageLevel.md[storage level].

For `NONE` storage level (i.e. no caching), the result is an empty locations (i.e. no location preference).

For other non-``NONE`` storage levels, `getCacheLocs` storage:BlockManagerMaster.md#getLocations-block-array[requests `BlockManagerMaster` for block locations] that are then mapped to [TaskLocations](TaskLocation.md) with the hostname of the owning `BlockManager` for a block (of a partition) and the executor id.

NOTE: `getCacheLocs` uses <<blockManagerMaster, BlockManagerMaster>> that was defined when <<creating-instance, DAGScheduler was created>>.

`getCacheLocs` records the computed block locations per partition (as [TaskLocation](TaskLocation.md)) in <<cacheLocs, cacheLocs>> internal registry.

NOTE: `getCacheLocs` requests locations from `BlockManagerMaster` using storage:BlockId.md#RDDBlockId[RDDBlockId] with the RDD id and the partition indices (which implies that the order of the partitions matters to request proper blocks).

NOTE: DAGScheduler uses TaskLocation.md[TaskLocations] (with host and executor) while storage:BlockManagerMaster.md[BlockManagerMaster] uses storage:BlockManagerId.md[] (to track similar information, i.e. block locations).

`getCacheLocs` is used when `DAGScheduler` is requested to find [missing parent MapStages](#getMissingParentStages) and [getPreferredLocsInternal](#getPreferredLocsInternal).

## <span id="getPreferredLocsInternal"> Finding Placement Preferences for RDD Partition (recursively)

```scala
getPreferredLocsInternal(
   rdd: RDD[_],
  partition: Int,
  visited: HashSet[(RDD[_], Int)]): Seq[TaskLocation]
```

`getPreferredLocsInternal` first <<getCacheLocs, finds the `TaskLocations` for the `partition` of the `rdd`>> (using <<cacheLocs, cacheLocs>> internal cache) and returns them.

Otherwise, if not found, `getPreferredLocsInternal` rdd/index.md#preferredLocations[requests `rdd` for the preferred locations of `partition`] and returns them.

NOTE: Preferred locations of the partitions of a RDD are also called *placement preferences* or *locality preferences*.

Otherwise, if not found, `getPreferredLocsInternal` finds the first parent [NarrowDependency](../rdd/NarrowDependency.md) and (recursively) [finds `TaskLocations`](#getPreferredLocsInternal).

If all the attempts fail to yield any non-empty result, `getPreferredLocsInternal` returns an empty collection of TaskLocation.md[TaskLocations].

`getPreferredLocsInternal` is used when `DAGScheduler` is requested for the [preferred locations for missing partitions](#getPreferredLocs).

## <span id="stop"> Stopping DAGScheduler

```scala
stop(): Unit
```

`stop` stops the internal `dag-scheduler-message` thread pool, [dag-scheduler-event-loop](#event-loop), and [TaskScheduler](TaskScheduler.md#stop).

`stop` is used when `SparkContext` is requested to [stop](../SparkContext.md#stop).

## <span id="checkBarrierStageWithNumSlots"> checkBarrierStageWithNumSlots

```scala
checkBarrierStageWithNumSlots(
  rdd: RDD[_]): Unit
```

checkBarrierStageWithNumSlots...FIXME

checkBarrierStageWithNumSlots is used when DAGScheduler is requested to create <<createShuffleMapStage, ShuffleMapStage>> and <<createResultStage, ResultStage>> stages.

## <span id="killTaskAttempt"> Killing Task

```scala
killTaskAttempt(
  taskId: Long,
  interruptThread: Boolean,
  reason: String): Boolean
```

`killTaskAttempt` requests the [TaskScheduler](#taskScheduler) to [kill a task](TaskScheduler.md#killTaskAttempt).

`killTaskAttempt` is used when `SparkContext` is requested to [kill a task](../SparkContext.md#killTaskAttempt).

## <span id="cleanUpAfterSchedulerStop"> cleanUpAfterSchedulerStop

```scala
cleanUpAfterSchedulerStop(): Unit
```

`cleanUpAfterSchedulerStop`...FIXME

`cleanUpAfterSchedulerStop` is used when `DAGSchedulerEventProcessLoop` is requested to [onStop](DAGSchedulerEventProcessLoop.md#onStop).

## <span id="removeExecutorAndUnregisterOutputs"> removeExecutorAndUnregisterOutputs

```scala
removeExecutorAndUnregisterOutputs(
  execId: String,
  fileLost: Boolean,
  hostToUnregisterOutputs: Option[String],
  maybeEpoch: Option[Long] = None): Unit
```

removeExecutorAndUnregisterOutputs...FIXME

removeExecutorAndUnregisterOutputs is used when DAGScheduler is requested to handle <<handleTaskCompletion, task completion>> (due to a fetch failure) and <<handleExecutorLost, executor lost>> events.

## <span id="markMapStageJobsAsFinished"> markMapStageJobsAsFinished

```scala
markMapStageJobsAsFinished(
  shuffleStage: ShuffleMapStage): Unit
```

`markMapStageJobsAsFinished`...FIXME

`markMapStageJobsAsFinished` is used when `DAGScheduler` is requested to [submit missing tasks](#submitMissingTasks) (of a `ShuffleMapStage` that has just been computed) and [handle a task completion](#handleTaskCompletion) (of a `ShuffleMapStage`).

## <span id="updateJobIdStageIdMaps"> updateJobIdStageIdMaps

```scala
updateJobIdStageIdMaps(
  jobId: Int,
  stage: Stage): Unit
```

`updateJobIdStageIdMaps`...FIXME

`updateJobIdStageIdMaps` is used when `DAGScheduler` is requested to create [ShuffleMapStage](#createShuffleMapStage) and [ResultStage](#createResultStage) stages.

## <span id="executorHeartbeatReceived"> executorHeartbeatReceived

```scala
executorHeartbeatReceived(
  execId: String,
  // (taskId, stageId, stageAttemptId, accumUpdates)
  accumUpdates: Array[(Long, Int, Int, Seq[AccumulableInfo])],
  blockManagerId: BlockManagerId,
  // (stageId, stageAttemptId) -> metrics
  executorUpdates: mutable.Map[(Int, Int), ExecutorMetrics]): Boolean
```

`executorHeartbeatReceived` posts a [SparkListenerExecutorMetricsUpdate](../SparkListener.md#SparkListenerExecutorMetricsUpdate) (to [listenerBus](#listenerBus)) and informs [BlockManagerMaster](../storage/BlockManagerMaster.md) that `blockManagerId` block manager is alive (by posting [BlockManagerHeartbeat](../storage/BlockManagerMaster.md#BlockManagerHeartbeat)).

`executorHeartbeatReceived` is used when `TaskSchedulerImpl` is requested to [handle an executor heartbeat](TaskSchedulerImpl.md#executorHeartbeatReceived).

## Event Handlers

### <span id="doCancelAllJobs"> AllJobsCancelled Event Handler

```scala
doCancelAllJobs(): Unit
```

`doCancelAllJobs`...FIXME

`doCancelAllJobs` is used when `DAGSchedulerEventProcessLoop` is requested to handle an [AllJobsCancelled](DAGSchedulerEventProcessLoop.md#AllJobsCancelled) event and [onError](DAGSchedulerEventProcessLoop.md#onError).

### <span id="handleBeginEvent"> BeginEvent Event Handler

```scala
handleBeginEvent(
  task: Task[_],
  taskInfo: TaskInfo): Unit
```

`handleBeginEvent`...FIXME

`handleBeginEvent` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [BeginEvent](DAGSchedulerEvent.md#BeginEvent) event.

### <span id="handleTaskCompletion"> Handling Task Completion Event

```scala
handleTaskCompletion(
  event: CompletionEvent): Unit
```

![DAGScheduler and CompletionEvent](../images/scheduler/dagscheduler-tasksetmanager.png)

`handleTaskCompletion` handles a [CompletionEvent](DAGSchedulerEvent.md#CompletionEvent).

`handleTaskCompletion` notifies the [OutputCommitCoordinator](../OutputCommitCoordinator.md) that a [task completed](../OutputCommitCoordinator.md#taskCompleted).

`handleTaskCompletion` finds the stage in the [stageIdToStage](#stageIdToStage) registry. If not found, `handleTaskCompletion` [postTaskEnd](#postTaskEnd) and quits.

`handleTaskCompletion` [updateAccumulators](#updateAccumulators).

`handleTaskCompletion` [announces task completion application-wide](#postTaskEnd).

`handleTaskCompletion` branches off per `TaskEndReason` (as `event.reason`).

TaskEndReason | Description
--------------|----------
 [Success](#handleTaskCompletion-Success) | Acts according to the type of the task that completed, i.e. [ShuffleMapTask](#handleTaskCompletion-Success-ShuffleMapTask) and [ResultTask](#handleTaskCompletion-Success-ResultTask)
 [Resubmitted](#handleTaskCompletion-Resubmitted) |
 _others_ |

#### <span id="handleTaskCompletion-Success"> Handling Successful Task Completion

When a task has finished successfully (i.e. `Success` end reason), `handleTaskCompletion` marks the partition as no longer pending (i.e. the partition the task worked on is removed from `pendingPartitions` of the stage).

NOTE: A `Stage` tracks its own pending partitions using scheduler:Stage.md#pendingPartitions[`pendingPartitions` property].

`handleTaskCompletion` branches off given the type of the task that completed, i.e. <<handleTaskCompletion-Success-ShuffleMapTask, ShuffleMapTask>> and <<handleTaskCompletion-Success-ResultTask, ResultTask>>.

##### <span id="handleTaskCompletion-Success-ResultTask"> Handling Successful ResultTask Completion

For scheduler:ResultTask.md[ResultTask], the stage is assumed a scheduler:ResultStage.md[ResultStage].

`handleTaskCompletion` finds the `ActiveJob` associated with the `ResultStage`.

NOTE: scheduler:ResultStage.md[ResultStage] tracks the optional `ActiveJob` as scheduler:ResultStage.md#activeJob[`activeJob` property]. There could only be one active job for a `ResultStage`.

If there is _no_ job for the `ResultStage`, you should see the following INFO message in the logs:

```text
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
3. Announces the job completion application-wide (by posting a SparkListener.md#SparkListenerJobEnd[SparkListenerJobEnd] to scheduler:LiveListenerBus.md[]).

In the end, `handleTaskCompletion` [notifies `JobListener` of the `ActiveJob` that the task succeeded](JobListener.md#taskSucceeded).

NOTE: A task succeeded notification holds the output index and the result.

When the notification throws an exception (because it runs user code), `handleTaskCompletion` [notifies `JobListener` about the failure](JobListener.md#jobFailed) (wrapping it inside a `SparkDriverExecutionException` exception).

##### <span id="handleTaskCompletion-Success-ShuffleMapTask"> Handling Successful ShuffleMapTask Completion

For scheduler:ShuffleMapTask.md[ShuffleMapTask], the stage is assumed a  scheduler:ShuffleMapStage.md[ShuffleMapStage].

`handleTaskCompletion` scheduler:DAGScheduler.md#updateAccumulators[updates accumulators].

The task's result is assumed scheduler:MapStatus.md[MapStatus] that knows the executor where the task has finished.

You should see the following DEBUG message in the logs:

```text
ShuffleMapTask finished on [execId]
```

If the executor is registered in scheduler:DAGScheduler.md#failedEpoch[`failedEpoch` internal registry] and the epoch of the completed task is not greater than that of the executor (as in `failedEpoch` registry), you should see the following INFO message in the logs:

```text
Ignoring possibly bogus [task] completion from executor [executorId]
```

Otherwise, `handleTaskCompletion` scheduler:ShuffleMapStage.md#addOutputLoc[registers the `MapStatus` result for the partition with the stage] (of the completed task).

`handleTaskCompletion` does more processing only if the `ShuffleMapStage` is registered as still running (in scheduler:DAGScheduler.md#runningStages[`runningStages` internal registry]) and the scheduler:Stage.md#pendingPartitions[`ShuffleMapStage` stage has no pending partitions to compute].

The `ShuffleMapStage` is <<markStageAsFinished, marked as finished>>.

You should see the following INFO messages in the logs:

```text
looking for newly runnable stages
running: [runningStages]
waiting: [waitingStages]
failed: [failedStages]
```

`handleTaskCompletion` scheduler:MapOutputTrackerMaster.md#registerMapOutputs[registers the shuffle map outputs of the `ShuffleDependency` with `MapOutputTrackerMaster`] (with the epoch incremented) and scheduler:DAGScheduler.md#clearCacheLocs[clears internal cache of the stage's RDD block locations].

NOTE: scheduler:MapOutputTrackerMaster.md[MapOutputTrackerMaster] is given when scheduler:DAGScheduler.md#creating-instance[DAGScheduler is created].

If the scheduler:ShuffleMapStage.md#isAvailable[`ShuffleMapStage` stage is ready], all scheduler:ShuffleMapStage.md#mapStageJobs[active jobs of the stage] (aka _map-stage jobs_) are scheduler:DAGScheduler.md#markMapStageJobAsFinished[marked as finished] (with scheduler:MapOutputTrackerMaster.md#getStatistics[`MapOutputStatistics` from `MapOutputTrackerMaster` for the `ShuffleDependency`]).

NOTE: A `ShuffleMapStage` stage is ready (aka _available_) when all partitions have shuffle outputs, i.e. when their tasks have completed.

Eventually, `handleTaskCompletion` scheduler:DAGScheduler.md#submitWaitingChildStages[submits waiting child stages (of the ready `ShuffleMapStage`)].

If however the `ShuffleMapStage` is _not_ ready, you should see the following INFO message in the logs:

```text
Resubmitting [shuffleStage] ([shuffleStage.name]) because some of its tasks had failed: [missingPartitions]
```

In the end, `handleTaskCompletion` scheduler:DAGScheduler.md#submitStage[submits the `ShuffleMapStage` for execution].

#### <span id="handleTaskCompletion-Resubmitted"> TaskEndReason: Resubmitted

For `Resubmitted` case, you should see the following INFO message in the logs:

```text
Resubmitted [task], so marking it as still running
```

The task (by `task.partitionId`) is added to the collection of pending partitions of the stage (using `stage.pendingPartitions`).

TIP: A stage knows how many partitions are yet to be calculated. A task knows about the partition id for which it was launched.

#### <span id="handleTaskCompletion-FetchFailed"> Task Failed with FetchFailed Exception

```scala
FetchFailed(
  bmAddress: BlockManagerId,
  shuffleId: Int,
  mapId: Int,
  reduceId: Int,
  message: String)
extends TaskFailedReason
```

When `FetchFailed` happens, `stageIdToStage` is used to access the failed stage (using `task.stageId` and the `task` is available in `event` in `handleTaskCompletion(event: CompletionEvent)`). `shuffleToMapStage` is used to access the map stage (using `shuffleId`).

If `failedStage.latestInfo.attemptId != task.stageAttemptId`, you should see the following INFO in the logs:

```text
Ignoring fetch failure from [task] as it's from [failedStage] attempt [task.stageAttemptId] and there is a more recent attempt for that stage (attempt ID [failedStage.latestInfo.attemptId]) running
```

CAUTION: FIXME What does `failedStage.latestInfo.attemptId != task.stageAttemptId` mean?

And the case finishes. Otherwise, the case continues.

If the failed stage is in `runningStages`, the following INFO message shows in the logs:

```text
Marking [failedStage] ([failedStage.name]) as failed due to a fetch failure from [mapStage] ([mapStage.name])
```

`markStageAsFinished(failedStage, Some(failureMessage))` is called.

CAUTION: FIXME What does `markStageAsFinished` do?

If the failed stage is not in `runningStages`, the following DEBUG message shows in the logs:

```text
Received fetch failure from [task], but its from [failedStage] which is no longer running
```

When `disallowStageRetryForTest` is set, `abortStage(failedStage, "Fetch failure will not retry stage due to testing config", None)` is called.

CAUTION: FIXME Describe `disallowStageRetryForTest` and `abortStage`.

If the scheduler:Stage.md#failedOnFetchAndShouldAbort[number of fetch failed attempts for the stage exceeds the allowed number], the scheduler:DAGScheduler.md#abortStage[failed stage is aborted] with the reason:

```text
[failedStage] ([name]) has failed the maximum allowable number of times: 4. Most recent failure reason: [failureMessage]
```

If there are no failed stages reported (scheduler:DAGScheduler.md#failedStages[DAGScheduler.failedStages] is empty), the following INFO shows in the logs:

```text
Resubmitting [mapStage] ([mapStage.name]) and [failedStage] ([failedStage.name]) due to fetch failure
```

And the following code is executed:

```text
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

`handleTaskCompletion` is used when:

* [DAGSchedulerEventProcessLoop](DAGSchedulerEventProcessLoop.md) is requested to handle a [CompletionEvent](DAGSchedulerEvent.md#CompletionEvent) event.

### <span id="handleExecutorAdded"> ExecutorAdded Event Handler

```scala
handleExecutorAdded(
  execId: String,
  host: String): Unit
```

`handleExecutorAdded`...FIXME

`handleExecutorAdded` is used when `DAGSchedulerEventProcessLoop` is requested to handle an [ExecutorAdded](DAGSchedulerEvent.md#ExecutorAdded) event.

### <span id="handleExecutorLost"> ExecutorLost Event Handler

```scala
handleExecutorLost(
  execId: String,
  workerLost: Boolean): Unit
```

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

`handleExecutorLost` exits unless the `ExecutorLost` event was for a map output fetch operation (and the input `filesLost` is `true`) or [external shuffle service](../external-shuffle-service/index.md) is _not_ used.

In such a case, you should see the following INFO message in the logs:

```text
Shuffle files lost for executor: [execId] (epoch [epoch])
```

`handleExecutorLost` walks over all scheduler:ShuffleMapStage.md[ShuffleMapStage]s in scheduler:DAGScheduler.md#shuffleToMapStage[DAGScheduler's `shuffleToMapStage` internal registry] and do the following (in order):

1. `ShuffleMapStage.removeOutputsOnExecutor(execId)` is called
2. scheduler:MapOutputTrackerMaster.md#registerMapOutputs[MapOutputTrackerMaster.registerMapOutputs(shuffleId, stage.outputLocInMapOutputTrackerFormat(), changeEpoch = true)] is called.

In case scheduler:DAGScheduler.md#shuffleToMapStage[DAGScheduler's `shuffleToMapStage` internal registry] has no shuffles registered,  scheduler:MapOutputTrackerMaster.md#incrementEpoch[`MapOutputTrackerMaster` is requested to increment epoch].

Ultimatelly, DAGScheduler scheduler:DAGScheduler.md#clearCacheLocs[clears the internal cache of RDD partition locations].

`handleExecutorLost` is used when `DAGSchedulerEventProcessLoop` is requested to handle an [ExecutorLost](DAGSchedulerEvent.md#ExecutorLost) event.

### <span id="handleGetTaskResult"> GettingResultEvent Event Handler

```scala
handleGetTaskResult(
  taskInfo: TaskInfo): Unit
```

`handleGetTaskResult`...FIXME

`handleGetTaskResult` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [GettingResultEvent](DAGSchedulerEvent.md#GettingResultEvent) event.

### <span id="handleJobCancellation"> JobCancelled Event Handler

```scala
handleJobCancellation(
  jobId: Int,
  reason: Option[String]): Unit
```

`handleJobCancellation` looks up the active job for the input job ID (in [jobIdToActiveJob](#jobIdToActiveJob) internal registry) and [fails it and all associated independent stages](#failJobAndIndependentStages) with failure reason:

```text
Job [jobId] cancelled [reason]
```

When the input job ID is not found, `handleJobCancellation` prints out the following DEBUG message to the logs:

```text
Trying to cancel unregistered job [jobId]
```

`handleJobCancellation` is used when `DAGScheduler` is requested to handle a [JobCancelled](DAGSchedulerEvent.md#JobCancelled) event, [doCancelAllJobs](#doCancelAllJobs), [handleJobGroupCancelled](#handleJobGroupCancelled), [handleStageCancellation](#handleStageCancellation).

### <span id="handleJobGroupCancelled"> JobGroupCancelled Event Handler

```scala
handleJobGroupCancelled(
  groupId: String): Unit
```

`handleJobGroupCancelled` finds active jobs in a group and cancels them.

Internally, `handleJobGroupCancelled` computes all the active jobs (registered in the internal [collection of active jobs](#activeJobs)) that have `spark.jobGroup.id` scheduling property set to `groupId`.

`handleJobGroupCancelled` then [cancels every active job](#handleJobCancellation) in the group one by one and the cancellation reason:

```text
part of cancelled job group [groupId]
```

`handleJobGroupCancelled` is used when `DAGScheduler` is requested to handle [JobGroupCancelled](DAGSchedulerEvent.md#JobGroupCancelled) event.

### <span id="handleJobSubmitted"> Handling JobSubmitted Event

```scala
handleJobSubmitted(
  jobId: Int,
  finalRDD: RDD[_],
  func: (TaskContext, Iterator[_]) => _,
  partitions: Array[Int],
  callSite: CallSite,
  listener: JobListener,
  properties: Properties): Unit
```

`handleJobSubmitted` [creates a ResultStage](#createResultStage) (as `finalStage` in the picture below) for the given RDD, `func`, `partitions`, `jobId` and `callSite`.

![DAGScheduler.handleJobSubmitted Method](../images/scheduler/dagscheduler-handleJobSubmitted.png)

`handleJobSubmitted` creates an [ActiveJob](ActiveJob.md) for the [ResultStage](ResultStage.md).

`handleJobSubmitted` [clears the internal cache of RDD partition locations](#clearCacheLocs).

!!! important
    FIXME Why is this clearing here so important?

`handleJobSubmitted` prints out the following INFO messages to the logs (with [missingParentStages](#getMissingParentStages)):

```text
Got job [id] ([callSite]) with [number] output partitions
Final stage: [stage] ([name])
Parents of final stage: [parents]
Missing parents: [missingParentStages]
```

`handleJobSubmitted` registers the new `ActiveJob` in [jobIdToActiveJob](#jobIdToActiveJob) and [activeJobs](#activeJobs) internal registries.

`handleJobSubmitted` requests the `ResultStage` to [associate itself with the ActiveJob](ResultStage.md#setActiveJob).

`handleJobSubmitted` uses the [jobIdToStageIds](#jobIdToStageIds) internal registry to find all registered stages for the given `jobId`. `handleJobSubmitted` uses the [stageIdToStage](#stageIdToStage) internal registry to request the `Stages` for the [latestInfo](Stage.md#latestInfo).

In the end, `handleJobSubmitted` posts a [SparkListenerJobStart](../SparkListener.md#SparkListenerJobStart) message to the [LiveListenerBus](#listenerBus) and [submits the ResultStage](#submitStage).

`handleJobSubmitted` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [JobSubmitted](DAGSchedulerEvent.md#JobSubmitted) event.

### <span id="handleMapStageSubmitted"> MapStageSubmitted Event Handler

```scala
handleMapStageSubmitted(
  jobId: Int,
  dependency: ShuffleDependency[_, _, _],
  callSite: CallSite,
  listener: JobListener,
  properties: Properties): Unit
```

![MapStageSubmitted Event Handling](../images/scheduler/scheduler-handlemapstagesubmitted.png)

!!! note
    `MapStageSubmitted` event processing is very similar to <<JobSubmitted, JobSubmitted>> events.

`handleMapStageSubmitted` [finds or creates a new `ShuffleMapStage`](#getOrCreateShuffleMapStage) for the input [ShuffleDependency](../rdd/ShuffleDependency.md) and `jobId`.

`handleMapStageSubmitted` creates an [ActiveJob](ActiveJob.md).

`handleMapStageSubmitted` [clears the internal cache of RDD partition locations](#clearCacheLocs).

!!! important
    FIXME Why is this clearing here so important?

`handleMapStageSubmitted` prints out the following INFO messages to the logs:

```text
Got map stage job [id] ([callSite]) with [number] output partitions
Final stage: [stage] ([name])
Parents of final stage: [parents]
Missing parents: [missingParentStages]
```

`handleMapStageSubmitted` registers the new job in [jobIdToActiveJob](#jobIdToActiveJob) and [activeJobs](#activeJobs) internal registries, and [with the final `ShuffleMapStage`](ShuffleMapStage.md#addActiveJob).

!!! note
    `ShuffleMapStage` can have multiple ``ActiveJob``s registered.

`handleMapStageSubmitted` [finds all the registered stages for the input `jobId`](#jobIdToStageIds) and collects [their latest `StageInfo`](Stage.md#latestInfo).

In the end, `handleMapStageSubmitted` posts [SparkListenerJobStart](../SparkListener.md#SparkListenerJobStart) message to [LiveListenerBus](LiveListenerBus.md) and [submits the `ShuffleMapStage`](#submitStage).

When the [`ShuffleMapStage` is available](ShuffleMapStage.md#isAvailable) already, `handleMapStageSubmitted` [marks the job finished](#markMapStageJobAsFinished).

When `handleMapStageSubmitted` could not find or create a `ShuffleMapStage`, `handleMapStageSubmitted` prints out the following WARN message to the logs.

```text
Creating new stage failed due to exception - job: [id]
```

`handleMapStageSubmitted` notifies [`listener` about the job failure](JobListener.md#jobFailed) and exits.

`handleMapStageSubmitted` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [MapStageSubmitted](DAGSchedulerEvent.md#MapStageSubmitted) event.

### <span id="resubmitFailedStages"> ResubmitFailedStages Event Handler

```scala
resubmitFailedStages(): Unit
```

`resubmitFailedStages` iterates over the internal [collection of failed stages](#failedStages) and [submits](#submitStage) them.

!!! note
    `resubmitFailedStages` does nothing when there are no [failed stages reported](#failedStages).

`resubmitFailedStages` prints out the following INFO message to the logs:

```text
Resubmitting failed stages
```

`resubmitFailedStages` [clears the internal cache of RDD partition locations](#clearCacheLocs) and makes a copy of the [collection of failed stages](#failedStages) to track failed stages afresh.

!!! note
    At this point DAGScheduler has no failed stages reported.

The previously-reported failed stages are sorted by the corresponding job ids in incremental order and [resubmitted](#submitStage).

`resubmitFailedStages` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [ResubmitFailedStages](DAGSchedulerEvent.md#ResubmitFailedStages) event.

### <span id="handleSpeculativeTaskSubmitted"> SpeculativeTaskSubmitted Event Handler

```scala
handleSpeculativeTaskSubmitted(): Unit
```

`handleSpeculativeTaskSubmitted`...FIXME

`handleSpeculativeTaskSubmitted` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [SpeculativeTaskSubmitted](DAGSchedulerEvent.md#SpeculativeTaskSubmitted) event.

### <span id="handleStageCancellation"> StageCancelled Event Handler

```scala
handleStageCancellation(): Unit
```

`handleStageCancellation`...FIXME

`handleStageCancellation` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [StageCancelled](DAGSchedulerEvent.md#StageCancelled) event.

### <span id="handleTaskSetFailed"> TaskSetFailed Event Handler

```scala
handleTaskSetFailed(): Unit
```

`handleTaskSetFailed`...FIXME

`handleTaskSetFailed` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [TaskSetFailed](DAGSchedulerEvent.md#TaskSetFailed) event.

### <span id="handleWorkerRemoved"> WorkerRemoved Event Handler

```scala
handleWorkerRemoved(
  workerId: String,
  host: String,
  message: String): Unit
```

`handleWorkerRemoved`...FIXME

`handleWorkerRemoved` is used when `DAGSchedulerEventProcessLoop` is requested to handle a [WorkerRemoved](DAGSchedulerEvent.md#WorkerRemoved) event.

## Internal Properties

### <span id="failedEpoch"> failedEpoch

The lookup table of lost executors and the epoch of the event.

### <span id="failedStages"> failedStages

Stages that failed due to fetch failures (when a DAGSchedulerEventProcessLoop.md#handleTaskCompletion-FetchFailed[task fails with `FetchFailed` exception]).

### <span id="jobIdToActiveJob"> jobIdToActiveJob

The lookup table of ``ActiveJob``s per job id.

### <span id="jobIdToStageIds"> jobIdToStageIds

The lookup table of all stages per `ActiveJob` id

### <span id="nextJobId"> nextJobId Counter

```scala
nextJobId: AtomicInteger
```

`nextJobId` is a Java [AtomicInteger]({{ java.doc }}/java/util/concurrent/atomic/AtomicInteger.html) for job IDs.

`nextJobId` starts at `0`.

Used when `DAGScheduler` is requested for [numTotalJobs](#numTotalJobs), to [submitJob](#submitJob), [runApproximateJob](#runApproximateJob) and [submitMapStage](#submitMapStage).

### <span id="nextStageId"> nextStageId

The next stage id counting from `0`.

Used when DAGScheduler creates a <<createShuffleMapStage, shuffle map stage>> and a <<createResultStage, result stage>>. It is the key in <<stageIdToStage, stageIdToStage>>.

### <span id="runningStages"> runningStages

The set of stages that are currently "running".

A stage is added when <<submitMissingTasks, submitMissingTasks>> gets executed (without first checking if the stage has not already been added).

### <span id="shuffleIdToMapStage"> shuffleIdToMapStage

A lookup table of [ShuffleMapStage](ShuffleMapStage.md)s by [ShuffleDependency](../rdd/ShuffleDependency.md)

### <span id="stageIdToStage"> stageIdToStage

A lookup table of stages by stage ID

Used when DAGScheduler [creates a shuffle map stage](#createShuffleMapStage), [creates a result stage](#createResultStage), [cleans up job state and independent stages](#cleanupStateForJobAndIndependentStages), is informed that [a task is started](DAGSchedulerEventProcessLoop.md#handleBeginEvent), [a taskset has failed](DAGSchedulerEventProcessLoop.md#handleTaskSetFailed), [a job is submitted (to compute a `ResultStage`)](DAGSchedulerEventProcessLoop.md#handleJobSubmitted), [a map stage was submitted](DAGSchedulerEventProcessLoop.md#handleMapStageSubmitted), [a task has completed](DAGSchedulerEventProcessLoop.md#handleTaskCompletion) or [a stage was cancelled](DAGSchedulerEventProcessLoop.md#handleStageCancellation), [updates accumulators](#updateAccumulators), [aborts a stage](#abortStage) and [fails a job and independent stages](#failJobAndIndependentStages).

### <span id="waitingStages"> waitingStages

Stages with parents to be computed

## Event Posting Methods

### <span id="cancelAllJobs"> Posting AllJobsCancelled

Posts an [AllJobsCancelled](DAGSchedulerEvent.md#AllJobsCancelled)

Used when `SparkContext` is requested to [cancel all running or scheduled Spark jobs](../SparkContext.md#cancelAllJobs)

### <span id="cancelJob"> Posting JobCancelled

Posts a [JobCancelled](DAGSchedulerEvent.md#JobCancelled)

Used when [SparkContext](../SparkContext.md#cancelJob) or [JobWaiter](JobWaiter.md) are requested to cancel a Spark job

### <span id="cancelJobGroup"> Posting JobGroupCancelled

Posts a [JobGroupCancelled](DAGSchedulerEvent.md#JobGroupCancelled)

Used when `SparkContext` is requested to [cancel a job group](../SparkContext.md#cancelJobGroup)

### <span id="cancelStage"> Posting StageCancelled

Posts a [StageCancelled](DAGSchedulerEvent.md#StageCancelled)

Used when `SparkContext` is requested to [cancel a stage](../SparkContext.md#cancelStage)

### <span id="executorAdded"> Posting ExecutorAdded

Posts an [ExecutorAdded](DAGSchedulerEvent.md#ExecutorAdded)

Used when `TaskSchedulerImpl` is requested to [handle resource offers](TaskSchedulerImpl.md#resourceOffers) (and a new executor is found in the resource offers)

### <span id="executorLost"> Posting ExecutorLost

Posts a [ExecutorLost](DAGSchedulerEvent.md#ExecutorLost)

Used when `TaskSchedulerImpl` is requested to [handle a task status update](TaskSchedulerImpl.md#statusUpdate) (and a task gets lost which is used to indicate that the executor got broken and hence should be considered lost) or [executorLost](TaskSchedulerImpl.md#executorLost)

### <span id="runApproximateJob"> Posting JobSubmitted

Posts a [JobSubmitted](DAGSchedulerEvent.md#JobSubmitted)

Used when `SparkContext` is requested to [run an approximate job](../SparkContext.md#runApproximateJob)

### <span id="speculativeTaskSubmitted"> Posting SpeculativeTaskSubmitted

Posts a [SpeculativeTaskSubmitted](DAGSchedulerEvent.md#SpeculativeTaskSubmitted)

Used when `TaskSetManager` is requested to [checkAndSubmitSpeculatableTask](TaskSetManager.md#checkAndSubmitSpeculatableTask)

### <span id="submitMapStage"> Posting MapStageSubmitted

Posts a [MapStageSubmitted](DAGSchedulerEvent.md#MapStageSubmitted)

Used when `SparkContext` is requested to [submit a MapStage for execution](../SparkContext.md#submitMapStage)

### <span id="taskEnded"> Posting CompletionEvent

Posts a [CompletionEvent](DAGSchedulerEvent.md#CompletionEvent)

Used when `TaskSetManager` is requested to [handleSuccessfulTask](TaskSetManager.md#handleSuccessfulTask), [handleFailedTask](TaskSetManager.md#handleFailedTask), and [executorLost](TaskSetManager.md#executorLost)

### <span id="taskGettingResult"> Posting GettingResultEvent

Posts a [GettingResultEvent](DAGSchedulerEvent.md#GettingResultEvent)

Used when `TaskSetManager` is requested to [handle a task fetching result](TaskSetManager.md#handleTaskGettingResult)

### <span id="taskSetFailed"> Posting TaskSetFailed

Posts a [TaskSetFailed](DAGSchedulerEvent.md#TaskSetFailed)

Used when `TaskSetManager` is requested to [abort](TaskSetManager.md#abort)

### <span id="taskStarted"> Posting BeginEvent

Posts a [BeginEvent](DAGSchedulerEvent.md#BeginEvent)

Used when `TaskSetManager` is requested to [start a task](TaskSetManager.md#resourceOffer)

### <span id="workerRemoved"> Posting WorkerRemoved

Posts a [WorkerRemoved](DAGSchedulerEvent.md#WorkerRemoved)

Used when `TaskSchedulerImpl` is requested to [handle a removed worker event](TaskSchedulerImpl.md#workerRemoved)

## <span id="updateAccumulators"> Updating Accumulators of Completed Tasks

```scala
updateAccumulators(
  event: CompletionEvent): Unit
```

`updateAccumulators` merges the partial values of accumulators from a completed task (based on the given [CompletionEvent](DAGSchedulerEvent.md#CompletionEvent)) into their "source" accumulators on the driver.

For every [AccumulatorV2](DAGSchedulerEvent.md#CompletionEvent-accumUpdates) update (in the given [CompletionEvent](DAGSchedulerEvent.md#CompletionEvent)), `updateAccumulators` [finds the corresponding accumulator on the driver](../accumulators/AccumulatorContext.md#get) and requests the `AccumulatorV2` to [merge the updates](../accumulators/AccumulatorV2.md#merge).

`updateAccumulators`...FIXME

For named accumulators with the update value being a non-zero value, i.e. not `Accumulable.zero`:

* `stage.latestInfo.accumulables` for the `AccumulableInfo.id` is set
* `CompletionEvent.taskInfo.accumulables` has a new [AccumulableInfo](../accumulators/AccumulableInfo.md) added.

CAUTION: FIXME Where are `Stage.latestInfo.accumulables` and `CompletionEvent.taskInfo.accumulables` used?

`updateAccumulators` is used when `DAGScheduler` is requested to [handle a task completion](#handleTaskCompletion).

## <span id="postTaskEnd"> Posting SparkListenerTaskEnd (at Task Completion)

```scala
postTaskEnd(
  event: CompletionEvent): Unit
```

`postTaskEnd` [reconstructs task metrics](../executor/TaskMetrics.md#fromAccumulators) (from the accumulator updates in the `CompletionEvent`).

In the end, `postTaskEnd` creates a [SparkListenerTaskEnd](../SparkListenerTaskEnd.md) and requests the [LiveListenerBus](#listenerBus) to [post it](LiveListenerBus.md#post).

`postTaskEnd` is used when:

* `DAGScheduler` is requested to [handle a task completion](#handleTaskCompletion)

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.DAGScheduler` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.DAGScheduler=ALL
```

Refer to [Logging](../spark-logging.md).
