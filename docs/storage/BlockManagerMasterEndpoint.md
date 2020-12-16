# BlockManagerMasterEndpoint

*BlockManagerMasterEndpoint* is a rpc:RpcEndpoint.md#ThreadSafeRpcEndpoint[ThreadSafeRpcEndpoint] for storage:BlockManagerMaster.md[BlockManagerMaster].

BlockManagerMasterEndpoint is registered under *BlockManagerMaster* name.

BlockManagerMasterEndpoint tracks status of the storage:BlockManager.md[BlockManagers] (on the executors) in a Spark application.

== [[creating-instance]] Creating Instance

BlockManagerMasterEndpoint takes the following to be created:

* [[rpcEnv]] rpc:RpcEnv.md[]
* [[isLocal]] Flag whether BlockManagerMasterEndpoint works in local or cluster mode
* [[conf]] SparkConf.md[]
* [[listenerBus]] scheduler:LiveListenerBus.md[]

BlockManagerMasterEndpoint is created for the core:SparkEnv.md#create[SparkEnv] on the driver (to create a storage:BlockManagerMaster.md[] for a storage:BlockManager.md#master[BlockManager]).

When created, BlockManagerMasterEndpoint prints out the following INFO message to the logs:

[source,plaintext]
----
BlockManagerMasterEndpoint up
----

== [[messages]][[receiveAndReply]] Messages

As an rpc:RpcEndpoint.md[], BlockManagerMasterEndpoint handles RPC messages.

=== [[BlockManagerHeartbeat]] BlockManagerHeartbeat

[source, scala]
----
BlockManagerHeartbeat(
  blockManagerId: BlockManagerId)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[GetLocations]] GetLocations

[source, scala]
----
GetLocations(
  blockId: BlockId)
----

When received, BlockManagerMasterEndpoint replies with the <<getLocations, locations>> of `blockId`.

Posted when BlockManagerMaster.md#getLocations-block[`BlockManagerMaster` requests the block locations of a single block].

=== [[GetLocationsAndStatus]] GetLocationsAndStatus

[source, scala]
----
GetLocationsAndStatus(
  blockId: BlockId)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[GetLocationsMultipleBlockIds]] GetLocationsMultipleBlockIds

[source, scala]
----
GetLocationsMultipleBlockIds(
  blockIds: Array[BlockId])
----

When received, BlockManagerMasterEndpoint replies with the <<getLocationsMultipleBlockIds, getLocationsMultipleBlockIds>> for the given storage:BlockId.md[].

Posted when BlockManagerMaster.md#getLocations[`BlockManagerMaster` requests the block locations for multiple blocks].

=== [[GetPeers]] GetPeers

[source, scala]
----
GetPeers(
  blockManagerId: BlockManagerId)
----

When received, BlockManagerMasterEndpoint replies with the <<getPeers, peers>> of `blockManagerId`.

*Peers* of a storage:BlockManager.md[BlockManager] are the other BlockManagers in a cluster (except the driver's BlockManager). Peers are used to know the available executors in a Spark application.

Posted when BlockManagerMaster.md#getPeers[`BlockManagerMaster` requests the peers of a `BlockManager`].

=== [[GetExecutorEndpointRef]] GetExecutorEndpointRef

[source, scala]
----
GetExecutorEndpointRef(
  executorId: String)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[GetMemoryStatus]] GetMemoryStatus

[source, scala]
----
GetMemoryStatus
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[GetStorageStatus]] GetStorageStatus

[source, scala]
----
GetStorageStatus
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[GetBlockStatus]] GetBlockStatus

[source, scala]
----
GetBlockStatus(
  blockId: BlockId,
  askSlaves: Boolean = true)
----

When received, BlockManagerMasterEndpoint is requested to <<blockStatus, blockStatus>>.

Posted when...FIXME

=== [[GetMatchingBlockIds]] GetMatchingBlockIds

[source, scala]
----
GetMatchingBlockIds(
  filter: BlockId => Boolean,
  askSlaves: Boolean = true)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[HasCachedBlocks]] HasCachedBlocks

[source, scala]
----
HasCachedBlocks(
  executorId: String)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[RegisterBlockManager]] RegisterBlockManager

[source,scala]
----
RegisterBlockManager(
  blockManagerId: BlockManagerId,
  maxOnHeapMemSize: Long,
  maxOffHeapMemSize: Long,
  sender: RpcEndpointRef)
----

When received, BlockManagerMasterEndpoint is requested to <<register, register the BlockManager>> (by the given storage:BlockManagerId.md[]).

Posted when BlockManagerMaster is requested to storage:BlockManagerMaster.md#registerBlockManager[register a BlockManager]

=== [[RemoveRdd]] RemoveRdd

[source, scala]
----
RemoveRdd(
  rddId: Int)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[RemoveShuffle]] RemoveShuffle

