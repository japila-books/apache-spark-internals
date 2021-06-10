# ElementTrackingStore

`ElementTrackingStore` is a [KVStore](../core/KVStore.md) that tracks the number of entities (_elements_) of specific types in a [store](#store) and triggers actions once they reach a threshold.

## Creating Instance

`ElementTrackingStore` takes the following to be created:

* <span id="store"> [KVStore](../core/KVStore.md)
* <span id="conf"> [SparkConf](../SparkConf.md)

`ElementTrackingStore` is created when:

* `AppStatusStore` is requested to [createLiveStore](AppStatusStore.md#createLiveStore)
* `FsHistoryProvider` is requested to [rebuildAppStore](../history-server/FsHistoryProvider.md#rebuildAppStore)

## <span id="write"> Writing Value to Store

```scala
write(
  value: Any): Unit
```

`write` is part of the [KVStore](../core/KVStore.md#write) abstraction.

`write` requests the [KVStore](#store) to [write the value](../core/KVStore.md#write)

## <span id="write-checkTriggers"> Writing Value to Store and Checking Triggers

```scala
write(
  value: Any,
  checkTriggers: Boolean): WriteQueueResult
```

`write` [writes the value](#write).

`write`...FIXME

`write` is used when:

* `LiveEntity` is requested to [write](LiveEntity.md#write)
* `StreamingQueryStatusListener` (Spark Structured Streaming) is requested to `onQueryStarted` and `onQueryTerminated`

## <span id="view"> Creating View of Specific Entities

```scala
view[T](
  klass: Class[T]): KVStoreView[T]
```

`view` is part of the [KVStore](../core/KVStore.md#view) abstraction.

`view` requests the [KVStore](#store) for a [view](../core/KVStore.md#view) of `klass` entities.

## <span id="addTrigger"> Registering Trigger

```scala
addTrigger(
  klass: Class[_],
  threshold: Long)(
  action: Long => Unit): Unit
```

`addTrigger`...FIXME

`addTrigger` is used when:

* `AppStatusListener` is [created](AppStatusListener.md#kvstore)
* `HiveThriftServer2Listener` (Spark Thrift Server) is created
* `SQLAppStatusListener` (Spark SQL) is created
* `StreamingQueryStatusListener` (Spark Structured Streaming) is created
