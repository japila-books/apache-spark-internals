# FairSchedulableBuilder

`FairSchedulableBuilder` is a <<spark-scheduler-SchedulableBuilder.md#, SchedulableBuilder>> that is <<creating-instance, created>> exclusively for scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl] for *FAIR scheduling mode* (when configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property is `FAIR`).

[[creating-instance]]
`FairSchedulableBuilder` takes the following to be created:

* [[rootPool]] <<spark-scheduler-Pool.md#, Root pool of schedulables>>
* [[conf]] SparkConf.md[]

Once <<creating-instance, created>>, `TaskSchedulerImpl` requests the `FairSchedulableBuilder` to <<buildPools, build the pools>>.

[[DEFAULT_SCHEDULER_FILE]]
`FairSchedulableBuilder` uses the pools defined in an <<allocations-file, allocation pools configuration file>> that is assumed to be the value of the configuration-properties.md#spark.scheduler.allocation.file[spark.scheduler.allocation.file] configuration property or the default *fairscheduler.xml* (that is <<buildPools, expected to be available on a Spark application's class path>>).

TIP: Use *conf/fairscheduler.xml.template* as a template for the <<allocations-file, allocation pools configuration file>>.

[[DEFAULT_POOL_NAME]]
`FairSchedulableBuilder` always has the *default* pool defined (and <<buildDefaultPool, registers it>> unless done in the <<allocations-file, allocation pools configuration file>>).

[[FAIR_SCHEDULER_PROPERTIES]]
[[spark.scheduler.pool]]
`FairSchedulableBuilder` uses *spark.scheduler.pool* local property for the name of the pool to use when requested to <<addTaskSetManager, addTaskSetManager>> (default: <<DEFAULT_POOL_NAME, default>>).

