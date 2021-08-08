# PluginContainer

`PluginContainer` is an [abstraction](#contract) of [plugin containers](#implementations) that can [registerMetrics](#registerMetrics) (for the driver and executors).

`PluginContainer` is created for the driver and executors using [apply](#apply) utility.

## Contract

### <span id="onTaskFailed"> Listening to Task Failures

```scala
onTaskFailed(
  failureReason: TaskFailedReason): Unit
```

For [ExecutorPluginContainer](ExecutorPluginContainer.md) only

Used when:

* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run) (and the task has failed)

### <span id="onTaskStart"> Listening to Task Start

```scala
onTaskStart(): Unit
```

For [ExecutorPluginContainer](ExecutorPluginContainer.md) only

Used when:

* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run) (and the task has just started)

### <span id="onTaskSucceeded"> Listening to Task Success

```scala
onTaskSucceeded(): Unit
```

For [ExecutorPluginContainer](ExecutorPluginContainer.md) only

Used when:

* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run) (and the task has finished successfully)

### <span id="registerMetrics"> Registering Metrics

```scala
registerMetrics(
  appId: String): Unit
```

Registers metrics for the [application ID](../SparkContext.md#applicationId)

For [DriverPluginContainer](DriverPluginContainer.md) only

Used when:

* [SparkContext](../SparkContext.md) is created

### <span id="shutdown"> Shutdown

```scala
shutdown(): Unit
```

Used when:

* `SparkContext` is requested to [stop](../SparkContext.md#stop)
* `Executor` is requested to [stop](../executor/Executor.md#stop)

## Implementations

??? note "Sealed Abstract Class"
    `PluginContainer` is a Scala **sealed abstract class** which means that all of the implementations are in the same compilation unit (a single file).

* [DriverPluginContainer](DriverPluginContainer.md)
* [ExecutorPluginContainer](ExecutorPluginContainer.md)

## <span id="apply"> Creating PluginContainer

```scala
// the driver
apply(
  sc: SparkContext,
  resources: java.util.Map[String, ResourceInformation]): Option[PluginContainer]
// executors
apply(
  env: SparkEnv,
  resources: java.util.Map[String, ResourceInformation]): Option[PluginContainer]
// private helper
apply(
  ctx: Either[SparkContext, SparkEnv],
  resources: java.util.Map[String, ResourceInformation]): Option[PluginContainer]
```

`apply` creates a `PluginContainer` for the driver or executors (based on the type of the first input argument, i.e. [SparkContext](../SparkContext.md) or [SparkEnv](../SparkEnv.md), respectively).

`apply` first loads the [SparkPlugin](SparkPlugin.md)s defined by [spark.plugins](../configuration-properties.md#spark.plugins) configuration property.

Only when there was at least one plugin loaded, `apply` creates a [DriverPluginContainer](DriverPluginContainer.md) or [ExecutorPluginContainer](ExecutorPluginContainer.md).

`apply` is used when:

* `SparkContext` is [created](../SparkContext.md#PluginContainer)
* `Executor` is [created](../executor/Executor.md#plugins)
