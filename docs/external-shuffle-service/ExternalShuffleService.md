# ExternalShuffleService

`ExternalShuffleService` is a Spark service that can serve RDD and shuffle blocks.

`ExternalShuffleService` manages shuffle output files so they are available to executors. As the shuffle output files are managed externally to the executors it offers an uninterrupted access to the shuffle output files regardless of executors being killed or down (esp. with [Dynamic Allocation of Executors](../dynamic-allocation/index.md)).

`ExternalShuffleService` is a standalone application that can be [launched from command line](#launching-externalshuffleservice).

`ExternalShuffleService` is enabled on the driver and executors using [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property.

!!! note
    Spark on YARN uses a custom external shuffle service (`YarnShuffleService`).

## Launching ExternalShuffleService

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

`main` turns [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) to `true` explicitly (since this service is started from the command line for a reason).

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

* `ExternalShuffleService` standalone application is [started](#launching-externalshuffleservice)
* `Worker` (Spark Standalone) is created (and initializes an `ExternalShuffleService`)

## <span id="server"> TransportServer

```scala
server: TransportServer
```

`ExternalShuffleService` uses an internal reference to a [TransportServer](../network/TransportServer.md) that is created when `ExternalShuffleService` is [started](#start).

`ExternalShuffleService` uses an [ExternalBlockHandler](#blockHandler) to handle RPC messages (and serve RDD blocks and shuffle blocks).

`TransportServer` is [closed](../network/TransportServer.md#close) when `ExternalShuffleService` is requested to [stop](#stop).

`TransportServer` is used for metrics.

## <span id="port"><span id="spark.shuffle.service.port"> Port

`ExternalShuffleService` uses [spark.shuffle.service.port](../configuration-properties.md#spark.shuffle.service.port) configuration property for the port to listen to when [started](#start).

## <span id="enabled"><span id="spark.shuffle.service.enabled"> spark.shuffle.service.enabled

`ExternalShuffleService` uses [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property to control whether or not is enabled (and should be [start](#startIfEnabled) when requested).

## <span id="blockHandler"><span id="newShuffleBlockHandler"><span id="getBlockHandler"> ExternalBlockHandler

```scala
blockHandler: ExternalBlockHandler
```

`ExternalShuffleService` creates an [ExternalBlockHandler](ExternalBlockHandler.md) when [created](#creating-instance).

`blockHandler` is used to create a [TransportContext](../network/TransportContext.md) that creates the [TransportServer](#server).

`blockHandler` is used when:

* [applicationRemoved](#applicationRemoved)
* [executorRemoved](#executorRemoved)

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

* `ExternalShuffleService` is requested to [startIfEnabled](#startIfEnabled) and is [launched](#launching-externalshuffleservice) (as a command-line application)

## <span id="startIfEnabled"> startIfEnabled

```scala
startIfEnabled(): Unit
```

`startIfEnabled` [starts](#start) the external shuffle service if [enabled](#enabled).

`startIfEnabled` is used when:

* `Worker` (Spark Standalone) is requested to `startExternalShuffleService`

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.ExternalShuffleService` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.ExternalShuffleService=ALL
```

Refer to [Logging](../spark-logging.md).
