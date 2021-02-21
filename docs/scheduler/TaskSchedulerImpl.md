# TaskSchedulerImpl

`TaskSchedulerImpl` is a [TaskScheduler](TaskScheduler.md) that uses a [SchedulerBackend](#backend) to schedule tasks (for execution on a cluster manager).

When a Spark application starts (and so an instance of `SparkContext` is [created](../SparkContext.md#creating-instance)) `TaskSchedulerImpl` with a [SchedulerBackend](SchedulerBackend.md) and [DAGScheduler](DAGScheduler.md) are created and soon started.

![TaskSchedulerImpl and Other Services](../images/scheduler/taskschedulerimpl-sparkcontext-schedulerbackend-dagscheduler.png)

`TaskSchedulerImpl` [generates tasks based on executor resource offers](#resourceOffers).

`TaskSchedulerImpl` can [track racks per host and port](#getRackForHost) (that however is only used with Hadoop YARN cluster manager).

Using [spark.scheduler.mode](../configuration-properties.md#spark.scheduler.mode) configuration property you can select the [scheduling policy](SchedulingMode.md).

`TaskSchedulerImpl` [submits tasks](#submitTasks) using [SchedulableBuilder](SchedulableBuilder.md)s.

## Creating Instance

`TaskSchedulerImpl` takes the following to be created:

* <span id="sc"> [SparkContext](../SparkContext.md)
* [Maximum Number of Task Failures](#maxTaskFailures)
* <span id="isLocal"> `isLocal` flag (default: `false`)
* <span id="clock"> `Clock` (default: `SystemClock`)

While being created, `TaskSchedulerImpl` sets [schedulingMode](TaskScheduler.md#schedulingMode) to the value of [spark.scheduler.mode](../configuration-properties.md#spark.scheduler.mode) configuration property.

!!! note
    `schedulingMode` is part of the [TaskScheduler](TaskScheduler.md#schedulingMode) abstraction.

`TaskSchedulerImpl` throws a `SparkException` for unrecognized scheduling mode:

```text
Unrecognized spark.scheduler.mode: [schedulingModeConf]
```

In the end, `TaskSchedulerImpl` creates a [TaskResultGetter](TaskResultGetter.md).

`TaskSchedulerImpl` is created when:

* `SparkContext` is requested for a [TaskScheduler](../SparkContext.md#createTaskScheduler) (for `local` and `spark` master URLs)
* `KubernetesClusterManager` and `MesosClusterManager` are requested for a `TaskScheduler`

## <span id="maxTaskFailures"> Maximum Number of Task Failures

`TaskSchedulerImpl` can be given the maximum number of task failures when [created](#creating-instance) or default to [spark.task.maxFailures](../configuration-properties.md#spark.task.maxFailures) configuration property.

The number of task failures is used when [submitting tasks](#submitTasks) (to [create a TaskSetManager](#createTaskSetManager)).

## <span id="CPUS_PER_TASK"> spark.task.cpus

`TaskSchedulerImpl` uses [spark.task.cpus](../configuration-properties.md#spark.task.cpus) configuration property for...FIXME

## <span id="backend"> SchedulerBackend

```scala
backend: SchedulerBackend
```

`TaskSchedulerImpl` is given a [SchedulerBackend](SchedulerBackend.md) when requested to [initialize](#initialize).

The lifecycle of the `SchedulerBackend` is tightly coupled to the lifecycle of the `TaskSchedulerImpl`:

* It is [started](SchedulerBackend.md#start) when `TaskSchedulerImpl` [is](#start)
* It is [stopped](SchedulerBackend.md#stop) when `TaskSchedulerImpl` [is](#stop)

`TaskSchedulerImpl` [waits until the SchedulerBackend is ready](#waitBackendReady) before requesting it for the following:

* [Reviving resource offers](SchedulerBackend.md#reviveOffers) when requested to [submitTasks](#submitTasks), [statusUpdate](#statusUpdate), [handleFailedTask](#handleFailedTask), [checkSpeculatableTasks](#checkSpeculatableTasks), and [executorLost](#executorLost)

* [Killing tasks](SchedulerBackend.md#killTask) when requested to [killTaskAttempt](#killTaskAttempt) and [killAllTaskAttempts](#killAllTaskAttempts)

* [Default parallelism](SchedulerBackend.md#defaultParallelism), [applicationId](SchedulerBackend.md#applicationId) and [applicationAttemptId](SchedulerBackend.md#applicationAttemptId) when requested for the [defaultParallelism](#defaultParallelism), [applicationId](#applicationId) and [applicationAttemptId](#applicationAttemptId), respectively

## <span id="applicationId"> Unique Identifier of Spark Application

```scala
applicationId(): String
```

`applicationId` is part of the [TaskScheduler](TaskScheduler.md#applicationId) abstraction.

`applicationId` simply request the [SchedulerBackend](#backend) for the [applicationId](SchedulerBackend.md#applicationId).

## <span id="executorHeartbeatReceived"> executorHeartbeatReceived

```scala
executorHeartbeatReceived(
  execId: String,
  accumUpdates: Array[(Long, Seq[AccumulatorV2[_, _]])],
  blockManagerId: BlockManagerId): Boolean
```

`executorHeartbeatReceived` is part of the [TaskScheduler](TaskScheduler.md#executorHeartbeatReceived) abstraction.

`executorHeartbeatReceived` is...FIXME

## <span id="cancelTasks"> Cancelling All Tasks of Stage

```scala
cancelTasks(
  stageId: Int,
  interruptThread: Boolean): Unit
```

`cancelTasks` is part of the [TaskScheduler](TaskScheduler.md#cancelTasks) abstraction.

`cancelTasks` cancels all tasks submitted for execution in a stage `stageId`.

`cancelTasks` is used when:

* `DAGScheduler` is requested to [failJobAndIndependentStages](DAGScheduler.md#failJobAndIndependentStages)

## <span id="handleSuccessfulTask"> handleSuccessfulTask

```scala
handleSuccessfulTask(
  taskSetManager: TaskSetManager,
  tid: Long,
  taskResult: DirectTaskResult[_]): Unit
```

`handleSuccessfulTask` requests the given [TaskSetManager](TaskSetManager.md) to [handleSuccessfulTask](TaskSetManager.md#handleSuccessfulTask) (with the given `tid` and `taskResult`).

`handleSuccessfulTask` is used when:

* `TaskResultGetter` is requested to [enqueueSuccessfulTask](#TaskResultGetter.md#enqueueSuccessfulTask)

## <span id="handleTaskGettingResult"> handleTaskGettingResult

```scala
handleTaskGettingResult(
  taskSetManager: TaskSetManager,
  tid: Long): Unit
```

`handleTaskGettingResult` requests the given [TaskSetManager](TaskSetManager.md) to [handleTaskGettingResult](#handleTaskGettingResult).

`handleTaskGettingResult` is used when:

* `TaskResultGetter` is requested to [enqueueSuccessfulTask](TaskResultGetter.md#enqueueSuccessfulTask)

## <span id="getRackForHost"> Tracking Racks per Hosts and Ports

```scala
getRackForHost(value: String): Option[String]
```

`getRackForHost` is a method to know about the racks per hosts and ports. By default, it assumes that racks are unknown (i.e. the method returns `None`).

`getRackForHost` is currently used in two places:

* <<resourceOffers, TaskSchedulerImpl.resourceOffers>> to track hosts per rack (using the <<internal-registries, internal `hostsByRack` registry>>) while processing resource offers.

* <<removeExecutor, TaskSchedulerImpl.removeExecutor>> to...FIXME

* scheduler:TaskSetManager.md#addPendingTask[TaskSetManager.addPendingTask], scheduler:TaskSetManager.md#[TaskSetManager.dequeueTask], and scheduler:TaskSetManager.md#dequeueSpeculativeTask[TaskSetManager.dequeueSpeculativeTask]

## <span id="initialize"> Initializing

```scala
initialize(
  backend: SchedulerBackend): Unit
```

`initialize` initializes the `TaskSchedulerImpl` with the given [SchedulerBackend](SchedulerBackend.md).

![TaskSchedulerImpl initialization](../images/scheduler/TaskSchedulerImpl-initialize.png)

`initialize` saves the given [SchedulerBackend](#backend).

`initialize` then sets <<rootPool, schedulable `Pool`>> as an empty-named Pool.md[Pool] (passing in <<schedulingMode, SchedulingMode>>, `initMinShare` and `initWeight` as `0`).

NOTE: <<schedulingMode, schedulingMode>> and <<rootPool, rootPool>> are a part of scheduler:TaskScheduler.md#contract[TaskScheduler Contract].

`initialize` sets <<schedulableBuilder, SchedulableBuilder>> (based on <<schedulingMode, SchedulingMode>>):

* FIFOSchedulableBuilder.md[FIFOSchedulableBuilder] for `FIFO` scheduling mode
* FairSchedulableBuilder.md[FairSchedulableBuilder] for `FAIR` scheduling mode

`initialize` SchedulableBuilder.md#buildPools[requests `SchedulableBuilder` to build pools].

CAUTION: FIXME Why are `rootPool` and `schedulableBuilder` created only now? What do they need that it is not available when TaskSchedulerImpl is created?

NOTE: `initialize` is called while SparkContext.md#createTaskScheduler[SparkContext is created and creates SchedulerBackend and `TaskScheduler`].

## <span id="start"> Starting TaskSchedulerImpl

```scala
start(): Unit
```

`start` starts the [SchedulerBackend](#backend) and the [task-scheduler-speculation](#task-scheduler-speculation) executor service.

![Starting TaskSchedulerImpl in Spark Standalone](../images/scheduler/taskschedulerimpl-start-standalone.png)

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

## <span id="speculationScheduler"><span id="task-scheduler-speculation"> task-scheduler-speculation Scheduled Executor Service

`speculationScheduler` is a [java.util.concurrent.ScheduledExecutorService]({{ java.api }}/java.base/java/util/concurrent/ScheduledExecutorService.html) with the name **task-scheduler-speculation** for [Speculative Execution of Tasks](../speculative-execution-of-tasks.md).

When `TaskSchedulerImpl` is requested to [start](#start) (in non-local run mode) with [spark.speculation](../configuration-properties.md#spark.speculation) enabled, `speculationScheduler` is used to schedule [checkSpeculatableTasks](#checkSpeculatableTasks) to execute periodically every [spark.speculation.interval](../configuration-properties.md#spark.speculation.interval).

`speculationScheduler` is shut down when `TaskSchedulerImpl` is requested to [stop](#stop).

## <span id="checkSpeculatableTasks"> Checking for Speculatable Tasks

```scala
checkSpeculatableTasks(): Unit
```

`checkSpeculatableTasks` requests `rootPool` to check for speculatable tasks (if they ran for more than `100` ms) and, if there any, requests scheduler:SchedulerBackend.md#reviveOffers[SchedulerBackend to revive offers].

NOTE: `checkSpeculatableTasks` is executed periodically as part of speculative-execution-of-tasks.md[].

## <span id="removeExecutor"> Cleaning up After Removing Executor

```scala
removeExecutor(
  executorId: String,
  reason: ExecutorLossReason): Unit
```

`removeExecutor` removes the `executorId` executor from the following <<internal-registries, internal registries>>: <<executorIdToTaskCount, executorIdToTaskCount>>, `executorIdToHost`, `executorsByHost`, and `hostsByRack`. If the affected hosts and racks are the last entries in `executorsByHost` and `hostsByRack`, appropriately, they are removed from the registries.

Unless `reason` is `LossReasonPending`, the executor is removed from `executorIdToHost` registry and Schedulable.md#executorLost[TaskSetManagers get notified].

NOTE: The internal `removeExecutor` is called as part of <<statusUpdate, statusUpdate>> and scheduler:TaskScheduler.md#executorLost[executorLost].

## <span id="postStartHook"> Handling Nearly-Completed SparkContext Initialization

```scala
postStartHook(): Unit
```

`postStartHook` is part of the [TaskScheduler](TaskScheduler.md#postStartHook) abstraction.

`postStartHook` [waits until a scheduler backend is ready](#waitBackendReady).

### <span id="waitBackendReady"> Waiting Until SchedulerBackend is Ready

```scala
waitBackendReady(): Unit
```

`waitBackendReady` waits until the [SchedulerBackend](#backend) is [ready](SchedulerBackend.md#isReady). If it is, `waitBackendReady` returns immediately. Otherwise, `waitBackendReady` keeps checking every `100` milliseconds (hardcoded) or the <<sc, SparkContext>> is SparkContext.md#stopped[stopped].

!!! note
    A `SchedulerBackend` is [ready](SchedulerBackend.md#isReady) by default.

If the `SparkContext` happens to be stopped while waiting, `waitBackendReady` throws an `IllegalStateException`:

```text
Spark context stopped while waiting for backend
```

## <span id="stop"> Stopping TaskSchedulerImpl

```scala
stop(): Unit
```

`stop` stops all the internal services, i.e. <<task-scheduler-speculation, `task-scheduler-speculation` executor service>>, scheduler:SchedulerBackend.md[SchedulerBackend], scheduler:TaskResultGetter.md[TaskResultGetter], and <<starvationTimer, starvationTimer>> timer.

## <span id="defaultParallelism"> Default Level of Parallelism

```scala
defaultParallelism(): Int
```

`defaultParallelism` is part of the [TaskScheduler](TaskScheduler.md#defaultParallelism) abstraction.

`defaultParallelism` requests the [SchedulerBackend](#backend) for the [default level of parallelism](SchedulerBackend.md#defaultParallelism).

!!! note
    **Default level of parallelism** is a hint for sizing jobs that `SparkContext` uses to [create RDDs with the right number of partitions unless specified explicitly](../SparkContext.md#defaultParallelism).

## <span id="submitTasks"> Submitting Tasks (of TaskSet) for Execution

```scala
submitTasks(
  taskSet: TaskSet): Unit
```

`submitTasks` is part of the [TaskScheduler](TaskScheduler.md#submitTasks) abstraction.

In essence, `submitTasks` registers a new [TaskSetManager](TaskSetManager.md) (for the given [TaskSet](TaskSet.md)) and requests the [SchedulerBackend](#backend) to [handle resource allocation offers (from the scheduling system)](SchedulerBackend.md#reviveOffers).

![TaskSchedulerImpl.submitTasks](../images/scheduler/taskschedulerImpl-submitTasks.png)

Internally, `submitTasks` prints out the following INFO message to the logs:

```text
Adding task set [id] with [length] tasks
```

`submitTasks` then <<createTaskSetManager, creates a TaskSetManager>> (for the given TaskSet.md[TaskSet] and the <<maxTaskFailures, acceptable number of task failures>>).

`submitTasks` registers (_adds_) the `TaskSetManager` per TaskSet.md#stageId[stage] and TaskSet.md#stageAttemptId[stage attempt] IDs (of the TaskSet.md[TaskSet]) in the <<taskSetsByStageIdAndAttempt, taskSetsByStageIdAndAttempt>> internal registry.

NOTE: <<taskSetsByStageIdAndAttempt, taskSetsByStageIdAndAttempt>> internal registry tracks the TaskSetManager.md[TaskSetManagers] (that represent TaskSet.md[TaskSets]) per stage and stage attempts. In other words, there could be many `TaskSetManagers` for a single stage, each representing a unique stage attempt.

NOTE: Not only could a task be retried (cf. <<maxTaskFailures, acceptable number of task failures>>), but also a single stage.

`submitTasks` makes sure that there is exactly one active `TaskSetManager` (with different `TaskSet`) across all the managers (for the stage). Otherwise, `submitTasks` throws an `IllegalStateException`:

```text
more than one active taskSet for stage [stage]: [TaskSet ids]
```

NOTE: `TaskSetManager` is considered *active* when it is not a *zombie*.

`submitTasks` requests the <<schedulableBuilder, SchedulableBuilder>> to SchedulableBuilder.md#addTaskSetManager[add the TaskSetManager to the schedulable pool].

NOTE: The TaskScheduler.md#rootPool[schedulable pool] can be a single flat linked queue (in FIFOSchedulableBuilder.md[FIFO scheduling mode]) or a hierarchy of pools of `Schedulables` (in FairSchedulableBuilder.md[FAIR scheduling mode]).

`submitTasks` <<submitTasks-starvationTimer, schedules a starvation task>> to make sure that the requested resources (i.e. CPU and memory) are assigned to the Spark application for a <<isLocal, non-local environment>> (the very first time the Spark application is started per <<hasReceivedTask, hasReceivedTask>> flag).

NOTE: The very first time (<<hasReceivedTask, hasReceivedTask>> flag is `false`) in cluster mode only (i.e. `isLocal` of the TaskSchedulerImpl is `false`), `starvationTimer` is scheduled to execute after configuration-properties.md#spark.starvation.timeout[spark.starvation.timeout]  to ensure that the requested resources, i.e. CPUs and memory, were assigned by a cluster manager.

NOTE: After the first configuration-properties.md#spark.starvation.timeout[spark.starvation.timeout] passes, the <<hasReceivedTask, hasReceivedTask>> internal flag is `true`.

In the end, `submitTasks` requests the <<backend, SchedulerBackend>> to scheduler:SchedulerBackend.md#reviveOffers[reviveOffers].

TIP: Use `dag-scheduler-event-loop` thread to step through the code in a debugger.

### <span id="submitTasks-starvationTimer"> Scheduling Starvation Task

Every time the starvation timer thread is executed and `hasLaunchedTask` flag is `false`, the following WARN message is printed out to the logs:

```text
Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
```

Otherwise, when the `hasLaunchedTask` flag is `true` the timer thread cancels itself.

### <span id="createTaskSetManager"> Creating TaskSetManager

```scala
createTaskSetManager(
  taskSet: TaskSet,
  maxTaskFailures: Int): TaskSetManager
```

`createTaskSetManager` creates a [TaskSetManager](TaskSetManager.md).

`createTaskSetManager` is used when:

* `TaskSchedulerImpl` is requested to [submits tasks](#submitTasks)

## <span id="handleFailedTask"> Notifying TaskSetManager that Task Failed

```scala
handleFailedTask(
  taskSetManager: TaskSetManager,
  tid: Long,
  taskState: TaskState,
  reason: TaskFailedReason): Unit
```

`handleFailedTask` scheduler:TaskSetManager.md#handleFailedTask[notifies `taskSetManager` that `tid` task has failed] and, only when scheduler:TaskSetManager.md#zombie-state[`taskSetManager` is not in zombie state] and `tid` is not in `KILLED` state, scheduler:SchedulerBackend.md#reviveOffers[requests SchedulerBackend to revive offers].

NOTE: `handleFailedTask` is called when scheduler:TaskResultGetter.md#enqueueSuccessfulTask[`TaskResultGetter` deserializes a `TaskFailedReason`] for a failed task.

## <span id="taskSetFinished"> taskSetFinished

```scala
taskSetFinished(
  manager: TaskSetManager): Unit
```

`taskSetFinished` looks all scheduler:TaskSet.md[TaskSet]s up by the stage id (in <<taskSetsByStageIdAndAttempt, taskSetsByStageIdAndAttempt>> registry) and removes the stage attempt from them, possibly with removing the entire stage record from `taskSetsByStageIdAndAttempt` registry completely (if there are no other attempts registered).

![TaskSchedulerImpl.taskSetFinished is called when all tasks are finished](../images/scheduler/taskschedulerimpl-tasksetmanager-tasksetfinished.png)

`taskSetFinished` then [removes `manager` from the parent's schedulable pool](Pool.md#removeSchedulable).

You should see the following INFO message in the logs:

```text
Removed TaskSet [id], whose tasks have all completed, from pool [name]
```

`taskSetFinished` is used when:

* `TaskSetManager` is requested to [maybeFinishTaskSet](TaskSetManager.md#maybeFinishTaskSet)

## <span id="executorAdded"> Notifying DAGScheduler About New Executor

```scala
executorAdded(
  execId: String,
  host: String)
```

`executorAdded` just DAGScheduler.md#executorAdded[notifies `DAGScheduler` that an executor was added].

NOTE: `executorAdded` uses <<dagScheduler, DAGScheduler>> that was given when <<setDAGScheduler, setDAGScheduler>>.

## <span id="resourceOffers"> Creating TaskDescriptions For Available Executor Resource Offers

```scala
resourceOffers(
  offers: Seq[WorkerOffer]): Seq[Seq[TaskDescription]]
```

`resourceOffers` takes the resources `offers` (as <<WorkerOffer, WorkerOffers>>) and generates a collection of tasks (as [TaskDescription](TaskDescription.md)) to launch (given the resources available).

NOTE: <<WorkerOffer, WorkerOffer>> represents a resource offer with CPU cores free to use on an executor.

![Processing Executor Resource Offers](../images/scheduler/taskscheduler-resourceOffers.png)

Internally, `resourceOffers` first updates <<hostToExecutors, hostToExecutors>> and <<executorIdToHost, executorIdToHost>> lookup tables to record new hosts and executors (given the input `offers`).

For new executors (not in <<executorIdToRunningTaskIds, executorIdToRunningTaskIds>>) `resourceOffers` <<executorAdded, notifies `DAGScheduler` that an executor was added>>.

NOTE: TaskSchedulerImpl uses `resourceOffers` to track active executors.

CAUTION: FIXME a picture with `executorAdded` call from TaskSchedulerImpl to DAGScheduler.

`resourceOffers` requests `BlacklistTracker` to `applyBlacklistTimeout` and filters out offers on blacklisted nodes and executors.

NOTE: `resourceOffers` uses the optional <<blacklistTrackerOpt, BlacklistTracker>> that was given when <<creating-instance, TaskSchedulerImpl was created>>.

CAUTION: FIXME Expand on blacklisting

`resourceOffers` then randomly shuffles offers (to evenly distribute tasks across executors and avoid over-utilizing some executors) and initializes the local data structures `tasks` and `availableCpus` (as shown in the figure below).

![Internal Structures of resourceOffers with 5 WorkerOffers (with 4, 2, 0, 3, 2 free cores)](../images/scheduler/TaskSchedulerImpl-resourceOffers-internal-structures.png)

`resourceOffers` Pool.md#getSortedTaskSetQueue[takes `TaskSets` in scheduling order] from scheduler:TaskScheduler.md#rootPool[top-level Schedulable Pool].

![TaskSchedulerImpl Requesting TaskSets (as TaskSetManagers) from Root Pool](../images/scheduler/TaskSchedulerImpl-resourceOffers-rootPool-getSortedTaskSetQueue.png)

!!! note
    `rootPool` is configured when <<initialize, TaskSchedulerImpl is initialized>>.

    `rootPool` is part of the scheduler:TaskScheduler.md#rootPool[TaskScheduler Contract] and exclusively managed by scheduler:SchedulableBuilder.md[SchedulableBuilders], i.e. scheduler:FIFOSchedulableBuilder.md[FIFOSchedulableBuilder] and scheduler:FairSchedulableBuilder.md[FairSchedulableBuilder] (that  scheduler:SchedulableBuilder.md#addTaskSetManager[manage registering TaskSetManagers with the root pool]).

    scheduler:TaskSetManager.md[TaskSetManager] manages execution of the tasks in a single scheduler:TaskSet.md[TaskSet] that represents a single scheduler:Stage.md[Stage].

For every `TaskSetManager` (in scheduling order), you should see the following DEBUG message in the logs:

```text
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

### <span id="maybeInitBarrierCoordinator"> maybeInitBarrierCoordinator

```scala
maybeInitBarrierCoordinator(): Unit
```

`maybeInitBarrierCoordinator`...FIXME

## <span id="resourceOfferSingleTaskSet"> Finding Tasks from TaskSetManager to Schedule on Executors

```scala
resourceOfferSingleTaskSet(
  taskSet: TaskSetManager,
  maxLocality: TaskLocality,
  shuffledOffers: Seq[WorkerOffer],
  availableCpus: Array[Int],
  tasks: Seq[ArrayBuffer[TaskDescription]]): Boolean
```

`resourceOfferSingleTaskSet` takes every `WorkerOffer` (from the input `shuffledOffers`) and (only if the number of available CPU cores (using the input `availableCpus`) is at least configuration-properties.md#spark.task.cpus[spark.task.cpus]) scheduler:TaskSetManager.md#resourceOffer[requests `TaskSetManager` (as the input `taskSet`) to find a `Task` to execute (given the resource offer)] (as an executor, a host, and the input `maxLocality`).

`resourceOfferSingleTaskSet` adds the task to the input `tasks` collection.

`resourceOfferSingleTaskSet` records the task id and `TaskSetManager` in the following registries:

* <<taskIdToTaskSetManager, taskIdToTaskSetManager>>
* <<taskIdToExecutorId, taskIdToExecutorId>>
* <<executorIdToRunningTaskIds, executorIdToRunningTaskIds>>

`resourceOfferSingleTaskSet` decreases configuration-properties.md#spark.task.cpus[spark.task.cpus] from the input `availableCpus` (for the `WorkerOffer`).

NOTE: `resourceOfferSingleTaskSet` makes sure that the number of available CPU cores (in the input `availableCpus` per `WorkerOffer`) is at least `0`.

If there is a `TaskNotSerializableException`, you should see the following ERROR in the logs:

```text
Resource offer failed, task set [name] was not serializable
```

`resourceOfferSingleTaskSet` returns whether a task was launched or not.

`resourceOfferSingleTaskSet` is used when:

* `TaskSchedulerImpl` is requested to [resourceOffers](#resourceOffers)

## <span id="TaskLocality"> Task Locality Preference

`TaskLocality` represents a task locality preference and can be one of the following (from most localized to the widest):

. `PROCESS_LOCAL`
. `NODE_LOCAL`
. `NO_PREF`
. `RACK_LOCAL`
. `ANY`

## <span id="WorkerOffer"> WorkerOffer &mdash; Free CPU Cores on Executor

```scala
WorkerOffer(
  executorId: String,
  host: String,
  cores: Int)
```

`WorkerOffer` represents a resource offer with free CPU `cores` available on an `executorId` executor on a `host`.

## <span id="workerRemoved"> workerRemoved

```scala
workerRemoved(
  workerId: String,
  host: String,
  message: String): Unit
```

`workerRemoved` is part of the [TaskScheduler](TaskScheduler.md#workerRemoved) abstraction.

`workerRemoved` prints out the following INFO message to the logs:

```text
Handle removed worker [workerId]: [message]
```

In the end, `workerRemoved` requests the [DAGScheduler](#dagScheduler) to [workerRemoved](DAGScheduler.md#workerRemoved).

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.TaskSchedulerImpl` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.TaskSchedulerImpl=ALL
```

Refer to [Logging](../spark-logging.md).

## Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| dagScheduler
a| [[dagScheduler]] DAGScheduler.md[DAGScheduler]

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
a| [[rootPool]] Pool.md[Schedulable pool]

Used when TaskSchedulerImpl...

| schedulableBuilder
a| [[schedulableBuilder]] <<SchedulableBuilder.md#, SchedulableBuilder>>

Created when TaskSchedulerImpl is requested to <<initialize, initialize>> and can be one of two available builders:

* FIFOSchedulableBuilder.md[FIFOSchedulableBuilder] when scheduling policy is FIFO (which is the default scheduling policy).

* FairSchedulableBuilder.md[FairSchedulableBuilder] for FAIR scheduling policy.

NOTE: Use configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property to select the scheduling policy.

| schedulingMode
a| [[schedulingMode]] SchedulingMode.md[SchedulingMode]

Used when TaskSchedulerImpl...

| taskSetsByStageIdAndAttempt
a| [[taskSetsByStageIdAndAttempt]] Lookup table of scheduler:TaskSet.md[TaskSet] by stage and attempt ids.

| taskIdToExecutorId
a| [[taskIdToExecutorId]] Lookup table of executor:Executor.md[] by task id.

| taskIdToTaskSetManager
a| [[taskIdToTaskSetManager]] Registry of active scheduler:TaskSetManager.md[TaskSetManagers] per task id.

|===
