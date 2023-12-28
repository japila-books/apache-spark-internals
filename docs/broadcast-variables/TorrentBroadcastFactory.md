# TorrentBroadcastFactory

`TorrentBroadcastFactory` is a [BroadcastFactory](BroadcastFactory.md) of [TorrentBroadcast](TorrentBroadcast.md)s.

!!! note
    As of [Spark 2.0](https://issues.apache.org/jira/browse/SPARK-12588) `TorrentBroadcastFactory` is the only known [BroadcastFactory](BroadcastFactory.md).

## Creating Instance

`TorrentBroadcastFactory` takes no arguments to be created.

`TorrentBroadcastFactory` is created for [BroadcastManager](BroadcastManager.md#broadcastFactory).

## Creating Broadcast Variable { #newBroadcast }

??? note "BroadcastFactory"

    ```scala
    newBroadcast[T: ClassTag](
      value_ : T,
      isLocal: Boolean,
      id: Long,
      serializedOnly: Boolean = false): Broadcast[T]
    ```

    `newBroadcast` is part of the [BroadcastFactory](BroadcastFactory.md#newBroadcast) abstraction.

`newBroadcast` creates a new [TorrentBroadcast](TorrentBroadcast.md) with the given `value_` and `id` (and ignoring `isLocal`).

## Deleting Broadcast Variable { #unbroadcast }

??? note "BroadcastFactory"

    ```scala
    unbroadcast(
      id: Long,
      removeFromDriver: Boolean,
      blocking: Boolean): Unit
    ```

    `unbroadcast` is part of the [BroadcastFactory](BroadcastFactory.md#unbroadcast) abstraction.

`unbroadcast` [removes all persisted state associated with the broadcast variable](TorrentBroadcast.md#unpersist) (identified by `id`).

## Initializing { #initialize }

??? note "BroadcastFactory"

    ```scala
    initialize(
      isDriver: Boolean,
      conf: SparkConf): Unit
    ```

    `initialize` is part of the [BroadcastFactory](BroadcastFactory.md#initialize) abstraction.

`initialize` does nothing (_noop_).

## Stopping { #stop }

??? note "BroadcastFactory"

    ```scala
    stop(): Unit
    ```

    `stop` is part of the [BroadcastFactory](BroadcastFactory.md#stop) abstraction.

`stop` does nothing (_noop_).
