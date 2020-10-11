# SparkListenerBus

`SparkListenerBus` is a `private[spark]` <<ListenerBus, ListenerBus>> for ROOT:SparkListener.md#SparkListenerInterface[SparkListenerInterface] listeners that process ROOT:SparkListener.md#SparkListenerEvent[SparkListenerEvent] events.

`SparkListenerBus` comes with a custom `doPostEvent` method that simply relays `SparkListenerEvent` events to appropriate `SparkListenerInterface` methods.

NOTE: There are two custom `SparkListenerBus` listeners: scheduler:LiveListenerBus.md[] and spark-history-server:ReplayListenerBus.md[].

.SparkListenerEvent to SparkListenerInterface's Method "mapping"
[width="100%",options="header"]
|===
|SparkListenerEvent |SparkListenerInterface's Method
|`SparkListenerStageSubmitted` | `onStageSubmitted`
|`SparkListenerStageCompleted` | `onStageCompleted`
|`SparkListenerJobStart`       | `onJobStart`
|`SparkListenerJobEnd`         | `onJobEnd`
| `SparkListenerJobEnd` | `onJobEnd`
| `SparkListenerTaskStart` | `onTaskStart`
| `SparkListenerTaskGettingResult` | `onTaskGettingResult`
| ROOT:SparkListener.md#SparkListenerTaskEnd[SparkListenerTaskEnd] | `onTaskEnd`
| `SparkListenerEnvironmentUpdate` | `onEnvironmentUpdate`
| `SparkListenerBlockManagerAdded` | `onBlockManagerAdded`
| `SparkListenerBlockManagerRemoved` | `onBlockManagerRemoved`
| `SparkListenerUnpersistRDD` | `onUnpersistRDD`
| `SparkListenerApplicationStart` | `onApplicationStart`
| `SparkListenerApplicationEnd` | `onApplicationEnd`
| `SparkListenerExecutorMetricsUpdate` | `onExecutorMetricsUpdate`
| `SparkListenerExecutorAdded` | `onExecutorAdded`
| `SparkListenerExecutorRemoved` | `onExecutorRemoved`
| `SparkListenerBlockUpdated` | `onBlockUpdated`
| `SparkListenerLogStart` | _event ignored_
| _other event types_ | `onOtherEvent`
|===

== [[ListenerBus]][[ListenerBus-addListener]][[ListenerBus-doPostEvent]] `ListenerBus` Event Bus Contract

[source, scala]
----
ListenerBus[L <: AnyRef, E]
----

`ListenerBus` is an event bus that post events (of type `E`) to all registered listeners (of type `L`).

It manages `listeners` of type `L`, i.e. it can add to and remove listeners from an internal `listeners` collection.

[source, scala]
----
addListener(listener: L): Unit
removeListener(listener: L): Unit
----

It can post events of type `E` to all registered listeners (using `postToAll` method). It simply iterates over the internal `listeners` collection and executes the abstract `doPostEvent` method.

[source, scala]
----
doPostEvent(listener: L, event: E): Unit
----

NOTE: `doPostEvent` is provided by more specialized `ListenerBus` event buses.

In case of exception while posting an event to a listener you should see the following ERROR message in the logs and the exception.

```
ERROR Listener [listener] threw an exception
```

NOTE: There are three custom `ListenerBus` listeners: <<SparkListenerBus, SparkListenerBus>>, spark-sql-streaming-StreamingQueryListenerBus.md[StreamingQueryListenerBus], and spark-streaming/spark-streaming-jobscheduler.md#StreamingListenerBus[StreamingListenerBus].

[TIP]
====
Enable `ERROR` logging level for `org.apache.spark.util.ListenerBus` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.util.ListenerBus=ERROR
```

Refer to spark-logging.md[Logging].
====