[source, scala]
----
RemoveShuffle(
  shuffleId: Int)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[RemoveBroadcast]] RemoveBroadcast

[source, scala]
----
RemoveBroadcast(
  broadcastId: Long,
  removeFromDriver: Boolean = true)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[RemoveBlock]] RemoveBlock

[source, scala]
----
RemoveBlock(
  blockId: BlockId)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[RemoveExecutor]] RemoveExecutor

[source, scala]
----
RemoveExecutor(
  execId: String)
----

When received, BlockManagerMasterEndpoint <<removeExecutor, executor `execId` is removed>> and the response `true` sent back.

Posted when BlockManagerMaster.md#removeExecutor[`BlockManagerMaster` removes an executor].

=== [[StopBlockManagerMaster]] StopBlockManagerMaster

[source, scala]
----
StopBlockManagerMaster
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when...FIXME

=== [[UpdateBlockInfo]] UpdateBlockInfo

[source, scala]
----
UpdateBlockInfo(
  blockManagerId: BlockManagerId,
  blockId: BlockId,
  storageLevel: StorageLevel,
  memSize: Long,
  diskSize: Long)
----

When received, BlockManagerMasterEndpoint...FIXME

Posted when BlockManagerMaster is requested to storage:BlockManagerMaster.md#updateBlockInfo[handle a block status update (from BlockManager on an executor)].

== [[storageStatus]] storageStatus Internal Method

[source,scala]
----
storageStatus: Array[StorageStatus]
----

storageStatus...FIXME

storageStatus is used when BlockManagerMasterEndpoint is requested to handle <<GetStorageStatus, GetStorageStatus>> message.

== [[getLocationsMultipleBlockIds]] getLocationsMultipleBlockIds Internal Method

[source,scala]
----
getLocationsMultipleBlockIds(
  blockIds: Array[BlockId]): IndexedSeq[Seq[BlockManagerId]]
----

getLocationsMultipleBlockIds...FIXME

getLocationsMultipleBlockIds is used when BlockManagerMasterEndpoint is requested to handle <<GetLocationsMultipleBlockIds, GetLocationsMultipleBlockIds>> message.

== [[removeShuffle]] removeShuffle Internal Method

[source,scala]
----
removeShuffle(
  shuffleId: Int): Future[Seq[Boolean]]
----

removeShuffle...FIXME

removeShuffle is used when BlockManagerMasterEndpoint is requested to handle <<RemoveShuffle, RemoveShuffle>> message.

== [[getPeers]] getPeers Internal Method

[source, scala]
----
getPeers(
  blockManagerId: BlockManagerId): Seq[BlockManagerId]
----

getPeers finds all the registered `BlockManagers` (using <<blockManagerInfo, blockManagerInfo>> internal registry) and checks if the input `blockManagerId` is amongst them.

If the input `blockManagerId` is registered, getPeers returns all the registered `BlockManagers` but the one on the driver and `blockManagerId`.

Otherwise, getPeers returns no `BlockManagers`.

