# SchedulerBackend

`SchedulerBackend` is an abstraction of <<implementations, task scheduling systems>> that can <<reviveOffers, revive resource offers>> from cluster managers.

SchedulerBackend abstraction allows TaskSchedulerImpl to use variety of cluster managers (with their own resource offers and task scheduling modes).

!!! note
    Being a scheduler backend system assumes a [Apache Mesos](http://mesos.apache.org/)-like scheduling model in which "an application" gets **resource offers** as machines become available so it is possible to launch tasks on them. Once required resource allocation is obtained, the scheduler backend can start executors.

== [[implementations]] Direct Implementations and Extensions

[cols="30m,70",options="header",width="100%"]
|===
| SchedulerBackend
| Description

| scheduler:CoarseGrainedSchedulerBackend.md[CoarseGrainedSchedulerBackend]
| [[CoarseGrainedSchedulerBackend]] Base SchedulerBackend for coarse-grained scheduling systems

| spark-local:spark-LocalSchedulerBackend.md[LocalSchedulerBackend]
| [[LocalSchedulerBackend]] Spark local

| MesosFineGrainedSchedulerBackend
| [[MesosFineGrainedSchedulerBackend]] Fine-grained scheduling system for Apache Mesos

|===

== [[start]] Starting SchedulerBackend

[source, scala]
----
start(): Unit
----

Starts the SchedulerBackend

Used when TaskSchedulerImpl is requested to scheduler:TaskSchedulerImpl.md#start[start]

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

*Execution attempt ID* of the Spark application

Default: `None` (undefined)

Used exclusively when `TaskSchedulerImpl` is requested for the scheduler:TaskSchedulerImpl.md#applicationAttemptId[execution attempt ID of a Spark application]

| applicationId
a| [[applicationId]][[appId]]

[source, scala]
----
applicationId(): String
----

*Unique identifier* of the Spark Application

Default: `spark-application-[currentTimeMillis]`

Used exclusively when `TaskSchedulerImpl` is requested for the scheduler:TaskSchedulerImpl.md#applicationId[unique identifier of a Spark application]

| defaultParallelism
a| [[defaultParallelism]]

[source, scala]
----
defaultParallelism(): Int
----

*Default parallelism*, i.e. a hint for the number of tasks in stages while sizing jobs

Used exclusively when `TaskSchedulerImpl` is requested for the scheduler:TaskSchedulerImpl.md#defaultParallelism[default parallelism]

| getDriverLogUrls
a| [[getDriverLogUrls]]

[source, scala]
----
getDriverLogUrls: Option[Map[String, String]]
----

*Driver log URLs*

Default: `None` (undefined)

Used exclusively when `SparkContext` is requested to SparkContext.md#postApplicationStart[postApplicationStart]

| isReady
a| [[isReady]]

[source, scala]
----
isReady(): Boolean
----

Controls whether the scheduler:SchedulerBackend.md[SchedulerBackend] is ready (`true`) or not (`false`)

Default: `true`

Used exclusively when `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#waitBackendReady[wait until scheduling backend is ready]

| killTask
a| [[killTask]]

[source, scala]
----
killTask(
  taskId: Long,
  executorId: String,
  interruptThread: Boolean,
  reason: String): Unit
----

Kills a given task

Default: Throws an `UnsupportedOperationException`

Used when:

* `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#killTaskAttempt[killTaskAttempt] and scheduler:TaskSchedulerImpl.md#killAllTaskAttempts[killAllTaskAttempts]

* `TaskSetManager` is requested to scheduler:TaskSetManager.md#handleSuccessfulTask[handle a successful task attempt]

| maxNumConcurrentTasks
a| [[maxNumConcurrentTasks]]

[source, scala]
----
maxNumConcurrentTasks(): Int
----

*Maximum number of concurrent tasks* that can be launched now

Used exclusively when `SparkContext` is requested to SparkContext.md#maxNumConcurrentTasks[maxNumConcurrentTasks]

| reviveOffers
a| [[reviveOffers]]

[source, scala]
----
reviveOffers(): Unit
----

Handles resource allocation offers (from the scheduling system)

Used when `TaskSchedulerImpl` is requested to:

* scheduler:TaskSchedulerImpl.md#submitTasks[Submit tasks (from a TaskSet)]

* scheduler:TaskSchedulerImpl.md#statusUpdate[Handle a task status update]

* scheduler:TaskSchedulerImpl.md#handleFailedTask[Notify the TaskSetManager that a task has failed]

* scheduler:TaskSchedulerImpl.md#checkSpeculatableTasks[Check for speculatable tasks]

* scheduler:TaskSchedulerImpl.md#executorLost[Handle a lost executor event]

| stop
a| [[stop]]

[source, scala]
----
stop(): Unit
----

Stops the SchedulerBackend

Used when:

* `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#stop[stop]

* `MesosCoarseGrainedSchedulerBackend` is requested to <<spark-mesos/spark-mesos-MesosCoarseGrainedSchedulerBackend.md#stopSchedulerBackend, stopSchedulerBackend>>

|===
