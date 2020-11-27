# LiveListenerBus

`LiveListenerBus` is an event bus to dispatch Spark events to registered [SparkListener](../SparkListener.md)s.

![LiveListenerBus, SparkListenerEvents, and Senders](../images/scheduler/spark-sparklistener-event-senders.png)

`LiveListenerBus` is a single-JVM [SparkListenerBus](../SparkListenerBus.md) that uses [listenerThread to poll events](#listenerThread).

!!! note
    The event queue is [java.util.concurrent.LinkedBlockingQueue]({{ java.api }}/java.base/java/util/concurrent/LinkedBlockingQueue.html) with capacity of 10000 `SparkListenerEvent` events.

## Creating Instance

`LiveListenerBus` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)

`LiveListenerBus` is created (and [started](#start)) when `SparkContext` is requested to [initialize](../SparkContext.md#listenerBus).

## <span id="queues"> Event Queues

```scala
queues: CopyOnWriteArrayList[AsyncEventQueue]
```

`LiveListenerBus` manages [AsyncEventQueue](../AsyncEventQueue.md)s.

`queues` is initialized empty when `LiveListenerBus` is [created](#creating-instance).

`queues` is used when:

* [Registering Listener with Queue](#addToQueue)
* [Posting Event to All Queues](#post)
* [Deregistering Listener](#removeListener)
* [Starting LiveListenerBus](#start)

## <span id="metrics"> LiveListenerBusMetrics

```scala
metrics: LiveListenerBusMetrics
```

`LiveListenerBus` creates a `LiveListenerBusMetrics` when [created](#creating-instance).

`metrics` is registered (with a [MetricsSystem](../metrics/MetricsSystem.md)) when `LiveListenerBus` is [started](#start).

`metrics` is used to:

* Increment events posted every [event posting](#post)
* Create a [AsyncEventQueue](../AsyncEventQueue.md) when [adding a listener to a queue](#addToQueue)

## <span id="start"> Starting LiveListenerBus

```scala
start(
  sc: SparkContext,
  metricsSystem: MetricsSystem): Unit
```

`start` starts [AsyncEventQueue](../AsyncEventQueue.md)s (from the [queues](#queues) internal registry).

In the end, `start` requests the given [MetricsSystem](../metrics/MetricsSystem.md) to [register](../metrics/MetricsSystem.md#registerSource) the [LiveListenerBusMetrics](#metrics).

`start` is used when:

* `SparkContext` is [created](../SparkContext-creating-instance-internals.md#setupAndStartListenerBus)

## <span id="post"> Posting Event to All Queues

```scala
post(
  event: SparkListenerEvent): Unit
```

`post` puts the input `event` onto the internal `eventQueue` queue and releases the internal `eventLock` semaphore. If the event placement was not successful (and it could happen since it is tapped at 10000 events) [onDropEvent](#onDropEvent) method is called.

The event publishing is only possible when `stopped` flag has been enabled.

`post` is used when...FIXME

### <span id="postToQueues"> postToQueues

```scala
postToQueues(
  event: SparkListenerEvent): Unit
```

`postToQueues`...FIXME

## <span id="onDropEvent"> Event Dropped Callback

```scala
onDropEvent(
  event: SparkListenerEvent): Unit
```

`onDropEvent` is called when no further events can be added to the internal `eventQueue` queue (while [posting a SparkListenerEvent event](#post)).

It simply prints out the following ERROR message to the logs and ensures that it happens only once.

```text
Dropping SparkListenerEvent because no remaining room in event queue. This likely means one of the SparkListeners is too slow and cannot keep up with the rate at which tasks are being started by the scheduler.
```

## <span id="stop"> Stopping LiveListenerBus

```scala
stop(): Unit
```

`stop` releases the internal `eventLock` semaphore and waits until [listenerThread](#listenerThread) dies. It can only happen after all events were posted (and polling `eventQueue` gives nothing).

`stopped` flag is enabled.

## <span id="listenerThread"> listenerThread for Event Polling

`LiveListenerBus` uses a [SparkListenerBus](../SparkListenerBus.md) single-daemon thread that ensures that the polling events from the event queue is only after the [listener was started](#start) and only one event at a time.

## <span id="addToStatusQueue"> Registering Listener with Status Queue

```scala
addToStatusQueue(
  listener: SparkListenerInterface): Unit
```

`addToStatusQueue` [adds](#addToQueue) the given [SparkListenerInterface](../SparkListenerInterface.md) to [appStatus](#APP_STATUS_QUEUE) queue.

`addToStatusQueue` is used when:

* `BarrierCoordinator` is requested to `onStart`
* `SparkContext` is [created](../SparkContext-creating-instance-internals.md#_statusStore)
* `HiveThriftServer2` utility is used to `createListenerAndUI`
* `SharedState` ([Spark SQL]({{ book.spark_sql }}/SharedState/)) is requested to create a SQLAppStatusStore

## <span id="addToSharedQueue"> Registering Listener with Shared Queue

```scala
addToSharedQueue(
  listener: SparkListenerInterface): Unit
```

`addToSharedQueue` [adds](#addToQueue) the given [SparkListenerInterface](../SparkListenerInterface.md) to [shared](#SHARED_QUEUE) queue.

`addToSharedQueue` is used when:

* `SparkContext` is requested to [register a SparkListener](../SparkContext.md#addSparkListener) and [register extra SparkListeners](../SparkContext.md#setupAndStartListenerBus)
* `ExecutionListenerBus` (Spark Structured Streaming) is created

## <span id="addToManagementQueue"> Registering Listener with executorManagement Queue

```scala
addToManagementQueue(
  listener: SparkListenerInterface): Unit
```

`addToManagementQueue` [adds](#addToQueue) the given [SparkListenerInterface](../SparkListenerInterface.md) to [executorManagement](#EXECUTOR_MANAGEMENT_QUEUE) queue.

`addToManagementQueue` is used when:

* `ExecutorAllocationManager` is requested to [start](../dynamic-allocation/ExecutorAllocationManager.md#start)
* `HeartbeatReceiver` is [created](../HeartbeatReceiver.md#creating-instance)

## <span id="addToEventLogQueue"> Registering Listener with eventLog Queue

```scala
addToEventLogQueue(
  listener: SparkListenerInterface): Unit
```

`addToEventLogQueue` [adds](#addToQueue) the given [SparkListenerInterface](../SparkListenerInterface.md) to [eventLog](#EVENT_LOG_QUEUE) queue.

`addToEventLogQueue` is used when:

* `SparkContext` is [created](../SparkContext-creating-instance-internals.md#_eventLogger) (with event logging enabled)

## <span id="addToQueue"> Registering Listener with Queue

```scala
addToQueue(
  listener: SparkListenerInterface,
  queue: String): Unit
```

`addToQueue` finds the queue in the [queues](#queues) internal registry.

If found, `addToQueue` requests it to [add the given listener](../ListenerBus.md#addListener)

If not found, `addToQueue` creates a [AsyncEventQueue](../AsyncEventQueue.md) (with the given name, the [LiveListenerBusMetrics](#metrics), and this `LiveListenerBus`) and requests it to [add the given listener](../ListenerBus.md#addListener). The `AsyncEventQueue` is [started](../AsyncEventQueue.md#start) and added to the [queues](#queues) internal registry.

`addToQueue` is used when:

* `LiveListenerBus` is requested to [addToSharedQueue](#addToSharedQueue), [addToManagementQueue](#addToManagementQueue), [addToStatusQueue](#addToStatusQueue), [addToEventLogQueue](#addToEventLogQueue)
* `StreamingQueryListenerBus` ([Spark Structured Streaming]({{ book.structured_streaming }}/StreamingQueryListenerBus/)) is created

## <span id="removeListener"> Deregistering Listener

```scala
removeListener(
  listener: SparkListenerInterface): Unit
```

`removeListener`...FIXME

`removeListener` is used when:

* `BarrierCoordinator` is requested to `onStop`
* `SparkContext` is requested to [deregister a SparkListener](../SparkContext.md#removeSparkListener)
* `AsyncEventQueue` is requested to [deregister a listener on error](../AsyncEventQueue.md#removeListenerOnError)
