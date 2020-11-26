# SparkListenerBus

`SparkListenerBus` is an extension of the [ListenerBus](ListenerBus.md) abstraction for [event buses](#implementations) for [SparkListenerInterface](SparkListenerInterface.md)s to be notified about [SparkListenerEvent](SparkListenerEvent.md)s.

# <span id="doPostEvent"> Posting Event to SparkListener

```scala
doPostEvent(
  listener: SparkListenerInterface,
  event: SparkListenerEvent): Unit
```

`doPostEvent` is part of the [ListenerBus](ListenerBus.md#doPostEvent) abstraction.

`doPostEvent` notifies the given [SparkListenerInterface](SparkListenerInterface.md) about the [SparkListenerEvent](SparkListenerEvent.md).

`doPostEvent` calls an event-specific method of [SparkListenerInterface](SparkListenerInterface.md) or falls back to [onOtherEvent](SparkListenerInterface.md#onOtherEvent).

## Implementations

* [AsyncEventQueue](AsyncEventQueue.md)
* [ReplayListenerBus](history-server/ReplayListenerBus.md)
