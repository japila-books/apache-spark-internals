# ExternalClusterManager

`ExternalClusterManager` is an [abstraction](#contract) of [pluggable cluster managers](#implementations) that can create a [SchedulerBackend](#createSchedulerBackend) and [TaskScheduler](#createTaskScheduler) for a given [master URL](#canCreate) (when [SparkContext](../SparkContext.md) is created).

!!! note
    The support for pluggable cluster managers was introduced in [SPARK-13904 Add support for pluggable cluster manager](https://issues.apache.org/jira/browse/SPARK-13904).

`ExternalClusterManager` can be [registered using the `java.util.ServiceLoader` mechanism](../SparkContext-creating-instance-internals.md#getClusterManager) (with service markers under `META-INF/services` directory).

## Contract

### <span id="canCreate"> Checking Support for Master URL

```scala
canCreate(
  masterURL: String): Boolean
```

Checks whether this cluster manager instance can create scheduler components for a given master URL

Used when [SparkContext](../SparkContext.md) is created (and requested for a [cluster manager](../SparkContext.md#getClusterManager))

### <span id="createSchedulerBackend"> Creating SchedulerBackend

```scala
createSchedulerBackend(
  sc: SparkContext,
  masterURL: String,
  scheduler: TaskScheduler): SchedulerBackend
```

Creates a [SchedulerBackend](SchedulerBackend.md) for a given [SparkContext](../SparkContext.md), master URL, and [TaskScheduler](TaskScheduler.md).

Used when [SparkContext](../SparkContext.md) is created (and requested for a [SchedulerBackend and TaskScheduler](../SparkContext.md#createTaskScheduler))

### <span id="createTaskScheduler"> Creating TaskScheduler

```scala
createTaskScheduler(
  sc: SparkContext,
  masterURL: String): TaskScheduler
```

Creates a [TaskScheduler](TaskScheduler.md) for a given [SparkContext](../SparkContext.md) and master URL

Used when [SparkContext](../SparkContext.md) is created (and requested for a [SchedulerBackend and TaskScheduler](../SparkContext.md#createTaskScheduler))

### <span id="initialize"> Initializing Scheduling Components

```scala
initialize(
  scheduler: TaskScheduler,
  backend: SchedulerBackend): Unit
```

Initializes the [TaskScheduler](TaskScheduler.md) and [SchedulerBackend](SchedulerBackend.md)

Used when [SparkContext](../SparkContext.md) is created (and requested for a [SchedulerBackend and TaskScheduler](../SparkContext.md#createTaskScheduler))

## Implementations

* `KubernetesClusterManager` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesClusterManager))
* `MesosClusterManager`
* `YarnClusterManager`
