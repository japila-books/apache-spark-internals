= BlockManagerMaster

BlockManagerMaster core:SparkEnv.md#BlockManagerMaster[runs on the driver].

BlockManagerMaster uses storage:BlockManagerMasterEndpoint.md[] registered under *BlockManagerMaster* RPC endpoint name on the driver (with the endpoint references on executors) to allow executors for sending block status updates to it and hence keep track of block statuses.

== [[creating-instance]] Creating Instance

BlockManagerMaster takes the following to be created:

* [[driverEndpoint]] rpc:RpcEndpointRef.md[]
* [[conf]] ROOT:SparkConf.md[]
* [[isDriver]] Flag whether BlockManagerMaster is created for the driver or executors

BlockManagerMaster is created when SparkEnv utility is used to core:SparkEnv.md#create[create a SparkEnv (for the driver and executors)] (to create a storage:BlockManager.md[]).

== [[removeExecutorAsync]] `removeExecutorAsync` Method

CAUTION: FIXME

== [[contains]] `contains` Method

CAUTION: FIXME

== [[removeExecutor]] Removing Executor -- `removeExecutor` Method

[source, scala]
----
removeExecutor(execId: String): Unit
----

`removeExecutor` posts storage:BlockManagerMasterEndpoint.md#RemoveExecutor[`RemoveExecutor` to BlockManagerMaster RPC endpoint] and waits for a response.

If `false` in response comes in, a `SparkException` is thrown with the following message:

```
BlockManagerMasterEndpoint returned false, expected true.
```

If all goes fine, you should see the following INFO message in the logs:

```
INFO BlockManagerMaster: Removed executor [execId]
```

NOTE: `removeExecutor` is executed when scheduler:DAGSchedulerEventProcessLoop.md#handleExecutorLost[`DAGScheduler` processes `ExecutorLost` event].

== [[removeBlock]] Removing Block -- `removeBlock` Method

[source, scala]
----
removeBlock(blockId: BlockId): Unit
----

`removeBlock` simply posts a `RemoveBlock` blocking message to storage:BlockManagerMasterEndpoint.md[] (and ultimately disregards the reponse).

== [[removeRdd]] Removing RDD Blocks -- `removeRdd` Method

[source, scala]
----
removeRdd(rddId: Int, blocking: Boolean)
----

`removeRdd` removes all the blocks of `rddId` RDD, possibly in `blocking` fashion.

Internally, `removeRdd` posts a `RemoveRdd(rddId)` message to storage:BlockManagerMasterEndpoint.md[] on a separate thread.

If there is an issue, you should see the following WARN message in the logs and the entire exception:

```
WARN Failed to remove RDD [rddId] - [exception]
```

If it is a `blocking` operation, it waits for a result for rpc:index.md#spark.rpc.askTimeout[spark.rpc.askTimeout], rpc:index.md#spark.network.timeout[spark.network.timeout] or `120` secs.

== [[removeShuffle]] Removing Shuffle Blocks -- `removeShuffle` Method

[source, scala]
----
removeShuffle(shuffleId: Int, blocking: Boolean)
----

`removeShuffle` removes all the blocks of `shuffleId` shuffle, possibly in a `blocking` fashion.

It posts a `RemoveShuffle(shuffleId)` message to storage:BlockManagerMasterEndpoint.md[] on a separate thread.

If there is an issue, you should see the following WARN message in the logs and the entire exception:

```
WARN Failed to remove shuffle [shuffleId] - [exception]
```

If it is a `blocking` operation, it waits for the result for rpc:index.md#spark.rpc.askTimeout[spark.rpc.askTimeout], rpc:index.md#spark.network.timeout[spark.network.timeout] or `120` secs.

NOTE: `removeShuffle` is used exclusively when core:ContextCleaner.md#doCleanupShuffle[`ContextCleaner` removes a shuffle].

== [[removeBroadcast]] Removing Broadcast Blocks -- `removeBroadcast` Method

[source, scala]
----
removeBroadcast(broadcastId: Long, removeFromMaster: Boolean, blocking: Boolean)
----

`removeBroadcast` removes all the blocks of `broadcastId` broadcast, possibly in a `blocking` fashion.

