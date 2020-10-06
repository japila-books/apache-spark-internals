= ExecutorBackend

ExecutorBackend is a <<contract, pluggable interface>> that xref:executor:TaskRunner.adoc[TaskRunners] use to <<statusUpdate, send task status updates>> to a scheduler.

.ExecutorBackend receives notifications from TaskRunners
image::ExecutorBackend.png[align="center"]

NOTE: `TaskRunner` manages a single individual xref:scheduler:Task.adoc[task] and is managed by an xref:executor:Executor.adoc#launchTask[`Executor` to launch a task].

It is effectively a bridge between the driver and an executor, i.e. there are two endpoints running.

There are three concrete executor backends:

* xref:executor:CoarseGrainedExecutorBackend.adoc[]

* xref:spark-local:spark-LocalSchedulerBackend.adoc[] (for xref:spark-local:index.adoc[Spark local])

* xref:spark-on-mesos:spark-executor-backends-MesosExecutorBackend.adoc[]

== [[contract]] ExecutorBackend Contract

=== [[statusUpdate]] statusUpdate Method

[source, scala]
----
statusUpdate(
  taskId: Long,
  state: TaskState,
  data: ByteBuffer): Unit
----

Used when `TaskRunner` is requested to xref:executor:TaskRunner.adoc#run[run a task] (to send task status updates).
