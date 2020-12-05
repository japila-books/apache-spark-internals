# FsHistoryProvider

`FsHistoryProvider` is the default [ApplicationHistoryProvider](ApplicationHistoryProvider.md) for [Spark History Server](index.md).

## Creating Instance

`FsHistoryProvider` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="clock"> `Clock` (default: `SystemClock`)

`FsHistoryProvider` is created when `HistoryServer` standalone application is [started](HistoryServer.md#main) (and no [spark.history.provider](configuration-properties.md#spark.history.provider) configuration property was defined).

## <span id="storePath"> Path of Application History Cache

```scala
storePath: Option[File]
```

`FsHistoryProvider` uses [spark.history.store.path](configuration-properties.md#spark.history.store.path) configuration property for the directory to cache application history.

With `storePath` defined, `FsHistoryProvider` uses a [LevelDB](../core/LevelDB.md) as the [KVStore](#listing). Otherwise, a [InMemoryStore](../core/InMemoryStore.md).

With `storePath` defined, `FsHistoryProvider` uses a [HistoryServerDiskManager](HistoryServerDiskManager.md) as the [disk manager](#diskManager).

## <span id="diskManager"> Disk Manager

```scala
diskManager: Option[HistoryServerDiskManager]
```

`FsHistoryProvider` creates a [HistoryServerDiskManager](HistoryServerDiskManager.md) when [created](#creating-instance) (with [storePath](#storePath) defined based on [spark.history.store.path](configuration-properties.md#spark.history.store.path) configuration property).

`FsHistoryProvider` uses the `HistoryServerDiskManager` for the following:

* [startPolling](#startPolling)
* [getAppUI](#getAppUI)
* [onUIDetached](#onUIDetached)
* [cleanAppData](#cleanAppData)

## <span id="getAppUI"> SparkUI of Spark Application

```scala
getAppUI(
  appId: String,
  attemptId: Option[String]): Option[LoadedAppUI]
```

`getAppUI` is part of the [ApplicationHistoryProvider](ApplicationHistoryProvider.md#getAppUI) abstraction.

`getAppUI`...FIXME

## <span id="onUIDetached"> onUIDetached

```scala
onUIDetached(): Unit
```

`onUIDetached` is part of the [ApplicationHistoryProvider](ApplicationHistoryProvider.md#onUIDetached) abstraction.

`onUIDetached`...FIXME

## <span id="loadDiskStore"> loadDiskStore

```scala
loadDiskStore(
  dm: HistoryServerDiskManager,
  appId: String,
  attempt: AttemptInfoWrapper): KVStore
```

`loadDiskStore`...FIXME

`loadDiskStore` is used in [getAppUI](#getAppUI) (with [HistoryServerDiskManager](#diskManager) available).

## <span id="createInMemoryStore"> createInMemoryStore

```scala
createInMemoryStore(
  attempt: AttemptInfoWrapper): KVStore
```

`createInMemoryStore`...FIXME

`createInMemoryStore` is used in [getAppUI](#getAppUI).

## <span id="rebuildAppStore"> rebuildAppStore

```scala
rebuildAppStore(
  store: KVStore,
  reader: EventLogFileReader,
  lastUpdated: Long): Unit
```

`rebuildAppStore`...FIXME

`rebuildAppStore` is used in [loadDiskStore](#loadDiskStore) and [createInMemoryStore](#createInMemoryStore).

## <span id="cleanAppData"> cleanAppData

```scala
cleanAppData(
  appId: String,
  attemptId: Option[String],
  logPath: String): Unit
```

`cleanAppData`...FIXME

`cleanAppData` is used in [checkForLogs](#checkForLogs) and [deleteAttemptLogs](#deleteAttemptLogs).

## <span id="startPolling"> Polling for Logs

```scala
startPolling(): Unit
```

`startPolling`...FIXME

`startPolling` is used in [initialize](#initialize) and [startSafeModeCheckThread](#startSafeModeCheckThread).

### <span id="checkForLogs"> Checking Available Event Logs

```scala
checkForLogs(): Unit
```

`checkForLogs`...FIXME

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.history.FsHistoryProvider` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.history.FsHistoryProvider=ALL
```

Refer to [Logging](../spark-logging.md).