!!! note
    [SparkContext.setLocalProperty](../SparkContext.md#setLocalProperty) lets you set local properties per thread to group jobs in logical groups, e.g. to allow `FairSchedulableBuilder` to use `spark.scheduler.pool` property and to group jobs from different threads to be submitted for execution on a non-<<DEFAULT_POOL_NAME, default>> pool.

[source, scala]
----
scala> :type sc
org.apache.spark.SparkContext

sc.setLocalProperty("spark.scheduler.pool", "production")

// whatever is executed afterwards is submitted to production pool
----

[[logging]]
[TIP]
====
Enable `ALL` logging level for `org.apache.spark.scheduler.FairSchedulableBuilder` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.scheduler.FairSchedulableBuilder=ALL
```

Refer to <<spark-logging.md#, Logging>>.
====

=== [[allocations-file]] Allocation Pools Configuration File

The *allocation pools configuration file* is an XML file.

The default `conf/fairscheduler.xml.template` is as follows:

[source, xml]
----
<?xml version="1.0"?>
<allocations>
  <pool name="production">
    <schedulingMode>FAIR</schedulingMode>
    <weight>1</weight>
    <minShare>2</minShare>
  </pool>
  <pool name="test">
    <schedulingMode>FIFO</schedulingMode>
    <weight>2</weight>
    <minShare>3</minShare>
  </pool>
</allocations>
----

TIP: The top-level element's name `allocations` can be anything. Spark does not insist on `allocations` and accepts any name.

=== [[buildPools]] Building (Tree of) Pools of Schedulables -- `buildPools` Method

[source, scala]
----
buildPools(): Unit
----

NOTE: `buildPools` is part of the <<spark-scheduler-SchedulableBuilder.md#buildPools, SchedulableBuilder Contract>> to build a tree of <<spark-scheduler-Pool.md#, pools (of Schedulables)>>.

`buildPools` <<buildFairSchedulerPool, creates Fair Scheduler pools from a configuration file>> if available and then <<buildDefaultPool, builds the default pool>>.

`buildPools` prints out the following INFO message to the logs when the configuration file (per the configuration-properties.md#spark.scheduler.allocation.file[spark.scheduler.allocation.file] configuration property) could be read:

```
Creating Fair Scheduler pools from [file]
```

`buildPools` prints out the following INFO message to the logs when the configuration-properties.md#spark.scheduler.allocation.file[spark.scheduler.allocation.file] configuration property was not used to define the configuration file and the <<DEFAULT_SCHEDULER_FILE, default configuration file>> is used instead:

```
Creating Fair Scheduler pools from default file: [DEFAULT_SCHEDULER_FILE]
```

When neither configuration-properties.md#spark.scheduler.allocation.file[spark.scheduler.allocation.file] configuration property nor the <<DEFAULT_SCHEDULER_FILE, default configuration file>> could be used, `buildPools` prints out the following WARN message to the logs:

```
Fair Scheduler configuration file not found so jobs will be scheduled in FIFO order. To use fair scheduling, configure pools in [DEFAULT_SCHEDULER_FILE] or set spark.scheduler.allocation.file to a file that contains the configuration.
```

=== [[addTaskSetManager]] `addTaskSetManager` Method

[source, scala]
----
addTaskSetManager(manager: Schedulable, properties: Properties): Unit
----

NOTE: `addTaskSetManager` is part of the <<spark-scheduler-SchedulableBuilder.md#addTaskSetManager, SchedulableBuilder Contract>> to register a new <<spark-scheduler-Schedulable.md#, Schedulable>> with the <<rootPool, rootPool>>

`addTaskSetManager` finds the pool by name (in the given `Properties`) under the <<FAIR_SCHEDULER_PROPERTIES, spark.scheduler.pool>> property or defaults to the <<DEFAULT_POOL_NAME, default>> pool if undefined.

`addTaskSetManager` then requests the <<rootPool, root pool>> to <<spark-scheduler-Pool.md#getSchedulableByName, find the Schedulable by that name>>.

Unless found, `addTaskSetManager` creates a new <<spark-scheduler-Pool.md#, Pool>> with the <<buildDefaultPool, default configuration>> (as if the <<DEFAULT_POOL_NAME, default>> pool were used) and requests the <<rootPool, Pool>> to <<spark-scheduler-Pool.md#addSchedulable, register it>>. In the end, `addTaskSetManager` prints out the following WARN message to the logs:

```
A job was submitted with scheduler pool [poolName], which has not been configured. This can happen when the file that pools are read from isn't set, or when that file doesn't contain [poolName]. Created [poolName] with default configuration (schedulingMode: [mode], minShare: [minShare], weight: [weight])
```

`addTaskSetManager` then requests the pool (found or newly-created) to <<spark-scheduler-Pool.md#addSchedulable, register>> the given <<spark-scheduler-Schedulable.md#, Schedulable>>.

In the end, `addTaskSetManager` prints out the following INFO message to the logs:

```
Added task set [name] tasks to pool [poolName]
```

=== [[buildDefaultPool]] Registering Default Pool -- `buildDefaultPool` Method

[source, scala]
----
buildDefaultPool(): Unit
----

`buildDefaultPool` requests the <<rootPool, root pool>> to <<getSchedulableByName, find the default pool>> (one with the <<DEFAULT_POOL_NAME, default>> name).

Unless already available, `buildDefaultPool` creates a <<spark-scheduler-Pool.md#, schedulable pool>> with the following:

* <<DEFAULT_POOL_NAME, default>> pool name

* `FIFO` scheduling mode

* `0` for the initial minimum share

* `1` for the initial weight

In the end, `buildDefaultPool` requests the <<rootPool, Pool>> to <<spark-scheduler-Pool.md#addSchedulable, register the pool>> followed by the INFO message in the logs:

```
Created default pool: [name], schedulingMode: [mode], minShare: [minShare], weight: [weight]
```

NOTE: `buildDefaultPool` is used exclusively when `FairSchedulableBuilder` is requested to <<buildPools, build the pools>>.

=== [[buildFairSchedulerPool]] Building Pools from XML Allocations File -- `buildFairSchedulerPool` Internal Method

[source, scala]
----
buildFairSchedulerPool(
  is: InputStream,
  fileName: String): Unit
----

`buildFairSchedulerPool` starts by loading the XML file from the given `InputStream`.

For every *pool* element, `buildFairSchedulerPool` creates a <<spark-scheduler-Pool.md#, schedulable pool>> with the following:

* Pool name per *name* attribute

* Scheduling mode per *schedulingMode* element (case-insensitive with `FIFO` as the default)

* Initial minimum share per *minShare* element (default: `0`)

* Initial weight per *weight* element (default: `1`)

In the end, `buildFairSchedulerPool` requests the <<rootPool, Pool>> to <<spark-scheduler-Pool.md#addSchedulable, register the pool>> followed by the INFO message in the logs:

```
Created pool: [name], schedulingMode: [mode], minShare: [minShare], weight: [weight]
```

NOTE: `buildFairSchedulerPool` is used exclusively when `FairSchedulableBuilder` is requested to <<buildPools, build the pools>>.
