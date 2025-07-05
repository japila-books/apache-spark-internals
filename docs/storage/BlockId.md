# BlockId

`BlockId` is an [abstraction](#contract) of [data block identifiers](#implementations) based on an unique [name](#name).

## Contract

### <span id="toString"> Name { #name }

```scala
name: String
```

A globally unique identifier of this `Block`

Used when:

* `BlockManager` is requested to [putBlockDataAsStream](BlockManager.md#putBlockDataAsStream) and [readDiskBlockFromSameHostExecutor](BlockManager.md#readDiskBlockFromSameHostExecutor)
* `UpdateBlockInfo` is requested to [writeExternal](BlockManagerMasterEndpoint.md#UpdateBlockInfo)
* `DiskBlockManager` is requested to [getFile](DiskBlockManager.md#getFile) and [containsBlock](DiskBlockManager.md#containsBlock)
* `DiskStore` is requested to [getBytes](DiskStore.md#getBytes), [remove](DiskStore.md#remove), [moveFileToBlock](DiskStore.md#moveFileToBlock), [contains](DiskStore.md#contains)

## Implementations

??? note "Sealed Abstract Class"
    `BlockId` is a Scala **sealed abstract class** which means that all of the implementations are in the same compilation unit (a single file).

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#sealed).

### BroadcastBlockId { #BroadcastBlockId }

`BlockId` for [broadcast variable](../broadcast-variables/index.md) blocks:

* `broadcastId` identifier
* Optional `field` name (default: `empty`)

Uses **broadcast_** prefix for the [name](#name)

Used when:

* `TorrentBroadcast` is [created](../broadcast-variables/TorrentBroadcast.md#broadcastId), requested to [store a broadcast and the blocks in a local BlockManager](../broadcast-variables/TorrentBroadcast.md#writeBlocks), and [read blocks](../broadcast-variables/TorrentBroadcast.md#readBlocks)
* `BlockManager` is requested to [remove all the blocks of a broadcast variable](BlockManager.md#removeBroadcast)
* `SerializerManager` is requested to [shouldCompress](../serializer/SerializerManager.md#shouldCompress)
* `AppStatusListener` is requested to [onBlockUpdated](../status/AppStatusListener.md#onBlockUpdated)

### CacheId { #CacheId }

`BlockId` for...FIXME

### PythonStreamBlockId { #PythonStreamBlockId }

`BlockId` for...FIXME

### RDDBlockId { #RDDBlockId }

`BlockId` for [RDD](../rdd/RDD.md) partitions:

* `rddId` identifier
* `splitIndex` identifier

Uses **rdd_** prefix for the [name](#name)

Used when:

* `StorageStatus` is requested to [register the status of a data block](StorageStatus.md#addBlock), [get the status of a data block](StorageStatus.md#getBlock), [updateStorageInfo](StorageStatus.md#updateStorageInfo)
* `LocalRDDCheckpointData` is requested to [doCheckpoint](../rdd/LocalRDDCheckpointData.md#doCheckpoint)
* `RDD` is requested to [getOrCompute](../rdd/RDD.md#getOrCompute)
* `DAGScheduler` is requested for the [BlockManagers (executors) for cached RDD partitions](../scheduler/DAGScheduler.md#getCacheLocs)
* `BlockManagerMasterEndpoint` is requested to [removeRdd](BlockManagerMasterEndpoint.md#removeRdd)
* `AppStatusListener` is requested to [updateRDDBlock](../status/AppStatusListener.md#updateRDDBlock) (when [onBlockUpdated](../status/AppStatusListener.md#onBlockUpdated) for an `RDDBlockId`)

[Compressed](../serializer/SerializerManager.md#shouldCompress) when [spark.rdd.compress](../configuration-properties.md#spark.rdd.compress) configuration property is enabled

### ShuffleBlockBatchId { #ShuffleBlockBatchId }

`BlockId` for...FIXME

### ShuffleBlockChunkId { #ShuffleBlockChunkId }

`BlockId` for shuffle block chunks in [Push-Based Shuffle](../push-based-shuffle.md):

* `shuffleId` identifier
* `shuffleMergeId` identifier
* `reduceId` identifier
* `chunkId` identifier

Uses `shuffleChunk_[shuffleId]_[shuffleMergeId]_[reduceId]_[chunkId]` pattern for the [name](#name)

### ShuffleBlockId { #ShuffleBlockId }

`BlockId` for shuffle blocks:

* `shuffleId` identifier
* `mapId` identifier
* `reduceId` identifier

Uses **shuffle_** prefix for the [name](#name)

Used when:

* `ShuffleBlockFetcherIterator` is requested to [throwFetchFailedException](ShuffleBlockFetcherIterator.md#throwFetchFailedException)
* `MapOutputTracker` utility is requested to [convertMapStatuses](../scheduler/MapOutputTracker.md#convertMapStatuses)
* `NettyBlockRpcServer` is requested to [handle a FetchShuffleBlocks message](NettyBlockRpcServer.md#FetchShuffleBlocks)
* `ExternalSorter` is requested to [writePartitionedMapOutput](../shuffle/ExternalSorter.md#writePartitionedMapOutput)
* `ShuffleBlockFetcherIterator` is requested to [mergeContinuousShuffleBlockIdsIfNeeded](ShuffleBlockFetcherIterator.md#mergeContinuousShuffleBlockIdsIfNeeded)
* `IndexShuffleBlockResolver` is requested to [getBlockData](../shuffle/IndexShuffleBlockResolver.md#getBlockData)

[Compressed](../serializer/SerializerManager.md#shouldCompress) when [spark.shuffle.compress](../configuration-properties.md#spark.shuffle.compress) configuration property is enabled

### ShuffleChecksumBlockId { #ShuffleChecksumBlockId }

`BlockId` for...FIXME

### ShuffleDataBlockId { #ShuffleDataBlockId }

`BlockId` for...FIXME

### ShuffleIndexBlockId { #ShuffleIndexBlockId }

`BlockId` for...FIXME

### ShuffleMergedBlockId { #ShuffleMergedBlockId }

`BlockId` for...FIXME

### ShuffleMergedDataBlockId { #ShuffleMergedDataBlockId }

`BlockId` for...FIXME

### ShuffleMergedIndexBlockId { #ShuffleMergedIndexBlockId }

`BlockId` for...FIXME

### ShuffleMergedMetaBlockId { #ShuffleMergedMetaBlockId }

`BlockId` for...FIXME

### ShufflePushBlockId { #ShufflePushBlockId }

`BlockId` for...FIXME

### StreamBlockId { #StreamBlockId }

`BlockId` for...FIXME:

* `streamId`
* `uniqueId`

Uses the following [name](#name):

```text
input-[streamId]-[uniqueId]
```

Used in Spark Streaming

### TaskResultBlockId { #TaskResultBlockId }

`BlockId` for...FIXME

### TempLocalBlockId { #TempLocalBlockId }

`BlockId` for...FIXME

### TempShuffleBlockId { #TempShuffleBlockId }

`BlockId` for...FIXME

### TestBlockId { #TestBlockId }

`BlockId` for...FIXME

## Creating BlockId by Name { #apply }

```scala
apply(
  name: String): BlockId
```

`apply` creates one of the available [BlockId](#implementations)s by the given name (that uses a prefix to differentiate between different `BlockId`s).

`apply` is used when:

* `NettyBlockRpcServer` is requested to handle [OpenBlocks](NettyBlockRpcServer.md#OpenBlocks), [UploadBlock](NettyBlockRpcServer.md#UploadBlock) messages and [receiveStream](NettyBlockRpcServer.md#receiveStream)
* `UpdateBlockInfo` is requested to deserialize (`readExternal`)
* `DiskBlockManager` is requested for [all the blocks (from files stored on disk)](DiskBlockManager.md#getAllBlocks)
* `ShuffleBlockFetcherIterator` is requested to [sendRequest](ShuffleBlockFetcherIterator.md#sendRequest)
* `JsonProtocol` utility is used to [accumValueFromJson](../history-server/JsonProtocol.md#accumValueFromJson), [taskMetricsFromJson](../history-server/JsonProtocol.md#taskMetricsFromJson) and [blockUpdatedInfoFromJson](../history-server/JsonProtocol.md#blockUpdatedInfoFromJson)
