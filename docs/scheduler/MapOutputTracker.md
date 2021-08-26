# MapOutputTracker

`MapOutputTracker` is an [base abstraction](#contract) of [shuffle map output location registries](#implementations).

## Contract

### <span id="getMapSizesByExecutorId"> getMapSizesByExecutorId

```scala
getMapSizesByExecutorId(
  shuffleId: Int,
  startPartition: Int,
  endPartition: Int): Iterator[(BlockManagerId, Seq[(BlockId, Long, Int)])]
```

Used when:

* `SortShuffleManager` is requested for a [ShuffleReader](../shuffle/SortShuffleManager.md#getReader)

### <span id="getMapSizesByRange"> getMapSizesByRange

```scala
getMapSizesByRange(
  shuffleId: Int,
  startMapIndex: Int,
  endMapIndex: Int,
  startPartition: Int,
  endPartition: Int): Iterator[(BlockManagerId, Seq[(BlockId, Long, Int)])]
```

Used when:

* `SortShuffleManager` is requested for a [ShuffleReader](../shuffle/SortShuffleManager.md#getReaderForRange)

### <span id="unregisterShuffle"> unregisterShuffle

```scala
unregisterShuffle(
  shuffleId: Int): Unit
```

Deletes map output status information for the specified shuffle stage

Used when:

* `ContextCleaner` is requested to [doCleanupShuffle](../core/ContextCleaner.md#doCleanupShuffle)
* `BlockManagerSlaveEndpoint` is requested to [handle a RemoveShuffle message](../storage/BlockManagerSlaveEndpoint.md#RemoveShuffle)

## Implementations

* [MapOutputTrackerMaster](MapOutputTrackerMaster.md)
* [MapOutputTrackerWorker](MapOutputTrackerWorker.md)

## Creating Instance

`MapOutputTracker` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)

??? note "Abstract Class"
    `MapOutputTracker` is an abstract class and cannot be created directly. It is created indirectly for the [concrete MapOutputTrackers](#implementations).

## Accessing MapOutputTracker

`MapOutputTracker` is available using [SparkEnv](../SparkEnv.md#mapOutputTracker) (on the driver and executors).

```scala
SparkEnv.get.mapOutputTracker
```

## <span id="trackerEndpoint"><span id="ENDPOINT_NAME"> MapOutputTracker RPC Endpoint

`trackerEndpoint` is a [RpcEndpointRef](../rpc/RpcEndpointRef.md) of the **MapOutputTracker** RPC endpoint.

`trackerEndpoint` is initialized (registered or looked up) when `SparkEnv` is [created](../SparkEnv.md#create) for the driver and executors.

`trackerEndpoint` is used to [communicate (synchronously)](#askTracker).

`trackerEndpoint` is cleared (`null`) when `MapOutputTrackerMaster` is requested to [stop](MapOutputTrackerMaster.md#stop).

## <span id="unregisterShuffle"> Deregistering Map Output Status Information of Shuffle Stage

```scala
unregisterShuffle(
  shuffleId: Int): Unit
```

Deregisters map output status information for the given shuffle stage

Used when:

* `ContextCleaner` is requested for [shuffle cleanup](../core/ContextCleaner.md#doCleanupShuffle)

* `BlockManagerSlaveEndpoint` is requested to [remove a shuffle](../storage/BlockManagerSlaveEndpoint.md#RemoveShuffle)

## <span id="stop"> Stopping MapOutputTracker

```scala
stop(): Unit
```

`stop` does nothing at all.

`stop` is used when `SparkEnv` is requested to [stop](../SparkEnv.md#stop) (and stops all the services, incl. `MapOutputTracker`).

## <span id="convertMapStatuses"> Converting MapStatuses To BlockManagerIds with ShuffleBlockIds and Their Sizes

```scala
convertMapStatuses(
  shuffleId: Int,
  startPartition: Int,
  endPartition: Int,
  statuses: Array[MapStatus]): Seq[(BlockManagerId, Seq[(BlockId, Long)])]
```

`convertMapStatuses` iterates over the input `statuses` array (of [MapStatus](MapStatus.md) entries indexed by map id) and creates a collection of [BlockManagerId](../storage/BlockManagerId.md)s (for each `MapStatus` entry) with a [ShuffleBlockId](../storage/BlockId.md#ShuffleBlockId) (with the input `shuffleId`, a `mapId`, and `partition` ranging from the input `startPartition` and `endPartition`) and [estimated size for the reduce block](MapStatus.md#getSizeForBlock) for every status and partitions.

For any empty `MapStatus`, `convertMapStatuses` prints out the following ERROR message to the logs:

```text
Missing an output location for shuffle [id]
```

And `convertMapStatuses` throws a `MetadataFetchFailedException` (with `shuffleId`, `startPartition`, and the above error message).

`convertMapStatuses` is used when:

* `MapOutputTrackerMaster` is requested for the sizes of shuffle map outputs by [executor](MapOutputTrackerMaster.md#getMapSizesByExecutorId) and [range](#getMapSizesByRange)
* `MapOutputTrackerWorker` is requested to sizes of shuffle map outputs by [executor](MapOutputTrackerWorker.md#getMapSizesByExecutorId) and [range](MapOutputTrackerWorker.md#getMapSizesByRange)

## <span id="askTracker"> Sending Blocking Messages To trackerEndpoint RpcEndpointRef

```scala
askTracker[T](message: Any): T
```

`askTracker` [sends](../rpc/RpcEndpointRef.md#askWithRetry) the input `message` to [trackerEndpoint RpcEndpointRef](#trackerEndpoint) and waits for a result.

When an exception happens, `askTracker` prints out the following ERROR message to the logs and throws a `SparkException`.

```text
Error communicating with MapOutputTracker
```

`askTracker` is used when `MapOutputTracker` is requested to [fetches map outputs for `ShuffleDependency` remotely](#getStatuses) and [sends a one-way message](#sendTracker).

## <span id="epoch"><span id="epochLock"> Epoch

Starts from `0` when `MapOutputTracker` is [created](#creating-instance).

Can be [updated](#updateEpoch) (on `MapOutputTrackerWorkers`) or [incremented](MapOutputTrackerMaster.md#incrementEpoch) (on the driver's `MapOutputTrackerMaster`).

## <span id="sendTracker"> sendTracker

```scala
sendTracker(
  message: Any): Unit
```

`sendTracker`...FIXME

`sendTracker` is used when:

* `MapOutputTrackerMaster` is requested to [stop](MapOutputTrackerMaster.md#stop)

## Utilities

### <span id="serializeMapStatuses"> serializeMapStatuses

```scala
serializeMapStatuses(
  statuses: Array[MapStatus],
  broadcastManager: BroadcastManager,
  isLocal: Boolean,
  minBroadcastSize: Int,
  conf: SparkConf): (Array[Byte], Broadcast[Array[Byte]])
```

`serializeMapStatuses` serializes the given array of map output locations into an efficient byte format (to send to reduce tasks). `serializeMapStatuses` compresses the serialized bytes using GZIP. They are supposed to be pretty compressible because many map outputs will be on the same hostname.

Internally, `serializeMapStatuses` creates a Java [ByteArrayOutputStream]({{ java.api }}/java.base/java/io/ByteArrayOutputStream.html).

`serializeMapStatuses` writes out 0 (direct) first.

`serializeMapStatuses` creates a Java [GZIPOutputStream]({{ java.api }}/java.base/java/util/zip/GZIPOutputStream.html) (with the `ByteArrayOutputStream` created) and writes out the given statuses array.

`serializeMapStatuses` decides whether to return the output array (of the output stream) or use a broadcast variable based on the size of the byte array.

If the size of the result byte array is the given `minBroadcastSize` threshold or bigger, `serializeMapStatuses` requests the input `BroadcastManager` to [create a broadcast variable](../broadcast-variables/BroadcastManager.md#newBroadcast).

`serializeMapStatuses` resets the `ByteArrayOutputStream` and starts over.

`serializeMapStatuses` writes out 1 (broadcast) first.

`serializeMapStatuses` creates a new Java `GZIPOutputStream` (with the `ByteArrayOutputStream` created) and writes out the broadcast variable.

`serializeMapStatuses` prints out the following INFO message to the logs:

```scala
Broadcast mapstatuses size = [length], actual size = [length]
```

`serializeMapStatuses` is used when `ShuffleStatus` is requested to [serialize shuffle map output statuses](ShuffleStatus.md#serializedMapStatus).

### <span id="deserializeMapStatuses"> deserializeMapStatuses

```scala
deserializeMapStatuses(
  bytes: Array[Byte],
  conf: SparkConf): Array[MapStatus]
```

`deserializeMapStatuses`...FIXME

`deserializeMapStatuses` is used when:

* `MapOutputTrackerWorker` is requested to [getStatuses](MapOutputTrackerWorker.md#getStatuses)