It posts a `RemoveBroadcast(broadcastId, removeFromMaster)` message to storage:BlockManagerMasterEndpoint.md[] on a separate thread.

If there is an issue, you should see the following WARN message in the logs and the entire exception:

```
WARN Failed to remove broadcast [broadcastId] with removeFromMaster = [removeFromMaster] - [exception]
```

If it is a `blocking` operation, it waits for the result for rpc:index.md#spark.rpc.askTimeout[spark.rpc.askTimeout], rpc:index.md#spark.network.timeout[spark.network.timeout] or `120` secs.

== [[stop]] Stopping BlockManagerMaster -- `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` sends a `StopBlockManagerMaster` message to storage:BlockManagerMasterEndpoint.md[] and waits for a response.

NOTE: It is only executed for the driver.

If all goes fine, you should see the following INFO message in the logs:

```
INFO BlockManagerMaster: BlockManagerMaster stopped
```

Otherwise, a `SparkException` is thrown.

```
BlockManagerMasterEndpoint returned false, expected true.
```

== [[registerBlockManager]] Registering BlockManager with Driver

[source, scala]
----
registerBlockManager(
  blockManagerId: BlockManagerId,
  maxMemSize: Long,
  slaveEndpoint: RpcEndpointRef): BlockManagerId
----

registerBlockManager prints the following INFO message to the logs:

[source,plaintext]
----
Registering BlockManager [blockManagerId]
----

.Registering BlockManager with the Driver
image::BlockManagerMaster-RegisterBlockManager.png[align="center"]

registerBlockManager then notifies the driver that the storage:BlockManagerId.md[] is registering itself. registerBlockManager posts a storage:BlockManagerMasterEndpoint.md#RegisterBlockManager[blocking `RegisterBlockManager` message to BlockManagerMaster RPC endpoint].

NOTE: The input `maxMemSize` is the storage:BlockManager.md#maxMemory[total available on-heap and off-heap memory for storage on a `BlockManager`].

registerBlockManager waits until a confirmation comes (as storage:BlockManagerId.md[]).

In the end, registerBlockManager prints the following INFO message to the logs and returns the storage:BlockManagerId.md[] received.

[source,plaintext]
----
Registered BlockManager [updatedId]
----

registerBlockManager is used when BlockManager is requested to storage:BlockManager.md#initialize[initialize] and storage:BlockManager.md#reregister[re-register itself with the driver].

== [[updateBlockInfo]] Relaying Block Status Update From BlockManager to Driver

[source, scala]
----
updateBlockInfo(
  blockManagerId: BlockManagerId,
  blockId: BlockId,
  storageLevel: StorageLevel,
  memSize: Long,
  diskSize: Long): Boolean
----

`updateBlockInfo` sends a blocking storage:BlockManagerMasterEndpoint.md#UpdateBlockInfo[UpdateBlockInfo] event to <<driverEndpoint, BlockManagerMaster RPC endpoint>> (and waits for a response).

`updateBlockInfo` prints out the following DEBUG message to the logs:

```
DEBUG BlockManagerMaster: Updated info of block [blockId]
```

`updateBlockInfo` returns the response from the <<driverEndpoint, BlockManagerMaster RPC endpoint>>.

NOTE: `updateBlockInfo` is used exclusively when `BlockManager` is requested to storage:BlockManager.md#tryToReportBlockStatus[report a block status update to the driver].

== [[getLocations-block]] Get Block Locations of One Block -- `getLocations` Method

[source, scala]
----
getLocations(blockId: BlockId): Seq[BlockManagerId]
----

`getLocations` storage:BlockManagerMasterEndpoint.md#GetLocations[posts a blocking `GetLocations` message to BlockManagerMaster RPC endpoint] and returns the response.

NOTE: `getLocations` is used when <<contains, BlockManagerMaster checks if a block was registered>> and storage:BlockManager.md#getLocations[`BlockManager` getLocations].

== [[getLocations-block-array]] Get Block Locations for Multiple Blocks -- `getLocations` Method

[source, scala]
----
getLocations(blockIds: Array[BlockId]): IndexedSeq[Seq[BlockManagerId]]
----

