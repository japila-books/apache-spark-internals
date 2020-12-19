# ExternalShuffleService

`ExternalShuffleService` is a Spark service that can serve RDD and shuffle blocks.

`ExternalShuffleService` manages shuffle output files so they are available to executors. As the shuffle output files are managed externally to the executors it offers an uninterrupted access to the shuffle output files regardless of executors being killed or down (esp. with [Dynamic Allocation of Executors](../dynamic-allocation/index.md)).

`ExternalShuffleService` can be [launched from command line](#launch).

`ExternalShuffleService` is enabled on the driver and executors using [spark.shuffle.service.enabled](configuration-properties.md#spark.shuffle.service.enabled) configuration property.

!!! note
    Spark on YARN uses a custom external shuffle service (`YarnShuffleService`).

## <span id="launch"> Launching ExternalShuffleService

`ExternalShuffleService` can be launched as a standalone application using [spark-class](../tools/spark-class.md).

```text
spark-class org.apache.spark.deploy.ExternalShuffleService
```

### <span id="main"> main Entry Point

```scala
main(
  args: Array[String]): Unit
```

`main` is the entry point of `ExternalShuffleService` standalone application.

`main` prints out the following INFO message to the logs:

```text
Started daemon with process name: [name]
```

`main` registers signal handlers for `TERM`, `HUP`, `INT` signals.

`main` [loads the default Spark properties](../Utils.md#loadDefaultSparkProperties).

`main` creates a `SecurityManager`.

`main` turns [spark.shuffle.service.enabled](configuration-properties.md#spark.shuffle.service.enabled) to `true` explicitly (since this service is started from the command line for a reason).

`main` creates an [ExternalShuffleService](#creating-instance) and [starts it](#start).

`main` prints out the following DEBUG message to the logs:

```text
Adding shutdown hook
```

`main` registers a shutdown hook. When triggered, the shutdown hook prints the following INFO message to the logs and requests the `ExternalShuffleService` to [stop](#stop).

```text
Shutting down shuffle service.
```

## Creating Instance

`ExternalShuffleService` takes the following to be created:

* <span id="sparkConf"> [SparkConf](../SparkConf.md)
* <span id="securityManager"> `SecurityManager`

`ExternalShuffleService` is created when:

* `ExternalShuffleService` standalone application is [started](#launch)
* `Worker` (Spark Standalone) is [created](../spark-standalone/Worker.md#shuffleService) (and initializes an `ExternalShuffleService`)

## <span id="server"> TransportServer

```scala
server: TransportServer
```

`ExternalShuffleService` uses an internal reference to a [TransportServer](../network/TransportServer.md) that is created when `ExternalShuffleService` is [started](#start).

`ExternalShuffleService` uses an [ExternalBlockHandler](#blockHandler) to handle RPC messages (and serve RDD blocks and shuffle blocks).

`TransportServer` is [closed](../network/TransportServer.md#close) when `ExternalShuffleService` is requested to [stop](#stop).

`TransportServer` is used for metrics.

## <span id="port"><span id="spark.shuffle.service.port"> Port

`ExternalShuffleService` uses [spark.shuffle.service.port](configuration-properties.md#spark.shuffle.service.port) configuration property for the port to listen to when [started](#start).

## <span id="enabled"><span id="spark.shuffle.service.enabled"> spark.shuffle.service.enabled

`ExternalShuffleService` uses [spark.shuffle.service.enabled](configuration-properties.md#spark.shuffle.service.enabled) configuration property to control whether or not is enabled (and should be [started](#startIfEnabled) when requested).

## <span id="blockHandler"><span id="newShuffleBlockHandler"><span id="getBlockHandler"><span id="registeredExecutorsDB"> ExternalBlockHandler

```scala
blockHandler: ExternalBlockHandler
```

`ExternalShuffleService` creates an [ExternalBlockHandler](ExternalBlockHandler.md) when [created](#creating-instance).

With [spark.shuffle.service.db.enabled](configuration-properties.md#spark.shuffle.service.db.enabled) and [spark.shuffle.service.enabled](#enabled) configuration properties enabled, the `ExternalBlockHandler` is given a [local directory with a registeredExecutors.ldb file](#findRegisteredExecutorsDBFile).

`blockHandler` is used to create a [TransportContext](../network/TransportContext.md) that creates the [TransportServer](#server).

`blockHandler` is used when:

* [applicationRemoved](#applicationRemoved)
* [executorRemoved](#executorRemoved)

### <span id="findRegisteredExecutorsDBFile"> findRegisteredExecutorsDBFile

```scala
findRegisteredExecutorsDBFile(
  dbName: String): File
```

`findRegisteredExecutorsDBFile` returns one of the local directories (defined using [spark.local.dir](../configuration-properties.md#spark.local.dir) configuration property) with the input `dbName` file or `null` when no directories defined.

`findRegisteredExecutorsDBFile` searches the local directories (defined using [spark.local.dir](../configuration-properties.md#spark.local.dir) configuration property) for the input `dbName` file. Unless found, `findRegisteredExecutorsDBFile` takes the first local directory.

With no local directories defined in [spark.local.dir](../configuration-properties.md#spark.local.dir) configuration property, `findRegisteredExecutorsDBFile` prints out the following WARN message to the logs and returns `null`.

```text
'spark.local.dir' should be set first when we use db in ExternalShuffleService. Note that this only affects standalone mode.
```

## <span id="start"> Starting ExternalShuffleService

```scala
start(): Unit
```

`start` prints out the following INFO message to the logs:

```text
Starting shuffle service on port [port] (auth enabled = [authEnabled])
```

`start` creates a `AuthServerBootstrap` with authentication enabled (using [SecurityManager](#securityManager)).

`start` creates a [TransportContext](../network/TransportContext.md) (with the [ExternalBlockHandler](#blockHandler)) and requests it to [create a server](../network/TransportContext.md#createServer) (on the [port](#port)).

`start`...FIXME

`start` is used when:

* `ExternalShuffleService` is requested to [startIfEnabled](#startIfEnabled) and is [launched](#launch) (as a command-line application)

## <span id="startIfEnabled"> startIfEnabled

```scala
startIfEnabled(): Unit
```

`startIfEnabled` [starts](#start) the external shuffle service if [enabled](#enabled).

`startIfEnabled` is used when:

* `Worker` (Spark Standalone) is requested to `startExternalShuffleService`

## <span id="executorRemoved"> Executor Removed Notification

```scala
executorRemoved(
  executorId: String,
  appId: String): Unit
```

`executorRemoved` requests the [ExternalBlockHandler](#blockHandler) to [executorRemoved](ExternalBlockHandler.md#executorRemoved).

`executorRemoved` is used when:

* `Worker` (Spark Standalone) is requested to [handleExecutorStateChanged](../spark-standalone/Worker.md#handleExecutorStateChanged)

## <span id="applicationRemoved"> Application Finished Notification

```scala
applicationRemoved(
  appId: String): Unit
```

`applicationRemoved` requests the [ExternalBlockHandler](#blockHandler) to [applicationRemoved](ExternalBlockHandler.md#applicationRemoved) (with `cleanupLocalDirs` flag enabled).

`applicationRemoved` is used when:

* `Worker` (Spark Standalone) is requested to handle [WorkDirCleanup](../spark-standalone/Worker.md#WorkDirCleanup) message and [maybeCleanupApplication](../spark-standalone/Worker.md#maybeCleanupApplication)

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.ExternalShuffleService` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.ExternalShuffleService=ALL
```

Refer to [Logging](../spark-logging.md).
