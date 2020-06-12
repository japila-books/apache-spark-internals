= MapOutputTracker

*MapOutputTracker* is a base abstraction of <<extensions, shuffle map output location registries>> that can <<getMapSizesByExecutorId, find shuffle blocks by executor>> and <<unregisterShuffle, deregister map output status information of a shuffle stage>>.

MapOutputTracker is available using xref:core:SparkEnv.adoc#get[SparkEnv] (on the driver and executors).

[source, scala]
----
SparkEnv.get.mapOutputTracker
----

== [[extensions]] MapOutputTrackers

[cols="30,70",options="header",width="100%"]
|===
| MapOutputTracker
| Description

| xref:scheduler:MapOutputTrackerMaster.adoc[MapOutputTrackerMaster]
| [[MapOutputTrackerMaster]] Runs on the driver

| xref:scheduler:MapOutputTrackerWorker.adoc[MapOutputTrackerWorker]
| [[MapOutputTrackerWorker]] Runs on executors

|===

== [[creating-instance]][[conf]] Creating Instance

MapOutputTracker takes a single xref:ROOT:SparkConf.adoc[SparkConf] to be created.

== [[trackerEndpoint]][[ENDPOINT_NAME]] MapOutputTracker RPC Endpoint

trackerEndpoint is a xref:rpc:RpcEndpointRef.adoc[RpcEndpointRef] of the *MapOutputTracker* RPC endpoint.

trackerEndpoint is initialized (registered or looked up) when SparkEnv is xref:core:SparkEnv.adoc#create[created] for the driver and executors.

trackerEndpoint is used to <<askTracker, communicate (synchronously)>>.

trackerEndpoint is cleared (`null`) when MapOutputTrackerMaster is requested to xref:scheduler:MapOutputTrackerMaster.adoc#stop[stop].

== [[serializeMapStatuses]] serializeMapStatuses Utility

[source, scala]
----
serializeMapStatuses(
  statuses: Array[MapStatus],
  broadcastManager: BroadcastManager,
  isLocal: Boolean,
  minBroadcastSize: Int): (Array[Byte], Broadcast[Array[Byte]])
----

serializeMapStatuses serializes the given array of map output locations into an efficient byte format (to send to reduce tasks). serializeMapStatuses compresses the serialized bytes using GZIP. They are supposed to be pretty compressible because many map outputs will be on the same hostname.

Internally, serializeMapStatuses creates a Java {java-javadoc-url}/java/io/ByteArrayOutputStream.html[ByteArrayOutputStream].

serializeMapStatuses writes out 0 (direct) first.

serializeMapStatuses creates a Java {java-javadoc-url}/java/util/zip/GZIPOutputStream.html[GZIPOutputStream] (with the ByteArrayOutputStream created) and writes out the given statuses array.

serializeMapStatuses decides whether to return the output array (of the output stream) or use a broadcast variable based on the size of the byte array.

If the size of the result byte array is the given minBroadcastSize threshold or bigger, serializeMapStatuses requests the input BroadcastManager to xref:core:BroadcastManager.adoc#newBroadcast[create a broadcast variable].

serializeMapStatuses resets the ByteArrayOutputStream and starts over.

serializeMapStatuses writes out 1 (broadcast) first.

serializeMapStatuses creates a new Java GZIPOutputStream (with the ByteArrayOutputStream created) and writes out the broadcast variable.

serializeMapStatuses prints out the following INFO message to the logs:

[source,plaintext]
----
Broadcast mapstatuses size = [length], actual size = [length]
----

serializeMapStatuses is used when ShuffleStatus is requested to xref:scheduler:ShuffleStatus.adoc#serializedMapStatus[serialize shuffle map output statuses].

== [[deserializeMapStatuses]] deserializeMapStatuses Utility

[source, scala]
----
deserializeMapStatuses(
  bytes: Array[Byte]): Array[MapStatus]
----

deserializeMapStatuses...FIXME

deserializeMapStatuses is used when...FIXME

== [[sendTracker]] sendTracker Utility

[source, scala]
----
sendTracker(
  message: Any): Unit
----

sendTracker...FIXME

sendTracker is used when...FIXME

== [[getMapSizesByExecutorId]] Finding Locations with Blocks and Sizes

