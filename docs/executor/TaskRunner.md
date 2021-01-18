# TaskRunner

`TaskRunner` is a **thread of execution** to [run a task](#run).

![Executor creates and runs TaskRunner](../images/executor/TaskRunner.png)

!!! note "Internal Class"
    `TaskRunner` is an internal class of [Executor](Executor.md) with full access to internal registries.

`TaskRunner` is a [java.lang.Runnable]({{ java.api }}/java.base/java/lang/Runnable.html) so once a [TaskRunner has completed execution](#run) it must not be restarted.

## Creating Instance

`TaskRunner` takes the following to be created:

* <span id="execBackend"> [ExecutorBackend](ExecutorBackend.md) (that manages the parent [Executor](Executor.md))
* <span id="taskDescription"><span id="taskId"> [TaskDescription](../scheduler/TaskDescription.md)

`TaskRunner` is created when:

* `Executor` is requested to [launch a task](Executor.md#launchTask)

## Demo

```text
./bin/spark-shell --conf spark.driver.maxResultSize=1m
```

```text
scala> println(sc.version)
3.0.1
```

```text
val maxResultSize = sc.getConf.get("spark.driver.maxResultSize")
assert(maxResultSize == "1m")
```

```text
val rddOver1m = sc.range(0, 1024 * 1024 + 10, 1)
```

```text
scala> rddOver1m.collect
ERROR TaskSetManager: Total size of serialized results of 2 tasks (1030.8 KiB) is bigger than spark.driver.maxResultSize (1024.0 KiB)
ERROR TaskSetManager: Total size of serialized results of 3 tasks (1546.2 KiB) is bigger than spark.driver.maxResultSize (1024.0 KiB)
ERROR TaskSetManager: Total size of serialized results of 4 tasks (2.0 MiB) is bigger than spark.driver.maxResultSize (1024.0 KiB)
WARN TaskSetManager: Lost task 7.0 in stage 0.0 (TID 7, 192.168.68.105, executor driver): TaskKilled (Tasks result size has exceeded maxResultSize)
WARN TaskSetManager: Lost task 5.0 in stage 0.0 (TID 5, 192.168.68.105, executor driver): TaskKilled (Tasks result size has exceeded maxResultSize)
WARN TaskSetManager: Lost task 12.0 in stage 0.0 (TID 12, 192.168.68.105, executor driver): TaskKilled (Tasks result size has exceeded maxResultSize)
ERROR TaskSetManager: Total size of serialized results of 5 tasks (2.5 MiB) is bigger than spark.driver.maxResultSize (1024.0 KiB)
WARN TaskSetManager: Lost task 8.0 in stage 0.0 (TID 8, 192.168.68.105, executor driver): TaskKilled (Tasks result size has exceeded maxResultSize)
...
org.apache.spark.SparkException: Job aborted due to stage failure: Total size of serialized results of 2 tasks (1030.8 KiB) is bigger than spark.driver.maxResultSize (1024.0 KiB)
  at org.apache.spark.scheduler.DAGScheduler.failJobAndIndependentStages(DAGScheduler.scala:2059)
  ...
```

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

### <span id="run-initialization"> Initialization

`run` initializes the [threadId](#threadId) internal registry as the current thread identifier (using [Thread.getId]({{ java.api }}/java.base/java/lang/Thread.html#getId())).

`run` sets the name of the current thread of execution as the [threadName](#threadName).

`run` creates a [TaskMemoryManager](../memory/TaskMemoryManager.md) (for the current [MemoryManager](../memory/MemoryManager.md) and [taskId](#taskId)). `run` uses `SparkEnv` to [access the current MemoryManager](../SparkEnv.md#memoryManager).

`run` starts tracking the time to deserialize a task and sets the current thread's context classloader.

`run` creates a [closure Serializer](../serializer/Serializer.md#newInstance). `run` uses `SparkEnv` to [access the closure Serializer](../SparkEnv.md#closureSerializer).

`run` prints out the following INFO message to the logs (with the [taskName](#taskName) and [taskId](#taskId)):

```text
Running [taskName] (TID [taskId])
```

`run` notifies the [ExecutorBackend](#execBackend) that the [status of the task has changed](ExecutorBackend.md#statusUpdate) to `RUNNING` (for the [taskId](#taskId)).

`run` [computes the total amount of time this JVM process has spent in garbage collection](#computeTotalGcTime).

`run` uses the [addedFiles](../scheduler/TaskDescription.md#addedFiles) and [addedJars](../scheduler/TaskDescription.md#addedJars) (of the given [TaskDescription](#taskDescription)) to [update dependencies](Executor.md#updateDependencies).

`run` takes the [serializedTask](../scheduler/TaskDescription.md#serializedTask) of the given [TaskDescription](#taskDescription) and requests the closure `Serializer` to [deserialize the task](../serializer/SerializerInstance.md#deserialize). `run` sets the [task](#task) internal reference to hold the deserialized task.

For non-local environments, `run` prints out the following DEBUG message to the logs before requesting the `MapOutputTrackerWorker` to [update the epoch](../scheduler/MapOutputTrackerWorker.md#updateEpoch) (using the [epoch](../scheduler/Task.md#epoch) of the [Task](#task) to be executed). `run` uses `SparkEnv` to [access the MapOutputTrackerWorker](../SparkEnv.md#mapOutputTracker).

```text
Task [taskId]'s epoch is [epoch]
```

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

### <span id="run-serializedResult"> Serialized Task Result

`run` creates a [DirectTaskResult](../scheduler/TaskResult.md#DirectTaskResult) (with the serialized task result, the accumulator updates and the metric peaks) and requests the [closure Serializer](../serializer/SerializerInstance.md) to [serialize it](../serializer/SerializerInstance.md#serialize).

!!! note
    The serialized `DirectTaskResult` is a [java.nio.ByteBuffer]({{ java.api }}/java.base/java/nio/ByteBuffer.html).

`run` selects between the `DirectTaskResult` and an [IndirectTaskResult](../scheduler/TaskResult.md#IndirectTaskResult) based on the size of the serialized task result (_limit_ of this `serializedDirectResult` byte buffer):

1. With the size above [spark.driver.maxResultSize](../configuration-properties.md#spark.driver.maxResultSize), `run` prints out the following WARN message to the logs and serializes an `IndirectTaskResult` with a [TaskResultBlockId](../storage/BlockId.md#TaskResultBlockId).

    ```text
    Finished [taskName] (TID [taskId]). Result is larger than maxResultSize ([resultSize] > [maxResultSize]), dropping it.
    ```

1. With the size above [maxDirectResultSize](Executor.md#maxDirectResultSize), `run` creates an `TaskResultBlockId` and requests the `BlockManager` to [store the task result locally](../storage/BlockManager.md#putBytes) (with `MEMORY_AND_DISK_SER`). `run` prints out the following INFO message to the logs and serializes an `IndirectTaskResult` with a `TaskResultBlockId`.

    ```text
    Finished [taskName] (TID [taskId]). [resultSize] bytes result sent via BlockManager)
    ```

1. `run` prints out the following INFO message to the logs and uses the `DirectTaskResult` created earlier.

    ```text
    Finished [taskName] (TID [taskId]). [resultSize] bytes result sent to driver
    ```

!!! note
    `serializedResult` is either a [IndirectTaskResult](../scheduler/TaskResult.md#IndirectTaskResult) (possibly with the block stored in `BlockManager`) or a [DirectTaskResult](../scheduler/TaskResult.md#DirectTaskResult).

### <span id="run-ExecutorSource-succeededTasks"> Incrementing succeededTasks Counter

`run` requests the [ExecutorSource](#executorSource) to increment `succeededTasks` counter.

### <span id="run-setTaskFinishedAndClearInterruptStatus"> Marking Task Finished

`run` [setTaskFinishedAndClearInterruptStatus](#setTaskFinishedAndClearInterruptStatus).

### <span id="run-statusUpdate-FINISHED"> Notifying ExecutorBackend that Task Finished

`run` notifies the [ExecutorBackend](#execBackend) that the status of the [taskId](#taskId) has [changed](ExecutorBackend.md#statusUpdate) to `FINISHED`.

!!! note
    `ExecutorBackend` is given when the [TaskRunner](#execBackend) is created.

### <span id="run-finally"> Wrapping Up

In the end, regardless of the task's execution status (successful or failed), `run` removes the [taskId](#taskId) from [runningTasks](Executor.md#runningTasks) registry.

In case a [onTaskStart](ExecutorMetricsPoller.md#onTaskStart) notification was sent out, `run` requests the [ExecutorMetricsPoller](#metricsPoller) to [onTaskCompletion](ExecutorMetricsPoller.md#onTaskCompletion).

### <span id="run-exceptions"> Exceptions

`run` handles certain exceptions.

Exception Type | TaskState | Serialized ByteBuffer
---------------|-----------|----------------------
[FetchFailedException](#run-FetchFailedException) | `FAILED` | `TaskFailedReason`
[TaskKilledException](#run-TaskKilledException) | `KILLED` | `TaskKilled`
[InterruptedException](#run-InterruptedException) | `KILLED` | `TaskKilled`
[CommitDeniedException](#run-CommitDeniedException) | `FAILED` | `TaskFailedReason`
[Throwable](#run-Throwable) | `FAILED` | `ExceptionFailure`

#### <span id="run-FetchFailedException"> FetchFailedException

When shuffle:FetchFailedException.md[FetchFailedException] is reported while running a task, run <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>>.

run shuffle:FetchFailedException.md#toTaskFailedReason[requests `FetchFailedException` for the `TaskFailedReason`], serializes it and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has failed] (with <<taskId, taskId>>, `TaskState.FAILED`, and a serialized reason).

NOTE: `ExecutorBackend` was specified when <<creating-instance, TaskRunner was created>>.

NOTE:  run uses a closure serializer:Serializer.md[Serializer] to serialize the failure reason. The `Serializer` was created before run ran the task.

#### <span id="run-TaskKilledException"> TaskKilledException

When `TaskKilledException` is reported while running a task, you should see the following INFO message in the logs:

```
Executor killed [taskName] (TID [taskId]), reason: [reason]
```

run then <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has been killed] (with <<taskId, taskId>>, `TaskState.KILLED`, and a serialized `TaskKilled` object).

#### <span id=run-InterruptedException"> InterruptedException (with Task Killed)

When `InterruptedException` is reported while running a task, and the task has been killed, you should see the following INFO message in the logs:

```
Executor interrupted and killed [taskName] (TID [taskId]), reason: [killReason]
```

run then <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has been killed] (with <<taskId, taskId>>, `TaskState.KILLED`, and a serialized `TaskKilled` object).

NOTE: The difference between this `InterruptedException` and <<run-TaskKilledException, TaskKilledException>> is the INFO message in the logs.

#### <span id="run-CommitDeniedException"> CommitDeniedException

When `CommitDeniedException` is reported while running a task, run <<setTaskFinishedAndClearInterruptStatus, setTaskFinishedAndClearInterruptStatus>> and ExecutorBackend.md#statusUpdate[notifies `ExecutorBackend` that the task has failed] (with <<taskId, taskId>>, `TaskState.FAILED`, and a serialized `TaskKilled` object).

NOTE: The difference between this `CommitDeniedException` and <<run-FetchFailedException, FetchFailedException>> is just the reason being sent to `ExecutorBackend`.

#### <span id="run-Throwable"> Throwable

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

#### <span id="collectAccumulatorsAndResetStatusOnFailure"> collectAccumulatorsAndResetStatusOnFailure

```scala
collectAccumulatorsAndResetStatusOnFailure(
  taskStartTimeNs: Long)
```

`collectAccumulatorsAndResetStatusOnFailure`...FIXME

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

### <span id="taskName"> Task Name

The [name of the task](../scheduler/TaskDescription.md#name) (of the [TaskDescription](#taskDescription)) that is used exclusively for <<logging, logging>> purposes when TaskRunner is requested to <<run, run>> and <<kill, kill>> the task

### <span id="threadId"><span id="getThreadId"> Thread Id

Current thread ID

Default: `-1`

Set immediately when TaskRunner is requested to <<run, run the task>> and used exclusively when `TaskReaper` is requested for the thread info of the current thread (aka _thread dump_)
