# DriverPluginContainer

`DriverPluginContainer` is a [PluginContainer](PluginContainer.md).

## Creating Instance

`DriverPluginContainer` takes the following to be created:

* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="resources"> Resources (`Map[String, ResourceInformation]`)
* <span id="plugins"> [SparkPlugin](SparkPlugin.md)s

`DriverPluginContainer` is created when:

* `PluginContainer` utility is used for a [PluginContainer](PluginContainer.md#apply) (at [SparkContext](../SparkContext-creating-instance-internals.md#PluginContainer) startup)

## <span id="registerMetrics"> Registering Metrics

```scala
registerMetrics(
  appId: String): Unit
```

`registerMetrics` is part of the [PluginContainer](PluginContainer.md#registerMetrics) abstraction.

For every [driver plugin](#driverPlugins), `registerMetrics` requests it to [register metrics](DriverPlugin.md#registerMetrics) and the associated [PluginContextImpl](PluginContextImpl.md) for the [same](PluginContextImpl.md#registerMetrics).

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.plugin.DriverPluginContainer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.internal.plugin.DriverPluginContainer=ALL
```

Refer to [Logging](../spark-logging.md).
