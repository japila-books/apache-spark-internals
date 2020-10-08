# PluginContainer

`PluginContainer` is an [abstraction](#contract) of [plugins](#implementations).

## Contract

### <span id="registerMetrics"> registerMetrics

```scala
registerMetrics(
  appId: String): Unit
```

Used when [SparkContext](../SparkContext.md) is created

### <span id="shutdown"> shutdown

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
