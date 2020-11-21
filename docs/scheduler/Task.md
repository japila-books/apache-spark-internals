= Task

*Task* is the <<contract, abstraction>> of smallest individual <<implementations, units of execution>> that <<run, compute an RDD partition>>.

[[contract]]
.Task Contract
[cols="1m,3",options="header",width="100%"]
|===
| Method
| Description

| runTask
a| [[runTask]]

[source, scala]
----
runTask(context: TaskContext): T
----

Runs the task

Used exclusively when Task is requested to <<run, run>>

|===

Task is <<creating-instance, created>> when `DAGScheduler` is requested to scheduler:DAGScheduler.md#submitMissingTasks[submit missing tasks of a stage].

NOTE: Task is a Scala abstract class and cannot be <<creating-instance, created>> directly. It is created indirectly for the <<implementations, concrete Tasks>>.

.Tasks Are Runtime Representation of RDD Partitions
image::spark-rdd-partitions-job-stage-tasks.png[align="center"]

[[creating-instance]]
Task is described by the following:

* [[stageId]] Stage ID
* [[stageAttemptId]] Stage (execution) attempt ID
* [[partitionId]] Partition ID
* [[localProperties]] Local properties
* [[serializedTaskMetrics]] Serialized executor:TaskMetrics.md[] (`Array[Byte]`)
* [[jobId]] Optional ID of the scheduler:spark-scheduler-ActiveJob.md[ActiveJob] (default: `None`)
* [[appId]] Optional ID of the Spark application (default: `None`)
* [[appAttemptId]] Optional ID of the Spark application's (execution) attempt ID (default: `None`)
* [[isBarrier]] `isBarrier` flag that is to say whether the task belongs to a barrier stage (default: `false`)

Task can be <<runTask, run>> (possibly on <<preferredLocations, preferred executor>>).

Tasks are executor:Executor.md#launchTask[launched on executors] and <<run, ran when `TaskRunner` starts>>.

In other words, a task is a computation on the records in a RDD partition in a stage of a RDD in a Spark job.

NOTE: In Scala Task is actually `Task[T]` in which `T` is the type of the result of a task (i.e. the type of the value computed).

[[implementations]]
.Tasks
[cols="1,3",options="header",width="100%"]
|===
| Task
| Description

| scheduler:ResultTask.md[ResultTask]
| [[ResultTask]] Computes a scheduler:ResultStage.md[ResultStage] and gives the result back to the driver

| scheduler:ShuffleMapTask.md[ShuffleMapTask]
| [[ShuffleMapTask]] Computes a scheduler:ShuffleMapStage.md[ShuffleMapStage]

|===

In most cases, the last stage of a Spark job consists of one or more scheduler:ResultTask.md[ResultTasks], while earlier stages are scheduler:ShuffleMapTask.md[ShuffleMapTasks].

NOTE: It is possible to have one or more scheduler:ShuffleMapTask.md[ShuffleMapTasks] as part of the last stage.

A task can only belong to one stage and operate on a single partition. All tasks in a stage must be completed before the stages that follow can start.

Tasks are spawned one by one for each stage and partition.

== [[preferredLocations]] `preferredLocations` Method

[source, scala]
----
preferredLocations: Seq[TaskLocation] = Nil
----

scheduler:TaskLocation.md[TaskLocations] that represent preferred locations (executors) to execute the task on.

Empty by default and so no task location preferences are defined that says the task could be launched on any executor.

NOTE: Defined by the <<implementations, concrete tasks>>, i.e. scheduler:ShuffleMapTask.md#preferredLocations[ShuffleMapTask] and scheduler:ResultTask.md#preferredLocations[ResultTask].

NOTE: `preferredLocations` is used exclusively when `TaskSetManager` is requested to scheduler:TaskSetManager.md#addPendingTask[register a task as pending execution] and scheduler:TaskSetManager.md#dequeueSpeculativeTask[dequeueSpeculativeTask].

== [[run]] Running Task Thread -- `run` Final Method

[source, scala]
----
run(
  taskAttemptId: Long,
  attemptNumber: Int,
  metricsSystem: MetricsSystem): T
----

`run` storage:BlockManager.md#registerTask[registers the task (identified as `taskAttemptId`) with the local `BlockManager`].

NOTE: `run` uses core:SparkEnv.md#blockManager[`SparkEnv` to access the current `BlockManager`].

