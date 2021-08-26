# MapOutputTrackerMaster

`MapOutputTrackerMaster` is a [MapOutputTracker](MapOutputTracker.md) for the driver.

`MapOutputTrackerMaster` is the source of truth of [shuffle map output locations](#shuffleStatuses).

## Creating Instance

`MapOutputTrackerMaster` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* [BroadcastManager](#broadcastManager)
* <span id="isLocal"> `isLocal` flag (to indicate whether `MapOutputTrackerMaster` runs in local or a cluster)

When created, `MapOutputTrackerMaster` starts [dispatcher threads](#MessageLoop) on the [map-output-dispatcher thread pool](#threadpool).

`MapOutputTrackerMaster` is created when:

* `SparkEnv` utility is used to [create a SparkEnv for the driver](../SparkEnv.md#create)

## <span id="maxRpcMessageSize"> maxRpcMessageSize

`maxRpcMessageSize` is...FIXME

## <span id="broadcastManager"><span id="BroadcastManager"> BroadcastManager

`MapOutputTrackerMaster` is given a [BroadcastManager](../broadcast-variables/BroadcastManager.md) to be created.

## <span id="shuffleStatuses"> Shuffle Map Output Status Registry

`MapOutputTrackerMaster` uses an internal registry of [ShuffleStatus](ShuffleStatus.md)es by shuffle stages.

`MapOutputTrackerMaster` adds a new shuffle when requested to [register one](#registerShuffle) (when `DAGScheduler` is requested to [create a ShuffleMapStage](DAGScheduler.md#createShuffleMapStage) for a [ShuffleDependency](../rdd/ShuffleDependency.md)).

`MapOutputTrackerMaster` uses the registry when requested for the following:

* [registerMapOutput](#registerMapOutput)

* [getStatistics](#getStatistics)

* [MessageLoop](#MessageLoop)

* [unregisterMapOutput](#unregisterMapOutput), [unregisterAllMapOutput](#unregisterAllMapOutput), [unregisterShuffle](#unregisterShuffle), [removeOutputsOnHost](#removeOutputsOnHost), [removeOutputsOnExecutor](#removeOutputsOnExecutor), [containsShuffle](#containsShuffle), [getNumAvailableOutputs](#getNumAvailableOutputs), [findMissingPartitions](#findMissingPartitions), [getLocationsWithLargestOutputs](#getLocationsWithLargestOutputs), [getMapSizesByExecutorId](#getMapSizesByExecutorId)

`MapOutputTrackerMaster` removes (_clears_) all shuffles when requested to [stop](#stop).

## Configuration Properties

`MapOutputTrackerMaster` uses the following configuration properties:

* <span id="spark.shuffle.mapOutput.minSizeForBroadcast"><span id="minSizeForBroadcast"> [spark.shuffle.mapOutput.minSizeForBroadcast](../configuration-properties.md#spark.shuffle.mapOutput.minSizeForBroadcast)

* <span id="spark.shuffle.mapOutput.dispatcher.numThreads"> [spark.shuffle.mapOutput.dispatcher.numThreads](../configuration-properties.md#spark.shuffle.mapOutput.dispatcher.numThreads)

* <span id="spark.shuffle.reduceLocality.enabled"><span id="shuffleLocalityEnabled"> [spark.shuffle.reduceLocality.enabled](../configuration-properties.md#spark.shuffle.reduceLocality.enabled)

## <span id="SHUFFLE_PREF_MAP_THRESHOLD"><span id="SHUFFLE_PREF_REDUCE_THRESHOLD"> Map and Reduce Task Thresholds for Preferred Locations

`MapOutputTrackerMaster` defines 1000 (tasks) as the hardcoded threshold of the number of map and reduce tasks when requested to [compute preferred locations](#getPreferredLocationsForShuffle) with [spark.shuffle.reduceLocality.enabled](#shuffleLocalityEnabled).

## <span id="REDUCER_PREF_LOCS_FRACTION"> Map Output Threshold for Preferred Location of Reduce Tasks

`MapOutputTrackerMaster` defines `0.2` as the fraction of total map output that must be at a location for it to considered as a preferred location for a reduce task.

Making this larger will focus on fewer locations where most data can be read locally, but may lead to more delay in scheduling if those locations are busy.

`MapOutputTrackerMaster` uses the fraction when requested for the [preferred locations of shuffle RDDs](#getPreferredLocationsForShuffle).

## <span id="mapOutputRequests"><span id="GetMapOutputMessage"> GetMapOutputMessage Queue

`MapOutputTrackerMaster` uses a blocking queue (a Java [LinkedBlockingQueue]({{ java.api }}/java.base/java/util/concurrent/LinkedBlockingQueue.html)) for requests for map output statuses.

```scala
GetMapOutputMessage(
  shuffleId: Int,
  context: RpcCallContext)
```

`GetMapOutputMessage` holds the shuffle ID and the `RpcCallContext` of the caller.

A new `GetMapOutputMessage` is added to the queue when `MapOutputTrackerMaster` is requested to [post one](#post).

`MapOutputTrackerMaster` uses [MessageLoop Dispatcher Threads](#MessageLoop) to process `GetMapOutputMessages`.

## <span id="MessageLoop"><span id="run"> MessageLoop Dispatcher Thread

`MessageLoop` is a thread of execution to handle [GetMapOutputMessage](#GetMapOutputMessage)s until a `PoisonPill` marker message arrives (when `MapOutputTrackerMaster` is requested to [stop](#stop)).

`MessageLoop` takes a `GetMapOutputMessage` and prints out the following DEBUG message to the logs:

```text
Handling request to send map output locations for shuffle [shuffleId] to [hostPort]
```

`MessageLoop` then finds the [ShuffleStatus](ShuffleStatus.md) by the shuffle ID in the [shuffleStatuses](#shuffleStatuses) internal registry and replies back (to the RPC client) with a [serialized map output status](ShuffleStatus.md#serializedMapStatus) (with the [BroadcastManager](#broadcastManager) and [spark.shuffle.mapOutput.minSizeForBroadcast](#spark.shuffle.mapOutput.minSizeForBroadcast) configuration property).

`MessageLoop` threads run on the [map-output-dispatcher Thread Pool](#threadpool).

## <span id="threadpool"> map-output-dispatcher Thread Pool

```scala
threadpool: ThreadPoolExecutor
```

`threadpool` is a daemon fixed thread pool registered with **map-output-dispatcher** thread name prefix.

`threadpool` uses [spark.shuffle.mapOutput.dispatcher.numThreads](../configuration-properties.md#spark.shuffle.mapOutput.dispatcher.numThreads) configuration property for the number of [MessageLoop dispatcher threads](#MessageLoop) to process received `GetMapOutputMessage` messages.

The dispatcher threads are started immediately when `MapOutputTrackerMaster` is [created](#creating-instance).

The thread pool is shut down when `MapOutputTrackerMaster` is requested to [stop](#stop).

## <span id="epoch"><span id="getEpoch"> Epoch Number

`MapOutputTrackerMaster` uses an **epoch number** to...FIXME

`getEpoch` is used when:

* `DAGScheduler` is requested to [removeExecutorAndUnregisterOutputs](DAGScheduler.md#removeExecutorAndUnregisterOutputs)

* [TaskSetManager](TaskSetManager.md) is created (and sets the epoch to tasks)

## <span id="post"> Enqueueing GetMapOutputMessage

```scala
post(
  message: GetMapOutputMessage): Unit
```

`post` simply adds the input `GetMapOutputMessage` to the [mapOutputRequests](#mapOutputRequests) internal queue.

`post` is used when `MapOutputTrackerMasterEndpoint` is requested to [handle a GetMapOutputStatuses message](MapOutputTrackerMasterEndpoint.md#GetMapOutputStatuses).

## <span id="stop"> Stopping MapOutputTrackerMaster

```scala
stop(): Unit
```

`stop`...FIXME

`stop` is part of the [MapOutputTracker](MapOutputTracker.md#stop) abstraction.

## <span id="unregisterMapOutput"> Unregistering Shuffle Map Output

```scala
unregisterMapOutput(
  shuffleId: Int,
  mapId: Int,
  bmAddress: BlockManagerId): Unit
```

`unregisterMapOutput`...FIXME

`unregisterMapOutput` is used when `DAGScheduler` is requested to [handle a task completion (due to a fetch failure)](DAGScheduler.md#handleTaskCompletion).

## <span id="getPreferredLocationsForShuffle"> Computing Preferred Locations

```scala
getPreferredLocationsForShuffle(
  dep: ShuffleDependency[_, _, _],
  partitionId: Int): Seq[String]
```

`getPreferredLocationsForShuffle` computes the locations ([BlockManager](../storage/BlockManager.md)s) with the most shuffle map outputs for the input [ShuffleDependency](../rdd/ShuffleDependency.md) and [Partition](../rdd/Partition.md).

`getPreferredLocationsForShuffle` computes the locations when all of the following are met:

* [spark.shuffle.reduceLocality.enabled](#spark.shuffle.reduceLocality.enabled) configuration property is enabled

* The number of "map" partitions (of the [RDD](../rdd/ShuffleDependency.md#rdd) of the input [ShuffleDependency](../rdd/ShuffleDependency.md)) is below [SHUFFLE_PREF_MAP_THRESHOLD](#SHUFFLE_PREF_MAP_THRESHOLD)

* The number of "reduce" partitions (of the [Partitioner](../rdd/ShuffleDependency.md#partitioner) of the input [ShuffleDependency](../rdd/ShuffleDependency.md)) is below [SHUFFLE_PREF_REDUCE_THRESHOLD](#SHUFFLE_PREF_REDUCE_THRESHOLD)

!!! note
    `getPreferredLocationsForShuffle` is simply [getLocationsWithLargestOutputs](#getLocationsWithLargestOutputs) with a guard condition.

Internally, `getPreferredLocationsForShuffle` checks whether [spark.shuffle.reduceLocality.enabled](#spark.shuffle.reduceLocality.enabled) configuration property is enabled with the number of partitions of the [RDD of the input `ShuffleDependency`](../rdd/ShuffleDependency.md#rdd) and partitions in the [partitioner of the input `ShuffleDependency`](../rdd/ShuffleDependency.md#partitioner) both being less than `1000`.

!!! note
    The thresholds for the number of partitions in the RDD and of the partitioner when computing the preferred locations are `1000` and are not configurable.

If the condition holds, `getPreferredLocationsForShuffle` [finds locations with the largest number of shuffle map outputs](#getLocationsWithLargestOutputs) for the input `ShuffleDependency` and `partitionId` (with the number of partitions in the partitioner of the input `ShuffleDependency` and `0.2`) and returns the hosts of the preferred `BlockManagers`.

!!! note
    `0.2` is the fraction of total map output that must be at a location to be considered as a preferred location for a reduce task. It is not configurable.

`getPreferredLocationsForShuffle` is used when [ShuffledRDD](../rdd/ShuffledRDD.md#getPreferredLocations) and Spark SQL's `ShuffledRowRDD` are requested for preferred locations of a partition.

### <span id="getLocationsWithLargestOutputs"> Finding Locations with Largest Number of Shuffle Map Outputs

```scala
getLocationsWithLargestOutputs(
  shuffleId: Int,
  reducerId: Int,
  numReducers: Int,
  fractionThreshold: Double): Option[Array[BlockManagerId]]
```

`getLocationsWithLargestOutputs` returns [BlockManagerId](../storage/BlockManagerId.md)s with the largest size (of all the shuffle blocks they manage) above the input `fractionThreshold` (given the total size of all the shuffle blocks for the shuffle across all [BlockManager](../storage/BlockManager.md)s).

!!! note
    `getLocationsWithLargestOutputs` may return no `BlockManagerId` if their shuffle blocks do not total up above the input `fractionThreshold`.

!!! note
    The input `numReducers` is not used.

Internally, `getLocationsWithLargestOutputs` queries the [mapStatuses](#mapStatuses) internal cache for the input `shuffleId`.

!!! note
    One entry in `mapStatuses` internal cache is a [MapStatus](MapStatus.md) array indexed by partition id.

    `MapStatus` includes [information about the `BlockManager` (as `BlockManagerId`) and estimated size of the reduce blocks](MapStatus.md#contract).

`getLocationsWithLargestOutputs` iterates over the `MapStatus` array and builds an interim mapping between [BlockManagerId](../storage/BlockManagerId.md) and the cumulative sum of shuffle blocks across [BlockManager](../storage/BlockManager.md)s.

## <span id="incrementEpoch"> Incrementing Epoch

```scala
incrementEpoch(): Unit
```

`incrementEpoch` increments the internal [epoch](MapOutputTracker.md#epoch).

`incrementEpoch` prints out the following DEBUG message to the logs:

```text
Increasing epoch to [epoch]
```

`incrementEpoch` is used when:

* `MapOutputTrackerMaster` is requested to [unregisterMapOutput](#unregisterMapOutput), [unregisterAllMapOutput](#unregisterAllMapOutput), [removeOutputsOnHost](#removeOutputsOnHost) and [removeOutputsOnExecutor](#removeOutputsOnExecutor)

* `DAGScheduler` is requested to [handle a ShuffleMapTask completion](DAGScheduler.md#handleTaskCompletion) (of a `ShuffleMapStage`)

## <span id="containsShuffle"> Checking Availability of Shuffle Map Output Status

```scala
containsShuffle(
  shuffleId: Int): Boolean
```

`containsShuffle` checks if the input `shuffleId` is registered in the [cachedSerializedStatuses](#cachedSerializedStatuses) or [mapStatuses](MapOutputTracker.md#mapStatuses) internal caches.

`containsShuffle` is used when `DAGScheduler` is requested to [create a createShuffleMapStage](DAGScheduler.md#createShuffleMapStage) (for a [ShuffleDependency](../rdd/ShuffleDependency.md)).

## <span id="registerShuffle"> Registering Shuffle

```scala
registerShuffle(
  shuffleId: Int,
  numMaps: Int): Unit
```

`registerShuffle` registers a new [ShuffleStatus](ShuffleStatus.md) (for the given shuffle ID and the number of partitions) to the [shuffleStatuses](#shuffleStatuses) internal registry.

`registerShuffle` throws an `IllegalArgumentException` when the shuffle ID has already been registered:

```text
Shuffle ID [shuffleId] registered twice
```

`registerShuffle` is used when:

* `DAGScheduler` is requested to [create a ShuffleMapStage](DAGScheduler.md#createShuffleMapStage) (for a [ShuffleDependency](../rdd/ShuffleDependency.md))

## <span id="registerMapOutputs"> Registering Map Outputs for Shuffle (Possibly with Epoch Change)

```scala
registerMapOutputs(
  shuffleId: Int,
  statuses: Array[MapStatus],
  changeEpoch: Boolean = false): Unit
```

`registerMapOutputs` registers the input `statuses` (as the shuffle map output) with the input `shuffleId` in the [mapStatuses](MapOutputTracker.md#mapStatuses) internal cache.

`registerMapOutputs` [increments epoch](#incrementEpoch) if the input `changeEpoch` is enabled (it is not by default).

`registerMapOutputs` is used when `DAGScheduler` handles [successful `ShuffleMapTask` completion](DAGSchedulerEventProcessLoop.md#handleTaskCompletion-Success-ShuffleMapTask) and [executor lost events](DAGSchedulerEventProcessLoop.md#handleExecutorLost).

## <span id="getSerializedMapOutputStatuses"> Finding Serialized Map Output Statuses (And Possibly Broadcasting Them)

```scala
getSerializedMapOutputStatuses(
  shuffleId: Int): Array[Byte]
```

`getSerializedMapOutputStatuses` [finds cached serialized map statuses](#checkCachedStatuses) for the input `shuffleId`.

If found, `getSerializedMapOutputStatuses` returns the cached serialized map statuses.

Otherwise, `getSerializedMapOutputStatuses` acquires the [shuffle lock](#shuffleIdLocks) for `shuffleId` and [finds cached serialized map statuses](#checkCachedStatuses) again since some other thread could not update the [cachedSerializedStatuses](#cachedSerializedStatuses) internal cache.

`getSerializedMapOutputStatuses` returns the serialized map statuses if found.

If not, `getSerializedMapOutputStatuses` [serializes the local array of `MapStatuses`](MapOutputTracker.md#serializeMapStatuses) (from [checkCachedStatuses](#checkCachedStatuses)).

`getSerializedMapOutputStatuses` prints out the following INFO message to the logs:

```text
Size of output statuses for shuffle [shuffleId] is [bytes] bytes
```

`getSerializedMapOutputStatuses` saves the serialized map output statuses in [cachedSerializedStatuses](#cachedSerializedStatuses) internal cache if the [epoch](#epoch) has not changed in the meantime. `getSerializedMapOutputStatuses` also saves its broadcast version in [cachedSerializedBroadcast](#cachedSerializedBroadcast) internal cache.

If the [epoch](#epoch) has changed in the meantime, the serialized map output statuses and their broadcast version are not saved, and `getSerializedMapOutputStatuses` prints out the following INFO message to the logs:

```text
Epoch changed, not caching!
```

`getSerializedMapOutputStatuses` [removes the broadcast](#removeBroadcast).

`getSerializedMapOutputStatuses` returns the serialized map statuses.

`getSerializedMapOutputStatuses` is used when [MapOutputTrackerMaster responds to `GetMapOutputMessage` requests](#MessageLoop) and [`DAGScheduler` creates `ShuffleMapStage` for `ShuffleDependency`](DAGScheduler.md#createShuffleMapStage) (copying the shuffle map output locations from previous jobs to avoid unnecessarily regenerating data).

### <span id="checkCachedStatuses"> Finding Cached Serialized Map Statuses

```scala
checkCachedStatuses(): Boolean
```

`checkCachedStatuses` is an internal helper method that <<getSerializedMapOutputStatuses, getSerializedMapOutputStatuses>> uses to do some bookkeeping (when the <<epoch, epoch>> and <<cacheEpoch, cacheEpoch>> differ) and set local `statuses`, `retBytes` and `epochGotten` (that getSerializedMapOutputStatuses uses).

Internally, `checkCachedStatuses` acquires the MapOutputTracker.md#epochLock[`epochLock` lock] and checks the status of <<epoch, epoch>> to <<cacheEpoch, cached `cacheEpoch`>>.

If `epoch` is younger (i.e. greater), `checkCachedStatuses` clears <<cachedSerializedStatuses, cachedSerializedStatuses>> internal cache, <<clearCachedBroadcast, cached broadcasts>> and sets `cacheEpoch` to be `epoch`.

`checkCachedStatuses` gets the serialized map output statuses for the `shuffleId` (of the owning <<getSerializedMapOutputStatuses, getSerializedMapOutputStatuses>>).

When the serialized map output status is found, `checkCachedStatuses` saves it in a local `retBytes` and returns `true`.

When not found, you should see the following DEBUG message in the logs:

```
cached status not found for : [shuffleId]
```

`checkCachedStatuses` uses MapOutputTracker.md#mapStatuses[mapStatuses] internal cache to get map output statuses for the `shuffleId` (of the owning <<getSerializedMapOutputStatuses, getSerializedMapOutputStatuses>>) or falls back to an empty array and sets it to a local `statuses`. `checkCachedStatuses` sets the local `epochGotten` to the current <<epoch, epoch>> and returns `false`.

## <span id="registerMapOutput"> Registering Shuffle Map Output

```scala
registerMapOutput(
  shuffleId: Int,
  mapId: Int,
  status: MapStatus): Unit
```

`registerMapOutput` finds the [ShuffleStatus](ShuffleStatus.md) by the given shuffle ID and [adds the given MapStatus](ShuffleStatus.md#addMapOutput):

* The given mapId is the [partitionId](Task.md#partitionId) of the [ShuffleMapTask](ShuffleMapTask.md) that finished.

* The given shuffleId is the [shuffleId](../rdd/ShuffleDependency.md#shuffleId) of the [ShuffleDependency](../rdd/ShuffleDependency.md) of the [ShuffleMapStage](ShuffleMapStage.md#shuffleDep) (for which the `ShuffleMapTask` completed)

`registerMapOutput` is used when `DAGScheduler` is requested to [handle a ShuffleMapTask completion](DAGScheduler.md#handleTaskCompletion).

## <span id="getStatistics"> Map Output Statistics for ShuffleDependency

```scala
getStatistics(
  dep: ShuffleDependency[_, _, _]): MapOutputStatistics
```

`getStatistics` looks up the [ShuffleStatus](ShuffleStatus.md) for the [shuffleId](../rdd/ShuffleDependency.md#shuffleId) (of the input [ShuffleDependency](../rdd/ShuffleDependency.md)) in the [shuffleStatuses](#shuffleStatuses) registry.

!!! note
    It is assumed that the [shuffleStatuses](#shuffleStatuses) registry does have the `ShuffleStatus`. That makes _me_ believe "someone else" is taking care of whether it is available or not.

`getStatistics` requests the `ShuffleStatus` for the [MapStatus](ShuffleStatus.md#withMapStatuses)es (of the `ShuffleDependency`).

`getStatistics` uses the [spark.shuffle.mapOutput.parallelAggregationThreshold](../configuration-properties.md#spark.shuffle.mapOutput.parallelAggregationThreshold) configuration property to decide on parallelism to calculate the statistics.

With no parallelism, `getStatistics` simply traverses over the `MapStatus`es and requests them (one by one) for the [size](MapStatus.md#getSizeForBlock) of every reduce shuffle block.

!!! note
    `getStatistics` requests the given `ShuffleDependency` for the [Partitioner](../rdd/ShuffleDependency.md#partitioner) that in turn is requested for the [number of partitions](../rdd/Partitioner.md#numPartitions).

    The number of reduce blocks is the number of `MapStatus`es multiplied by the number of partitions.

    And hence the need for parallelism based on the [spark.shuffle.mapOutput.parallelAggregationThreshold](../configuration-properties.md#spark.shuffle.mapOutput.parallelAggregationThreshold) configuration property.

In the end, `getStatistics` creates a `MapOutputStatistics` with the shuffle ID and the total sizes (sumed up for every partition).

`getStatistics` is used when:

* `DAGScheduler` is requested to [handle a successful ShuffleMapStage submission](DAGScheduler.md#handleMapStageSubmitted) and [markMapStageJobsAsFinished](DAGScheduler.md#markMapStageJobsAsFinished)

## <span id="unregisterAllMapOutput"> Deregistering All Map Outputs of Shuffle Stage

```scala
unregisterAllMapOutput(
  shuffleId: Int): Unit
```

`unregisterAllMapOutput`...FIXME

`unregisterAllMapOutput` is used when `DAGScheduler` is requested to [handle a task completion (due to a fetch failure)](DAGScheduler.md#handleTaskCompletion).

## <span id="unregisterShuffle"> Deregistering Shuffle

```scala
unregisterShuffle(
  shuffleId: Int): Unit
```

`unregisterShuffle`...FIXME

`unregisterShuffle` is part of the [MapOutputTracker](MapOutputTracker.md#unregisterShuffle) abstraction.

## <span id="removeOutputsOnHost"> Deregistering Shuffle Outputs Associated with Host

```scala
removeOutputsOnHost(
  host: String): Unit
```

`removeOutputsOnHost`...FIXME

`removeOutputsOnHost` is used when `DAGScheduler` is requested to [removeExecutorAndUnregisterOutputs](DAGScheduler.md#removeExecutorAndUnregisterOutputs) and [handle a worker removal](DAGScheduler.md#handleWorkerRemoved).

## <span id="removeOutputsOnExecutor"> Deregistering Shuffle Outputs Associated with Executor

```scala
removeOutputsOnExecutor(
  execId: String): Unit
```

`removeOutputsOnExecutor`...FIXME

`removeOutputsOnExecutor` is used when `DAGScheduler` is requested to [removeExecutorAndUnregisterOutputs](DAGScheduler.md#removeExecutorAndUnregisterOutputs).

## <span id="getNumAvailableOutputs"> Number of Partitions with Shuffle Map Outputs Available

```scala
getNumAvailableOutputs(
  shuffleId: Int): Int
```

`getNumAvailableOutputs`...FIXME

`getNumAvailableOutputs` is used when `ShuffleMapStage` is requested for the [number of partitions with shuffle outputs available](ShuffleMapStage.md#numAvailableOutputs).

## <span id="findMissingPartitions"> Finding Missing Partitions

```scala
findMissingPartitions(
  shuffleId: Int): Option[Seq[Int]]
```

`findMissingPartitions`...FIXME

`findMissingPartitions` is used when `ShuffleMapStage` is requested for [missing partitions](ShuffleMapStage.md#findMissingPartitions).

## <span id="getMapSizesByExecutorId"> Finding Locations with Blocks and Sizes

```scala
getMapSizesByExecutorId(
  shuffleId: Int,
  startPartition: Int,
  endPartition: Int): Iterator[(BlockManagerId, Seq[(BlockId, Long)])]
```

`getMapSizesByExecutorId` is part of the [MapOutputTracker](MapOutputTracker.md#getMapSizesByExecutorId) abstraction.

`getMapSizesByExecutorId` returns a collection of [BlockManagerId](../storage/BlockManagerId.md)s with their blocks and sizes.

When executed, `getMapSizesByExecutorId` prints out the following DEBUG message to the logs:

```text
Fetching outputs for shuffle [id], partitions [startPartition]-[endPartition]
```

`getMapSizesByExecutorId` [finds map outputs](#getStatuses) for the input `shuffleId`.

!!! note
    `getMapSizesByExecutorId` gets the map outputs for all the partitions (despite the method's signature).

In the end, `getMapSizesByExecutorId` [converts shuffle map outputs](#convertMapStatuses) (as `MapStatuses`) into the collection of [BlockManagerId](../storage/BlockManagerId.md)s with their blocks and sizes.

## Logging

Enable `ALL` logging level for `org.apache.spark.MapOutputTrackerMaster` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.MapOutputTrackerMaster=ALL
```

Refer to [Logging](../spark-logging.md).
