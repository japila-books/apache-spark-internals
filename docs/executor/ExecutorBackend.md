= ExecutorBackend

ExecutorBackend is a <<contract, pluggable interface>> that executor:TaskRunner.md[TaskRunners] use to <<statusUpdate, send task status updates>> to a scheduler.

.ExecutorBackend receives notifications from TaskRunners
image::ExecutorBackend.png[align="center"]

NOTE: `TaskRunner` manages a single individual scheduler:Task.md[task] and is managed by an executor:Executor.md#launchTask[`Executor` to launch a task].

It is effectively a bridge between the driver and an executor, i.e. there are two endpoints running.

There are three concrete executor backends:

* executor:CoarseGrainedExecutorBackend.md[]

* spark-local:spark-LocalSchedulerBackend.md[] (for spark-local:index.md[Spark local])

* spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md[]

== [[contract]] ExecutorBackend Contract

=== [[statusUpdate]] statusUpdate Method

[source, scala]
----
statusUpdate(
  taskId: Long,
  state: TaskState,
  data: ByteBuffer): Unit
----

Used when `TaskRunner` is requested to executor:TaskRunner.md#run[run a task] (to send task status updates).
