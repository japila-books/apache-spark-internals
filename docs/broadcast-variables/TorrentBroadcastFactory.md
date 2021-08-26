# TorrentBroadcastFactory

`TorrentBroadcastFactory` is a [BroadcastFactory](BroadcastFactory.md) of [TorrentBroadcast](TorrentBroadcast.md)s (for BitTorrent-like broadcast variables).

!!! note
    As of [Spark 2.0](https://issues.apache.org/jira/browse/SPARK-12588) `TorrentBroadcastFactory` is the one and only known [BroadcastFactory](BroadcastFactory.md).

## Creating Instance

`TorrentBroadcastFactory` takes no arguments to be created.

`TorrentBroadcastFactory` is created for [BroadcastManager](BroadcastManager.md#broadcastFactory).

== [[newBroadcast]] Creating Broadcast Variable (TorrentBroadcast)

[source,scala]
----
newBroadcast[T: ClassTag](
  value_ : T,
  isLocal: Boolean,
  id: Long): Broadcast[T]
----

`newBroadcast` creates a [TorrentBroadcast](TorrentBroadcast.md) (for the given `value_` and `id` and ignoring the `isLocal` flag).

`newBroadcast` is part of the [BroadcastFactory](BroadcastFactory.md#newBroadcast) abstraction.

== [[unbroadcast]] Unbroadcasting Broadcast Variable

[source,scala]
----
unbroadcast(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
----

`unbroadcast` [removes all persisted state associated with the TorrentBroadcast](TorrentBroadcast.md#unpersist) (by the given `id`).

`unbroadcast` is part of the [BroadcastFactory](BroadcastFactory.md#unbroadcast) abstraction.