[source, scala]
----
getMapSizesByExecutorId(
  shuffleId: Int,
  startPartition: Int,
  endPartition: Int): Seq[(BlockManagerId, Seq[(BlockId, Long)])]
----

getMapSizesByExecutorId returns a collection of xref:storage:BlockManagerId.adoc[]s with their blocks and sizes.

When executed, you should see the following DEBUG message in the logs:

```
Fetching outputs for shuffle [id], partitions [startPartition]-[endPartition]
```

getMapSizesByExecutorId <<getStatuses, finds map outputs>> for the input `shuffleId`.

NOTE: getMapSizesByExecutorId gets the map outputs for all the partitions (despite the method's signature).

In the end, getMapSizesByExecutorId <<convertMapStatuses, converts shuffle map outputs>> (as `MapStatuses`) into the collection of xref:storage:BlockManagerId.adoc[]s with their blocks and sizes.

getMapSizesByExecutorId is used when BlockStoreShuffleReader is requested to xref:shuffle:BlockStoreShuffleReader.adoc#read[read combined records for a reduce task].

== [[unregisterShuffle]] Deregistering Map Output Status Information of Shuffle Stage

[source, scala]
----
unregisterShuffle(
  shuffleId: Int): Unit
----

Deregisters map output status information for the given shuffle stage

Used when:

* ContextCleaner is requested for xref:core:ContextCleaner.adoc#doCleanupShuffle[shuffle cleanup]

* BlockManagerSlaveEndpoint is requested to xref:storage:BlockManagerSlaveEndpoint.adoc#RemoveShuffle[remove a shuffle]

== [[stop]] Stopping MapOutputTracker

[source, scala]
----
stop(): Unit
----

stop does nothing at all.

stop is used when SparkEnv is requested to xref:core:SparkEnv.adoc#stop[stop] (and stops all the services, incl. MapOutputTracker).

== [[convertMapStatuses]] Converting MapStatuses To BlockManagerIds with ShuffleBlockIds and Their Sizes

[source, scala]
----
convertMapStatuses(
  shuffleId: Int,
  startPartition: Int,
  endPartition: Int,
  statuses: Array[MapStatus]): Seq[(BlockManagerId, Seq[(BlockId, Long)])]
----

convertMapStatuses iterates over the input `statuses` array (of xref:scheduler:MapStatus.adoc[MapStatus] entries indexed by map id) and creates a collection of xref:storage:BlockManagerId.adoc[]s (for each `MapStatus` entry) with a xref:storage:BlockId.adoc#ShuffleBlockId[ShuffleBlockId] (with the input `shuffleId`, a `mapId`, and `partition` ranging from the input `startPartition` and `endPartition`) and xref:scheduler:MapStatus.adoc#getSizeForBlock[estimated size for the reduce block] for every status and partitions.

For any empty `MapStatus`, you should see the following ERROR message in the logs:

```
Missing an output location for shuffle [id]
```

And convertMapStatuses throws a `MetadataFetchFailedException` (with `shuffleId`, `startPartition`, and the above error message).

convertMapStatuses is used when <<getMapSizesByExecutorId, MapOutputTracker computes ``BlockManagerId``s with their ``ShuffleBlockId``s and sizes>>.

== [[askTracker]] Sending Blocking Messages To trackerEndpoint RpcEndpointRef

[source, scala]
----
askTracker[T](message: Any): T
----

askTracker xref:rpc:RpcEndpointRef.adoc#askWithRetry[sends the `message`] to <<trackerEndpoint, trackerEndpoint RpcEndpointRef>> and waits for a result.

When an exception happens, you should see the following ERROR message in the logs and askTracker throws a `SparkException`.

```
Error communicating with MapOutputTracker
```

askTracker is used when MapOutputTracker <<getStatuses, fetches map outputs for `ShuffleDependency` remotely>> and <<sendTracker, sends a one-way message>>.

== [[epoch]][[epochLock]] Epoch

Starts from `0` when <<creating-instance, MapOutputTracker is created>>.

Can be <<updateEpoch, updated>> (on `MapOutputTrackerWorkers`) or xref:scheduler:MapOutputTrackerMaster.adoc#incrementEpoch[incremented] (on the driver's `MapOutputTrackerMaster`).
