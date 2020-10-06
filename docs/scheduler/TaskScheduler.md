= [[TaskScheduler]] TaskScheduler

*TaskScheduler* is an abstraction of <<implementations, Spark schedulers>> that can <<submitTasks, submit tasks for execution>> in a Spark application (per <<schedulingMode, scheduling policy>>).

.TaskScheduler and SparkContext
image::sparkstandalone-sparkcontext-taskscheduler-schedulerbackend.png[align="center"]

NOTE: TaskScheduler works closely with xref:scheduler:DAGScheduler.adoc[DAGScheduler] that <<submitTasks, submits sets of tasks for execution>> (for every stage in a Spark job).

TaskScheduler can track the executors available in a Spark application using <<executorHeartbeatReceived, executorHeartbeatReceived>> and <<executorLost, executorLost>> interceptors (that inform about active and lost executors, respectively).

== [[submitTasks]] Submitting Tasks for Execution

[source, scala]
----
submitTasks(
  taskSet: TaskSet): Unit
----

Submits the tasks (of the given xref:scheduler:TaskSet.adoc[TaskSet]) for execution.

Used when DAGScheduler is requested to xref:scheduler:DAGScheduler.adoc#submitMissingTasks[submit missing tasks (of a stage)].

== [[executorHeartbeatReceived]] Handling Executor Heartbeat

[source, scala]
----
executorHeartbeatReceived(
  execId: String,
  accumUpdates: Array[(Long, Seq[AccumulatorV2[_, _]])],
  blockManagerId: BlockManagerId): Boolean
----

Handles a heartbeat from an executor

Returns `true` when the `execId` executor is managed by the TaskScheduler. `false` indicates that the xref:executor:Executor.adoc#reportHeartBeat[block manager (on the executor) should re-register].

Used when HeartbeatReceiver RPC endpoint is requested to xref:ROOT:spark-HeartbeatReceiver.adoc#Heartbeat[handle a Heartbeat (with task metrics) from an executor]

== [[killTaskAttempt]] Killing Task

[source, scala]
----
killTaskAttempt(
  taskId: Long,
  interruptThread: Boolean,
  reason: String): Boolean
----

Kills a task (attempt)

Used when DAGScheduler is requested to xref:scheduler:DAGScheduler.adoc#killTaskAttempt[kill a task]

== [[workerRemoved]] workerRemoved Notification

[source, scala]
----
workerRemoved(
  workerId: String,
  host: String,
  message: String): Unit
----

Used when DriverEndpoint is requested to xref:scheduler:CoarseGrainedSchedulerBackend-DriverEndpoint.adoc#removeWorker[handle a RemoveWorker event]

== [[contract]] Contract

[cols="30m,70",options="header",width="100%"]
|===
| Method
| Description

| applicationAttemptId
a| [[applicationAttemptId]]

[source, scala]
----
applicationAttemptId(): Option[String]
----

*Unique identifier of an (execution) attempt* of the Spark application

Used when `SparkContext` is xref:ROOT:spark-SparkContext-creating-instance-internals.adoc#_applicationAttemptId[created]

| cancelTasks
a| [[cancelTasks]]

[source, scala]
----
cancelTasks(
  stageId: Int,
  interruptThread: Boolean): Unit
----

Cancels all the tasks of a given xref:scheduler:Stage.adoc[stage]

Used when DAGScheduler is requested to xref:scheduler:DAGScheduler.adoc#failJobAndIndependentStages[failJobAndIndependentStages]

| defaultParallelism
a| [[defaultParallelism]]

[source, scala]
----
defaultParallelism(): Int
----

*Default level of parallelism*

Used when `SparkContext` is requested for the xref:ROOT:SparkContext.adoc#defaultParallelism[default level of parallelism]

| executorLost
a| [[executorLost]]

[source, scala]
----
executorLost(
  executorId: String,
  reason: ExecutorLossReason): Unit
----

Handles an executor lost event

Used when:

* `HeartbeatReceiver` RPC endpoint is requested to xref:ROOT:spark-HeartbeatReceiver.adoc#expireDeadHosts[expireDeadHosts]

* DriverEndpoint RPC endpoint is requested to xref:scheduler:CoarseGrainedSchedulerBackend-DriverEndpoint.adoc#removeExecutor[removes] (_forgets_) and xref:scheduler:CoarseGrainedSchedulerBackend-DriverEndpoint.adoc#disableExecutor[disables] a malfunctioning executor (i.e. either lost or blacklisted for some reason)

* Spark on Mesos' `MesosFineGrainedSchedulerBackend` is requested to `recordSlaveLost`

| killAllTaskAttempts
a| [[killAllTaskAttempts]]

[source, scala]
----
killAllTaskAttempts(
  stageId: Int,
  interruptThread: Boolean,
  reason: String): Unit
----

Used when:

* DAGScheduler is requested to xref:scheduler:DAGScheduler.adoc#handleTaskCompletion[handleTaskCompletion]

* `TaskSchedulerImpl` is requested to xref:scheduler:TaskSchedulerImpl.adoc#cancelTasks[cancel all the tasks of a stage]

| rootPool
a| [[rootPool]]

[source, scala]
----
rootPool: Pool
----

Top-level (root) xref:scheduler:spark-scheduler-Pool.adoc[schedulable pool]

Used when:

* `TaskSchedulerImpl` is requested to xref:scheduler:TaskSchedulerImpl.adoc#initialize[initialize]

* `SparkContext` is requested to xref:ROOT:SparkContext.adoc#getAllPools[getAllPools] and xref:ROOT:SparkContext.adoc#getPoolForName[getPoolForName]

