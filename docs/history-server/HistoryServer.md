# HistoryServer

`HistoryServer` is an extension of the [web UI](../webui/WebUI.md) for reviewing event logs of running (active) and completed Spark applications with event log collection enabled (based on [spark.eventLog.enabled](configuration-properties.md#spark.eventLog.enabled) configuration property).

## <span id="main"> Starting HistoryServer Standalone Application

```scala
main(
  argStrings: Array[String]): Unit
```

`main` creates a [HistoryServerArguments](HistoryServerArguments.md) (with the given `argStrings` arguments).

`main` initializes security.

`main` creates an [ApplicationHistoryProvider](ApplicationHistoryProvider.md) (based on [spark.history.provider](configuration-properties.md#spark.history.provider) configuration property).

`main` creates a [HistoryServer](HistoryServer.md) (with the `ApplicationHistoryProvider` and [spark.history.ui.port](configuration-properties.md#spark.history.ui.port) configuration property) and requests it to [bind](HistoryServer.md#bind).

`main` requests the `ApplicationHistoryProvider` to [start](ApplicationHistoryProvider.md#start).

`main` registers a shutdown hook that requests the `HistoryServer` to [stop](HistoryServer.md#stop) and sleeps..._till the end of the world_ (giving the daemon thread a go).

## Creating Instance

`HistoryServer` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="provider"> [ApplicationHistoryProvider](ApplicationHistoryProvider.md)
* <span id="securityManager"> `SecurityManager`
* <span id="port"> Port number

When created, `HistoryServer` [initializes itself](#initialize).

`HistoryServer` is created when [HistoryServer](#main) standalone application is started.

## <span id="ApplicationCacheOperations"> ApplicationCacheOperations

`HistoryServer` is a [ApplicationCacheOperations](ApplicationCacheOperations.md).

## <span id="UIRoot"> UIRoot

`HistoryServer` is a [UIRoot](../rest/UIRoot.md).

## <span id="initialize"> Initializing HistoryServer

```scala
initialize(): Unit
```

`initialize` is part of the [WebUI](../webui/WebUI.md#initialize) abstraction.

`initialize`...FIXME

## <span id="attachSparkUI"> Attaching SparkUI

```scala
attachSparkUI(
  appId: String,
  attemptId: Option[String],
  ui: SparkUI,
  completed: Boolean): Unit
```

`attachSparkUI` is part of the [ApplicationCacheOperations](ApplicationCacheOperations.md#attachSparkUI) abstraction.

`attachSparkUI`...FIXME

## <span id="getAppUI"> Spark UI

```scala
getAppUI(
  appId: String,
  attemptId: Option[String]): Option[LoadedAppUI]
```

`getAppUI` is part of the [ApplicationCacheOperations](ApplicationCacheOperations.md#getAppUI) abstraction.

`getAppUI` requests the [ApplicationHistoryProvider](#provider) for the [Spark UI](ApplicationHistoryProvider.md#getAppUI) of a Spark application (based on the `appId` and `attemptId`).

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.history.HistoryServer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.history.HistoryServer=ALL
```

Refer to [Logging](../spark-logging.md).
