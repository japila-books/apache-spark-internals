---
tags:
  - DeveloperApi
---

# SparkListener

`SparkListener` is an extension of the [SparkListenerInterface](SparkListenerInterface.md) abstraction for [event listeners](#implementations) with a no-op implementation for callback methods.

## Implementations

* BarrierCoordinator
* SparkSession ([Spark SQL]({{ book.spark_sql }}/SparkSession/#registerContextListener))
* AppListingListener (Spark History Server)
* [AppStatusListener](status/AppStatusListener.md)
* BasicEventFilterBuilder (Spark History Server)
* [EventLoggingListener](history-server/EventLoggingListener.md) (Spark History Server)
* ExecutionListenerBus
* [ExecutorAllocationListener](dynamic-allocation/ExecutorAllocationListener.md)
* ExecutorMonitor
* [HeartbeatReceiver](HeartbeatReceiver.md)
* HiveThriftServer2Listener (Spark Thrift Server)
* [SpillListener](SpillListener.md)
* SQLAppStatusListener ([Spark SQL]({{ book.spark_sql }}/SQLAppStatusListener/))
* SQLEventFilterBuilder
* [StatsReportListener](StatsReportListener.md)
* StreamingQueryListenerBus ([Spark Structured Streaming]({{ book.structured_streaming }}/StreamingQueryListenerBus/))
