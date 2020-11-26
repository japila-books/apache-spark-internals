# SparkListener

`SparkListener` is an extension of the [SparkListenerInterface](SparkListenerInterface.md) abstraction for [event listeners](#implementations).

is a mechanism in Spark to intercept events from the Spark scheduler that are emitted over the course of execution of a Spark application.

SparkListener extends <<SparkListenerInterface, SparkListenerInterface>> with all the _callback methods_ being no-op/do-nothing.

Spark <<builtin-implementations, relies on `SparkListeners` internally>> to manage communication between internal components in the distributed environment for a Spark application, e.g. spark-webui.md[web UI], spark-history-server:EventLoggingListener.md[event persistence] (for History Server), spark-ExecutorAllocationManager.md[dynamic allocation of executors], [keeping track of executors (using `HeartbeatReceiver`)](HeartbeatReceiver.md) and others.

You can develop your own custom SparkListener and register it using ROOT:SparkContext.md#addSparkListener[SparkContext.addSparkListener] method or ROOT:configuration-properties.md#spark.extraListeners[spark.extraListeners] configuration property.

With SparkListener you can focus on Spark events of your liking and process a subset of all scheduling events.

[TIP]
====
Enable `INFO` logging level for `org.apache.spark.SparkContext` logger to see when custom Spark listeners are registered.

```
INFO SparkContext: Registered listener org.apache.spark.scheduler.StatsReportListener
```

See ROOT:SparkContext.md[].
====

== [[builtin-implementations]] Built-In Spark Listeners

.Built-In Spark Listeners
[cols="1,2",options="header",width="100%"]
|===
| Spark Listener | Description
| spark-history-server:EventLoggingListener.md[EventLoggingListener] | Logs JSON-encoded events to a file that can later be read by spark-history-server:index.md[History Server]
| spark-SparkListener-StatsReportListener.md[StatsReportListener] |
| [[SparkFirehoseListener]] `SparkFirehoseListener` | Allows users to receive all <<SparkListenerEvent, SparkListenerEvent>> events by overriding the single `onEvent` method only.
| spark-SparkListener-ExecutorAllocationListener.md[ExecutorAllocationListener] |
| [HeartbeatReceiver](HeartbeatReceiver.md) |
| spark-streaming/spark-streaming-streaminglisteners.md#StreamingJobProgressListener[StreamingJobProgressListener] |
| spark-webui-executors-ExecutorsListener.md[ExecutorsListener] | Prepares information for spark-webui-executors.md[Executors tab] in spark-webui.md[web UI]
| spark-webui-StorageStatusListener.md[StorageStatusListener], spark-webui-RDDOperationGraphListener.md[RDDOperationGraphListener], spark-webui-EnvironmentListener.md[EnvironmentListener], spark-webui-BlockStatusListener.md[BlockStatusListener] and spark-webui-StorageListener.md[StorageListener] | For spark-webui.md[web UI]
| `SpillListener` |
| `ApplicationEventListener` |
| spark-sql-streaming-StreamingQueryListenerBus.md[StreamingQueryListenerBus] |
| spark-sql-SQLListener.md[SQLListener] / spark-history-server:SQLHistoryListener.md[SQLHistoryListener] | Support for spark-history-server:index.md[History Server]
| spark-streaming/spark-streaming-jobscheduler.md#StreamingListenerBus[StreamingListenerBus] |
| spark-webui-JobProgressListener.md[JobProgressListener] |
|===
