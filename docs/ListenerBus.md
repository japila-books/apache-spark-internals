# ListenerBus

`ListenerBus` is an [abstraction](#contract) of [event buses](#implementations) that can [notify listeners about scheduling events](#doPostEvent).

## Contract

### <span id="doPostEvent"> Notifying Listener about Event

```scala
doPostEvent(
  listener: L,
  event: E): Unit
```

Used when `ListenerBus` is requested to [postToAll](#postToAll)

## Implementations

* ExecutionListenerBus
* ExternalCatalogWithListener
* [SparkListenerBus](SparkListenerBus.md)
* StreamingListenerBus
* StreamingQueryListenerBus

## <span id="postToAll"> Posting Event To All Listeners

```scala
postToAll(
  event: E): Unit
```

`postToAll`...FIXME

`postToAll` is used when:

* `AsyncEventQueue` is requested to [dispatch an event](AsyncEventQueue.md#dispatch)
* `ReplayListenerBus` is requested to [replay events](history-server/ReplayListenerBus.md#replay)

## <span id="addListener"> Registering Listener

```scala
addListener(
  listener: L): Unit
```

`addListener`...FIXME

`addListener` is used when:

* `LiveListenerBus` is requested to [addToQueue](scheduler/LiveListenerBus.md#addToQueue)
* `EventLogFileCompactor` is requested to `initializeBuilders`
* `FsHistoryProvider` is requested to [doMergeApplicationListing](history-server/FsHistoryProvider.md#doMergeApplicationListing) and [rebuildAppStore](history-server/FsHistoryProvider.md#rebuildAppStore)
