# Stage-Level Scheduling

**Stage-Level Scheduling** uses [ResourceProfile](ResourceProfile.md)s for the following:

* Spark developers can specify task and executor resource requirements at stage level
* Spark (Scheduler) uses the stage-level requirements to acquire the necessary resources and executors and schedule tasks based on the per-stage requirements

!!! note "Apache Spark 3.1.1"
    Stage-Level Scheduling was introduced in Apache Spark 3.1.1 (cf. [SPARK-27495](https://issues.apache.org/jira/browse/SPARK-27495))

## Resource Profiles

Resource Profiles are managed by [ResourceProfileManager](ResourceProfileManager.md).

The [Default ResourceProfile](ResourceProfileManager.md#defaultProfile) is known by ID `0`.

**Custom Resource Profiles** are [ResourceProfile](ResourceProfile.md)s with non-`0` IDs.
Custom Resource Profiles are only supported on YARN, Kubernetes and Spark Standalone.

`ResourceProfile`s are associated with an `RDD` using [withResources](../rdd/RDD.md#withResources) operator.

## Executor Resources

Executor Resources are specified using [executorResources](ResourceProfile.md#executorResources) of a `ResourceProfile`.

Executor Resources can be the following [built-in resources](ResourceProfile.md#allSupportedExecutorResources):

* `cores`
* `memory`
* `memoryOverhead`
* `pyspark.memory`
* `offHeap`

Other (deployment environment-specific) executor resources can be defined as [Custom Executor Resources](ResourceProfile.md#getCustomExecutorResources).

## Task Resources

[Default Task Resources](ResourceProfile.md#getDefaultTaskResources) are specified based on [spark.task.cpus](../configuration-properties.md#spark.task.cpus) and [spark.task.resource](ResourceUtils.md#addTaskResourceRequests)-prefixed configuration properties.

## Dynamic Allocation

[Dynamic Allocation of Executors](../dynamic-allocation/index.md) is not supported.

## Demo

### Describe Distributed Computation

Let's describe a distributed computation (using [RDD API](../rdd/index.md)) over a 10-record dataset.

```scala
val rdd = sc.range(0, 9)
```

### Describe Required Resources

!!! note "Optional Step"
    This demo assumes to be executed in `local` deployment mode (that supports the [default ResourceProfile](#resource-profiles) only) and so the step is considered optional until a supported cluster manager is used.

```scala
import org.apache.spark.resource.ResourceProfileBuilder
val rpb = new ResourceProfileBuilder
val rp1 = rpb.build()
```

```text
scala> println(rp1.toString)
Profile: id = 1, executor resources: , task resources:
```

### Configure Default ResourceProfile

!!! note "FIXME"
    Use `spark.task.resource`-prefixed properties per [ResourceUtils](ResourceUtils.md#addTaskResourceRequests).

### Associate Required Resources to Distributed Computation

```scala
rdd.withResources(rp1)
```

```text
scala> rdd.withResources(rp1)
org.apache.spark.SparkException: TaskResourceProfiles are only supported for Standalone cluster for now when dynamic allocation is disabled.
  at org.apache.spark.resource.ResourceProfileManager.isSupported(ResourceProfileManager.scala:71)
  at org.apache.spark.resource.ResourceProfileManager.addResourceProfile(ResourceProfileManager.scala:126)
  at org.apache.spark.rdd.RDD.withResources(RDD.scala:1802)
  ... 42 elided
```

??? note "SPARK-43912"
    Reported as [SPARK-43912 Incorrect SparkException for Stage-Level Scheduling in local mode](https://issues.apache.org/jira/browse/SPARK-43912).

    Until it is fixed, enable [Dynamic Allocation](../dynamic-allocation/index.md).

    ```shell
    $ ./bin/spark-shell -c spark.dynamicAllocation.enabled=true
    ```
