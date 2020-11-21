# TaskContextImpl

`TaskContextImpl` is a concrete [TaskContext](TaskContext.md) that is <<creating-instance, created>> exclusively when `Task` is requested to scheduler:Task.md#run[run] (when `Executor` is requested to executor:Executor.md#launchTask[launch a task (on "Executor task launch worker" thread pool) sometime in the future]).

[[creating-instance]]
`TaskContextImpl` takes the following to be created:

* [[stageId]] Stage ID
* [[stageAttemptNumber]] Stage (execution) attempt ID
* [[partitionId]] Partition ID
* [[taskAttemptId]] Task (execution) attempt ID
* [[attemptNumber]] Attempt ID
* [[taskMemoryManager]] memory:TaskMemoryManager.md[TaskMemoryManager]
* [[localProperties]] Local properties
* [[metricsSystem]] metrics:spark-metrics-MetricsSystem.md[MetricsSystem]
* [[taskMetrics]] executor:TaskMetrics.md[]

[[internal-registries]]
.TaskContextImpl's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1m,3",options="header",width="100%"]
|===
| Name
| Description

| onCompleteCallbacks
a| [[onCompleteCallbacks]] (`ArrayBuffer[TaskCompletionListener]`)

Used when...FIXME

| onFailureCallbacks
a| [[onFailureCallbacks]] (`ArrayBuffer[TaskFailureListener]`)

Used when...FIXME

| reasonIfKilled
a| [[reasonIfKilled]] Reason if the task was killed

Used when...FIXME

| completed
a| [[completed]][[isCompleted]] Flag whether...FIXME

Default: `false`

Used when...FIXME

| failed
a| [[failed]] Flag whether...FIXME

Default: `false`

Used when...FIXME

| failure
a| [[failure]] `java.lang.Throwable` that caused a failure

Used when...FIXME

| _fetchFailedException
a| [[_fetchFailedException]] shuffle:FetchFailedException.md[FetchFailedException] if there was a fetch failure

Used when...FIXME

|===

=== [[addTaskCompletionListener]] `addTaskCompletionListener` Method

[source, scala]
----
addTaskCompletionListener(listener: TaskCompletionListener): TaskContext
----

`addTaskCompletionListener` is part of the [TaskContext](TaskContext.md#addTaskCompletionListener) abstraction.

`addTaskCompletionListener`...FIXME

=== [[addTaskFailureListener]] `addTaskFailureListener` Method

[source, scala]
----
addTaskFailureListener(listener: TaskFailureListener): TaskContext
----

`addTaskFailureListener` is part of the [TaskContext](TaskContext.md#addTaskFailureListener) abstraction.

`addTaskFailureListener`...FIXME

=== [[markTaskFailed]] `markTaskFailed` Method

[source, scala]
----
markTaskFailed(error: Throwable): Unit
----

`markTaskFailed` is part of the [TaskContext](TaskContext.md#markTaskFailed) abstraction.

`markTaskFailed`...FIXME

=== [[markTaskCompleted]] `markTaskCompleted` Method

[source, scala]
----
markTaskCompleted(error: Option[Throwable]): Unit
----

`markTaskCompleted` is part of the [TaskContext](TaskContext.md#markTaskCompleted) abstraction.

`markTaskCompleted`...FIXME

=== [[invokeListeners]] `invokeListeners` Internal Method

[source, scala]
----
invokeListeners[T](
  listeners: Seq[T],
  name: String,
  error: Option[Throwable])(
  callback: T => Unit): Unit
----

`invokeListeners`...FIXME

NOTE: `invokeListeners` is used when...FIXME

=== [[markInterrupted]] `markInterrupted` Method

[source, scala]
----
markInterrupted(reason: String): Unit
----

`markInterrupted` is part of the [TaskContext](TaskContext.md#markInterrupted) abstraction.

`markInterrupted`...FIXME

=== [[killTaskIfInterrupted]] `killTaskIfInterrupted` Method

[source, scala]
----
killTaskIfInterrupted(): Unit
----

`killTaskIfInterrupted` is part of the [TaskContext](TaskContext.md#killTaskIfInterrupted) abstraction.

`killTaskIfInterrupted`...FIXME
