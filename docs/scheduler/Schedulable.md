== [[Schedulable]] Schedulable Contract -- Schedulable Entities

`Schedulable` is the <<contract, abstraction>> of <<implementations, schedulable entities>> that manages the <<schedulableQueue, schedulableQueue>> and can <<getSortedTaskSetQueue, getSortedTaskSetQueue>>.

[[contract]]
.Schedulable Contract
[cols="1m,3",options="header",width="100%"]
|===
| Method
| Description

| addSchedulable
a| [[addSchedulable]]

[source, scala]
----
addSchedulable(schedulable: Schedulable): Unit
----

Registers a <<spark-scheduler-Schedulable.md#, Schedulable>>

Used when:

* `FIFOSchedulableBuilder` is requested to <<spark-scheduler-FIFOSchedulableBuilder.md#addTaskSetManager, addTaskSetManager>>

* `FairSchedulableBuilder` is requested to <<spark-scheduler-FairSchedulableBuilder.md#buildDefaultPool, buildDefaultPool>>, <<spark-scheduler-FairSchedulableBuilder.md#buildFairSchedulerPool, buildFairSchedulerPool>>, and <<spark-scheduler-FairSchedulableBuilder.md#addTaskSetManager, addTaskSetManager>>

| checkSpeculatableTasks
a| [[checkSpeculatableTasks]]

[source, scala]
----
checkSpeculatableTasks(minTimeToSpeculation: Int): Boolean
----

Used when...FIXME

| executorLost
a| [[executorLost]]

[source, scala]
----
executorLost(
  executorId: String,
  host: String,
  reason: ExecutorLossReason): Unit
----

Handles an executor lost event

Used when:

* `Pool` is requested to <<spark-scheduler-Pool.md#executorLost, handle an executor lost event>>

* `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#removeExecutor[removeExecutor]

| getSchedulableByName
a| [[getSchedulableByName]]

[source, scala]
----
getSchedulableByName(name: String): Schedulable
----

Finds a <<spark-scheduler-Schedulable.md#, Schedulable>> by name

Used when...FIXME

| getSortedTaskSetQueue
a| [[getSortedTaskSetQueue]]

[source, scala]
----
getSortedTaskSetQueue: ArrayBuffer[TaskSetManager]
----

Builds a collection of scheduler:TaskSetManager.md[TaskSetManagers] sorted by <<priority, priority>>

Used when:

* `Pool` is requested to <<spark-scheduler-Pool.md#getSortedTaskSetQueue, getSortedTaskSetQueue>> (recursively)

* `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#resourceOffers[resourceOffers]

| minShare
a| [[minShare]]

[source, scala]
----
minShare: Int
----

Used when...FIXME

| name
a| [[name]]

[source, scala]
----
name: String
----

Used when...FIXME

| parent
a| [[parent]]

[source, scala]
----
parent: Pool
----

Used when...FIXME

| priority
a| [[priority]]

[source, scala]
----
priority: Int
----

Used when...FIXME

| removeSchedulable
a| [[removeSchedulable]]

[source, scala]
----
removeSchedulable(schedulable: Schedulable): Unit
----

Used when...FIXME

| runningTasks
a| [[runningTasks]]

[source, scala]
----
runningTasks: Int
----

Used when...FIXME

| schedulableQueue
a| [[schedulableQueue]]

[source, scala]
----
schedulableQueue: ConcurrentLinkedQueue[Schedulable]
----

Queue of <<spark-scheduler-Schedulable.md#, schedulables>> (as https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ConcurrentLinkedQueue.html[ConcurrentLinkedQueue])

Used when:

* `SparkContext` is requested to SparkContext.md#getAllPools[getAllPools]

* `Pool` is requested to <<spark-scheduler-Pool.md#addSchedulable, addSchedulable>>, <<spark-scheduler-Pool.md#removeSchedulable, removeSchedulable>>, <<spark-scheduler-Pool.md#getSchedulableByName, getSchedulableByName>>, <<spark-scheduler-Pool.md#executorLost, executorLost>>, <<spark-scheduler-Pool.md#checkSpeculatableTasks, checkSpeculatableTasks>>, and <<spark-scheduler-Pool.md#getSortedTaskSetQueue, getSortedTaskSetQueue>>

| schedulingMode
a| [[schedulingMode]]

[source, scala]
----
schedulingMode: SchedulingMode
----

<<spark-scheduler-SchedulingMode.md#, SchedulingMode>>

Used when:

* `Pool` is <<spark-scheduler-Pool.md#taskSetSchedulingAlgorithm, created>>

* web UI's `PoolTable` is requested to render a page with pools (`poolRow`)

| stageId
a| [[stageId]]

[source, scala]
----
stageId: Int
----

Used when...FIXME

| weight
a| [[weight]]

[source, scala]
----
weight: Int
----

Used when...FIXME

|===

[[implementations]]
.Schedulables
[cols="1,3",options="header",width="100%"]
|===
| Schedulable
| Description

| <<spark-scheduler-Pool.md#, Pool>>
| [[Pool]] Pool of <<spark-scheduler-Schedulable.md#, schedulables>> (i.e. a recursive data structure for prioritizing task sets)

| scheduler:TaskSetManager.md[TaskSetManager]
| [[TaskSetManager]] Manages scheduling of tasks of a scheduler:TaskSet.md[TaskSet]

|===
