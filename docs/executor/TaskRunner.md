# TaskRunner

`TaskRunner` is a **thread of execution** (a [java.lang.Runnable]({{ java.api }}/java.base/java/lang/Runnable.html)) of a [task](#taskDescription).

![Executor creates and runs TaskRunner](../images/executor/TaskRunner.png)

!!! note
    `TaskRunner` is an internal class of the [Executor](Executor.md) class and has access to its internals (properties and methods).

## Creating Instance

`TaskRunner` takes the following to be created:

* <span id="execBackend"> [ExecutorBackend](ExecutorBackend.md) (that manages the parent [Executor](Executor.md))
* <span id="taskDescription"> [TaskDescription](../scheduler/TaskDescription.md)

`TaskRunner` is created when `Executor` is requested to [launch a task](Executor.md#launchTask).

## <span id="threadName"> Thread Name

`TaskRunner` uses the following thread name (with the [taskId](#taskId) of the [TaskDescription](#taskDescription)):

```text
Executor task launch worker for task [taskId]
```

## <span id="run"> Running Task

```scala
run(): Unit
```

`run` is part of the [java.lang.Runnable]({{ java.api }}/java.base/java/lang/Runnable.html#run()) abstraction.

`run` initializes the [threadId](#threadId) internal registry as the current thread identifier (using [Thread.getId]({{ java.api }}/java.base/java/lang/Thread.html#getId())).

`run` sets the name of the current thread of execution as the [threadName](#threadName).

`run` creates a [TaskMemoryManager](../memory/TaskMemoryManager.md) (for the current [MemoryManager](../memory/MemoryManager.md) and [taskId](#taskId)).

!!! note
    `run` uses `SparkEnv` to [access the current MemoryManager](../SparkEnv.md#memoryManager).

`run` starts tracking the time to deserialize a task and sets the current thread's context classloader.

`run` creates a [closure Serializer](../serializer/Serializer.md#newInstance).

!!! note
    `run` uses `SparkEnv` to [access the closure Serializer](../SparkEnv.md#closureSerializer).

`run` prints out the following INFO message to the logs (with the [taskName](#taskName) and [taskId](#taskId)):

```text
Running [taskName] (TID [taskId])
```

`run` notifies the [ExecutorBackend](#execBackend) that the [status of the task has changed](ExecutorBackend.md#statusUpdate) to `RUNNING` (for the [taskId](#taskId)).

`run` [computes the total amount of time this JVM process has spent in garbage collection](#computeTotalGcTime).

`run` uses the [addedFiles](../scheduler/TaskDescription.md#addedFiles) and [addedJars](../scheduler/TaskDescription.md#addedJars) of the given [TaskDescription](#taskDescription) to [update dependencies](#updateDependencies).

`run` takes the [serializedTask](../scheduler/TaskDescription.md#serializedTask) of the given [TaskDescription](#taskDescription) and requests the closure `Serializer` to [deserialize the task](../serializer/SerializerInstance.md#deserialize). `run` sets the [task](#task) internal reference to hold the deserialized task.

For non-local environments, `run` prints out the following DEBUG message to the logs before requesting the `MapOutputTrackerWorker` to [update the epoch](../scheduler/MapOutputTrackerWorker.md#updateEpoch) (using the [epoch](../scheduler/Task.md#epoch) of the [Task](#task) to be executed).

```text
Task [taskId]'s epoch is [epoch]
```

!!! note
    `run` uses `SparkEnv` to [access the MapOutputTrackerWorker](../SparkEnv.md#mapOutputTracker).

`run` requests the `metricsPoller`...FIXME

`run` records the current time as the task's start time (`taskStartTimeNs`).

`run` requests the [Task](#task) to [run](../scheduler/Task.md#run) (with `taskAttemptId` as [taskId](#taskId), `attemptNumber` from `TaskDescription`, and `metricsSystem` as the current [MetricsSystem](../metrics/MetricsSystem.md)).

!!! note
    `run` uses `SparkEnv` to [access the MetricsSystem](../SparkEnv.md#metricsSystem).

!!! note
    The task runs inside a "monitored" block (`try-finally` block) to detect any memory and lock leaks after the task's run finishes regardless of the final outcome - the computed value or an exception thrown.

`run` creates a [Serializer](../serializer/Serializer.md#newInstance) and requests it to [serialize](../serializer/SerializerInstance.md#serialize) the task result (`valueBytes`).

!!! note
    `run` uses `SparkEnv` to [access the Serializer](../SparkEnv.md#serializer).

`run` updates the [metrics](../scheduler/Task.md#metrics) of the [Task](#task) executed.

`run` updates the metric counters in the [ExecutorSource](#executorSource).

`run` requests the [Task](#task) executed for [accumulator updates](../scheduler/Task.md#collectAccumulatorUpdates) and the [ExecutorMetricsPoller](#metricsPoller) for [metric peaks](ExecutorMetricsPoller.md#getTaskMetricPeaks).

`run` creates a [DirectTaskResult](../scheduler/TaskResult.md#DirectTaskResult) (with the task result serialized, the accumulator updates and the metric peaks) and requests the [closure Serializer](../serializer/SerializerInstance.md) to [serialize it](../serializer/SerializerInstance.md#serialize).

!!! danger
    `run`...FIXME

IMPORTANT: This is when `TaskExecutor` serializes the computed value of a task to be sent back to the driver.

run records the scheduler:Task.md#metrics[task metrics]:

* TaskMetrics.md#setExecutorDeserializeTime[executorDeserializeTime]
* TaskMetrics.md#setExecutorDeserializeCpuTime[executorDeserializeCpuTime]
* TaskMetrics.md#setExecutorRunTime[executorRunTime]
* TaskMetrics.md#setExecutorCpuTime[executorCpuTime]
* TaskMetrics.md#setJvmGCTime[jvmGCTime]
* TaskMetrics.md#setResultSerializationTime[resultSerializationTime]

run scheduler:Task.md#collectAccumulatorUpdates[collects the latest values of internal and external accumulators used in the task].

run creates a spark-scheduler-TaskResult.md#DirectTaskResult[DirectTaskResult] (with the serialized result and the latest values of accumulators).

run serializer:Serializer.md#serialize[serializes the `DirectTaskResult`] and gets the byte buffer's limit.

NOTE: A serialized `DirectTaskResult` is Java's https://docs.oracle.com/javase/8/docs/api/java/nio/ByteBuffer.html[java.nio.ByteBuffer].

run selects the proper serialized version of the result before ExecutorBackend.md#statusUpdate[sending it to `ExecutorBackend`].

run branches off based on the serialized `DirectTaskResult` byte buffer's limit.

When Executor.md#maxResultSize[maxResultSize] is greater than `0` and the serialized `DirectTaskResult` buffer limit exceeds it, the following WARN message is displayed in the logs:

```
Finished [taskName] (TID [taskId]). Result is larger than maxResultSize ([resultSize] > [maxResultSize]), dropping it.
```

TIP: Read about configuration-properties.md#spark.driver.maxResultSize[spark.driver.maxResultSize].

```
$ ./bin/spark-shell -c spark.driver.maxResultSize=1m

scala> sc.version
res0: String = 2.0.0-SNAPSHOT

scala> sc.getConf.get("spark.driver.maxResultSize")
res1: String = 1m

scala> sc.range(0, 1024 * 1024 + 10, 1).collect
WARN  Finished task 4.0 in stage 0.0 (TID 4). Result is larger than maxResultSize (1031.4 KB > 1024.0 KB), dropping it.
...
ERROR TaskSetManager: Total size of serialized results of 1 tasks (1031.4 KB) is bigger than spark.driver.maxResultSize (1024.0 KB)
...
org.apache.spark.SparkException: Job aborted due to stage failure: Total size of serialized results of 1 tasks (1031.4 KB) is bigger than spark.driver.maxResultSize (1024.0 KB)
  at org.apache.spark.scheduler.DAGScheduler.org$apache$spark$scheduler$DAGScheduler$$failJobAndIndependentStages(DAGScheduler.scala:1448)
...
```

In this case, run creates a spark-scheduler-TaskResult.md#IndirectTaskResult[IndirectTaskResult] (with a `TaskResultBlockId` for the task's <<taskId, taskId>> and `resultSize`) and serializer:Serializer.md#serialize[serializes it].

<span id="run-result-sent-via-blockmanager">
When `maxResultSize` is not positive or `resultSize` is smaller than `maxResultSize` but greater than Executor.md#maxDirectResultSize[maxDirectResultSize], run creates a `TaskResultBlockId` for the task's <<taskId, taskId>> and BlockManager.md#putBytes[stores the serialized `DirectTaskResult` in `BlockManager`] (as the `TaskResultBlockId` with `MEMORY_AND_DISK_SER` storage level).

You should see the following INFO message in the logs:

```
Finished [taskName] (TID [taskId]). [resultSize] bytes result sent via BlockManager)
```

In this case, run creates a spark-scheduler-TaskResult.md#IndirectTaskResult[IndirectTaskResult] (with a `TaskResultBlockId` for the task's <<taskId, taskId>> and `resultSize`) and serializer:Serializer.md#serialize[serializes it].

NOTE: The difference between the two above cases is that the result is dropped or stored in `BlockManager` with `MEMORY_AND_DISK_SER` storage level.

When the two cases above do not hold, you should see the following INFO message in the logs:

```text
Finished [taskName] (TID [taskId]). [resultSize] bytes result sent to driver
```

run uses the serialized `DirectTaskResult` byte buffer as the final `serializedResult`.

NOTE: The final `serializedResult` is either a spark-scheduler-TaskResult.md#IndirectTaskResult[IndirectTaskResult] (possibly with the block stored in `BlockManager`) or a spark-scheduler-TaskResult.md#DirectTaskResult[DirectTaskResult].

run ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend`] that <<taskId, taskId>> is in `TaskState.FINISHED` state with the serialized result and removes <<taskId, taskId>> from the owning executor's Executor.md#runningTasks[ runningTasks] registry.

NOTE: run uses `ExecutorBackend` that is specified when TaskRunner <<creating-instance, is created>>.

NOTE: TaskRunner is Java's https://docs.oracle.com/javase/8/docs/api/java/lang/Runnable.html[Runnable] and the contract requires that once a TaskRunner has completed execution it must not be restarted.

When run catches a exception while executing the task, run acts according to its type (as presented in the following "run's Exception Cases" table and the following sections linked from the table).

.run's Exception Cases, TaskState and Serialized ByteBuffer
[cols="1,1,2",options="header",width="100%"]
|===
| Exception Type
| TaskState
| Serialized ByteBuffer

| <<run-FetchFailedException, FetchFailedException>>
| `FAILED`
| `TaskFailedReason`

| <<run-TaskKilledException, TaskKilledException>>
| `KILLED`
| `TaskKilled`

| <<run-InterruptedException, InterruptedException>>
| `KILLED`
| `TaskKilled`

| <<run-CommitDeniedException, CommitDeniedException>>
| `FAILED`
| `TaskFailedReason`

| <<run-Throwable, Throwable>>
| `FAILED`
| `ExceptionFailure`

|===

run is part of {java-javadoc-url}/java/lang/Runnable.html[java.lang.Runnable] contract.

### <span id="run-FetchFailedException"> FetchFailedException

When shuffle:FetchFailedException.md[FetchFailedException] is reported while running a task, run <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>>.

run shuffle:FetchFailedException.md#toTaskFailedReason[requests `FetchFailedException` for the `TaskFailedReason`], serializes it and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has failed] (with <<taskId, taskId>>, `TaskState.FAILED`, and a serialized reason).

NOTE: `ExecutorBackend` was specified when <<creating-instance, TaskRunner was created>>.

NOTE:  run uses a closure serializer:Serializer.md[Serializer] to serialize the failure reason. The `Serializer` was created before run ran the task.

### <span id="run-TaskKilledException"> TaskKilledException

When `TaskKilledException` is reported while running a task, you should see the following INFO message in the logs:

```
Executor killed [taskName] (TID [taskId]), reason: [reason]
```

run then <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has been killed] (with <<taskId, taskId>>, `TaskState.KILLED`, and a serialized `TaskKilled` object).

### <span id=run-InterruptedException"> InterruptedException (with Task Killed)

When `InterruptedException` is reported while running a task, and the task has been killed, you should see the following INFO message in the logs:

```
Executor interrupted and killed [taskName] (TID [taskId]), reason: [killReason]
```

run then <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has been killed] (with <<taskId, taskId>>, `TaskState.KILLED`, and a serialized `TaskKilled` object).

NOTE: The difference between this `InterruptedException` and <<run-TaskKilledException, TaskKilledException>> is the INFO message in the logs.

### <span id="run-CommitDeniedException"> CommitDeniedException

When `CommitDeniedException` is reported while running a task, run <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has failed] (with <<taskId, taskId>>, `TaskState.FAILED`, and a serialized `TaskKilled` object).

NOTE: The difference between this `CommitDeniedException` and <<run-FetchFailedException, FetchFailedException>> is just the reason being sent to `ExecutorBackend`.

### <span id="run-Throwable"> Throwable

When run catches a `Throwable`, you should see the following ERROR message in the logs (followed by the exception).

```
Exception in [taskName] (TID [taskId])
```

run then records the following task metrics (only when <<task, Task>> is available):

* TaskMetrics.md#setExecutorRunTime[executorRunTime]
* TaskMetrics.md#setJvmGCTime[jvmGCTime]

run then scheduler:Task.md#collectAccumulatorUpdates[collects the latest values of internal and external accumulators] (with `taskFailed` flag enabled to inform that the collection is for a failed task).

Otherwise, when <<task, Task>> is not available, the accumulator collection is empty.

run converts the task accumulators to collection of `AccumulableInfo`, creates a `ExceptionFailure` (with the accumulators), and serializer:Serializer.md#serialize[serializes them].

NOTE: run uses a closure serializer:Serializer.md[Serializer] to serialize the `ExceptionFailure`.

CAUTION: FIXME Why does run create `new ExceptionFailure(t, accUpdates).withAccums(accums)`, i.e. accumulators occur twice in the object.

run <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has failed] (with <<taskId, taskId>>, `TaskState.FAILED`, and the serialized `ExceptionFailure`).

run may also trigger `SparkUncaughtExceptionHandler.uncaughtException(t)` if this is a fatal error.

NOTE: The difference between this most `Throwable` case and other `FAILED` cases (i.e. <<run-FetchFailedException, FetchFailedException>> and <<run-CommitDeniedException, CommitDeniedException>>) is just the serialized `ExceptionFailure` vs a reason being sent to `ExecutorBackend`, respectively.

## <span id="kill"> Killing Task

```scala
kill(
  interruptThread: Boolean,
  reason: String): Unit
```

`kill` marks the TaskRunner as <<killed, killed>> and scheduler:Task.md#kill[kills the task] (if available and not <<finished, finished>> already).

NOTE: `kill` passes the input `interruptThread` on to the task itself while killing it.

When executed, you should see the following INFO message in the logs:

```
Executor is trying to kill [taskName] (TID [taskId]), reason: [reason]
```

NOTE: <<killed, killed>> flag is checked periodically in <<run, run>> to stop executing the task. Once killed, the task will eventually stop.

## <span id="collectAccumulatorsAndResetStatusOnFailure"> collectAccumulatorsAndResetStatusOnFailure

```scala
collectAccumulatorsAndResetStatusOnFailure(
  taskStartTime: Long): (Seq[AccumulatorV2[_, _]], Seq[AccumulableInfo])
```

`collectAccumulatorsAndResetStatusOnFailure`...FIXME

`collectAccumulatorsAndResetStatusOnFailure` is used when `TaskRunner` is requested to [run](#run).

## Logging

Enable `ALL` logging level for `org.apache.spark.executor.Executor` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.executor.Executor=ALL
```

Refer to [Logging](../spark-logging.md).

## Internal Properties

### <span id="finished"><span id="isFinished"> finished Flag

finished flag says whether the <<taskDescription, task>> has finished (`true`) or not (`false`)

Default: `false`

Enabled (`true`) after TaskRunner has been requested to <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>>

Used when TaskRunner is requested to <<kill, kill the task>>

### <span id="reasonIfKilled"> reasonIfKilled

Reason to <<kill, kill the task>> (and avoid <<run, executing it>>)

Default: `(empty)` (`None`)

### <span id="startGCTime"> startGCTime Timestamp

Timestamp (which is really the Executor.md#computeTotalGcTime[total amount of time this Executor JVM process has already spent in garbage collection]) that is used to mark the GC "zero" time (when <<run, run the task>>) and then compute the *JVM GC time metric* when:

* TaskRunner is requested to <<collectAccumulatorsAndResetStatusOnFailure, collectAccumulatorsAndResetStatusOnFailure>> and <<run, run>>

* `Executor` is requested to Executor.md#reportHeartBeat[reportHeartBeat]

### <span id="task"> Task

Deserialized scheduler:Task.md[task] to execute

Used when:

* TaskRunner is requested to <<kill, kill the task>>, <<collectAccumulatorsAndResetStatusOnFailure, collectAccumulatorsAndResetStatusOnFailure>>, <<run, run the task>>, <<hasFetchFailure, hasFetchFailure>>

* `Executor` is requested to Executor.md#reportHeartBeat[reportHeartBeat]

### <span id="taskId"> Task Id

The <<spark-scheduler-TaskDescription.md#taskId, task ID>> (of the <<taskDescription, TaskDescription>>)

Used when:

* TaskRunner is requested to <<run, run>> (to create a memory:TaskMemoryManager.md[TaskMemoryManager] and serialize a `IndirectTaskResult` for a large task result) and <<kill, kill>> the task and for the <<threadName, threadName>>

* `Executor` is requested to Executor.md#reportHeartBeat[reportHeartBeat]

### <span id="taskName"> Task Name

The <<spark-scheduler-TaskDescription.md#name, name of the task>> (of the <<taskDescription, TaskDescription>>) that is used exclusively for <<logging, logging>> purposes when TaskRunner is requested to <<run, run>> and <<kill, kill>> the task

### <span id="threadId"><span id="getThreadId"> Thread Id

Current thread ID

Default: `-1`

Set immediately when TaskRunner is requested to <<run, run the task>> and used exclusively when `TaskReaper` is requested for the thread info of the current thread (aka _thread dump_)