* `TaskSchedulerImpl` is requested to xref:scheduler:TaskSchedulerImpl.adoc#resourceOffers[resourceOffers], xref:scheduler:TaskSchedulerImpl.adoc#checkSpeculatableTasks[checkSpeculatableTasks], and xref:scheduler:TaskSchedulerImpl.adoc#removeExecutor[removeExecutor]

| schedulingMode
a| [[schedulingMode]]

[source, scala]
----
schedulingMode: SchedulingMode
----

xref:scheduler:spark-scheduler-SchedulingMode.adoc[Scheduling mode]

Used when:

* `TaskSchedulerImpl` is xref:scheduler:TaskSchedulerImpl.adoc#rootPool[created] and xref:scheduler:TaskSchedulerImpl.adoc#initialize[initialized]

* `SparkContext` is requested to xref:ROOT:SparkContext.adoc#getSchedulingMode[getSchedulingMode]

| setDAGScheduler
a| [[setDAGScheduler]]

[source, scala]
----
setDAGScheduler(dagScheduler: DAGScheduler): Unit
----

Associates a xref:scheduler:DAGScheduler.adoc[DAGScheduler]

Used when DAGScheduler is xref:scheduler:DAGScheduler.adoc#creating-instance[created]

| start
a| [[start]]

[source, scala]
----
start(): Unit
----

Starts the TaskScheduler

Used when `SparkContext` is xref:ROOT:spark-SparkContext-creating-instance-internals.adoc#taskScheduler-start[created]

| stop
a| [[stop]]

[source, scala]
----
stop(): Unit
----

Stops the TaskScheduler

Used when DAGScheduler is requested to xref:scheduler:DAGScheduler.adoc#stop[stop]

|===

== [[implementations]] TaskSchedulers

[cols="30m,70",options="header",width="100%"]
|===
| TaskScheduler
| Description

| xref:scheduler:TaskSchedulerImpl.adoc[TaskSchedulerImpl]
| [[TaskSchedulerImpl]] Default Spark scheduler

| xref:spark-on-yarn:spark-yarn-yarnscheduler.adoc[YarnScheduler]
| [[YarnScheduler]] TaskScheduler for xref:tools:spark-submit.adoc#deploy-mode[client] deploy mode in xref:spark-on-yarn:index.adoc[Spark on YARN]

| xref:spark-on-yarn:spark-yarn-yarnclusterscheduler.adoc[YarnClusterScheduler]
| [[YarnClusterScheduler]] TaskScheduler for xref:tools:spark-submit.adoc#deploy-mode[cluster] deploy mode in xref:spark-on-yarn:index.adoc[Spark on YARN]

|===

== [[lifecycle]] Lifecycle

A TaskScheduler is created while xref:ROOT:SparkContext.adoc#creating-instance[SparkContext is being created] (by calling xref:ROOT:SparkContext.adoc#createTaskScheduler[SparkContext.createTaskScheduler] for a given xref:ROOT:spark-deployment-environments.adoc[master URL] and xref:tools:spark-submit.adoc#deploy-mode[deploy mode]).

.TaskScheduler uses SchedulerBackend to support different clusters
image::taskscheduler-uses-schedulerbackend.png[align="center"]

At this point in SparkContext's lifecycle, the internal `_taskScheduler` points at the TaskScheduler (and it is "announced" by sending a blocking xref:ROOT:spark-HeartbeatReceiver.adoc#TaskSchedulerIsSet[`TaskSchedulerIsSet` message to HeartbeatReceiver RPC endpoint]).

The <<start, TaskScheduler is started>> right after the blocking `TaskSchedulerIsSet` message receives a response.

The <<applicationId, application ID>> and the <<applicationAttemptId, application's attempt ID>> are set at this point (and `SparkContext` uses the application id to set xref:ROOT:SparkConf.adoc#spark.app.id[spark.app.id] Spark property, and configure xref:webui:spark-webui-SparkUI.adoc[SparkUI], and xref:storage:BlockManager.adoc[BlockManager]).

CAUTION: FIXME The application id is described as "associated with the job." in TaskScheduler, but I think it is "associated with the application" and you can have many jobs per application.

Right before SparkContext is fully initialized, <<postStartHook, TaskScheduler.postStartHook>> is called.

The internal `_taskScheduler` is cleared (i.e. set to `null`) while xref:ROOT:SparkContext.adoc#stop[SparkContext is being stopped].

<<stop, TaskScheduler is stopped>> while xref:scheduler:DAGScheduler.adoc#stop[DAGScheduler is being stopped].

WARNING: FIXME If it is SparkContext to start a TaskScheduler, shouldn't SparkContext stop it too? Why is this the way it is now?

== [[postStartHook]] Post-Start Initialization

[source, scala]
----
postStartHook(): Unit
----

`postStartHook` does nothing by default, but allows <<implementations, custom implementations>> for some additional post-start initialization.

[NOTE]
====
`postStartHook` is used when:

* `SparkContext` is xref:ROOT:spark-SparkContext-creating-instance-internals.adoc#postStartHook[created] (right before considered fully initialized)

* Spark on YARN's `YarnClusterScheduler` is requested to xref:spark-on-yarn:spark-yarn-yarnclusterscheduler.adoc#postStartHook[postStartHook]
====

== [[applicationId]][[appId]] Unique Identifier of Spark Application

[source, scala]
----
applicationId(): String
----

`applicationId` is the *unique identifier* of the Spark application and defaults to *spark-application-[currentTimeMillis]*.

NOTE: `applicationId` is used when `SparkContext` is xref:ROOT:spark-SparkContext-creating-instance-internals.adoc#_applicationId[created].
