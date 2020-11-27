# MapOutputTrackerMaster

`MapOutputTrackerMaster` is a [MapOutputTracker](MapOutputTracker.md) for the driver.

`MapOutputTrackerMaster` is the source of truth of [shuffle map output locations](#shuffleStatuses).

## Creating Instance

MapOutputTrackerMaster takes the following to be created:

* [[conf]] SparkConf.md[SparkConf]
* <<broadcastManager, BroadcastManager>>
* [[isLocal]] isLocal flag (whether MapOutputTrackerMaster runs in local or on a cluster)

MapOutputTrackerMaster starts <<MessageLoop, dispatcher threads>> on the <<threadpool, map-output-dispatcher thread pool>>.

== [[BroadcastManager]][[broadcastManager]] MapOutputTrackerMaster and BroadcastManager

MapOutputTrackerMaster is given a core:BroadcastManager.md[] to be created.

== [[shuffleStatuses]] Shuffle Map Output Status Registry

MapOutputTrackerMaster uses an internal registry of ShuffleStatus.md[ShuffleStatuses] by shuffle stages.

MapOutputTrackerMaster adds a new shuffle when requested to <<registerShuffle, register one>> (when DAGScheduler is requested to [create a ShuffleMapStage](DAGScheduler.md#createShuffleMapStage) for a [ShuffleDependency](../rdd/ShuffleDependency.md)).

MapOutputTrackerMaster uses the registry when requested for the following:

* <<registerMapOutput, registerMapOutput>>

* <<getStatistics, getStatistics>>

* <<MessageLoop, MessageLoop>>

* <<unregisterMapOutput, unregisterMapOutput>>, <<unregisterAllMapOutput, unregisterAllMapOutput>>, <<unregisterShuffle, unregisterShuffle>>, <<removeOutputsOnHost, removeOutputsOnHost>>, <<removeOutputsOnExecutor, removeOutputsOnExecutor>>, <<containsShuffle, containsShuffle>>, <<getNumAvailableOutputs, getNumAvailableOutputs>>, <<findMissingPartitions, findMissingPartitions>>, <<getLocationsWithLargestOutputs, getLocationsWithLargestOutputs>>, <<getMapSizesByExecutorId, getMapSizesByExecutorId>>

MapOutputTrackerMaster removes (_clears_) all shuffles when requested to <<stop, stop>>.

== [[configuration-properties]] Configuration Properties

MapOutputTrackerMaster uses the following configuration properties:

* [[spark.shuffle.mapOutput.minSizeForBroadcast]][[minSizeForBroadcast]] configuration-properties.md#spark.shuffle.mapOutput.minSizeForBroadcast[spark.shuffle.mapOutput.minSizeForBroadcast]

* [[spark.shuffle.mapOutput.dispatcher.numThreads]] configuration-properties.md#spark.shuffle.mapOutput.dispatcher.numThreads[spark.shuffle.mapOutput.dispatcher.numThreads]

* [[spark.shuffle.reduceLocality.enabled]][[shuffleLocalityEnabled]] configuration-properties.md#spark.shuffle.reduceLocality.enabled[spark.shuffle.reduceLocality.enabled]

== [[SHUFFLE_PREF_MAP_THRESHOLD]][[SHUFFLE_PREF_REDUCE_THRESHOLD]] Map and Reduce Task Thresholds for Preferred Locations

MapOutputTrackerMaster defines 1000 (tasks) as the hardcoded threshold of the number of map and reduce tasks when requested to <<getPreferredLocationsForShuffle, compute preferred locations>> with <<shuffleLocalityEnabled, spark.shuffle.reduceLocality.enabled>>.

== [[REDUCER_PREF_LOCS_FRACTION]] Map Output Threshold for Preferred Location of Reduce Tasks

MapOutputTrackerMaster defines `0.2` as the fraction of total map output that must be at a location for it to considered as a preferred location for a reduce task.

Making this larger will focus on fewer locations where most data can be read locally, but may lead to more delay in scheduling if those locations are busy.

MapOutputTrackerMaster uses the fraction when requested for the <<getPreferredLocationsForShuffle, preferred locations of shuffle RDDs>>.

== [[mapOutputRequests]][[GetMapOutputMessage]] GetMapOutputMessage Queue

MapOutputTrackerMaster uses a blocking queue (a Java {java-javadoc-url}/java/util/concurrent/LinkedBlockingQueue.html[LinkedBlockingQueue]) for requests for map output statuses.

[source,scala]
----
GetMapOutputMessage(shuffleId: Int, context: RpcCallContext)
----

GetMapOutputMessage holds the shuffle ID and the RpcCallContext of the caller.

A new GetMapOutputMessage is added to the queue when MapOutputTrackerMaster is requested to <<post, post one>>.

MapOutputTrackerMaster uses <<MessageLoop, MessageLoop Dispatcher Threads>> to process GetMapOutputMessages.

== [[MessageLoop]][[run]] MessageLoop Dispatcher Thread

MessageLoop is a thread of execution to handle <<GetMapOutputMessage, GetMapOutputMessages>> until a PoisonPill marker message arrives (posted when <<stop, MapOutputTrackerMaster stops>>).

MessageLoop takes a GetMapOutputMessage and prints out the following DEBUG message to the logs:

[source,plaintext]
----
Handling request to send map output locations for shuffle [shuffleId] to [hostPort]
----

MessageLoop then finds the ShuffleStatus.md[ShuffleStatus] by the shuffle ID in the <<shuffleStatuses, shuffleStatuses>> internal registry and replies back (to the RPC client) with a ShuffleStatus.md#serializedMapStatus[serialized map output status] (with the <<broadcastManager, BroadcastManager>> and <<spark.shuffle.mapOutput.minSizeForBroadcast, spark.shuffle.mapOutput.minSizeForBroadcast>> configuration property).

MessageLoop threads run on the <<threadpool, map-output-dispatcher Thread Pool>>.

== [[threadpool]] map-output-dispatcher Thread Pool

[source, scala]
----
threadpool: ThreadPoolExecutor
----

threadpool is a daemon fixed thread pool registered with *map-output-dispatcher* thread name prefix.

threadpool uses configuration-properties.md#spark.shuffle.mapOutput.dispatcher.numThreads[spark.shuffle.mapOutput.dispatcher.numThreads] configuration property for the number of <<MessageLoop, MessageLoop dispatcher threads>> to process received `GetMapOutputMessage` messages.

The dispatcher threads are started immediately when <<creating-instance, MapOutputTrackerMaster is created>>.

The thread pool is shut down when MapOutputTrackerMaster is requested to <<stop, stop>>.

== [[epoch]][[getEpoch]] Epoch Number

MapOutputTrackerMaster uses an *epoch number* to...FIXME

getEpoch is used when:

* DAGScheduler is requested to DAGScheduler.md#removeExecutorAndUnregisterOutputs[removeExecutorAndUnregisterOutputs]

* TaskSetManager.md[TaskSetManager] is created (and sets the epoch to tasks)

== [[post]] Enqueueing GetMapOutputMessage

[source, scala]
----
post(
  message: GetMapOutputMessage): Unit
----

post simply adds the input GetMapOutputMessage to the <<mapOutputRequests, mapOutputRequests>> internal queue.

post is used when MapOutputTrackerMasterEndpoint is requested to MapOutputTrackerMasterEndpoint.md#GetMapOutputStatuses[handle a GetMapOutputStatuses message].

== [[stop]] Stopping MapOutputTrackerMaster

[source, scala]
----
stop(): Unit
----

stop...FIXME

stop is part of the MapOutputTracker.md#stop[MapOutputTracker] abstraction.

== [[unregisterMapOutput]] Unregistering Shuffle Map Output

[source, scala]
----
unregisterMapOutput(
  shuffleId: Int,
  mapId: Int,
  bmAddress: BlockManagerId): Unit
----

unregisterMapOutput...FIXME

unregisterMapOutput is used when DAGScheduler is requested to DAGScheduler.md#handleTaskCompletion[handle a task completion (due to a fetch failure)].

== [[getPreferredLocationsForShuffle]] Computing Preferred Locations (with Most Shuffle Map Outputs)

[source, scala]
----
getPreferredLocationsForShuffle(
  dep: ShuffleDependency[_, _, _],
  partitionId: Int): Seq[String]
----

getPreferredLocationsForShuffle computes the locations (storage:BlockManager.md[BlockManagers]) with the most shuffle map outputs for the input [ShuffleDependency](../rdd/ShuffleDependency.md) and [Partition](../rdd/Partition.md).

getPreferredLocationsForShuffle computes the locations when all of the following are met:

* <<spark.shuffle.reduceLocality.enabled, spark.shuffle.reduceLocality.enabled>> configuration property is enabled

* The number of "map" partitions (of the ../rdd/ShuffleDependency.md#rdd[RDD] of the input [ShuffleDependency](../rdd/ShuffleDependency.md)) is below <<SHUFFLE_PREF_MAP_THRESHOLD, SHUFFLE_PREF_MAP_THRESHOLD>>

* The number of "reduce" partitions (of the [Partitioner](../rdd/ShuffleDependency.md#partitioner) of the input [ShuffleDependency](../rdd/ShuffleDependency.md)) is below <<SHUFFLE_PREF_REDUCE_THRESHOLD, SHUFFLE_PREF_REDUCE_THRESHOLD>>

NOTE: getPreferredLocationsForShuffle is simply <<getLocationsWithLargestOutputs, getLocationsWithLargestOutputs>> with a guard condition.

Internally, getPreferredLocationsForShuffle checks whether <<spark_shuffle_reduceLocality_enabled, `spark.shuffle.reduceLocality.enabled` Spark property>> is enabled (it is by default) with the number of partitions of the [RDD of the input `ShuffleDependency`](../rdd/ShuffleDependency.md#rdd) and partitions in the [partitioner of the input `ShuffleDependency`](../rdd/ShuffleDependency.md#partitioner) both being less than `1000`.

NOTE: The thresholds for the number of partitions in the RDD and of the partitioner when computing the preferred locations are `1000` and are not configurable.

If the condition holds, getPreferredLocationsForShuffle <<getLocationsWithLargestOutputs, finds locations with the largest number of shuffle map outputs>> for the input `ShuffleDependency` and `partitionId` (with the number of partitions in the partitioner of the input `ShuffleDependency` and `0.2`) and returns the hosts of the preferred `BlockManagers`.

NOTE: `0.2` is the fraction of total map output that must be at a location to be considered as a preferred location for a reduce task. It is not configurable.

getPreferredLocationsForShuffle is used when ../rdd/ShuffledRDD.md#getPreferredLocations[ShuffledRDD] and Spark SQL's ShuffledRowRDD are requested for preferred locations of a partition.

== [[incrementEpoch]] Incrementing Epoch

[source, scala]
----
incrementEpoch(): Unit
----

incrementEpoch increments the internal MapOutputTracker.md#epoch[epoch].

incrementEpoch prints out the following DEBUG message to the logs:

```
Increasing epoch to [epoch]
```

incrementEpoch is used when:

* MapOutputTrackerMaster is requested to <<unregisterMapOutput, unregisterMapOutput>>, <<unregisterAllMapOutput, unregisterAllMapOutput>>, <<removeOutputsOnHost, removeOutputsOnHost>> and <<removeOutputsOnExecutor, removeOutputsOnExecutor>>

* DAGScheduler is requested to DAGScheduler.md#handleTaskCompletion[handle a ShuffleMapTask completion] (of a ShuffleMapStage)

== [[containsShuffle]] Checking Availability of Shuffle Map Output Status

[source, scala]
----
containsShuffle(
  shuffleId: Int): Boolean
----

containsShuffle checks if the input `shuffleId` is registered in the <<cachedSerializedStatuses, cachedSerializedStatuses>> or MapOutputTracker.md#mapStatuses[mapStatuses] internal caches.

containsShuffle is used when DAGScheduler is requested to DAGScheduler.md#createShuffleMapStage[create a createShuffleMapStage] (for a [ShuffleDependency](../rdd/ShuffleDependency.md)).

== [[registerShuffle]] Registering Shuffle

[source, scala]
----
registerShuffle(
  shuffleId: Int,
  numMaps: Int): Unit
----

registerShuffle adds the input shuffle ID and the number of partitions (as a ShuffleStatus.md[ShuffleStatus]) to <<shuffleStatuses, shuffleStatuses>> internal registry.

If the shuffle ID has already been registered, registerShuffle throws an IllegalArgumentException:

```
Shuffle ID [shuffleId] registered twice
```

registerShuffle is used when DAGScheduler is requested to DAGScheduler.md#createShuffleMapStage[create a ShuffleMapStage] (for a [ShuffleDependency](../rdd/ShuffleDependency.md)).

== [[registerMapOutputs]] Registering Map Outputs for Shuffle (Possibly with Epoch Change)

[source, scala]
----
registerMapOutputs(
  shuffleId: Int,
  statuses: Array[MapStatus],
  changeEpoch: Boolean = false): Unit
----

registerMapOutputs registers the input `statuses` (as the shuffle map output) with the input `shuffleId` in the MapOutputTracker.md#mapStatuses[mapStatuses] internal cache.

registerMapOutputs <<incrementEpoch, increments epoch>> if the input `changeEpoch` is enabled (it is not by default).

registerMapOutputs is used when `DAGScheduler` handles DAGSchedulerEventProcessLoop.md#handleTaskCompletion-Success-ShuffleMapTask[successful `ShuffleMapTask` completion] and DAGSchedulerEventProcessLoop.md#handleExecutorLost[executor lost events].

== [[getSerializedMapOutputStatuses]] Finding Serialized Map Output Statuses (And Possibly Broadcasting Them)

[source, scala]
----
getSerializedMapOutputStatuses(
  shuffleId: Int): Array[Byte]
----

getSerializedMapOutputStatuses <<checkCachedStatuses, finds cached serialized map statuses>> for the input `shuffleId`.

If found, getSerializedMapOutputStatuses returns the cached serialized map statuses.

Otherwise, getSerializedMapOutputStatuses acquires the <<shuffleIdLocks, shuffle lock>> for `shuffleId` and <<checkCachedStatuses, finds cached serialized map statuses>> again since some other thread could not update the <<cachedSerializedStatuses, cachedSerializedStatuses>> internal cache.

getSerializedMapOutputStatuses returns the serialized map statuses if found.

If not, getSerializedMapOutputStatuses MapOutputTracker.md#serializeMapStatuses[serializes the local array of `MapStatuses`] (from <<checkCachedStatuses, checkCachedStatuses>>).

You should see the following INFO message in the logs:

```
Size of output statuses for shuffle [shuffleId] is [bytes] bytes
```

getSerializedMapOutputStatuses saves the serialized map output statuses in <<cachedSerializedStatuses, cachedSerializedStatuses>> internal cache if the <<epoch, epoch>> has not changed in the meantime. getSerializedMapOutputStatuses also saves its broadcast version in <<cachedSerializedBroadcast, cachedSerializedBroadcast>> internal cache.

If the <<epoch, epoch>> has changed in the meantime, the serialized map output statuses and their broadcast version are not saved, and you should see the following INFO message in the logs:

```
Epoch changed, not caching!
```

getSerializedMapOutputStatuses <<removeBroadcast, removes the broadcast>>.

getSerializedMapOutputStatuses returns the serialized map statuses.

getSerializedMapOutputStatuses is used when <<MessageLoop, MapOutputTrackerMaster responds to `GetMapOutputMessage` requests>> and DAGScheduler.md#createShuffleMapStage[`DAGScheduler` creates `ShuffleMapStage` for `ShuffleDependency`] (copying the shuffle map output locations from previous jobs to avoid unnecessarily regenerating data).

=== [[checkCachedStatuses]] Finding Cached Serialized Map Statuses

[source, scala]
----
checkCachedStatuses(): Boolean
----

checkCachedStatuses is an internal helper method that <<getSerializedMapOutputStatuses, getSerializedMapOutputStatuses>> uses to do some bookkeeping (when the <<epoch, epoch>> and <<cacheEpoch, cacheEpoch>> differ) and set local `statuses`, `retBytes` and `epochGotten` (that getSerializedMapOutputStatuses uses).

Internally, checkCachedStatuses acquires the MapOutputTracker.md#epochLock[`epochLock` lock] and checks the status of <<epoch, epoch>> to <<cacheEpoch, cached `cacheEpoch`>>.

If `epoch` is younger (i.e. greater), checkCachedStatuses clears <<cachedSerializedStatuses, cachedSerializedStatuses>> internal cache, <<clearCachedBroadcast, cached broadcasts>> and sets `cacheEpoch` to be `epoch`.

checkCachedStatuses gets the serialized map output statuses for the `shuffleId` (of the owning <<getSerializedMapOutputStatuses, getSerializedMapOutputStatuses>>).

When the serialized map output status is found, checkCachedStatuses saves it in a local `retBytes` and returns `true`.

When not found, you should see the following DEBUG message in the logs:

```
cached status not found for : [shuffleId]
```

checkCachedStatuses uses MapOutputTracker.md#mapStatuses[mapStatuses] internal cache to get map output statuses for the `shuffleId` (of the owning <<getSerializedMapOutputStatuses, getSerializedMapOutputStatuses>>) or falls back to an empty array and sets it to a local `statuses`. checkCachedStatuses sets the local `epochGotten` to the current <<epoch, epoch>> and returns `false`.

== [[registerMapOutput]] Registering Shuffle Map Output

[source, scala]
----
registerMapOutput(
  shuffleId: Int,
  mapId: Int,
  status: MapStatus): Unit
----

registerMapOutput finds the ShuffleStatus.md[ShuffleStatus] by the given shuffle ID and ShuffleStatus.md#addMapOutput[adds the given MapStatus]:

* The given mapId is the Task.md#partitionId[partitionId] of the ShuffleMapTask.md[ShuffleMapTask] that finished.

* The given shuffleId is the [shuffleId](../rdd/ShuffleDependency.md#shuffleId) of the [ShuffleDependency](../rdd/ShuffleDependency.md) of the [ShuffleMapStage](ShuffleMapStage.md#shuffleDep) (for which the ShuffleMapTask completed)

registerMapOutput is used when DAGScheduler is requested to DAGScheduler.md#handleTaskCompletion[handle a ShuffleMapTask completion].

== [[getStatistics]] Calculating Shuffle Map Output Statistics

[source, scala]
----
getStatistics(
  dep: ShuffleDependency[_, _, _]): MapOutputStatistics
----

getStatistics...FIXME

getStatistics is used when DAGScheduler is requested to DAGScheduler.md#handleMapStageSubmitted[handle a ShuffleMapStage submission] (and the stage has finished) and DAGScheduler.md#markMapStageJobsAsFinished[markMapStageJobsAsFinished].

== [[unregisterAllMapOutput]] Deregistering All Map Outputs of Shuffle Stage

[source, scala]
----
unregisterAllMapOutput(
  shuffleId: Int): Unit
----

unregisterAllMapOutput...FIXME

unregisterAllMapOutput is used when DAGScheduler is requested to DAGScheduler.md#handleTaskCompletion[handle a task completion (due to a fetch failure)].

== [[unregisterShuffle]] Deregistering Shuffle

[source, scala]
----
unregisterShuffle(
  shuffleId: Int): Unit
----

unregisterShuffle...FIXME

unregisterShuffle is part of the MapOutputTracker.md#unregisterShuffle[MapOutputTracker] abstraction.

== [[removeOutputsOnHost]] Deregistering Shuffle Outputs Associated with Host

[source, scala]
----
removeOutputsOnHost(
  host: String): Unit
----

removeOutputsOnHost...FIXME

removeOutputsOnHost is used when DAGScheduler is requested to DAGScheduler.md#removeExecutorAndUnregisterOutputs[removeExecutorAndUnregisterOutputs] and DAGScheduler.md#handleWorkerRemoved[handle a worker removal].

== [[removeOutputsOnExecutor]] Deregistering Shuffle Outputs Associated with Executor

[source, scala]
----
removeOutputsOnExecutor(
  execId: String): Unit
----

removeOutputsOnExecutor...FIXME

removeOutputsOnExecutor is used when DAGScheduler is requested to DAGScheduler.md#removeExecutorAndUnregisterOutputs[removeExecutorAndUnregisterOutputs].

== [[getNumAvailableOutputs]] Number of Partitions with Shuffle Map Outputs Available

[source, scala]
----
getNumAvailableOutputs(
  shuffleId: Int): Int
----

getNumAvailableOutputs...FIXME

getNumAvailableOutputs is used when ShuffleMapStage is requested for the ShuffleMapStage.md#numAvailableOutputs[number of partitions with shuffle outputs available].

== [[findMissingPartitions]] Finding Missing Partitions

[source, scala]
----
findMissingPartitions(
  shuffleId: Int): Option[Seq[Int]]
----

findMissingPartitions...FIXME

findMissingPartitions is used when ShuffleMapStage is requested for ShuffleMapStage.md#findMissingPartitions[missing partitions].

== [[getMapSizesByExecutorId]] Finding Locations with Blocks and Sizes

[source, scala]
----
getMapSizesByExecutorId(
  shuffleId: Int,
  startPartition: Int,
  endPartition: Int): Iterator[(BlockManagerId, Seq[(BlockId, Long)])]
----

getMapSizesByExecutorId...FIXME

getMapSizesByExecutorId is part of the MapOutputTracker.md#getMapSizesByExecutorId[MapOutputTracker] abstraction.

== [[getLocationsWithLargestOutputs]] Finding Locations with Largest Number of Shuffle Map Outputs

[source, scala]
----
getLocationsWithLargestOutputs(
  shuffleId: Int,
  reducerId: Int,
  numReducers: Int,
  fractionThreshold: Double): Option[Array[BlockManagerId]]
----

getLocationsWithLargestOutputs returns storage:BlockManagerId.md[]s with the largest size (of all the shuffle blocks they manage) above the input `fractionThreshold` (given the total size of all the shuffle blocks for the shuffle across all storage:BlockManager.md[BlockManagers]).

NOTE: getLocationsWithLargestOutputs may return no `BlockManagerId` if their shuffle blocks do not total up above the input `fractionThreshold`.

NOTE: The input `numReducers` is not used.

Internally, getLocationsWithLargestOutputs queries the <<mapStatuses, mapStatuses>> internal cache for the input `shuffleId`.

[NOTE]
====
One entry in `mapStatuses` internal cache is a MapStatus.md[MapStatus] array indexed by partition id.

`MapStatus` includes MapStatus.md#contract[information about the `BlockManager` (as `BlockManagerId`) and estimated size of the reduce blocks].
====

getLocationsWithLargestOutputs iterates over the `MapStatus` array and builds an interim mapping between storage:BlockManagerId.md[] and the cumulative sum of shuffle blocks across storage:BlockManager.md[BlockManagers].

getLocationsWithLargestOutputs is used when MapOutputTrackerMaster is requested for the <<getPreferredLocationsForShuffle, preferred locations of a shuffle>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.MapOutputTrackerMaster` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.MapOutputTrackerMaster=ALL
----

Refer to spark-logging.md[Logging].
