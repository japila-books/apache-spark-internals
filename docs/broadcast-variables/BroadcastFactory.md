# BroadcastFactory

`BroadcastFactory` is an [abstraction](#contract) of [broadcast variable factories](#implementations) that [BroadcastManager](BroadcastManager.md) uses to [create](#newBroadcast) or [delete](#unbroadcast) broadcast variables.

## Contract

### <span id="initialize"> Initializing

```scala
initialize(
  isDriver: Boolean,
  conf: SparkConf): Unit
```

Used when:

* `BroadcastManager` is requested to [initialize](BroadcastManager.md#initialize)

### <span id="newBroadcast"> Creating Broadcast Variable

```scala
newBroadcast(
  value: T,
  isLocal: Boolean,
  id: Long): Broadcast[T]
```

Used when:

* `BroadcastManager` is requested for a [new broadcast variable](BroadcastManager.md#newBroadcast)

### <span id="stop"> Stopping

```scala
stop(): Unit
```

Used when:

* `BroadcastManager` is requested to [stop](BroadcastManager.md#stop)

### <span id="unbroadcast"> Deleting Broadcast Variable

```scala
unbroadcast(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
```

Used when:

* `BroadcastManager` is requested to [delete a broadcast variable](BroadcastManager.md#unbroadcast)

## Implementations

* [TorrentBroadcastFactory](TorrentBroadcastFactory.md)
