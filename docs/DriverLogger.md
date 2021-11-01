# DriverLogger

`DriverLogger` runs on the driver (in `client` deploy mode) to copy driver logs to Hadoop DFS periodically.

## Creating Instance

`DriverLogger` takes the following to be created:

* <span id="conf"> [SparkConf](SparkConf.md)

`DriverLogger` is created using [apply](#apply) utility.

## <span id="apply"> Creating DriverLogger

```scala
apply(
  conf: SparkConf): Option[DriverLogger]
```

`apply` creates a [DriverLogger](#creating-instance) when the following hold:

1. [spark.driver.log.persistToDfs.enabled](configuration-properties.md#spark.driver.log.persistToDfs.enabled) configuration property is enabled
1. The Spark application runs in `client` deploy mode (and [spark.submit.deployMode](configuration-properties.md#spark.submit.deployMode) is `client`)
1. [spark.driver.log.dfsDir](configuration-properties.md#spark.driver.log.dfsDir) is specified

`apply` prints out the following WARN message to the logs with no [spark.driver.log.dfsDir](configuration-properties.md#spark.driver.log.dfsDir) specified:

```text
Driver logs are not persisted because spark.driver.log.dfsDir is not configured
```

`apply` is used when:

* `SparkContext` is [created](SparkContext.md#_driverLogger)

## <span id="startSync"> Starting DfsAsyncWriter

```scala
startSync(
  hadoopConf: Configuration): Unit
```

`startSync` creates and starts a `DfsAsyncWriter` (with the [spark.app.id](configuration-properties.md#spark.app.id) configuration property).

`startSync` is used when:

* `SparkContext` is requested to [postApplicationStart](SparkContext.md#postApplicationStart)
