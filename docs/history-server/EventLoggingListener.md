# EventLoggingListener

`EventLoggingListener` is a [SparkListener](../SparkListener.md) that [writes out JSON-encoded events](#logEvent) of a Spark application with event logging enabled (based on [spark.eventLog.enabled](../configuration-properties.md#spark.eventLog.enabled) configuration property).

`EventLoggingListener` supports custom [configuration properties](configuration-properties.md#EventLoggingListener).

`EventLoggingListener` writes out log files to a directory (based on [spark.eventLog.dir](configuration-properties.md#spark.eventLog.dir) configuration property).

## Creating Instance

`EventLoggingListener` takes the following to be created:

* <span id="appId"> Application ID
* <span id="appAttemptId"> Application Attempt ID
* <span id="logBaseDir"> Log Directory
* <span id="sparkConf"> [SparkConf](../SparkConf.md)
* <span id="hadoopConf"> Hadoop [Configuration]({{ hadoop.api }}/org/apache/hadoop/conf/Configuration.html)

`EventLoggingListener` is created when `SparkContext` is [created](../SparkContext-creating-instance-internals.md#_eventLogger) (with [spark.eventLog.enabled](configuration-properties.md#spark.eventLog.enabled) enabled).

## <span id="logWriter"> EventLogFileWriter

```scala
logWriter: EventLogFileWriter
```

`EventLoggingListener` creates a [EventLogFileWriter](EventLogFileWriter.md) when [created](#creating-instance).

!!! note
    All arguments to [create an EventLoggingListener](#creating-instance) are passed to the `EventLogFileWriter`.

The `EventLogFileWriter` is [started](EventLogFileWriter.md#start) when `EventLoggingListener` is [started](#start).

The `EventLogFileWriter` is [stopped](EventLogFileWriter.md#stop) when `EventLoggingListener` is [stopped](#stop).

The `EventLogFileWriter` is requested to [writeEvent](EventLogFileWriter.md#writeEvent) when `EventLoggingListener` is requested to [start](#start) and [log an event](#logEvent).

## <span id="start"> Starting EventLoggingListener

```scala
start(): Unit
```

`start` requests the [EventLogFileWriter](#logWriter) to [start](EventLogFileWriter.md#start) and [initEventLog](#initEventLog).

### <span id="initEventLog"> initEventLog

```scala
initEventLog(): Unit
```

`initEventLog`...FIXME

## <span id="logEvent"> Logging Event

```scala
logEvent(
  event: SparkListenerEvent,
  flushLogger: Boolean = false): Unit
```

`logEvent` persists the given [SparkListenerEvent](../SparkListenerEvent.md) in JSON format.

`logEvent` [converts the event to JSON format](JsonProtocol.md#sparkEventToJson) and requests the [EventLogFileWriter](#logWriter) to [write it out](#writeEvent).

## <span id="stop"> Stopping EventLoggingListener

```scala
stop(): Unit
```

`stop` requests the [EventLogFileWriter](#logWriter) to [stop](EventLogFileWriter.md#stop).

`stop` is used when `SparkContext` is requested to [stop](../SparkContext.md#stop).

## <span id="inprogress-extension"><span id="IN_PROGRESS"> inprogress File Extension

`EventLoggingListener` uses **.inprogress** file extension for in-flight event log files of active Spark applications.

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.EventLoggingListener` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.EventLoggingListener=ALL
```

Refer to [Logging](../spark-logging.md).
