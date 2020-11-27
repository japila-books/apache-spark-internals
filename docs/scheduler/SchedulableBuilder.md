== [[SchedulableBuilder]] SchedulableBuilder Contract -- Builders of Schedulable Pools

`SchedulableBuilder` is the <<contract, abstraction>> of <<implementations, schedulable builders>> that manage a <<rootPool, root pool (of Schedulables)>>, which is to <<buildPools, build a pool>> and <<addTaskSetManager, register a new Schedulable (with the pool)>>.

`SchedulableBuilder` is a `private[spark]` Scala trait that is used exclusively by scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl] (the default Spark scheduler). When requested to scheduler:TaskSchedulerImpl.md#initialize[initialize], `TaskSchedulerImpl` uses the configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property (default: `FIFO`) to select one of the <<implementations, available schedulable builders>>.

[[contract]]
.SchedulableBuilder Contract
[cols="1m,3",options="header",width="100%"]
|===
| Method
| Description

| addTaskSetManager
a| [[addTaskSetManager]]

[source, scala]
----
addTaskSetManager(manager: Schedulable, properties: Properties): Unit
----

Registers a new <<spark-scheduler-Schedulable.md#, Schedulable>> with the <<rootPool, rootPool>>

Used exclusively when `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#submitTasks[submit tasks (of TaskSet) for execution] (and registers a new scheduler:TaskSetManager.md[TaskSetManager] for the `TaskSet`)

| buildPools
a| [[buildPools]]

[source, scala]
----
buildPools(): Unit
----

Builds a tree of <<spark-scheduler-Pool.md#, pools (of Schedulables)>>

Used exclusively when `TaskSchedulerImpl` is requested to scheduler:TaskSchedulerImpl.md#initialize[initialize] (and creates a scheduler:TaskSchedulerImpl.md#schedulableBuilder[SchedulableBuilder] per configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property)

| rootPool
a| [[rootPool]]

[source, scala]
----
rootPool: Pool
----

Root (top-level) <<spark-scheduler-Pool.md#, pool (of Schedulables)>>

Used when:

* `FIFOSchedulableBuilder` is requested to <<spark-scheduler-FIFOSchedulableBuilder.md#addTaskSetManager, addTaskSetManager>>

* `FairSchedulableBuilder` is requested to <<spark-scheduler-FairSchedulableBuilder.md#buildDefaultPool, buildDefaultPool>>, <<spark-scheduler-FairSchedulableBuilder.md#buildFairSchedulerPool, buildFairSchedulerPool>>, and <<spark-scheduler-FairSchedulableBuilder.md#addTaskSetManager, addTaskSetManager>>

|===

[[implementations]]
.SchedulableBuilders
[cols="1,3",options="header",width="100%"]
|===
| SchedulableBuilder
| Description

| <<spark-scheduler-FairSchedulableBuilder.md#, FairSchedulableBuilder>>
| [[FairSchedulableBuilder]] Used when the configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property is `FAIR`

| <<spark-scheduler-FIFOSchedulableBuilder.md#, FIFOSchedulableBuilder>>
| [[FIFOSchedulableBuilder]] Default `SchedulableBuilder` that is used when the configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property is `FIFO` (default)

|===
