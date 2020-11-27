= BroadcastFactory

*BroadcastFactory* is an <<contract, abstraction>> for <<implementations, factories>> that core:BroadcastManager.md[BroadcastManager] uses for Broadcast.md[].

NOTE: As of https://issues.apache.org/jira/browse/SPARK-12588[Spark 2.0], it is no longer possible to plug a custom BroadcastFactory in, and core:TorrentBroadcastFactory.md[TorrentBroadcastFactory] is the one and only known implementation.

== [[contract]] Contract

=== [[initialize]] initialize Method

[source,scala]
----
initialize(
  isDriver: Boolean,
  conf: SparkConf,
  securityMgr: SecurityManager): Unit
----

Used when BroadcastManager is BroadcastManager.md#creating-instance[created].

=== [[newBroadcast]] newBroadcast Method

[source,scala]
----
newBroadcast[T: ClassTag](
  value: T,
  isLocal: Boolean,
  id: Long): Broadcast[T]
----

Used when BroadcastManager is requested for a BroadcastManager.md#newBroadcast[new broadcast variable].

=== [[stop]] stop Method

[source,scala]
----
stop(): Unit
----

Used when BroadcastManager is requested to BroadcastManager.md#stop[stop].

=== [[unbroadcast]] unbroadcast Method

[source,scala]
----
unbroadcast(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
----

Used when BroadcastManager is requested to BroadcastManager.md#unbroadcast[unbroadcast a broadcast variable].

== [[implementations]] Available BroadcastFactories

core:TorrentBroadcastFactory.md[TorrentBroadcastFactory] is the default and only known BroadcastFactory in Apache Spark.
