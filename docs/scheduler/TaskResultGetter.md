# TaskResultGetter

`TaskResultGetter` is a helper class of scheduler:TaskSchedulerImpl.md#statusUpdate[TaskSchedulerImpl] for _asynchronous_ deserialization of <<enqueueSuccessfulTask, task results of tasks that have finished successfully>> (possibly fetching remote blocks) or <<enqueueFailedTask, the failures for failed tasks>>.

CAUTION: FIXME Image with the dependencies

TIP: Consult scheduler:Task.md#states[Task States] in Tasks to learn about the different task states.

NOTE: The only instance of `TaskResultGetter` is created while scheduler:TaskSchedulerImpl.md#creating-instance[`TaskSchedulerImpl` is created].

`TaskResultGetter` requires a core:SparkEnv.md[SparkEnv] and scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl] to be created and is stopped when scheduler:TaskSchedulerImpl.md#stop[`TaskSchedulerImpl` stops].

`TaskResultGetter` uses <<task-result-getter, `task-result-getter` asynchronous task executor>> for operation.

[TIP]
====
Enable `DEBUG` logging level for `org.apache.spark.scheduler.TaskResultGetter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.scheduler.TaskResultGetter=DEBUG
```

Refer to spark-logging.md[Logging].
====

=== [[getTaskResultExecutor]][[task-result-getter]] `task-result-getter` Asynchronous Task Executor

[source, scala]
----
getTaskResultExecutor: ExecutorService
----

`getTaskResultExecutor` creates a daemon thread pool with <<spark_resultGetter_threads, spark.resultGetter.threads>> threads and `task-result-getter` prefix.

TIP: Read up on https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ThreadPoolExecutor.html[java.util.concurrent.ThreadPoolExecutor] that `getTaskResultExecutor` uses under the covers.

=== [[stop]] `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` stops the internal <<task-result-getter, `task-result-getter` asynchronous task executor>>.

=== [[serializer]] `serializer` Attribute

[source, scala]
----
serializer: ThreadLocal[SerializerInstance]
----

`serializer` is a thread-local serializer:SerializerInstance.md[SerializerInstance] that `TaskResultGetter` uses to deserialize byte buffers (with ``TaskResult``s or a `TaskEndReason`).

