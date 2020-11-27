# BroadcastManager

`BroadcastManager` is a Spark service to manage Broadcast.md[]s in a Spark application.

[BroadcastManager, SparkEnv and BroadcastFactory](../images/core/BroadcastManager.png)

BroadcastManager assigns <<nextBroadcastId, unique identifiers>> to broadcast variables.

BroadcastManager is used to create a scheduler:MapOutputTrackerMaster.md#BroadcastManager[MapOutputTrackerMaster]

== [[creating-instance]] Creating Instance

BroadcastManager takes the following to be created:

* <<isDriver, isDriver>> flag
* [[conf]] SparkConf.md[SparkConf]
* [[securityManager]] SecurityManager

When created, BroadcastManager <<initialize, initializes>>.

BroadcastManager is created when SparkEnv is core:SparkEnv.md[created] (for the driver and executors and hence the need for the <<isDriver, isDriver>> flag).

== [[isDriver]] isDriver Flag

BroadcastManager is given `isDriver` flag when <<creating-instance, created>>.

The isDriver flag indicates whether the initialization happens on the driver (`true`) or executors (`false`).

BroadcastManager uses the flag when requested to <<initialize, initialize>> for the <<broadcastFactory, TorrentBroadcastFactory>> to TorrentBroadcastFactory.md#initialize[initialize].

== [[broadcastFactory]] TorrentBroadcastFactory

BroadcastManager manages a core:BroadcastFactory.md[BroadcastFactory]:

* It is created and initialized in <<initialize, initialize>>

* It is stopped in <<stop, stop>> (and that is all it does)

BroadcastManager uses the BroadcastFactory when requested to <<newBroadcast, newBroadcast>> and <<unbroadcast, unbroadcast>>.

== [[cachedValues]] cachedValues Registry

[source,scala]
----
cachedValues: ReferenceMap
----

== [[nextBroadcastId]] Unique Identifiers of Broadcast Variables

BroadcastManager tracks broadcast variables and controls their identifiers.

Every <<newBroadcast, newBroadcast>> is given a new and unique identifier.

== [[initialize]][[initialized]] Initializing BroadcastManager

[source, scala]
----
initialize(): Unit
----

initialize creates a <<broadcastFactory, TorrentBroadcastFactory>> and requests it to core:TorrentBroadcastFactory.md#initialize[initialize].

initialize turns `initialized` internal flag on to guard against multiple initializations. With the initialized flag already enabled, initialize does nothing.

initialize is used once when BroadcastManager is <<creating-instance, created>>.

== [[stop]] Stopping BroadcastManager

[source, scala]
----
stop(): Unit
----

stop requests the <<broadcastFactory, BroadcastFactory>> to core:BroadcastFactory.md#stop[stop].

== [[newBroadcast]] Creating Broadcast Variable

[source, scala]
----
newBroadcast[T](
  value_ : T,
  isLocal: Boolean): Broadcast[T]
----

newBroadcast requests the core:BroadcastFactory.md[current `BroadcastFactory` for a new broadcast variable].

The `BroadcastFactory` is created when <<initialize, BroadcastManager is initialized>>.

newBroadcast is used when:

* MapOutputTracker utility is used to scheduler:MapOutputTracker.md#serializeMapStatuses[serializeMapStatuses]

* SparkContext is requested for a SparkContext.md#broadcast[new broadcast variable]
