# ExecutorPluginContainer

`ExecutorPluginContainer` is a [PluginContainer](PluginContainer.md) for [Executor](../executor/Executor.md#plugins)s.

## Creating Instance

`ExecutorPluginContainer` takes the following to be created:

* <span id="env"> [SparkEnv](../SparkEnv.md)
* <span id="resources"> Resources (`Map[String, ResourceInformation]`)
* <span id="plugins"> [SparkPlugin](SparkPlugin.md)s

`ExecutorPluginContainer` is created when:

* `PluginContainer` utility is used to [create a PluginContainer](PluginContainer.md#apply) (for [Executor](../executor/Executor.md#plugins)s)

## <span id="executorPlugins"> ExecutorPlugins

`ExecutorPluginContainer` [initializes](#initialization) `executorPlugins` internal registry of [ExecutorPlugin](ExecutorPlugin.md)s when [created](#creating-instance).

### Initialization

`executorPlugins` finds all the configuration properties with `spark.plugins.internal.conf.` prefix (in the [SparkConf](../SparkEnv.md#conf)) for extra configuration of every [ExecutorPlugin](SparkPlugin.md#executorPlugin) of the given [SparkPlugin](#plugins)s.

For every `SparkPlugin` (in the given [SparkPlugin](#plugins)s) that defines an [ExecutorPlugin](SparkPlugin.md#executorPlugin), `executorPlugins` creates a [PluginContextImpl](PluginContextImpl.md), requests the `ExecutorPlugin` to [init](ExecutorPlugin.md#init) (with the `PluginContextImpl` and the extra configuration) and the `PluginContextImpl` to [registerMetrics](PluginContextImpl.md#registerMetrics).

In the end, `executorPlugins` prints out the following INFO message to the logs (for every `ExecutorPlugin`):

```text
Initialized executor component for plugin [name].
```

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.plugin.ExecutorPluginContainer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.internal.plugin.ExecutorPluginContainer=ALL
```

Refer to [Logging](../spark-logging.md).