`getLocations` storage:BlockManagerMasterEndpoint.md#GetLocationsMultipleBlockIds[posts a blocking `GetLocationsMultipleBlockIds` message to BlockManagerMaster RPC endpoint] and returns the response.

NOTE: `getLocations` is used when scheduler:DAGScheduler.md#getCacheLocs[`DAGScheduler` finds BlockManagers (and so executors) for cached RDD partitions] and when `BlockManager` storage:BlockManager.md#getLocationBlockIds[getLocationBlockIds] and storage:BlockManager.md#blockIdsToHosts[blockIdsToHosts].

== [[getPeers]] Finding Peers of BlockManager -- `getPeers` Internal Method

[source, scala]
----
getPeers(blockManagerId: BlockManagerId): Seq[BlockManagerId]
----

`getPeers` storage:BlockManagerMasterEndpoint.md#GetPeers[posts a blocking `GetPeers` message to BlockManagerMaster RPC endpoint] and returns the response.

NOTE: *Peers* of a storage:BlockManager.md[BlockManager] are the other BlockManagers in a cluster (except the driver's BlockManager). Peers are used to know the available executors in a Spark application.

NOTE: `getPeers` is used when storage:BlockManager.md#getPeers[`BlockManager` finds the peers of a `BlockManager`], Structured Streaming's `KafkaSource` and Spark Streaming's `KafkaRDD`.

== [[getExecutorEndpointRef]] `getExecutorEndpointRef` Method

[source, scala]
----
getExecutorEndpointRef(executorId: String): Option[RpcEndpointRef]
----

`getExecutorEndpointRef` posts `GetExecutorEndpointRef(executorId)` message to storage:BlockManagerMasterEndpoint.md[] and waits for a response which becomes the return value.

== [[getMemoryStatus]] `getMemoryStatus` Method

[source, scala]
----
getMemoryStatus: Map[BlockManagerId, (Long, Long)]
----

`getMemoryStatus` posts a `GetMemoryStatus` message storage:BlockManagerMasterEndpoint.md[] and waits for a response which becomes the return value.

== [[getStorageStatus]] Storage Status (Posting GetStorageStatus to BlockManagerMaster RPC endpoint) -- `getStorageStatus` Method

[source, scala]
----
getStorageStatus: Array[StorageStatus]
----

`getStorageStatus` posts a `GetStorageStatus` message to storage:BlockManagerMasterEndpoint.md[] and waits for a response which becomes the return value.

== [[getBlockStatus]] `getBlockStatus` Method

[source, scala]
----
getBlockStatus(
  blockId: BlockId,
  askSlaves: Boolean = true): Map[BlockManagerId, BlockStatus]
----

`getBlockStatus` posts a `GetBlockStatus(blockId, askSlaves)` message to storage:BlockManagerMasterEndpoint.md[] and waits for a response (of type `Map[BlockManagerId, Future[Option[BlockStatus]]]`).

It then builds a sequence of future results that are `BlockStatus` statuses and waits for a result for rpc:index.md#spark.rpc.askTimeout[spark.rpc.askTimeout], rpc:index.md#spark.network.timeout[spark.network.timeout] or `120` secs.

No result leads to a `SparkException` with the following message:

```
BlockManager returned null for BlockStatus query: [blockId]
```

== [[getMatchingBlockIds]] `getMatchingBlockIds` Method

[source, scala]
----
getMatchingBlockIds(
  filter: BlockId => Boolean,
  askSlaves: Boolean): Seq[BlockId]
----

`getMatchingBlockIds` posts a `GetMatchingBlockIds(filter, askSlaves)` message to storage:BlockManagerMasterEndpoint.md[] and waits for a response which becomes the result for rpc:index.md#spark.rpc.askTimeout[spark.rpc.askTimeout], rpc:index.md#spark.network.timeout[spark.network.timeout] or `120` secs.

== [[hasCachedBlocks]] `hasCachedBlocks` Method

[source, scala]
----
hasCachedBlocks(executorId: String): Boolean
----

`hasCachedBlocks` posts a `HasCachedBlocks(executorId)` message to storage:BlockManagerMasterEndpoint.md[] and waits for a response which becomes the result.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockManagerMaster` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.storage.BlockManagerMaster=ALL
----

Refer to ROOT:spark-logging.md[Logging].
