== [[SchedulingMode]] Scheduling Mode -- `spark.scheduler.mode` Spark Property

*Scheduling Mode* (aka _order task policy_ or _scheduling policy_ or _scheduling order_) defines a policy to sort tasks in order for execution.

The scheduling mode `schedulingMode` attribute is part of the scheduler:TaskScheduler.md#schedulingMode[TaskScheduler Contract].

The only implementation of the `TaskScheduler` contract in Spark -- scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl] -- uses configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] setting to configure `schedulingMode` that is _merely_ used to set up the scheduler:TaskScheduler.md#rootPool[rootPool] attribute (with `FIFO` being the default). It happens when scheduler:TaskSchedulerImpl.md#initialize[`TaskSchedulerImpl` is initialized].

There are three acceptable scheduling modes:

* [[FIFO]] `FIFO` with no pools but a single top-level unnamed pool with elements being scheduler:TaskSetManager.md[TaskSetManager] objects; lower priority gets scheduler:spark-scheduler-Schedulable.md[Schedulable] sooner or earlier stage wins.
* [[FAIR]] `FAIR` with a scheduler:spark-scheduler-FairSchedulableBuilder.md#buildPools[hierarchy of `Schedulable` (sub)pools] with the scheduler:TaskScheduler.md#rootPool[rootPool] at the top.
* [[NONE]] *NONE* (not used)

NOTE: Out of three possible `SchedulingMode` policies only `FIFO` and `FAIR` modes are supported by scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl].

[NOTE]
====
After the root pool is initialized, the scheduling mode is no longer relevant (since the spark-scheduler-Schedulable.md[Schedulable] that represents the root pool is fully set up).

The root pool is later used when scheduler:TaskSchedulerImpl.md#submitTasks[`TaskSchedulerImpl` submits tasks (as `TaskSets`) for execution].
====

NOTE: The scheduler:TaskScheduler.md#rootPool[root pool] is a `Schedulable`. Refer to spark-scheduler-Schedulable.md[Schedulable].

=== [[fair-scheduling-sparkui]] Monitoring FAIR Scheduling Mode using Spark UI

CAUTION: FIXME Describe me...
