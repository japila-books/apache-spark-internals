# TaskSchedulerImpl

`TaskSchedulerImpl` is the default [TaskScheduler](TaskScheduler.md) that uses a [SchedulerBackend](#backend) to schedule tasks (for execution on a cluster manager).

When a Spark application starts (and so an instance of SparkContext.md#creating-instance[SparkContext is created]) TaskSchedulerImpl with a scheduler:SchedulerBackend.md[SchedulerBackend] and scheduler:DAGScheduler.md[DAGScheduler] are created and soon started.

![TaskSchedulerImpl and Other Services](../images/scheduler/taskschedulerimpl-sparkcontext-schedulerbackend-dagscheduler.png)

TaskSchedulerImpl <<resourceOffers, generates tasks for executor resource offers>>.

TaskSchedulerImpl can <<getRackForHost, track racks per host and port>> (that however is spark-on-yarn:spark-yarn-yarnscheduler.md[only used with Hadoop YARN cluster manager]).

Using configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property you can select the scheduler:spark-scheduler-SchedulingMode.md[scheduling policy].

TaskSchedulerImpl <<submitTasks, submits tasks>> using scheduler:spark-scheduler-SchedulableBuilder.md[SchedulableBuilders].

[[CPUS_PER_TASK]]
TaskSchedulerImpl uses configuration-properties.md#spark.task.cpus[spark.task.cpus] configuration property for...FIXME

## Creating Instance

TaskSchedulerImpl takes the following to be created:

* [[sc]] SparkContext.md[]
* <<maxTaskFailures, Acceptable number of task failures>>
* [[isLocal]] isLocal flag for local and cluster run modes (default: `false`)

TaskSchedulerImpl initializes the <<internal-properties, internal properties>>.

TaskSchedulerImpl sets scheduler:TaskScheduler.md#schedulingMode[schedulingMode] to the value of configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property.

NOTE: `schedulingMode` is part of scheduler:TaskScheduler.md#schedulingMode[TaskScheduler] contract.

Failure to set `schedulingMode` results in a `SparkException`:

```
Unrecognized spark.scheduler.mode: [schedulingModeConf]
```

Ultimately, TaskSchedulerImpl creates a scheduler:TaskResultGetter.md[TaskResultGetter].

== [[backend]] SchedulerBackend

TaskSchedulerImpl is assigned a scheduler:SchedulerBackend.md[SchedulerBackend] when requested to <<initialize, initialize>>.

The lifecycle of the SchedulerBackend is tightly coupled to the lifecycle of the owning TaskSchedulerImpl:

* When <<start, started up>> so is the scheduler:SchedulerBackend.md#start[SchedulerBackend]

* When <<stop, stopped>>, so is the scheduler:SchedulerBackend.md#stop[SchedulerBackend]

TaskSchedulerImpl <<waitBackendReady, waits until the SchedulerBackend is ready>> before requesting it for the following:

* scheduler:SchedulerBackend.md#reviveOffers[Reviving resource offers] when requested to <<submitTasks, submitTasks>>, <<statusUpdate, statusUpdate>>, <<handleFailedTask, handleFailedTask>>, <<checkSpeculatableTasks, checkSpeculatableTasks>>, and <<executorLost, executorLost>>

* scheduler:SchedulerBackend.md#killTask[Killing tasks] when requested to <<killTaskAttempt, killTaskAttempt>> and <<killAllTaskAttempts, killAllTaskAttempts>>

* scheduler:SchedulerBackend.md#defaultParallelism[Default parallelism], <<applicationId, applicationId>> and <<applicationAttemptId, applicationAttemptId>> when requested for the <<defaultParallelism, defaultParallelism>>, scheduler:SchedulerBackend.md#applicationId[applicationId] and scheduler:SchedulerBackend.md#applicationAttemptId[applicationAttemptId], respectively

== [[applicationId]] Unique Identifier of Spark Application

[source, scala]
----
applicationId(): String
----

NOTE: `applicationId` is part of scheduler:TaskScheduler.md#applicationId[TaskScheduler] contract.

`applicationId` simply request the <<backend, SchedulerBackend>> for the scheduler:SchedulerBackend.md#applicationId[applicationId].

== [[nodeBlacklist]] `nodeBlacklist` Method

CAUTION: FIXME

== [[cleanupTaskState]] `cleanupTaskState` Method

CAUTION: FIXME

== [[newTaskId]] `newTaskId` Method

CAUTION: FIXME

== [[getExecutorsAliveOnHost]] `getExecutorsAliveOnHost` Method

CAUTION: FIXME

== [[isExecutorAlive]] `isExecutorAlive` Method

CAUTION: FIXME

== [[hasExecutorsAliveOnHost]] `hasExecutorsAliveOnHost` Method

CAUTION: FIXME

== [[hasHostAliveOnRack]] `hasHostAliveOnRack` Method

CAUTION: FIXME

== [[executorLost]] `executorLost` Method

CAUTION: FIXME

== [[mapOutputTracker]] `mapOutputTracker`

CAUTION: FIXME

== [[starvationTimer]] `starvationTimer`

CAUTION: FIXME

== [[executorHeartbeatReceived]] executorHeartbeatReceived Method

[source, scala]
----
executorHeartbeatReceived(
  execId: String,
  accumUpdates: Array[(Long, Seq[AccumulatorV2[_, _]])],
  blockManagerId: BlockManagerId): Boolean
----

executorHeartbeatReceived is...FIXME

executorHeartbeatReceived is part of the scheduler:TaskScheduler.md#executorHeartbeatReceived[TaskScheduler] contract.

== [[cancelTasks]] Cancelling All Tasks of Stage -- `cancelTasks` Method

[source, scala]
----
cancelTasks(stageId: Int, interruptThread: Boolean): Unit
----

NOTE: `cancelTasks` is part of scheduler:TaskScheduler.md#contract[TaskScheduler contract].

`cancelTasks` cancels all tasks submitted for execution in a stage `stageId`.

NOTE: `cancelTasks` is used exclusively when `DAGScheduler` scheduler:DAGScheduler.md#failJobAndIndependentStages[cancels a stage].

== [[handleSuccessfulTask]] `handleSuccessfulTask` Method

[source, scala]
----
handleSuccessfulTask(
  taskSetManager: TaskSetManager,
  tid: Long,
  taskResult: DirectTaskResult[_]): Unit
----

`handleSuccessfulTask` simply scheduler:TaskSetManager.md#handleSuccessfulTask[forwards the call to the input `taskSetManager`] (passing `tid` and `taskResult`).

NOTE: `handleSuccessfulTask` is called when scheduler:TaskResultGetter.md#enqueueSuccessfulTask[`TaskSchedulerGetter` has managed to deserialize the task result of a task that finished successfully].

== [[handleTaskGettingResult]] `handleTaskGettingResult` Method

[source, scala]
----
handleTaskGettingResult(taskSetManager: TaskSetManager, tid: Long): Unit
----

`handleTaskGettingResult` simply scheduler:TaskSetManager.md#handleTaskGettingResult[forwards the call to the `taskSetManager`].

NOTE: `handleTaskGettingResult` is used to inform that scheduler:TaskResultGetter.md#enqueueSuccessfulTask[`TaskResultGetter` enqueues a successful task with `IndirectTaskResult` task result (and so is about to fetch a remote block from a `BlockManager`)].

== [[applicationAttemptId]] `applicationAttemptId` Method

[source, scala]
----
applicationAttemptId(): Option[String]
----

CAUTION: FIXME

== [[getRackForHost]] Tracking Racks per Hosts and Ports -- `getRackForHost` Method

[source, scala]
----
getRackForHost(value: String): Option[String]
----

`getRackForHost` is a method to know about the racks per hosts and ports. By default, it assumes that racks are unknown (i.e. the method returns `None`).

NOTE: It is overriden by the YARN-specific TaskScheduler spark-on-yarn:spark-yarn-yarnscheduler.md[YarnScheduler].

`getRackForHost` is currently used in two places:

* <<resourceOffers, TaskSchedulerImpl.resourceOffers>> to track hosts per rack (using the <<internal-registries, internal `hostsByRack` registry>>) while processing resource offers.

* <<removeExecutor, TaskSchedulerImpl.removeExecutor>> to...FIXME

* scheduler:TaskSetManager.md#addPendingTask[TaskSetManager.addPendingTask], scheduler:TaskSetManager.md#[TaskSetManager.dequeueTask], and scheduler:TaskSetManager.md#dequeueSpeculativeTask[TaskSetManager.dequeueSpeculativeTask]

== [[initialize]] Initializing -- `initialize` Method

[source, scala]
----
initialize(
  backend: SchedulerBackend): Unit
----

`initialize` initializes TaskSchedulerImpl.

.TaskSchedulerImpl initialization
image::TaskSchedulerImpl-initialize.png[align="center"]

`initialize` saves the input <<backend, SchedulerBackend>>.

`initialize` then sets <<rootPool, schedulable `Pool`>> as an empty-named spark-scheduler-Pool.md[Pool] (passing in <<schedulingMode, SchedulingMode>>, `initMinShare` and `initWeight` as `0`).

NOTE: <<schedulingMode, SchedulingMode>> is defined when <<creating-instance, TaskSchedulerImpl is created>>.

NOTE: <<schedulingMode, schedulingMode>> and <<rootPool, rootPool>> are a part of scheduler:TaskScheduler.md#contract[TaskScheduler Contract].

`initialize` sets <<schedulableBuilder, SchedulableBuilder>> (based on <<schedulingMode, SchedulingMode>>):

* spark-scheduler-FIFOSchedulableBuilder.md[FIFOSchedulableBuilder] for `FIFO` scheduling mode
* spark-scheduler-FairSchedulableBuilder.md[FairSchedulableBuilder] for `FAIR` scheduling mode

`initialize` spark-scheduler-SchedulableBuilder.md#buildPools[requests `SchedulableBuilder` to build pools].

CAUTION: FIXME Why are `rootPool` and `schedulableBuilder` created only now? What do they need that it is not available when TaskSchedulerImpl is created?

NOTE: `initialize` is called while SparkContext.md#createTaskScheduler[SparkContext is created and creates SchedulerBackend and `TaskScheduler`].

== [[start]] Starting TaskSchedulerImpl

[source, scala]
----
start(): Unit
----

`start` starts the scheduler:SchedulerBackend.md[scheduler backend].

.Starting TaskSchedulerImpl in Spark Standalone
image::taskschedulerimpl-start-standalone.png[align="center"]

`start` also starts <<task-scheduler-speculation, `task-scheduler-speculation` executor service>>.

## <span id="statusUpdate"> Handling Task Status Update

```scala
statusUpdate(
  tid: Long,
  state: TaskState,
  serializedData: ByteBuffer): Unit
```

`statusUpdate` finds [TaskSetManager](TaskSetManager.md) for the input `tid` task (in <<taskIdToTaskSetManager, taskIdToTaskSetManager>>).

When `state` is `LOST`, `statusUpdate`...FIXME

NOTE: `TaskState.LOST` is only used by the deprecated Mesos fine-grained scheduling mode.

When `state` is one of the scheduler:Task.md#states[finished states], i.e. `FINISHED`, `FAILED`, `KILLED` or `LOST`, `statusUpdate` <<cleanupTaskState, cleanupTaskState>> for the input `tid`.

`statusUpdate` scheduler:TaskSetManager.md#removeRunningTask[requests `TaskSetManager` to unregister `tid` from running tasks].

`statusUpdate` requests <<taskResultGetter, TaskResultGetter>> to scheduler:TaskResultGetter.md#enqueueSuccessfulTask[schedule an asynchrounous task to deserialize the task result (and notify TaskSchedulerImpl back)] for `tid` in `FINISHED` state and scheduler:TaskResultGetter.md#enqueueFailedTask[schedule an asynchrounous task to deserialize `TaskFailedReason` (and notify TaskSchedulerImpl back)] for `tid` in the other finished states (i.e. `FAILED`, `KILLED`, `LOST`).

If a task is in `LOST` state, `statusUpdate` scheduler:DAGScheduler.md#executorLost[notifies `DAGScheduler` that the executor was lost] (with `SlaveLost` and the reason `Task [tid] was lost, so marking the executor as lost as well.`) and scheduler:SchedulerBackend.md#reviveOffers[requests SchedulerBackend to revive offers].

In case the `TaskSetManager` for `tid` could not be found (in <<taskIdToTaskSetManager, taskIdToTaskSetManager>> registry), you should see the following ERROR message in the logs:

```text
Ignoring update with state [state] for TID [tid] because its task set is gone (this is likely the result of receiving duplicate task finished status updates)
```

Any exception is caught and reported as ERROR message in the logs:

```text
Exception in statusUpdate
```

CAUTION: FIXME image with scheduler backends calling `TaskSchedulerImpl.statusUpdate`.

`statusUpdate` is used when:

* `DriverEndpoint` (of [CoarseGrainedSchedulerBackend](CoarseGrainedSchedulerBackend.md)) is requested to [handle a StatusUpdate message](DriverEndpoint.md#StatusUpdate)

* `LocalEndpoint` is requested to [handle a StatusUpdate message](../local/LocalEndpoint.md#StatusUpdate)

== [[speculationScheduler]][[task-scheduler-speculation]] task-scheduler-speculation Scheduled Executor Service -- `speculationScheduler` Internal Attribute

`speculationScheduler` is a http://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ScheduledExecutorService.html[java.util.concurrent.ScheduledExecutorService] with the name *task-scheduler-speculation* for speculative-execution-of-tasks.md[].

When <<start, TaskSchedulerImpl starts>> (in non-local run mode) with configuration-properties.md#spark.speculation[spark.speculation] enabled, `speculationScheduler` is used to schedule <<checkSpeculatableTasks, checkSpeculatableTasks>> to execute periodically every configuration-properties.md#spark.speculation.interval[spark.speculation.interval] after the initial `spark.speculation.interval` passes.

`speculationScheduler` is shut down when <<stop, TaskSchedulerImpl stops>>.

== [[checkSpeculatableTasks]] Checking for Speculatable Tasks

[source, scala]
----
checkSpeculatableTasks(): Unit
----

`checkSpeculatableTasks` requests `rootPool` to check for speculatable tasks (if they ran for more than `100` ms) and, if there any, requests scheduler:SchedulerBackend.md#reviveOffers[SchedulerBackend to revive offers].

NOTE: `checkSpeculatableTasks` is executed periodically as part of speculative-execution-of-tasks.md[].

== [[maxTaskFailures]] Acceptable Number of Task Failures

TaskSchedulerImpl can be given the acceptable number of task failures when created or defaults to configuration-properties.md#spark.task.maxFailures[spark.task.maxFailures] configuration property.

The number of task failures is used when <<submitTasks, submitting tasks>> through scheduler:TaskSetManager.md[TaskSetManager].

== [[removeExecutor]] Cleaning up After Removing Executor -- `removeExecutor` Internal Method

[source, scala]
----
removeExecutor(executorId: String, reason: ExecutorLossReason): Unit
----

`removeExecutor` removes the `executorId` executor from the following <<internal-registries, internal registries>>: <<executorIdToTaskCount, executorIdToTaskCount>>, `executorIdToHost`, `executorsByHost`, and `hostsByRack`. If the affected hosts and racks are the last entries in `executorsByHost` and `hostsByRack`, appropriately, they are removed from the registries.

Unless `reason` is `LossReasonPending`, the executor is removed from `executorIdToHost` registry and spark-scheduler-Schedulable.md#executorLost[TaskSetManagers get notified].

NOTE: The internal `removeExecutor` is called as part of <<statusUpdate, statusUpdate>> and scheduler:TaskScheduler.md#executorLost[executorLost].

== [[postStartHook]] Handling Nearly-Completed SparkContext Initialization -- `postStartHook` Callback

[source, scala]
----
postStartHook(): Unit
----

NOTE: `postStartHook` is part of the scheduler:TaskScheduler.md#postStartHook[TaskScheduler Contract] to notify a scheduler:TaskScheduler.md[task scheduler] that the `SparkContext` (and hence the Spark application itself) is about to finish initialization.

`postStartHook` simply <<waitBackendReady, waits until a scheduler backend is ready>>.

== [[stop]] Stopping TaskSchedulerImpl -- `stop` Method

[source, scala]
----
stop(): Unit
----

`stop()` stops all the internal services, i.e. <<task-scheduler-speculation, `task-scheduler-speculation` executor service>>, scheduler:SchedulerBackend.md[SchedulerBackend], scheduler:TaskResultGetter.md[TaskResultGetter], and <<starvationTimer, starvationTimer>> timer.

== [[defaultParallelism]] Finding Default Level of Parallelism -- `defaultParallelism` Method

[source, scala]
----
defaultParallelism(): Int
----

NOTE: `defaultParallelism` is part of scheduler:TaskScheduler.md#defaultParallelism[TaskScheduler contract] as a hint for sizing jobs.

`defaultParallelism` simply requests <<backend, SchedulerBackend>> for the scheduler:SchedulerBackend.md#defaultParallelism[default level of parallelism].

NOTE: *Default level of parallelism* is a hint for sizing jobs that `SparkContext` SparkContext.md#defaultParallelism[uses to create RDDs with the right number of partitions when not specified explicitly].

== [[submitTasks]] Submitting Tasks (of TaskSet) for Execution -- `submitTasks` Method

[source, scala]
----
submitTasks(taskSet: TaskSet): Unit
----

NOTE: `submitTasks` is part of the scheduler:TaskScheduler.md#submitTasks[TaskScheduler Contract] to submit the tasks (of the given scheduler:TaskSet.md[TaskSet]) for execution.

In essence, `submitTasks` registers a new scheduler:TaskSetManager.md[TaskSetManager] (for the given scheduler:TaskSet.md[TaskSet]) and requests the <<backend, SchedulerBackend>> to scheduler:SchedulerBackend.md#reviveOffers[handle resource allocation offers (from the scheduling system)].

.TaskSchedulerImpl.submitTasks
image::taskschedulerImpl-submitTasks.png[align="center"]

Internally, `submitTasks` first prints out the following INFO message to the logs:

```
Adding task set [id] with [length] tasks
```

`submitTasks` then <<createTaskSetManager, creates a TaskSetManager>> (for the given scheduler:TaskSet.md[TaskSet] and the <<maxTaskFailures, acceptable number of task failures>>).

`submitTasks` registers (_adds_) the `TaskSetManager` per scheduler:TaskSet.md#stageId[stage] and scheduler:TaskSet.md#stageAttemptId[stage attempt] IDs (of the scheduler:TaskSet.md[TaskSet]) in the <<taskSetsByStageIdAndAttempt, taskSetsByStageIdAndAttempt>> internal registry.

NOTE: <<taskSetsByStageIdAndAttempt, taskSetsByStageIdAndAttempt>> internal registry tracks the scheduler:TaskSetManager.md[TaskSetManagers] (that represent scheduler:TaskSet.md[TaskSets]) per stage and stage attempts. In other words, there could be many `TaskSetManagers` for a single stage, each representing a unique stage attempt.

NOTE: Not only could a task be retried (cf. <<maxTaskFailures, acceptable number of task failures>>), but also a single stage.

`submitTasks` makes sure that there is exactly one active `TaskSetManager` (with different `TaskSet`) across all the managers (for the stage). Otherwise, `submitTasks` throws an `IllegalStateException`:

```
more than one active taskSet for stage [stage]: [TaskSet ids]
```

NOTE: `TaskSetManager` is considered *active* when it is not a *zombie*.

`submitTasks` requests the <<schedulableBuilder, SchedulableBuilder>> to spark-scheduler-SchedulableBuilder.md#addTaskSetManager[add the TaskSetManager to the schedulable pool].

NOTE: The scheduler:TaskScheduler.md#rootPool[schedulable pool] can be a single flat linked queue (in spark-scheduler-FIFOSchedulableBuilder.md[FIFO scheduling mode]) or a hierarchy of pools of `Schedulables` (in spark-scheduler-FairSchedulableBuilder.md[FAIR scheduling mode]).

`submitTasks` <<submitTasks-starvationTimer, schedules a starvation task>> to make sure that the requested resources (i.e. CPU and memory) are assigned to the Spark application for a <<isLocal, non-local environment>> (the very first time the Spark application is started per <<hasReceivedTask, hasReceivedTask>> flag).

NOTE: The very first time (<<hasReceivedTask, hasReceivedTask>> flag is `false`) in cluster mode only (i.e. `isLocal` of the TaskSchedulerImpl is `false`), `starvationTimer` is scheduled to execute after configuration-properties.md#spark.starvation.timeout[spark.starvation.timeout]  to ensure that the requested resources, i.e. CPUs and memory, were assigned by a cluster manager.

NOTE: After the first configuration-properties.md#spark.starvation.timeout[spark.starvation.timeout] passes, the <<hasReceivedTask, hasReceivedTask>> internal flag is `true`.

In the end, `submitTasks` requests the <<backend, SchedulerBackend>> to scheduler:SchedulerBackend.md#reviveOffers[reviveOffers].

TIP: Use `dag-scheduler-event-loop` thread to step through the code in a debugger.

=== [[submitTasks-starvationTimer]] Scheduling Starvation Task

Every time the starvation timer thread is executed and `hasLaunchedTask` flag is `false`, the following WARN message is printed out to the logs:

```
WARN Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
```

Otherwise, when the `hasLaunchedTask` flag is `true` the timer thread cancels itself.

== [[createTaskSetManager]] Creating TaskSetManager -- `createTaskSetManager` Method

[source, scala]
----
createTaskSetManager(taskSet: TaskSet, maxTaskFailures: Int): TaskSetManager
----

`createTaskSetManager` scheduler:TaskSetManager.md#creating-instance[creates a `TaskSetManager`] (passing on the reference to TaskSchedulerImpl, the input `taskSet` and `maxTaskFailures`, and optional `BlacklistTracker`).

NOTE: `createTaskSetManager` uses the optional <<blacklistTrackerOpt, BlacklistTracker>> that is specified when <<creating-instance, TaskSchedulerImpl is created>>.

NOTE: `createTaskSetManager` is used exclusively when <<submitTasks, TaskSchedulerImpl submits tasks (for a given `TaskSet`)>>.

== [[handleFailedTask]] Notifying TaskSetManager that Task Failed -- `handleFailedTask` Method

[source, scala]
----
handleFailedTask(
  taskSetManager: TaskSetManager,
  tid: Long,
  taskState: TaskState,
  reason: TaskFailedReason): Unit
----

`handleFailedTask` scheduler:TaskSetManager.md#handleFailedTask[notifies `taskSetManager` that `tid` task has failed] and, only when scheduler:TaskSetManager.md#zombie-state[`taskSetManager` is not in zombie state] and `tid` is not in `KILLED` state, scheduler:SchedulerBackend.md#reviveOffers[requests SchedulerBackend to revive offers].

NOTE: `handleFailedTask` is called when scheduler:TaskResultGetter.md#enqueueSuccessfulTask[`TaskResultGetter` deserializes a `TaskFailedReason`] for a failed task.

== [[taskSetFinished]] `taskSetFinished` Method

[source, scala]
----
taskSetFinished(manager: TaskSetManager): Unit
----

`taskSetFinished` looks all scheduler:TaskSet.md[TaskSet]s up by the stage id (in <<taskSetsByStageIdAndAttempt, taskSetsByStageIdAndAttempt>> registry) and removes the stage attempt from them, possibly with removing the entire stage record from `taskSetsByStageIdAndAttempt` registry completely (if there are no other attempts registered).

.TaskSchedulerImpl.taskSetFinished is called when all tasks are finished
image::taskschedulerimpl-tasksetmanager-tasksetfinished.png[align="center"]

NOTE: A `TaskSetManager` manages a `TaskSet` for a stage.

`taskSetFinished` then spark-scheduler-Pool.md#removeSchedulable[removes `manager` from the parent's schedulable pool].

You should see the following INFO message in the logs:

```
Removed TaskSet [id], whose tasks have all completed, from pool [name]
```

NOTE: `taskSetFinished` method is called when scheduler:TaskSetManager.md#maybeFinishTaskSet[`TaskSetManager` has received the results of all the tasks in a `TaskSet`].

== [[executorAdded]] Notifying DAGScheduler About New Executor -- `executorAdded` Method

[source, scala]
----
executorAdded(execId: String, host: String)
----

`executorAdded` just scheduler:DAGScheduler.md#executorAdded[notifies `DAGScheduler` that an executor was added].

CAUTION: FIXME Image with a call from TaskSchedulerImpl to DAGScheduler, please.

NOTE: `executorAdded` uses <<dagScheduler, DAGScheduler>> that was given when <<setDAGScheduler, setDAGScheduler>>.

== [[waitBackendReady]] Waiting Until SchedulerBackend is Ready -- `waitBackendReady` Internal Method

[source, scala]
----
waitBackendReady(): Unit
----

`waitBackendReady` waits until the <<backend, SchedulerBackend>> is scheduler:SchedulerBackend.md#isReady[ready]. If it is, `waitBackendReady` returns immediately. Otherwise, `waitBackendReady` keeps checking every `100` milliseconds (hardcoded) or the <<sc, SparkContext>> is SparkContext.md#stopped[stopped].

NOTE: A SchedulerBackend is scheduler:SchedulerBackend.md#isReady[ready] by default.

If the `SparkContext` happens to be stopped while waiting, `waitBackendReady` throws an `IllegalStateException`:

```
Spark context stopped while waiting for backend
```

NOTE: `waitBackendReady` is used exclusively when TaskSchedulerImpl is requested to <<postStartHook, handle a notification that SparkContext is about to be fully initialized>>.

== [[resourceOffers]] Creating TaskDescriptions For Available Executor Resource Offers

[source, scala]
----
resourceOffers(
  offers: Seq[WorkerOffer]): Seq[Seq[TaskDescription]]
----

`resourceOffers` takes the resources `offers` (as <<WorkerOffer, WorkerOffers>>) and generates a collection of tasks (as [TaskDescription](TaskDescription.md)) to launch (given the resources available).

NOTE: <<WorkerOffer, WorkerOffer>> represents a resource offer with CPU cores free to use on an executor.

.Processing Executor Resource Offers
image::taskscheduler-resourceOffers.png[align="center"]

Internally, `resourceOffers` first updates <<hostToExecutors, hostToExecutors>> and <<executorIdToHost, executorIdToHost>> lookup tables to record new hosts and executors (given the input `offers`).

For new executors (not in <<executorIdToRunningTaskIds, executorIdToRunningTaskIds>>) `resourceOffers` <<executorAdded, notifies `DAGScheduler` that an executor was added>>.

NOTE: TaskSchedulerImpl uses `resourceOffers` to track active executors.

CAUTION: FIXME a picture with `executorAdded` call from TaskSchedulerImpl to DAGScheduler.

`resourceOffers` requests `BlacklistTracker` to `applyBlacklistTimeout` and filters out offers on blacklisted nodes and executors.

NOTE: `resourceOffers` uses the optional <<blacklistTrackerOpt, BlacklistTracker>> that was given when <<creating-instance, TaskSchedulerImpl was created>>.

CAUTION: FIXME Expand on blacklisting

`resourceOffers` then randomly shuffles offers (to evenly distribute tasks across executors and avoid over-utilizing some executors) and initializes the local data structures `tasks` and `availableCpus` (as shown in the figure below).

.Internal Structures of resourceOffers with 5 WorkerOffers (with 4, 2, 0, 3, 2 free cores)
image::TaskSchedulerImpl-resourceOffers-internal-structures.png[align="center"]

`resourceOffers` spark-scheduler-Pool.md#getSortedTaskSetQueue[takes `TaskSets` in scheduling order] from scheduler:TaskScheduler.md#rootPool[top-level Schedulable Pool].

.TaskSchedulerImpl Requesting TaskSets (as TaskSetManagers) from Root Pool
image::TaskSchedulerImpl-resourceOffers-rootPool-getSortedTaskSetQueue.png[align="center"]

[NOTE]
====
`rootPool` is configured when <<initialize, TaskSchedulerImpl is initialized>>.

`rootPool` is part of the scheduler:TaskScheduler.md#rootPool[TaskScheduler Contract] and exclusively managed by scheduler:spark-scheduler-SchedulableBuilder.md[SchedulableBuilders], i.e. scheduler:spark-scheduler-FIFOSchedulableBuilder.md[FIFOSchedulableBuilder] and scheduler:spark-scheduler-FairSchedulableBuilder.md[FairSchedulableBuilder] (that  scheduler:spark-scheduler-SchedulableBuilder.md#addTaskSetManager[manage registering TaskSetManagers with the root pool]).

scheduler:TaskSetManager.md[TaskSetManager] manages execution of the tasks in a single scheduler:TaskSet.md[TaskSet] that represents a single scheduler:Stage.md[Stage].
====

For every `TaskSetManager` (in scheduling order), you should see the following DEBUG message in the logs:

```
parentName: [name], name: [name], runningTasks: [count]
```

Only if a new executor was added, `resourceOffers` scheduler:TaskSetManager.md#executorAdded[notifies every `TaskSetManager` about the change] (to recompute locality preferences).

`resourceOffers` then takes every `TaskSetManager` (in scheduling order) and offers them each node in increasing order of locality levels (per scheduler:TaskSetManager.md#computeValidLocalityLevels[TaskSetManager's valid locality levels]).

NOTE: A `TaskSetManager` scheduler:TaskSetManager.md##computeValidLocalityLevels[computes locality levels of the tasks] it manages.

For every `TaskSetManager` and the ``TaskSetManager``'s valid locality level, `resourceOffers` tries to <<resourceOfferSingleTaskSet, find tasks to schedule (on executors)>> as long as the `TaskSetManager` manages to launch a task (given the locality level).

If `resourceOffers` did not manage to offer resources to a `TaskSetManager` so it could launch any task, `resourceOffers` scheduler:TaskSetManager.md#abortIfCompletelyBlacklisted[requests the `TaskSetManager` to abort the `TaskSet` if completely blacklisted].

When `resourceOffers` managed to launch a task, the internal <<hasLaunchedTask, hasLaunchedTask>> flag gets enabled (that effectively means what the name says _"there were executors and I managed to launch a task"_).

`resourceOffers` is used when:

* `CoarseGrainedSchedulerBackend` (via `DriverEndpoint` RPC endpoint) is requested to [make executor resource offers](DriverEndpoint.md#makeOffers)

* `LocalEndpoint` is requested to [revive resource offers](../local/LocalEndpoint.md#reviveOffers)

== [[resourceOfferSingleTaskSet]] Finding Tasks from TaskSetManager to Schedule on Executors -- `resourceOfferSingleTaskSet` Internal Method

[source, scala]
----
resourceOfferSingleTaskSet(
  taskSet: TaskSetManager,
  maxLocality: TaskLocality,
  shuffledOffers: Seq[WorkerOffer],
  availableCpus: Array[Int],
  tasks: Seq[ArrayBuffer[TaskDescription]]): Boolean
----

`resourceOfferSingleTaskSet` takes every `WorkerOffer` (from the input `shuffledOffers`) and (only if the number of available CPU cores (using the input `availableCpus`) is at least configuration-properties.md#spark.task.cpus[spark.task.cpus]) scheduler:TaskSetManager.md#resourceOffer[requests `TaskSetManager` (as the input `taskSet`) to find a `Task` to execute (given the resource offer)] (as an executor, a host, and the input `maxLocality`).

`resourceOfferSingleTaskSet` adds the task to the input `tasks` collection.

`resourceOfferSingleTaskSet` records the task id and `TaskSetManager` in the following registries:

* <<taskIdToTaskSetManager, taskIdToTaskSetManager>>
* <<taskIdToExecutorId, taskIdToExecutorId>>
* <<executorIdToRunningTaskIds, executorIdToRunningTaskIds>>

`resourceOfferSingleTaskSet` decreases configuration-properties.md#spark.task.cpus[spark.task.cpus] from the input `availableCpus` (for the `WorkerOffer`).

NOTE: `resourceOfferSingleTaskSet` makes sure that the number of available CPU cores (in the input `availableCpus` per `WorkerOffer`) is at least `0`.

If there is a `TaskNotSerializableException`, you should see the following ERROR in the logs:

```
ERROR Resource offer failed, task set [name] was not serializable
```

`resourceOfferSingleTaskSet` returns whether a task was launched or not.

NOTE: `resourceOfferSingleTaskSet` is used when TaskSchedulerImpl <<resourceOffers, creates `TaskDescriptions` for available executor resource offers (with CPU cores)>>.

== [[TaskLocality]] TaskLocality -- Task Locality Preference

`TaskLocality` represents a task locality preference and can be one of the following (from most localized to the widest):

. `PROCESS_LOCAL`
. `NODE_LOCAL`
. `NO_PREF`
. `RACK_LOCAL`
. `ANY`

== [[WorkerOffer]] WorkerOffer -- Free CPU Cores on Executor

[source, scala]
----
WorkerOffer(executorId: String, host: String, cores: Int)
----

`WorkerOffer` represents a resource offer with free CPU `cores` available on an `executorId` executor on a `host`.

== [[workerRemoved]] workerRemoved Method

[source, scala]
----
workerRemoved(
  workerId: String,
  host: String,
  message: String): Unit
----

workerRemoved prints out the following INFO message to the logs:

```
Handle removed worker [workerId]: [message]
```

workerRemoved then requests the <<dagScheduler, DAGScheduler>> to scheduler:DAGScheduler.md#workerRemoved[handle it].

workerRemoved is part of the scheduler:TaskScheduler.md#workerRemoved[TaskScheduler] abstraction.

== [[maybeInitBarrierCoordinator]] maybeInitBarrierCoordinator Method

[source,scala]
----
maybeInitBarrierCoordinator(): Unit
----

maybeInitBarrierCoordinator...FIXME

maybeInitBarrierCoordinator is used when TaskSchedulerImpl is requested to <<resourceOffers, resourceOffers>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.TaskSchedulerImpl` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.scheduler.TaskSchedulerImpl=ALL
----

Refer to spark-logging.md[Logging].

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| dagScheduler
a| [[dagScheduler]] scheduler:DAGScheduler.md[DAGScheduler]

Used when...FIXME

| executorIdToHost
a| [[executorIdToHost]] Lookup table of hosts per executor.

Used when...FIXME

| executorIdToRunningTaskIds
a| [[executorIdToRunningTaskIds]] Lookup table of running tasks per executor.

Used when...FIXME

| executorIdToTaskCount
a| [[executorIdToTaskCount]] Lookup table of the number of running tasks by executor:Executor.md[].

| executorsByHost
a| [[executorsByHost]] Collection of executor:Executor.md[executors] per host

| hasLaunchedTask
a| [[hasLaunchedTask]] Flag...FIXME

Used when...FIXME

| hostToExecutors
a| [[hostToExecutors]] Lookup table of executors per hosts in a cluster.

Used when...FIXME

| hostsByRack
a| [[hostsByRack]] Lookup table of hosts per rack.

Used when...FIXME

| nextTaskId
a| [[nextTaskId]] The next scheduler:Task.md[task] id counting from `0`.

Used when TaskSchedulerImpl...

| rootPool
a| [[rootPool]] spark-scheduler-Pool.md[Schedulable pool]

Used when TaskSchedulerImpl...

| schedulableBuilder
a| [[schedulableBuilder]] <<spark-scheduler-SchedulableBuilder.md#, SchedulableBuilder>>

Created when TaskSchedulerImpl is requested to <<initialize, initialize>> and can be one of two available builders:

* spark-scheduler-FIFOSchedulableBuilder.md[FIFOSchedulableBuilder] when scheduling policy is FIFO (which is the default scheduling policy).

* spark-scheduler-FairSchedulableBuilder.md[FairSchedulableBuilder] for FAIR scheduling policy.

NOTE: Use configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property to select the scheduling policy.

| schedulingMode
a| [[schedulingMode]] spark-scheduler-SchedulingMode.md[SchedulingMode]

Used when TaskSchedulerImpl...

| taskSetsByStageIdAndAttempt
a| [[taskSetsByStageIdAndAttempt]] Lookup table of scheduler:TaskSet.md[TaskSet] by stage and attempt ids.

| taskIdToExecutorId
a| [[taskIdToExecutorId]] Lookup table of executor:Executor.md[] by task id.

| taskIdToTaskSetManager
a| [[taskIdToTaskSetManager]] Registry of active scheduler:TaskSetManager.md[TaskSetManagers] per task id.

|===
