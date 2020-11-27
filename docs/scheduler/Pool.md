== [[Pool]] Schedulable Pool

`Pool` is a scheduler:spark-scheduler-Schedulable.md[Schedulable] entity that represents a tree of scheduler:TaskSetManager.md[TaskSetManagers], i.e. it contains a collection of `TaskSetManagers` or the `Pools` thereof.

A `Pool` has a mandatory name, a spark-scheduler-SchedulingMode.md[scheduling mode], initial `minShare` and `weight` that are defined when it is created.

NOTE: An instance of `Pool` is created when scheduler:TaskSchedulerImpl.md#initialize[TaskSchedulerImpl is initialized].

NOTE: The scheduler:TaskScheduler.md#contract[TaskScheduler Contract] and spark-scheduler-Schedulable.md#contract[Schedulable Contract] both require that their entities have `rootPool` of type `Pool`.

=== [[increaseRunningTasks]] `increaseRunningTasks` Method

CAUTION: FIXME

=== [[decreaseRunningTasks]] `decreaseRunningTasks` Method

CAUTION: FIXME

=== [[taskSetSchedulingAlgorithm]] `taskSetSchedulingAlgorithm` Attribute

Using the spark-scheduler-SchedulingMode.md[scheduling mode] (given when a `Pool` object is created), `Pool` selects <<SchedulingAlgorithm, SchedulingAlgorithm>> and sets `taskSetSchedulingAlgorithm`:

* <<FIFOSchedulingAlgorithm, FIFOSchedulingAlgorithm>> for FIFO scheduling mode.
* <<FairSchedulingAlgorithm, FairSchedulingAlgorithm>> for FAIR scheduling mode.

It throws an `IllegalArgumentException` when unsupported scheduling mode is passed on:

```
Unsupported spark.scheduler.mode: [schedulingMode]
```

TIP: Read about the scheduling modes in spark-scheduler-SchedulingMode.md[SchedulingMode].

NOTE: `taskSetSchedulingAlgorithm` is used in <<getSortedTaskSetQueue, getSortedTaskSetQueue>>.

=== [[getSortedTaskSetQueue]] Getting TaskSetManagers Sorted -- `getSortedTaskSetQueue` Method

NOTE: `getSortedTaskSetQueue` is part of the spark-scheduler-Schedulable.md#contract[Schedulable Contract].

`getSortedTaskSetQueue` sorts all the spark-scheduler-Schedulable.md[Schedulables] in spark-scheduler-Schedulable.md#contract[schedulableQueue] queue by a <<SchedulingAlgorithm, SchedulingAlgorithm>> (from the internal <<taskSetSchedulingAlgorithm, taskSetSchedulingAlgorithm>>).

NOTE: It is called when scheduler:TaskSchedulerImpl.md#resourceOffers[`TaskSchedulerImpl` processes executor resource offers].

=== [[schedulableNameToSchedulable]] Schedulables by Name -- `schedulableNameToSchedulable` Registry

[source, scala]
----
schedulableNameToSchedulable = new ConcurrentHashMap[String, Schedulable]
----

`schedulableNameToSchedulable` is a lookup table of spark-scheduler-Schedulable.md[Schedulable] objects by their names.

Beside the obvious usage in the housekeeping methods like `addSchedulable`, `removeSchedulable`, `getSchedulableByName` from the spark-scheduler-Schedulable.md#contract[Schedulable Contract], it is exclusively used in SparkContext.md#getPoolForName[SparkContext.getPoolForName].

=== [[addSchedulable]] `addSchedulable` Method

NOTE: `addSchedulable` is part of the spark-scheduler-Schedulable.md#contract[Schedulable Contract].

`addSchedulable` adds a `Schedulable` to the spark-scheduler-Schedulable.md#contract[schedulableQueue] and <<schedulableNameToSchedulable, schedulableNameToSchedulable>>.

More importantly, it sets the `Schedulable` entity's spark-scheduler-Schedulable.md#contract[parent] to itself.

=== [[removeSchedulable]] `removeSchedulable` Method

NOTE: `removeSchedulable` is part of the spark-scheduler-Schedulable.md#contract[Schedulable Contract].

`removeSchedulable` removes a `Schedulable` from the spark-scheduler-Schedulable.md#contract[schedulableQueue] and <<schedulableNameToSchedulable, schedulableNameToSchedulable>>.

NOTE: `removeSchedulable` is the opposite to <<addSchedulable, `addSchedulable` method>>.

=== [[SchedulingAlgorithm]] SchedulingAlgorithm

`SchedulingAlgorithm` is the interface for a sorting algorithm to sort spark-scheduler-Schedulable.md[Schedulables].

There are currently two `SchedulingAlgorithms`:

* <<FIFOSchedulingAlgorithm, FIFOSchedulingAlgorithm>> for FIFO scheduling mode.
* <<FairSchedulingAlgorithm, FairSchedulingAlgorithm>> for FAIR scheduling mode.

==== [[FIFOSchedulingAlgorithm]] FIFOSchedulingAlgorithm

`FIFOSchedulingAlgorithm` is a scheduling algorithm that compares `Schedulables` by their `priority` first and, when equal, by their `stageId`.

NOTE: `priority` and `stageId` are part of spark-scheduler-Schedulable.md#contract[Schedulable Contract].

CAUTION: FIXME _A picture is worth a thousand words._ How to picture the algorithm?

==== [[FairSchedulingAlgorithm]] FairSchedulingAlgorithm

`FairSchedulingAlgorithm` is a scheduling algorithm that compares `Schedulables` by their `minShare`, `runningTasks`, and `weight`.

NOTE: `minShare`, `runningTasks`, and `weight` are part of spark-scheduler-Schedulable.md#contract[Schedulable Contract].

.FairSchedulingAlgorithm
image::spark-pool-FairSchedulingAlgorithm.png[align="center"]

For each input `Schedulable`, `minShareRatio` is computed as `runningTasks` by `minShare` (but at least `1`) while `taskToWeightRatio` is `runningTasks` by `weight`.

=== [[getSchedulableByName]] Finding Schedulable by Name -- `getSchedulableByName` Method

[source, scala]
----
getSchedulableByName(schedulableName: String): Schedulable
----

NOTE: `getSchedulableByName` is part of the <<spark-scheduler-Schedulable.md#getSchedulableByName, Schedulable Contract>> to find a <<spark-scheduler-Schedulable.md#, Schedulable>> by name.

`getSchedulableByName`...FIXME
