# BlockId

*BlockId* is an <<contract, abstraction>> of <<implementations, data block identifiers>> based on an unique <<name, name>>.

BlockId is a Scala sealed abstract class and so all the possible <<implementations, implementations>> are in the single Scala file alongside BlockId.

== [[contract]] Contract

=== [[name]][[toString]] Unique Name

[source, scala]
----
name: String
----

Used when:

* NettyBlockTransferService is requested to storage:NettyBlockTransferService.md#uploadBlock[upload a block]

* AppStatusListener is requested to [updateRDDBlock](../AppStatusListener.md#updateRDDBlock), [updateStreamBlock](../AppStatusListener.md#updateStreamBlock)

* BlockManager is requested to storage:BlockManager.md#putBlockDataAsStream[putBlockDataAsStream]

* UpdateBlockInfo is requested to storage:BlockManagerMasterEndpoint.md#UpdateBlockInfo[writeExternal]

* DiskBlockManager is requested to storage:DiskBlockManager.md#getFile[getFile] and storage:DiskBlockManager.md#containsBlock[containsBlock]

* DiskStore is requested to storage:DiskStore.md#getBytes[getBytes]

== [[implementations]] Available BlockIds

=== [[BroadcastBlockId]] BroadcastBlockId

BlockId for Broadcast.md[]s with `broadcastId` identifier and optional `field` name (default: `empty`)

Uses `broadcast_` prefix for the <<name, name>>

Used when:

* TorrentBroadcast is core:TorrentBroadcast.md#broadcastId[created], requested to core:TorrentBroadcast.md#writeBlocks[store a broadcast and the blocks in a local BlockManager], and <<readBlocks, read blocks>>

* BlockManager is requested to storage:BlockManager.md#removeBroadcast[remove all the blocks of a broadcast variable]

* AppStatusListener is requested to [updateBroadcastBlock](../AppStatusListener.md#updateBroadcastBlock) (when [onBlockUpdated](../AppStatusListener.md#onBlockUpdated) for a `BroadcastBlockId`)

serializer:SerializerManager.md#shouldCompress[Compressed] when core:BroadcastManager.md#spark.broadcast.compress[spark.broadcast.compress] configuration property is enabled

## <span id="RDDBlockId"> RDDBlockId

BlockId for RDD partitions with `rddId` and `splitIndex` identifiers

Uses `rdd_` prefix for the <<name, name>>

Used when:

* `StorageStatus` is requested to <<spark-blockmanager-StorageStatus.md#addBlock, register the status of a data block>>, <<spark-blockmanager-StorageStatus.md#getBlock, get the status of a data block>>, <<spark-blockmanager-StorageStatus.md#updateStorageInfo, updateStorageInfo>>

* `LocalCheckpointRDD` is requested to `compute` a partition

* LocalRDDCheckpointData is requested to rdd:LocalRDDCheckpointData.md#doCheckpoint[doCheckpoint]

* `RDD` is requested to rdd:RDD.md#getOrCompute[getOrCompute]

* `DAGScheduler` is requested for the scheduler:DAGScheduler.md#getCacheLocs[BlockManagers (executors) for cached RDD partitions]

* `AppStatusListener` is requested to [updateRDDBlock](../AppStatusListener.md#updateRDDBlock) (when [onBlockUpdated](../AppStatusListener.md#onBlockUpdated) for a `RDDBlockId`)

serializer:SerializerManager.md#shouldCompress[Compressed] when configuration-properties.md#spark.rdd.compress[spark.rdd.compress] configuration property is enabled (default: `false`)

=== [[ShuffleBlockId]] ShuffleBlockId

BlockId for _FIXME_ with `shuffleId`, `mapId`, and `reduceId` identifiers

Uses `shuffle_` prefix for the <<name, name>>

Used when:

* `ShuffleBlockFetcherIterator` is requested to storage:ShuffleBlockFetcherIterator.md#throwFetchFailedException[throwFetchFailedException]

* `MapOutputTracker` object is requested to scheduler:MapOutputTracker.md#convertMapStatuses[convertMapStatuses]

* `SortShuffleWriter` is requested to shuffle:SortShuffleWriter.md#write[write partition records]

* `ShuffleBlockResolver` is requested for a shuffle:ShuffleBlockResolver.md#getBlockData[ManagedBuffer to read shuffle block data file]

serializer:SerializerManager.md#shouldCompress[Compressed] when configuration-properties.md#spark.shuffle.compress[spark.shuffle.compress] configuration property is enabled (default: `true`)

=== [[ShuffleDataBlockId]] ShuffleDataBlockId

=== [[ShuffleIndexBlockId]] ShuffleIndexBlockId

=== [[StreamBlockId]] StreamBlockId

### <span id="TaskResultBlockId"> TaskResultBlockId

=== [[TempLocalBlockId]] TempLocalBlockId

=== [[TempShuffleBlockId]] TempShuffleBlockId

== [[apply]] apply Factory Method

[source, scala]
----
apply(
  name: String): BlockId
----

apply creates one of the available <<implementations, BlockIds>> by the given name (that uses a prefix to differentiate between different BlockIds).

apply is used when:

* NettyBlockRpcServer is requested to storage:NettyBlockRpcServer.md#receive[handle an RPC message] and storage:NettyBlockRpcServer.md#receiveStream[receiveStream]

* UpdateBlockInfo is requested to deserialize (readExternal)

* DiskBlockManager is requested for storage:DiskBlockManager.md#getAllBlocks[all the blocks (from files stored on disk)]

* ShuffleBlockFetcherIterator is requested to storage:ShuffleBlockFetcherIterator.md#sendRequest[sendRequest]

* JsonProtocol utility is used to spark-history-server:JsonProtocol.md#accumValueFromJson[accumValueFromJson], spark-history-server:JsonProtocol.md#taskMetricsFromJson[taskMetricsFromJson] and spark-history-server:JsonProtocol.md#blockUpdatedInfoFromJson[blockUpdatedInfoFromJson]