`run` [creates a `TaskContextImpl`](TaskContextImpl.md#creating-instance) that in turn becomes the task's [TaskContext](TaskContext.md#setTaskContext).

NOTE: `run` is a `final` method and so must not be overriden.

`run` checks <<_killed, _killed>> flag and, if enabled, <<kill, kills the task>> (with `interruptThread` flag disabled).

`run` creates a Hadoop `CallerContext` and sets it.

`run` <<runTask, runs the task>>.

NOTE: This is the moment when the custom `Task`'s <<runTask, runTask>> is executed.

In the end, `run` [notifies `TaskContextImpl` that the task has completed](TaskContextImpl.md#markTaskCompleted) (regardless of the final outcome -- a success or a failure).

In case of any exceptions, `run` [notifies `TaskContextImpl` that the task has failed](TaskContextImpl.md#markTaskFailed). `run` storage:MemoryStore.md#releaseUnrollMemoryForThisTask[requests `MemoryStore` to release unroll memory for this task] (for both `ON_HEAP` and `OFF_HEAP` memory modes).

NOTE: `run` uses core:SparkEnv.md#blockManager[`SparkEnv` to access the current `BlockManager`] that it uses to access storage:BlockManager.md#memoryStore[MemoryStore].

`run` memory:MemoryManager.md[requests `MemoryManager` to notify any tasks waiting for execution memory to be freed to wake up and try to acquire memory again].

`run` [unsets the task's `TaskContext`](TaskContext.md#unset).

NOTE: `run` uses core:SparkEnv.md#memoryManager[`SparkEnv` to access the current `MemoryManager`].

NOTE: `run` is used exclusively when `TaskRunner` is requested to executor:TaskRunner.md#run[run] (when `Executor` is requested to executor:Executor.md#launchTask[launch a task (on "Executor task launch worker" thread pool sometime in the future)]).

. The Task instance has just been deserialized from `taskBytes` that were sent over the wire to an executor. `localProperties` and memory:TaskMemoryManager.md[TaskMemoryManager] are already assigned.

== [[states]][[TaskState]] Task States

A task can be in one of the following states (as described by `TaskState` enumeration):

* `LAUNCHING`
* `RUNNING` when the task is being started.
* `FINISHED` when the task finished with the serialized result.
* `FAILED` when the task fails, e.g. when shuffle:FetchFailedException.md[FetchFailedException], `CommitDeniedException` or any `Throwable` occurs
* `KILLED` when an executor kills a task.
* `LOST`

States are the values of `org.apache.spark.TaskState`.

NOTE: Task status updates are sent from executors to the driver through executor:ExecutorBackend.md[].

Task is finished when it is in one of `FINISHED`, `FAILED`, `KILLED`, `LOST`.

`LOST` and `FAILED` states are considered failures.

TIP: Task states correspond to https://github.com/apache/mesos/blob/master/include/mesos/mesos.proto[org.apache.mesos.Protos.TaskState].

== [[collectAccumulatorUpdates]] Collect Latest Values of (Internal and External) Accumulators -- `collectAccumulatorUpdates` Method

[source, scala]
----
collectAccumulatorUpdates(taskFailed: Boolean = false): Seq[AccumulableInfo]
----

`collectAccumulatorUpdates` collects the latest values of internal and external accumulators from a task (and returns the values as a collection of spark-accumulators.md#AccumulableInfo[AccumulableInfo]).

Internally, `collectAccumulatorUpdates` [takes `TaskMetrics`](TaskContextImpl.md#taskMetrics).

NOTE: `collectAccumulatorUpdates` uses <<context, TaskContextImpl>> to access the task's `TaskMetrics`.

`collectAccumulatorUpdates` collects the latest values of:

* executor:TaskMetrics.md#internalAccums[internal accumulators] whose current value is not the zero value and the `RESULT_SIZE` accumulator (regardless whether the value is its zero or not).

* executor:TaskMetrics.md#externalAccums[external accumulators] when `taskFailed` is disabled (`false`) or which spark-accumulators.md#countFailedValues[should be included on failures].

`collectAccumulatorUpdates` returns an empty collection when <<context, TaskContextImpl>> is not initialized.

NOTE: `collectAccumulatorUpdates` is used when executor:TaskRunner.md#run[`TaskRunner` runs a task] (and sends a task's final results back to the driver).

== [[kill]] Killing Task -- `kill` Method

[source, scala]
----
kill(interruptThread: Boolean)
----

`kill` marks the task to be killed, i.e. it sets the internal `_killed` flag to `true`.

`kill` calls [TaskContextImpl.markInterrupted](TaskContextImpl.md#markInterrupted) when `context` is set.

If `interruptThread` is enabled and the internal `taskThread` is available, `kill` interrupts it.

CAUTION: FIXME When could `context` and `interruptThread` not be set?

## Internal Properties

.Task's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1m,3",options="header",width="100%"]
|===
| Name
| Description

| _executorDeserializeCpuTime
| [[_executorDeserializeCpuTime]]

| _executorDeserializeTime
| [[_executorDeserializeTime]]

| _reasonIfKilled
| [[_reasonIfKilled]]

| _killed
| [[_killed]]

| context
| [[context]] [TaskContext](TaskContext.md)

Set to be a [BarrierTaskContext](BarrierTaskContext.md) or [TaskContextImpl](TaskContextImpl.md) when the <<isBarrier, isBarrier>> flag is enabled or not, respectively, when Task is requested to <<run, run>>

| epoch
| [[epoch]] Task epoch

Starts as `-1`

Set when `TaskSetManager` is scheduler:TaskSetManager.md[created] (to be the scheduler:MapOutputTrackerMaster.md#getEpoch[epoch] of the `MapOutputTrackerMaster`)

| metrics
| [[metrics]] executor:TaskMetrics.md[]

Created lazily when <<creating-instance, Task is created>> from <<serializedTaskMetrics, serializedTaskMetrics>>.

| taskMemoryManager
| [[taskMemoryManager]] memory:TaskMemoryManager.md[TaskMemoryManager] that manages the memory allocated by the task.

| taskThread
| [[taskThread]]

|===
