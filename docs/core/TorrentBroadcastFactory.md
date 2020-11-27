= TorrentBroadcastFactory

*TorrentBroadcastFactory* is a core:BroadcastFactory.md[BroadcastFactory] of core:TorrentBroadcast.md[TorrentBroadcast]s (for BitTorrent-like Broadcast.md[]s).

NOTE: As of https://issues.apache.org/jira/browse/SPARK-12588[Spark 2.0] TorrentBroadcastFactory is is the one and only known core:BroadcastFactory.md[BroadcastFactory].

== [[creating-instance]] Creating Instance

TorrentBroadcastFactory takes no arguments to be created.

TorrentBroadcastFactory is created for BroadcastManager.md#broadcastFactory[BroadcastManager].

== [[newBroadcast]] Creating Broadcast Variable (TorrentBroadcast)

[source,scala]
----
newBroadcast[T: ClassTag](
  value_ : T,
  isLocal: Boolean,
  id: Long): Broadcast[T]
----

newBroadcast creates a core:TorrentBroadcast.md[] (for the given `value_` and `id` and ignoring the `isLocal` flag).

newBroadcast is part of the BroadcastFactory.md#newBroadcast[BroadcastFactory] abstraction.

== [[unbroadcast]] Unbroadcasting Broadcast Variable

[source,scala]
----
unbroadcast(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
----

unbroadcast core:TorrentBroadcast.md#unpersist[removes all persisted state associated with the TorrentBroadcast] (by the given id).

unbroadcast is part of the BroadcastFactory.md#unbroadcast[BroadcastFactory] abstraction.

== [[initialize]] Initializing TorrentBroadcastFactory

[source,scala]
----
initialize(
  isDriver: Boolean,
  conf: SparkConf,
  securityMgr: SecurityManager): Unit
----

initialize does nothing.

initialize is part of the BroadcastFactory.md#initialize[BroadcastFactory] abstraction.

== [[stop]] Stopping TorrentBroadcastFactory

[source,scala]
----
stop(): Unit
----

stop does nothing.

stop is part of the BroadcastFactory.md#stop[BroadcastFactory] abstraction.
