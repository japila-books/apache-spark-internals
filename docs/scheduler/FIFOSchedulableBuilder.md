== FIFOSchedulableBuilder - SchedulableBuilder for FIFO Scheduling Mode

`FIFOSchedulableBuilder` is a <<SchedulableBuilder, SchedulableBuilder>> that holds a single spark-scheduler-Pool.md[Pool] (that is given when <<creating-instance, `FIFOSchedulableBuilder` is created>>).

NOTE: `FIFOSchedulableBuilder` is the scheduler:TaskSchedulerImpl.md#creating-instance[default `SchedulableBuilder` for `TaskSchedulerImpl`].

NOTE: When `FIFOSchedulableBuilder` is created, the `TaskSchedulerImpl` passes its own `rootPool` (a part of scheduler:TaskScheduler.md#contract[TaskScheduler Contract]).

`FIFOSchedulableBuilder` obeys the <<contract, SchedulableBuilder Contract>> as follows:

* <<buildPools, buildPools>> does nothing.
* `addTaskSetManager` spark-scheduler-Pool.md#addSchedulable[passes the input `Schedulable` to the one and only rootPool Pool (using `addSchedulable`)] and completely disregards the properties of the Schedulable.

=== [[creating-instance]] Creating FIFOSchedulableBuilder Instance

`FIFOSchedulableBuilder` takes the following when created:

* [[rootPool]] `rootPool` spark-scheduler-Pool.md[Pool]
