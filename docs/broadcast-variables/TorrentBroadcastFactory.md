# TorrentBroadcastFactory

`TorrentBroadcastFactory` is a [BroadcastFactory](BroadcastFactory.md) of [TorrentBroadcast](TorrentBroadcast.md)s.

!!! note
    As of [Spark 2.0](https://issues.apache.org/jira/browse/SPARK-12588) `TorrentBroadcastFactory` is the only known [BroadcastFactory](BroadcastFactory.md).

## Creating Instance

`TorrentBroadcastFactory` takes no arguments to be created.

`TorrentBroadcastFactory` is created for [BroadcastManager](BroadcastManager.md#broadcastFactory).

## <span id="newBroadcast"> Creating Broadcast Variable

```scala
newBroadcast(
  value_ : T,
  isLocal: Boolean,
  id: Long): Broadcast[T]
```

`newBroadcast` creates a new [TorrentBroadcast](TorrentBroadcast.md) with the given `value_` and `id` (and ignoring `isLocal`).

`newBroadcast` is part of the [BroadcastFactory](BroadcastFactory.md#newBroadcast) abstraction.

## <span id="unbroadcast"> Deleting Broadcast Variable

```scala
unbroadcast(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
```

`unbroadcast` [removes all persisted state associated with the broadcast variable](TorrentBroadcast.md#unpersist) (identified by `id`).

`unbroadcast` is part of the [BroadcastFactory](BroadcastFactory.md#unbroadcast) abstraction.

## <span id="initialize"> Initializing

```scala
initialize(
  isDriver: Boolean,
  conf: SparkConf): Unit
```

`initialize` does nothing (_noop_).

`initialize` is part of the [BroadcastFactory](BroadcastFactory.md#initialize) abstraction.

## <span id="stop"> Stopping

```scala
stop(): Unit
```

`stop` does nothing (_noop_).

`stop` is part of the [BroadcastFactory](BroadcastFactory.md#stop) abstraction.