NOTE: *Peers* of a storage:BlockManager.md[BlockManager] are the other BlockManagers in a cluster (except the driver's BlockManager). Peers are used to know the available executors in a Spark application.

getPeers is used when BlockManagerMasterEndpoint is requested to handle <<GetPeers, GetPeers>> message.

== [[register]] register Internal Method

[source, scala]
----
register(
  idWithoutTopologyInfo: BlockManagerId,
  maxOnHeapMemSize: Long,
  maxOffHeapMemSize: Long,
  slaveEndpoint: RpcEndpointRef): BlockManagerId
----

register registers a storage:BlockManager.md[] (based on the given storage:BlockManagerId.md[]) in the <<blockManagerIdByExecutor, blockManagerIdByExecutor>> and <<blockManagerInfo, blockManagerInfo>> registries and posts a SparkListenerBlockManagerAdded message (to the <<listenerBus, LiveListenerBus>>).

NOTE: The input `maxMemSize` is the storage:BlockManager.md#maxMemory[total available on-heap and off-heap memory for storage on a `BlockManager`].

NOTE: Registering a `BlockManager` can only happen once for an executor (identified by `BlockManagerId.executorId` in <<blockManagerIdByExecutor, blockManagerIdByExecutor>> internal registry).

If another `BlockManager` has earlier been registered for the executor, you should see the following ERROR message in the logs:

[source,plaintext]
----
Got two different block manager registrations on same executor - will replace old one [oldId] with new one [id]
----

And then <<removeExecutor, executor is removed>>.

register prints out the following INFO message to the logs:

[source,plaintext]
----
Registering block manager [hostPort] with [bytes] RAM, [id]
----

The `BlockManager` is recorded in the internal registries:

* <<blockManagerIdByExecutor, blockManagerIdByExecutor>>
* <<blockManagerInfo, blockManagerInfo>>

In the end, register requests the <<listenerBus, LiveListenerBus>> to scheduler:LiveListenerBus.md#post[post] a SparkListener.md#SparkListenerBlockManagerAdded[SparkListenerBlockManagerAdded] message.

register is used when BlockManagerMasterEndpoint is requested to handle <<RegisterBlockManager, RegisterBlockManager>> message.

== [[removeExecutor]] removeExecutor Internal Method

[source, scala]
----
removeExecutor(
  execId: String): Unit
----

removeExecutor prints the following INFO message to the logs:

[source,plaintext]
----
Trying to remove executor [execId] from BlockManagerMaster.
----

If the `execId` executor is registered (in the internal <<blockManagerIdByExecutor, blockManagerIdByExecutor>> internal registry), removeExecutor <<removeBlockManager, removes the corresponding `BlockManager`>>.

removeExecutor is used when BlockManagerMasterEndpoint is requested to handle <<RemoveExecutor, RemoveExecutor>> or <<RegisterBlockManager, RegisterBlockManager>> messages.

== [[removeBlockManager]] removeBlockManager Internal Method

[source, scala]
----
removeBlockManager(
  blockManagerId: BlockManagerId): Unit
----

removeBlockManager looks up `blockManagerId` and removes the executor it was working on from the internal registries:

* <<blockManagerIdByExecutor, blockManagerIdByExecutor>>
* <<blockManagerInfo, blockManagerInfo>>

It then goes over all the blocks for the `BlockManager`, and removes the executor for each block from `blockLocations` registry.

SparkListener.md#SparkListenerBlockManagerRemoved[SparkListenerBlockManagerRemoved(System.currentTimeMillis(), blockManagerId)] is posted to SparkContext.md#listenerBus[listenerBus].

You should then see the following INFO message in the logs:

[source,plaintext]
----
Removing block manager [blockManagerId]
----

removeBlockManager is used when BlockManagerMasterEndpoint is requested to <<removeExecutor, removeExecutor>> (to handle <<RemoveExecutor, RemoveExecutor>> or <<RegisterBlockManager, RegisterBlockManager>> messages).

== [[getLocations]] getLocations Internal Method

[source, scala]
----
getLocations(
  blockId: BlockId): Seq[BlockManagerId]
----

getLocations looks up the given storage:BlockId.md[] in the `blockLocations` internal registry and returns the locations (as a collection of `BlockManagerId`) or an empty collection.

getLocations is used when BlockManagerMasterEndpoint is requested to handle <<GetLocations, GetLocations>> and <<GetLocationsMultipleBlockIds, GetLocationsMultipleBlockIds>> messages.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockManagerMasterEndpoint` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.storage.BlockManagerMasterEndpoint=ALL
----

Refer to spark-logging.md[Logging].

== [[internal-properties]] Internal Properties

=== [[blockManagerIdByExecutor]] blockManagerIdByExecutor Lookup Table

[source,scala]
----
blockManagerIdByExecutor: Map[String, BlockManagerId]
----

Lookup table of storage:BlockManagerId.md[]s by executor ID

A new executor is added when BlockManagerMasterEndpoint is requested to handle a <<RegisterBlockManager, RegisterBlockManager>> message (and <<register, registers a new BlockManager>>).

An executor is removed when BlockManagerMasterEndpoint is requested to handle a <<RemoveExecutor, RemoveExecutor>> and a <<RegisterBlockManager, RegisterBlockManager>> messages (via <<removeBlockManager, removeBlockManager>>)

Used when BlockManagerMasterEndpoint is requested to handle <<HasCachedBlocks, HasCachedBlocks>> message, <<removeExecutor, removeExecutor>>, <<register, register>> and <<getExecutorEndpointRef, getExecutorEndpointRef>>.

=== [[blockManagerInfo]] blockManagerInfo Lookup Table

[source,scala]
----
blockManagerIdByExecutor: Map[String, BlockManagerId]
----

Lookup table of storage:BlockManagerInfo.md[] by storage:BlockManagerId.md[]

A new BlockManagerInfo is added when BlockManagerMasterEndpoint is requested to handle a <<RegisterBlockManager, RegisterBlockManager>> message (and <<register, registers a new BlockManager>>).

A BlockManagerInfo is removed when BlockManagerMasterEndpoint is requested to <<removeBlockManager, remove a BlockManager>> (to handle <<RemoveExecutor, RemoveExecutor>> and <<RegisterBlockManager, RegisterBlockManager>> messages).

=== [[blockLocations]] blockLocations

[source,scala]
----
blockLocations: Map[BlockId, Set[BlockManagerId]]
----

Collection of storage:BlockId.md[] and their locations (as `BlockManagerId`).

Used in `removeRdd` to remove blocks for a RDD, removeBlockManager to remove blocks after a BlockManager gets removed, `removeBlockFromWorkers`, `updateBlockInfo`, and <<getLocations, getLocations>>.