When created for a new thread, `serializer` is initialized with a new instance of `Serializer` (using core:SparkEnv.md#closureSerializer[SparkEnv.closureSerializer]).

NOTE: `TaskResultGetter` uses https://docs.oracle.com/javase/8/docs/api/java/lang/ThreadLocal.html[java.lang.ThreadLocal] for the thread-local `SerializerInstance` variable.

=== [[taskResultSerializer]] `taskResultSerializer` Attribute

[source, scala]
----
taskResultSerializer: ThreadLocal[SerializerInstance]
----

`taskResultSerializer` is a thread-local serializer:SerializerInstance.md[SerializerInstance] that `TaskResultGetter` uses to...

When created for a new thread, `taskResultSerializer` is initialized with a new instance of `Serializer` (using core:SparkEnv.md#serializer[SparkEnv.serializer]).

NOTE: `TaskResultGetter` uses https://docs.oracle.com/javase/8/docs/api/java/lang/ThreadLocal.html[java.lang.ThreadLocal] for the thread-local `SerializerInstance` variable.

## <span id="enqueueSuccessfulTask"> Enqueuing Successful Task

```scala
enqueueSuccessfulTask(
  taskSetManager: TaskSetManager,
  tid: Long,
  serializedData: ByteBuffer): Unit
```

`enqueueSuccessfulTask` submits an asynchronous task (to <<getTaskResultExecutor, task-result-getter>> asynchronous task executor) that first deserializes `serializedData` to a `DirectTaskResult`, then updates the internal accumulator (with the size of the `DirectTaskResult`) and ultimately notifies the `TaskSchedulerImpl` that the `tid` task was completed and scheduler:TaskSchedulerImpl.md#handleSuccessfulTask[the task result was received successfully] or scheduler:TaskSchedulerImpl.md#handleFailedTask[not].

NOTE: `enqueueSuccessfulTask` is just the asynchronous task enqueued for execution by <<getTaskResultExecutor, task-result-getter>> asynchronous task executor at some point in the future.

Internally, the enqueued task first deserializes `serializedData` to a `TaskResult` (using the internal thread-local <<serializer, serializer>>).

For a [DirectTaskResult](TaskResult.md#DirectTaskResult), the task scheduler:TaskSetManager.md#canFetchMoreResults[checks the available memory for the task result] and, when the size overflows configuration-properties.md#spark.driver.maxResultSize[spark.driver.maxResultSize], it simply returns.

!!! note
    `enqueueSuccessfulTask` is a mere thread so returning from a thread is to do nothing else. That is why the [check for quota does abort](TaskSetManager.md#canFetchMoreResults) when there is not enough memory.

Otherwise, when there _is_ enough memory to hold the task result, it deserializes the `DirectTaskResult` (using the internal thread-local <<taskResultSerializer, taskResultSerializer>>).

For an [IndirectTaskResult](TaskResult.md#IndirectTaskResult), the task checks the available memory for the task result and, when the size could overflow the maximum result size, it storage:BlockManagerMaster.md#removeBlock[removes the block] and simply returns.

Otherwise, when there _is_ enough memory to hold the task result, you should see the following DEBUG message in the logs:

```text
Fetching indirect task result for TID [tid]
```

The task scheduler:TaskSchedulerImpl.md#handleTaskGettingResult[notifies `TaskSchedulerImpl` that it is about to fetch a remote block for a task result]. It then storage:BlockManager.md#getRemoteBytes[gets the block from remote block managers (as serialized bytes)].

When the block could not be fetched, scheduler:TaskSchedulerImpl.md#handleFailedTask[`TaskSchedulerImpl` is informed] (with `TaskResultLost` task failure reason) and the task simply returns.

NOTE: `enqueueSuccessfulTask` is a mere thread so returning from a thread is to do nothing else and so the real handling is when scheduler:TaskSchedulerImpl.md#handleFailedTask[`TaskSchedulerImpl` is informed].

The task result (as a serialized byte buffer) is then deserialized to a [DirectTaskResult](TaskResult.md#DirectTaskResult) (using the internal thread-local <<serializer, serializer>>) and deserialized again using the internal thread-local <<taskResultSerializer, taskResultSerializer>> (just like for the `DirectTaskResult` case). The  storage:BlockManagerMaster.md#removeBlock[block is removed from `BlockManagerMaster`] and simply returns.

!!! note
    A [IndirectTaskResult](TaskResult.md#IndirectTaskResult) is deserialized twice to become the final deserialized task result (using <<serializer, serializer>> for a `DirectTaskResult`). Compare it to a `DirectTaskResult` task result that is deserialized once only.

With no exceptions thrown, `enqueueSuccessfulTask` scheduler:TaskSchedulerImpl.md#handleSuccessfulTask[informs the `TaskSchedulerImpl` that the `tid` task was completed and the task result was received].

A `ClassNotFoundException` leads to scheduler:TaskSetManager.md#abort[aborting the `TaskSet`] (with `ClassNotFound with classloader: [loader]` error message) while any non-fatal exception shows the following ERROR message in the logs followed by scheduler:TaskSetManager.md#abort[aborting the `TaskSet`].

```text
Exception while getting task result
```

`enqueueSuccessfulTask` is used when `TaskSchedulerImpl` is requested to [handle task status update](TaskSchedulerImpl.md#statusUpdate) (and the task has finished successfully).

=== [[enqueueFailedTask]] Deserializing TaskFailedReason and Notifying TaskSchedulerImpl -- `enqueueFailedTask` Method

[source, scala]
----
enqueueFailedTask(
  taskSetManager: TaskSetManager,
  tid: Long,
  taskState: TaskState.TaskState,
  serializedData: ByteBuffer): Unit
----

`enqueueFailedTask` submits an asynchronous task (to <<getTaskResultExecutor, `task-result-getter` asynchronous task executor>>) that first attempts to deserialize a `TaskFailedReason` from `serializedData` (using the internal thread-local <<serializer, serializer>>) and then scheduler:TaskSchedulerImpl.md#handleFailedTask[notifies `TaskSchedulerImpl` that the task has failed].

Any `ClassNotFoundException` leads to the following ERROR message in the logs (without breaking the flow of `enqueueFailedTask`):

```
ERROR Could not deserialize TaskEndReason: ClassNotFound with classloader [loader]
```

NOTE: `enqueueFailedTask` is called when scheduler:TaskSchedulerImpl.md#statusUpdate[`TaskSchedulerImpl` is notified about a task that has failed (and is in `FAILED`, `KILLED` or `LOST` state)].

=== [[settings]] Settings

.Spark Properties
[cols="1,1,2",options="header",width="100%"]
|===
| Spark Property | Default Value | Description
| [[spark_resultGetter_threads]] `spark.resultGetter.threads` | `4` | The number of threads for `TaskResultGetter`.
|===
