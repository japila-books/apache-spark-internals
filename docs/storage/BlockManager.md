# BlockManager

`BlockManager` manages the storage for blocks (_chunks of data_) that can be stored in [memory](#memoryStore) and on [disk](#diskStore).

![BlockManager and Stores](../images/storage/BlockManager.png)

`BlockManager` runs on the [driver](../driver.md) and [executors](../executor/Executor.md).

`BlockManager` provides interface for uploading and fetching blocks both locally and remotely using various [stores](#stores) (i.e. memory, disk, and off-heap).

**Cached blocks** are blocks with non-zero sum of memory and disk sizes.

!!! tip
    Use [Web UI](../webui/index.md) (esp. [Storage](../webui/storage.md) and [Executors](../webui/executors.md) tabs) to monitor the memory used.

!!! tip
    Use [spark-submit](../tools/spark-submit.md)'s command-line options (i.e. [--driver-memory](../tools/spark-submit.md#driver-memory) for the driver and [--executor-memory](../tools/spark-submit.md#executor-memory) for executors) or their equivalents as Spark properties (i.e. [spark.executor.memory](../tools/spark-submit.md#spark.executor.memory) and [spark.driver.memory](../tools/spark-submit.md#spark_driver_memory)) to control the memory for storage memory.

When [External Shuffle Service is enabled](#externalShuffleServiceEnabled), BlockManager uses [ExternalShuffleClient](#externalBlockStoreClient) to read shuffle files (of other executors).

## Creating Instance

`BlockManager` takes the following to be created:

* [Executor ID](#executorId)
* [RpcEnv](#rpcEnv)
* [BlockManagerMaster](#master)
* <span id="serializerManager"> [SerializerManager](../serializer/SerializerManager.md)
* <span id="conf"> [SparkConf](../SparkConf.md)
* [MemoryManager](#memoryManager)
* [MapOutputTracker](#mapOutputTracker)
* [ShuffleManager](#shuffleManager)
* [BlockTransferService](#blockTransferService)
* <span id="securityManager"> SecurityManager
* <span id="externalBlockStoreClient"> ExternalBlockStoreClient

When created, BlockManager sets [externalShuffleServiceEnabled](#externalShuffleServiceEnabled) internal flag based on [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property.

BlockManager then creates an instance of [DiskBlockManager](DiskBlockManager.md) (requesting `deleteFilesOnStop` when an external shuffle service is not in use).

BlockManager creates **block-manager-future** daemon cached thread pool with 128 threads maximum (as `futureExecutionContext`).

BlockManager calculates the maximum memory to use (as `maxMemory`) by requesting the maximum [on-heap](../memory/MemoryManager.md#maxOnHeapStorageMemory) and [off-heap](../memory/MemoryManager.md#maxOffHeapStorageMemory) storage memory from the assigned `MemoryManager`.

BlockManager calculates the port used by the external shuffle service (as `externalShuffleServicePort`).

!!! note
    It is computed specially in Spark on YARN.

BlockManager creates a client to read other executors' shuffle files (as `shuffleClient`). If the external shuffle service is used an [ExternalShuffleClient](ExternalShuffleClient.md) is created or the input [BlockTransferService](BlockTransferService.md) is used.

BlockManager sets the [maximum number of failures](../configuration-properties.md#spark.block.failures.beforeLocationRefresh) before this block manager refreshes the block locations from the driver (as `maxFailuresBeforeLocationRefresh`).

BlockManager registers a [BlockManagerSlaveEndpoint](BlockManagerSlaveEndpoint.md) with the input [RpcEnv](../rpc/RpcEnv.md), itself, and [MapOutputTracker](../scheduler/MapOutputTracker.md) (as `slaveEndpoint`).

BlockManager is created when SparkEnv is [created](../SparkEnv.md#create-BlockManager) (for the driver and executors) when a Spark application starts.

![BlockManager and SparkEnv](../images/storage/BlockManager-SparkEnv.png)

## <span id="futureExecutionContext"> ExecutionContextExecutorService

`BlockManager` uses a Scala [ExecutionContextExecutorService]({{ scala.api }}/scala/concurrent/ExecutionContextExecutorService.html) to execute *FIXME* asynchronously (on a thread pool with **block-manager-future** prefix and maximum of 128 threads).

## <span id="BlockEvictionHandler"> BlockEvictionHandler

`BlockManager` is a [BlockEvictionHandler](BlockEvictionHandler.md) that can [drop a block from memory](#dropFromMemory) (and store it on a disk when necessary).

## <span id="shuffleClient"><span id="externalShuffleServiceEnabled"> ShuffleClient and External Shuffle Service

`BlockManager` manages the lifecycle of a [ShuffleClient](ShuffleClient.md):

* Creates when [created](#creating-instance)

* [Inits](ShuffleClient.md#init) (and possibly [registers with an external shuffle server](#registerWithExternalShuffleServer)) when requested to [initialize](#initialize)

* Closes when requested to [stop](#stop)

The `ShuffleClient` can be an [ExternalShuffleClient](ExternalShuffleClient.md) or the given [BlockTransferService](#blockTransferService) based on [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property. When enabled, BlockManager uses the [ExternalShuffleClient](ExternalShuffleClient.md).

The `ShuffleClient` is available to other Spark services (using `shuffleClient` value) and is used when BlockStoreShuffleReader is requested to [read combined key-value records for a reduce task](../shuffle/BlockStoreShuffleReader.md#read).

When requested for [shuffle metrics](#shuffleMetricsSource), BlockManager simply requests [them](ShuffleClient.md#shuffleMetrics) from the `ShuffleClient`.

## <span id="rpcEnv"> BlockManager and RpcEnv

`BlockManager` is given a [RpcEnv](../rpc/RpcEnv.md) when [created](#creating-instance).

The `RpcEnv` is used to set up a [BlockManagerSlaveEndpoint](#slaveEndpoint).

## <span id="blockInfoManager"> BlockInfoManager

`BlockManager` creates a [BlockInfoManager](BlockInfoManager.md) when [created](#creating-instance).

`BlockManager` requests the `BlockInfoManager` to [clear](BlockInfoManager.md#clear) when requested to [stop](#stop).

`BlockManager` uses the `BlockInfoManager` to create a [MemoryStore](#memoryStore).

`BlockManager` uses the `BlockInfoManager` when requested for the following:

* [reportAllBlocks](#reportAllBlocks)

* [getStatus](#getStatus)

* [getMatchingBlockIds](#getMatchingBlockIds)

* [getLocalValues](#getLocalValues) and [getLocalBytes](#getLocalBytes)

* [doPut](#doPut)

* [replicateBlock](#replicateBlock)

* [dropFromMemory](#dropFromMemory)

* [removeRdd](#removeRdd), [removeBroadcast](#removeBroadcast), [removeBlock](#removeBlock), [removeBlockInternal](#removeBlockInternal)

* [downgradeLock](#downgradeLock), [releaseLock](#releaseLock), [registerTask](#registerTask), [releaseAllLocksForTask](#releaseAllLocksForTask)

## <span id="master"> BlockManager and BlockManagerMaster

`BlockManager` is given a [BlockManagerMaster](BlockManagerMaster.md) when [created](#creating-instance).

## <span id="BlockDataManager"> BlockManager as BlockDataManager

`BlockManager` is a [BlockDataManager](BlockDataManager.md).

## <span id="mapOutputTracker"> BlockManager and MapOutputTracker

`BlockManager` is given a [MapOutputTracker](../scheduler/MapOutputTracker.md) when [created](#creating-instance).

## <span id="executorId"> Executor ID

`BlockManager` is given an Executor ID when [created](#creating-instance).

The Executor ID is one of the following:

* **driver** (`SparkContext.DRIVER_IDENTIFIER`) for the driver

* Value of [--executor-id](../executor/CoarseGrainedExecutorBackend.md#executor-id) command-line argument for [CoarseGrainedExecutorBackend](../executor/CoarseGrainedExecutorBackend.md) executors

## <span id="slaveEndpoint"> BlockManagerEndpoint RPC Endpoint

`BlockManager` requests the [RpcEnv](#rpcEnv) to [register](../rpc/RpcEnv.md#setupEndpoint) a [BlockManagerSlaveEndpoint](BlockManagerSlaveEndpoint.md) under the name `BlockManagerEndpoint[ID]`.

The RPC endpoint is used when `BlockManager` is requested to [initialize](#initialize) and [reregister](#reregister) (to register the `BlockManager` on an executor with the [BlockManagerMaster](#master) on the driver).

The endpoint is stopped (by requesting the [RpcEnv](#rpcEnv) to [stop the reference](../rpc/RpcEnv.md#stop)) when `BlockManager` is requested to [stop](#stop).

## <span id="SparkEnv"> Accessing BlockManager

`BlockManager` is available using [SparkEnv](../SparkEnv.md#blockManager) on the driver and executors.

```text
import org.apache.spark.SparkEnv
val bm = SparkEnv.get.blockManager

scala> :type bm
org.apache.spark.storage.BlockManager
```

## <span id="blockTransferService"> BlockTransferService

`BlockManager` is given a [BlockTransferService](BlockTransferService.md) when [created](#creating-instance).

`BlockTransferService` is used as the [ShuffleClient](#shuffleClient) when `BlockManager` is configured with no external shuffle service (based on [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property).

`BlockTransferService` is [initialized](BlockTransferService.md#init) when `BlockManager` [is](#initialize).

`BlockTransferService` is [closed](BlockTransferService.md#close) when `BlockManager` is requested to [stop](#stop).

`BlockTransferService` is used when `BlockManager` is requested to [fetching a block from](#getRemoteBytes) or [replicate a block to](#replicate) remote block managers.

## <span id="memoryManager"> MemoryManager

BlockManager is given a [MemoryManager](../memory/MemoryManager.md) when [created](#creating-instance).

BlockManager uses the `MemoryManager` for the following:

* Create the [MemoryStore](#memoryStore) (that is then assigned to [MemoryManager](../memory/MemoryManager.md#setMemoryStore) as a "circular dependency")

* Initialize [maxOnHeapMemory](#maxOnHeapMemory) and [maxOffHeapMemory](#maxOffHeapMemory) (for reporting)

## <span id="shuffleManager"> ShuffleManager

`BlockManager` is given a [ShuffleManager](../shuffle/ShuffleManager.md) when [created](#creating-instance).

`BlockManager` uses the `ShuffleManager` for the following:

* [Retrieving a block data](#getBlockData) (for shuffle blocks)

* [Retrieving a non-shuffle block data](#getLocalBytes) (for shuffle blocks anyway)

* [Registering an executor with a local external shuffle service](#registerWithExternalShuffleServer) (when [initialized](#initialize) on an executor with [externalShuffleServiceEnabled](#externalShuffleServiceEnabled))

## <span id="diskBlockManager"> DiskBlockManager

BlockManager creates a [DiskBlockManager](DiskBlockManager.md) when [created](#creating-instance).

![DiskBlockManager and BlockManager](../images/storage/DiskBlockManager-BlockManager.png)

BlockManager uses the BlockManager for the following:

* Creating a [DiskStore](#diskStore)

* [Registering an executor with a local external shuffle service](#registerWithExternalShuffleServer) (when [initialized](#initialize) on an executor with [externalShuffleServiceEnabled](#externalShuffleServiceEnabled))

The `BlockManager` is available as `diskBlockManager` reference to other Spark systems.

```scala
import org.apache.spark.SparkEnv
SparkEnv.get.blockManager.diskBlockManager
```

## <span id="memoryStore"> MemoryStore

BlockManager creates a [MemoryStore](MemoryStore.md) when [created](#creating-instance) (with the [BlockInfoManager](#blockInfoManager), the [SerializerManager](#serializerManager), the [MemoryManager](#memoryManager) and itself as a [BlockEvictionHandler](BlockEvictionHandler.md)).

![MemoryStore and BlockManager](../images/storage/MemoryStore-BlockManager.png)

`BlockManager` requests the [MemoryManager](#memoryManager) to [use](../memory/MemoryManager.md#setMemoryStore) the `MemoryStore`.

`BlockManager` uses the `MemoryStore` for the following:

* [getStatus](#getStatus) and [getCurrentBlockStatus](#getCurrentBlockStatus)

* [getLocalValues](#getLocalValues)

* [doGetLocalBytes](#doGetLocalBytes)

* [doPutBytes](#doPutBytes) and [doPutIterator](#doPutIterator)

* [maybeCacheDiskBytesInMemory](#maybeCacheDiskBytesInMemory) and [maybeCacheDiskValuesInMemory](#maybeCacheDiskValuesInMemory)

* [dropFromMemory](#dropFromMemory)

* [removeBlockInternal](#removeBlockInternal)

The `MemoryStore` is requested to [clear](MemoryStore.md#clear) when `BlockManager` is requested to [stop](#stop).

The MemoryStore is available as `memoryStore` private reference to other Spark services.

```scala
import org.apache.spark.SparkEnv
SparkEnv.get.blockManager.memoryStore
```

The MemoryStore is used (via `SparkEnv.get.blockManager.memoryStore` reference) when Task is requested to [run](../scheduler/Task.md#run) (that has finished and requests the MemoryStore to [releaseUnrollMemoryForThisTask](MemoryStore.md#releaseUnrollMemoryForThisTask)).

## <span id="diskStore"> DiskStore

BlockManager creates a [DiskStore](DiskStore.md) (with the [DiskBlockManager](#diskBlockManager)) when [created](#creating-instance).

![DiskStore and BlockManager](../images/storage/DiskStore-BlockManager.png)

BlockManager uses the DiskStore when requested to [getStatus](#getStatus), [getCurrentBlockStatus](#getCurrentBlockStatus), [getLocalValues](#getLocalValues), [doGetLocalBytes](#doGetLocalBytes), [doPutBytes](#doPutBytes), [doPutIterator](#doPutIterator), [dropFromMemory](#dropFromMemory), [removeBlockInternal](#removeBlockInternal).

## <span id="metrics"> Performance Metrics

BlockManager uses [BlockManagerSource](BlockManagerSource.md) to report metrics under the name **BlockManager**.

## <span id="getPeers"> getPeers

```scala
getPeers(
  forceFetch: Boolean): Seq[BlockManagerId]
```

`getPeers`...FIXME

`getPeers` is used when `BlockManager` is requested to [replicateBlock](#replicateBlock) and [replicate](#replicate).

## <span id="releaseAllLocksForTask"> Releasing All Locks For Task

```scala
releaseAllLocksForTask(
  taskAttemptId: Long): Seq[BlockId]
```

`releaseAllLocksForTask`...FIXME

`releaseAllLocksForTask` is used when `TaskRunner` is requested to [run](../executor/TaskRunner.md#run) (at the end of a task).

## <span id="stop"> Stopping BlockManager

```scala
stop(): Unit
```

`stop`...FIXME

`stop` is used when `SparkEnv` is requested to [stop](../SparkEnv.md#stop).

## <span id="getMatchingBlockIds"> Getting IDs of Existing Blocks (For a Given Filter)

```scala
getMatchingBlockIds(
  filter: BlockId => Boolean): Seq[BlockId]
```

`getMatchingBlockIds`...FIXME

`getMatchingBlockIds` is used when `BlockManagerSlaveEndpoint` is requested to [handle a GetMatchingBlockIds message](BlockManagerSlaveEndpoint.md#GetMatchingBlockIds).

## <span id="getLocalValues"> Getting Local Block

```scala
getLocalValues(
  blockId: BlockId): Option[BlockResult]
```

`getLocalValues` prints out the following DEBUG message to the logs:

```text
Getting local block [blockId]
```

`getLocalValues` [obtains a read lock for `blockId`](BlockInfoManager.md#lockForReading).

When no `blockId` block was found, you should see the following DEBUG message in the logs and `getLocalValues` returns "nothing" (i.e. `NONE`).

```text
Block [blockId] was not found
```

When the `blockId` block was found, you should see the following DEBUG message in the logs:

```text
Level for block [blockId] is [level]
```

If `blockId` block has memory level and [is registered in `MemoryStore`](MemoryStore.md#contains), `getLocalValues` returns a [BlockResult](#BlockResult) as `Memory` read method and with a `CompletionIterator` for an interator:

1. [Values iterator from `MemoryStore` for `blockId`](MemoryStore.md#getValues) for "deserialized" persistence levels.
1. Iterator from [`SerializerManager` after the data stream has been deserialized](serializer:SerializerManager.md#dataDeserializeStream) for the `blockId` block and [the bytes for `blockId` block](MemoryStore.md#getBytes) for "serialized" persistence levels.

`getLocalValues` is used when:

* `TorrentBroadcast` is requested to [readBroadcastBlock](../core/TorrentBroadcast.md#readBroadcastBlock)

* `BlockManager` is requested to [get](#get) and [getOrElseUpdate](#getOrElseUpdate)

### <span id="maybeCacheDiskValuesInMemory"> maybeCacheDiskValuesInMemory

```scala
maybeCacheDiskValuesInMemory[T](
  blockInfo: BlockInfo,
  blockId: BlockId,
  level: StorageLevel,
  diskIterator: Iterator[T]): Iterator[T]
```

`maybeCacheDiskValuesInMemory`...FIXME

`maybeCacheDiskValuesInMemory` is used when `BlockManager` is requested to [getLocalValues](#getLocalValues).

## <span id="getRemoteValues"> getRemoteValues

```scala
getRemoteValues[T: ClassTag](
  blockId: BlockId): Option[BlockResult]
```

`getRemoteValues`...FIXME

## <span id="get"> Retrieving Block from Local or Remote Block Managers

```scala
get[T: ClassTag](
  blockId: BlockId): Option[BlockResult]
```

`get` attempts to get the `blockId` block from a local block manager first before requesting it from remote block managers.

Internally, `get` tries to [get the block from the local BlockManager](#getLocalValues). If the block was found, you should see the following INFO message in the logs and `get` returns the local [BlockResult](#BlockResult).

```text
Found block [blockId] locally
```

If however the block was not found locally, `get` tries to [get the block from remote block managers](#getRemoteValues). If retrieved from a remote block manager, you should see the following INFO message in the logs and `get` returns the remote [BlockResult](#BlockResult).

```text
Found block [blockId] remotely
```

In the end, `get` returns "nothing" (i.e. `NONE`) when the `blockId` block was not found either in the local BlockManager or any remote BlockManager.

`get` is used when:

* `BlockManager` is requested to [getOrElseUpdate](#getOrElseUpdate) and [getSingle](#getSingle)

### <span id="getRemoteValues"> getRemoteValues

```scala
getRemoteValues[T: ClassTag](
  blockId: BlockId): Option[BlockResult]
```

`getRemoteValues`...FIXME

## <span id="getBlockData"> Retrieving Block Data

```scala
getBlockData(
  blockId: BlockId): ManagedBuffer
```

`getBlockData` is part of the [BlockDataManager](BlockDataManager.md#getBlockData) abstraction.

For a BlockId.md[] of a shuffle (a ShuffleBlockId), getBlockData requests the <<shuffleManager, ShuffleManager>> for the shuffle:ShuffleManager.md#shuffleBlockResolver[ShuffleBlockResolver] that is then requested for shuffle:ShuffleBlockResolver.md#getBlockData[getBlockData].

Otherwise, getBlockData <<getLocalBytes, getLocalBytes>> for the given BlockId.

If found, getBlockData creates a new BlockManagerManagedBuffer (with the <<blockInfoManager, BlockInfoManager>>, the input BlockId, the retrieved BlockData and the dispose flag enabled).

If not found, getBlockData <<reportBlockStatus, informs the BlockManagerMaster>> that the block could not be found (and that the master should no longer assume the block is available on this executor) and throws a BlockNotFoundException.

NOTE: `getBlockData` is executed for shuffle blocks or local blocks that the BlockManagerMaster knows this executor really has (unless BlockManagerMaster is outdated).

## <span id="getLocalBytes"> Retrieving Non-Shuffle Local Block Data

```scala
getLocalBytes(
  blockId: BlockId): Option[BlockData]
```

`getLocalBytes`...FIXME

`getLocalBytes` is used when:

* TorrentBroadcast is requested to core:TorrentBroadcast.md#readBlocks[readBlocks]

* BlockManager is requested for the <<getBlockData, block data>> (of a non-shuffle block)

## <span id="removeBlockInternal"> removeBlockInternal

```scala
removeBlockInternal(
  blockId: BlockId,
  tellMaster: Boolean): Unit
```

`removeBlockInternal`...FIXME

`removeBlockInternal` is used when BlockManager is requested to <<doPut, doPut>> and <<removeBlock, removeBlock>>.

## <span id="stores"> Stores

A *Store* is the place where blocks are held.

There are the following possible stores:

* MemoryStore.md[MemoryStore] for memory storage level.
* DiskStore.md[DiskStore] for disk storage level.
* `ExternalBlockStore` for OFF_HEAP storage level.

## <span id="putBlockData"> Storing Block Data Locally

```scala
putBlockData(
  blockId: BlockId,
  data: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Boolean
```

`putBlockData` simply <<putBytes, stores `blockId` locally>> (given the given storage `level`).

`putBlockData` is part of the [BlockDataManager](BlockDataManager.md#putBlockData) abstraction.

Internally, `putBlockData` wraps `ChunkedByteBuffer` around `data` buffer's NIO `ByteBuffer` and calls <<putBytes, putBytes>>.

## <span id="putBytes"> Storing Block Bytes Locally

```scala
putBytes(
  blockId: BlockId,
  bytes: ChunkedByteBuffer,
  level: StorageLevel,
  tellMaster: Boolean = true): Boolean
```

`putBytes` makes sure that the `bytes` are not `null` and <<doPutBytes, doPutBytes>>.

`putBytes` is used when:

* BlockManager is requested to <<putBlockData, puts a block data locally>>

* `TaskRunner` is requested to executor:TaskRunner.md#run-result-sent-via-blockmanager[run] (and the result size is above executor:Executor.md#maxDirectResultSize[maxDirectResultSize])

* `TorrentBroadcast` is requested to core:TorrentBroadcast.md#writeBlocks[writeBlocks] and core:TorrentBroadcast.md#readBlocks[readBlocks]

### <span id="doPutBytes"> doPutBytes

```scala
doPutBytes[T](
  blockId: BlockId,
  bytes: ChunkedByteBuffer,
  level: StorageLevel,
  classTag: ClassTag[T],
  tellMaster: Boolean = true,
  keepReadLock: Boolean = false): Boolean
```

`doPutBytes` calls the internal helper <<doPut, doPut>> with a function that accepts a `BlockInfo` and does the uploading.

Inside the function, if the StorageLevel.md[storage `level`]'s replication is greater than 1, it immediately starts <<replicate, replication>> of the `blockId` block on a separate thread (from `futureExecutionContext` thread pool). The replication uses the input `bytes` and `level` storage level.

For a memory storage level, the function checks whether the storage `level` is deserialized or not. For a deserialized storage `level`, ``BlockManager``'s serializer:SerializerManager.md#dataDeserializeStream[`SerializerManager` deserializes `bytes` into an iterator of values] that MemoryStore.md#putIteratorAsValues[`MemoryStore` stores]. If however the storage `level` is not deserialized, the function requests MemoryStore.md#putBytes[`MemoryStore` to store the bytes]

If the put did not succeed and the storage level is to use disk, you should see the following WARN message in the logs:

```text
Persisting block [blockId] to disk instead.
```

And DiskStore.md#putBytes[`DiskStore` stores the bytes].

NOTE: DiskStore.md[DiskStore] is requested to store the bytes of a block with memory and disk storage level only when MemoryStore.md[MemoryStore] has failed.

If the storage level is to use disk only, DiskStore.md#putBytes[`DiskStore` stores the bytes].

`doPutBytes` requests <<getCurrentBlockStatus, current block status>> and if the block was successfully stored, and the driver should know about it (`tellMaster`), the function <<reportBlockStatus, reports the current storage status of the block to the driver>>. The executor:TaskMetrics.md#incUpdatedBlockStatuses[current `TaskContext` metrics are updated with the updated block status] (only when executed inside a task where `TaskContext` is available).

You should see the following DEBUG message in the logs:

```text
Put block [blockId] locally took [time] ms
```

The function waits till the earlier asynchronous replication finishes for a block with replication level greater than `1`.

The final result of `doPutBytes` is the result of storing the block successful or not (as computed earlier).

NOTE: `doPutBytes` is used exclusively when BlockManager is requested to <<putBytes, putBytes>>.

## <span id="doPut"> doPut

```scala
doPut[T](
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[_],
  tellMaster: Boolean,
  keepReadLock: Boolean)(putBody: BlockInfo => Option[T]): Option[T]
```

doPut executes the input `putBody` function with a BlockInfo.md[] being a new `BlockInfo` object (with `level` storage level) that BlockInfoManager.md#lockNewBlockForWriting[`BlockInfoManager` managed to create a write lock for].

If the block has already been created (and BlockInfoManager.md#lockNewBlockForWriting[`BlockInfoManager` did not manage to create a write lock for]), the following WARN message is printed out to the logs:

```text
Block [blockId] already exists on this machine; not re-adding it
```

doPut <<releaseLock, releases the read lock for the block>> when `keepReadLock` flag is disabled and returns `None` immediately.

If however the write lock has been given, doPut executes `putBody`.

If the result of `putBody` is `None` the block is considered saved successfully.

For successful save and `keepReadLock` enabled, BlockInfoManager.md#downgradeLock[`BlockInfoManager` is requested to downgrade an exclusive write lock for `blockId` to a shared read lock].

For successful save and `keepReadLock` disabled, BlockInfoManager.md#unlock[`BlockInfoManager` is requested to release lock on `blockId`].

For unsuccessful save, <<removeBlockInternal, the block is removed from memory and disk stores>> and the following WARN message is printed out to the logs:

```text
Putting block [blockId] failed
```

In the end, doPut prints out the following DEBUG message to the logs:

```text
Putting block [blockId] [withOrWithout] replication took [usedTime] ms
```

doPut is used when BlockManager is requested to <<doPutBytes, doPutBytes>> and <<doPutIterator, doPutIterator>>.

## <span id="removeBlock"> Removing Block From Memory and Disk

```scala
removeBlock(
  blockId: BlockId,
  tellMaster: Boolean = true): Unit
```

removeBlock removes the `blockId` block from the MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore].

When executed, it prints out the following DEBUG message to the logs:

```
Removing block [blockId]
```

It requests BlockInfoManager.md[] for lock for writing for the `blockId` block. If it receives none, it prints out the following WARN message to the logs and quits.

```
Asked to remove block [blockId], which does not exist
```

Otherwise, with a write lock for the block, the block is removed from MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore] (see MemoryStore.md#remove[Removing Block in `MemoryStore`] and DiskStore.md#remove[Removing Block in `DiskStore`]).

If both removals fail, it prints out the following WARN message:

```
Block [blockId] could not be removed as it was not found in either the disk, memory, or external block store
```

The block is removed from BlockInfoManager.md[].

removeBlock then <<getCurrentBlockStatus, calculates the current block status>> that is used to <<reportBlockStatus, report the block status to the driver>> (if the input `tellMaster` and the info's `tellMaster` are both enabled, i.e. `true`) and the executor:TaskMetrics.md#incUpdatedBlockStatuses[current TaskContext metrics are updated with the change].

removeBlock is used when:

* BlockManager is requested to <<handleLocalReadFailure, handleLocalReadFailure>>, <<removeRdd, remove an RDD>> and <<removeBroadcast, broadcast>>

* BlockManagerSlaveEndpoint is requested to handle a BlockManagerSlaveEndpoint.md#RemoveBlock[RemoveBlock] message

## <span id="removeRdd"> Removing RDD Blocks

```scala
removeRdd(rddId: Int): Int
```

`removeRdd` removes all the blocks that belong to the `rddId` RDD.

It prints out the following INFO message to the logs:

```text
Removing RDD [rddId]
```

It then requests RDD blocks from BlockInfoManager.md[] and <<removeBlock, removes them (from memory and disk)>> (without informing the driver).

The number of blocks removed is the final result.

NOTE: It is used by BlockManagerSlaveEndpoint.md#RemoveRdd[`BlockManagerSlaveEndpoint` while handling `RemoveRdd` messages].

## <span id="removeBroadcast"> Removing All Blocks of Broadcast Variable

```scala
removeBroadcast(broadcastId: Long, tellMaster: Boolean): Int
```

`removeBroadcast` removes all the blocks of the input `broadcastId` broadcast.

Internally, it starts by printing out the following DEBUG message to the logs:

```
Removing broadcast [broadcastId]
```

It then requests all the BlockId.md#BroadcastBlockId[BroadcastBlockId] objects that belong to the `broadcastId` broadcast from BlockInfoManager.md[] and <<removeBlock, removes them (from memory and disk)>>.

The number of blocks removed is the final result.

NOTE: It is used by storage:BlockManagerSlaveEndpoint.md#RemoveBroadcast[`BlockManagerSlaveEndpoint` while handling `RemoveBroadcast` messages].

## <span id="shuffleServerId"> BlockManagerId of Shuffle Server

BlockManager uses storage:BlockManagerId.md[] for the location (address) of the server that serves shuffle files of this executor.

The BlockManagerId is either the BlockManagerId of the external shuffle service (when <<externalShuffleServiceEnabled, enabled>>) or the <<blockManagerId, blockManagerId>>.

The BlockManagerId of the Shuffle Server is used for the location of a scheduler:MapStatus.md[shuffle map output] when:

* BypassMergeSortShuffleWriter is requested to shuffle:BypassMergeSortShuffleWriter.md#write[write partition records to a shuffle file]

* UnsafeShuffleWriter is requested to shuffle:UnsafeShuffleWriter.md#closeAndWriteOutput[close and write output]

## <span id="getStatus"> getStatus

```scala
getStatus(
  blockId: BlockId): Option[BlockStatus]
```

`getStatus`...FIXME

`getStatus` is used when `BlockManagerSlaveEndpoint` is requested to handle [GetBlockStatus](BlockManagerSlaveEndpoint.md#GetBlockStatus) message.

## <span id="initialize"> Initializing BlockManager

```scala
initialize(
  appId: String): Unit
```

`initialize` initializes a `BlockManager` on the driver and executors (see [Creating SparkContext Instance](../SparkContext.md#creating-instance) and [Creating Executor Instance](../executor/Executor.md#creating-instance), respectively).

!!! note
    The method must be called before a BlockManager can be considered fully operable.

initialize does the following in order:

1. Initializes BlockTransferService.md#init[BlockTransferService]
2. Initializes the internal shuffle client, be it ExternalShuffleClient.md[ExternalShuffleClient] or BlockTransferService.md[BlockTransferService].
3. BlockManagerMaster.md#registerBlockManager[Registers itself with the driver's `BlockManagerMaster`] (using the `id`, `maxMemory` and its `slaveEndpoint`).
+
The `BlockManagerMaster` reference is passed in when the <<creating-instance, BlockManager is created>> on the driver and executors.
4. Sets <<shuffleServerId, shuffleServerId>> to an instance of BlockManagerId.md[] given an executor id, host name and port for BlockTransferService.md[BlockTransferService].
5. It creates the address of the server that serves this executor's shuffle files (using <<shuffleServerId, shuffleServerId>>)

CAUTION: FIXME Review the initialize procedure again

CAUTION: FIXME Describe `shuffleServerId`. Where is it used?

If the [External Shuffle Service is used](#externalShuffleServiceEnabled), initialize prints out the following INFO message to the logs:

```text
external shuffle service port = [externalShuffleServicePort]
```

It [registers itself to the driver's BlockManagerMaster](BlockManagerMaster.md#registerBlockManager) passing the [BlockManagerId](BlockManagerId.md), the maximum memory (as `maxMemory`), and the [BlockManagerSlaveEndpoint](BlockManagerSlaveEndpoint.md).

Ultimately, if the initialization happens on an executor and the [External Shuffle Service is used](#externalShuffleServiceEnabled), it [registers to the shuffle service](#registerWithExternalShuffleServer).

`initialize` is used when [SparkContext](../SparkContext.md) is created and when an executor:Executor.md#creating-instance[`Executor` is created] (for executor:CoarseGrainedExecutorBackend.md#RegisteredExecutor[CoarseGrainedExecutorBackend] and spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md[MesosExecutorBackend]).

## <span id="registerWithExternalShuffleServer"> Registering Executor's BlockManager with External Shuffle Server

```scala
registerWithExternalShuffleServer(): Unit
```

registerWithExternalShuffleServer is an internal helper method to register the BlockManager for an executor with an deploy:ExternalShuffleService.md[external shuffle server].

!!! note
    It is executed when a [BlockManager is initialized on an executor and an external shuffle service is used](#initialize).

When executed, you should see the following INFO message in the logs:

```text
Registering executor with local external shuffle service.
```

It uses [shuffleClient](#shuffleClient) to [register the block manager](ExternalShuffleClient.md#registerWithShuffleServer) using [shuffleServerId](#shuffleServerId) (i.e. the host, the port and the executorId) and a `ExecutorShuffleInfo`.

!!! note
    The `ExecutorShuffleInfo` uses `localDirs` and `subDirsPerLocalDir` from [DiskBlockManager](DiskBlockManager.md) and the class name of the constructor [ShuffleManager](../shuffle/ShuffleManager.md).

It tries to register at most 3 times with 5-second sleeps in-between.

!!! note
    The maximum number of attempts and the sleep time in-between are hard-coded, i.e. they are not configured.

Any issues while connecting to the external shuffle service are reported as ERROR messages in the logs:

```text
Failed to connect to external shuffle server, will retry [#attempts] more times after waiting 5 seconds...
```

registerWithExternalShuffleServer is used when BlockManager is requested to [initialize](#initialize) (when executed on an executor with [externalShuffleServiceEnabled](#externalShuffleServiceEnabled)).

## <span id="reregister"> Re-registering BlockManager with Driver and Reporting Blocks

```scala
reregister(): Unit
```

When executed, reregister prints the following INFO message to the logs:

```text
BlockManager [blockManagerId] re-registering with master
```

reregister then BlockManagerMaster.md#registerBlockManager[registers itself to the driver's `BlockManagerMaster`] (just as it was when [BlockManager was initializing](#initialize)). It passes the BlockManagerId.md[], the maximum memory (as `maxMemory`), and the BlockManagerSlaveEndpoint.md[].

reregister will then report all the local blocks to the BlockManagerMaster.md[BlockManagerMaster].

You should see the following INFO message in the logs:

```text
Reporting [blockInfoManager.size] blocks to the master.
```

For each block metadata (in BlockInfoManager.md[]) it [gets block current status](#getCurrentBlockStatus) and [tries to send it to the BlockManagerMaster](#tryToReportBlockStatus).

If there is an issue communicating to the BlockManagerMaster.md[BlockManagerMaster], you should see the following ERROR message in the logs:

```text
Failed to report [blockId] to master; giving up.
```

After the ERROR message, reregister stops reporting.

`reregister` is used when an [`Executor` was informed to re-register while sending heartbeats](../executor/Executor.md#heartbeats-and-active-task-metrics).

### <span id="reportAllBlocks"> reportAllBlocks

```scala
reportAllBlocks(): Unit
```

`reportAllBlocks`...FIXME

## <span id="getCurrentBlockStatus"> Calculate Current Block Status

```scala
getCurrentBlockStatus(
  blockId: BlockId,
  info: BlockInfo): BlockStatus
```

`getCurrentBlockStatus` gives the current `BlockStatus` of the `BlockId` block (with the block's current StorageLevel.md[StorageLevel], memory and disk sizes). It uses MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore] for size and other information.

NOTE: Most of the information to build `BlockStatus` is already in `BlockInfo` except that it may not necessarily reflect the current state per MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore].

Internally, it uses the input BlockInfo.md[] to know about the block's storage level. If the storage level is not set (i.e. `null`), the returned `BlockStatus` assumes the StorageLevel.md[default `NONE` storage level] and the memory and disk sizes being `0`.

If however the storage level is set, `getCurrentBlockStatus` uses MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore] to check whether the block is stored in the storages or not and request for their sizes in the storages respectively (using their `getSize` or assume `0`).

NOTE: It is acceptable that the `BlockInfo` says to use memory or disk yet the block is not in the storages (yet or anymore). The method will give current status.

`getCurrentBlockStatus` is used when <<reregister, executor's BlockManager is requested to report the current status of the local blocks to the master>>, <<doPutBytes, saving a block to a storage>> or <<dropFromMemory, removing a block from memory only>> or <<removeBlock, both, i.e. from memory and disk>>.

## <span id="reportBlockStatus"> Reporting Current Storage Status of Block to Driver

```scala
reportBlockStatus(
  blockId: BlockId,
  info: BlockInfo,
  status: BlockStatus,
  droppedMemorySize: Long = 0L): Unit
```

reportBlockStatus is an for <<tryToReportBlockStatus, reporting a block status to the driver>> and if told to re-register it prints out the following INFO message to the logs:

```text
Got told to re-register updating block [blockId]
```

It does asynchronous reregistration (using `asyncReregister`).

In either case, it prints out the following DEBUG message to the logs:

```text
Told master about block [blockId]
```

reportBlockStatus is used when BlockManager is requested to [getBlockData](#getBlockData), [doPutBytes](#doPutBytes), [doPutIterator](#doPutIterator), [dropFromMemory](#dropFromMemory) and [removeBlockInternal](#removeBlockInternal).

## <span id="tryToReportBlockStatus"> Reporting Block Status Update to Driver

```scala
def tryToReportBlockStatus(
  blockId: BlockId,
  info: BlockInfo,
  status: BlockStatus,
  droppedMemorySize: Long = 0L): Boolean
```

`tryToReportBlockStatus` [reports block status update](BlockManagerMaster.md#updateBlockInfo) to [BlockManagerMaster](#master) and returns its response.

`tryToReportBlockStatus` is used when BlockManager is requested to [reportAllBlocks](#reportAllBlocks) or [reportBlockStatus](#reportBlockStatus).

## <span id="execution-context"> Execution Context

**block-manager-future** is the execution context for...FIXME

## <span id="ByteBuffer"> ByteBuffer

The underlying abstraction for blocks in Spark is a `ByteBuffer` that limits the size of a block to 2GB (`Integer.MAX_VALUE` - see [Why does FileChannel.map take up to Integer.MAX_VALUE of data?](http://stackoverflow.com/q/8076472/1305344) and [SPARK-1476 2GB limit in spark for blocks](https://issues.apache.org/jira/browse/SPARK-1476)). This has implication not just for managed blocks in use, but also for shuffle blocks (memory mapped blocks are limited to 2GB, even though the API allows for `long`), ser-deser via byte array-backed output streams.

## <span id="BlockResult"> BlockResult

`BlockResult` is a description of a fetched block with the `readMethod` and `bytes`.

## <span id="registerTask"> Registering Task

```scala
registerTask(
  taskAttemptId: Long): Unit
```

`registerTask` requests the [BlockInfoManager](#blockInfoManager) to [register a given task](BlockInfoManager.md#registerTask).

`registerTask` is used when `Task` is requested to [run](../scheduler/Task.md#run) (at the start of a task).

## <span id="getDiskWriter"> Creating DiskBlockObjectWriter

```scala
getDiskWriter(
  blockId: BlockId,
  file: File,
  serializerInstance: SerializerInstance,
  bufferSize: Int,
  writeMetrics: ShuffleWriteMetrics): DiskBlockObjectWriter
```

getDiskWriter creates a [DiskBlockObjectWriter](DiskBlockObjectWriter.md) (with [spark.shuffle.sync](../configuration-properties.md#spark.shuffle.sync) configuration property for `syncWrites` argument).

`getDiskWriter` uses the [SerializerManager](#serializerManager).

`getDiskWriter` is used when:

* `BypassMergeSortShuffleWriter` is requested to shuffle:BypassMergeSortShuffleWriter.md#write[write records (of a partition)]

* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)

* `ExternalAppendOnlyMap` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalAppendOnlyMap.md#spillMemoryIteratorToDisk)

* `ExternalSorter` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalSorter.md#spillMemoryIteratorToDisk) and [writePartitionedFile](../shuffle/ExternalSorter.md#writePartitionedFile)

* [UnsafeSorterSpillWriter](../memory/UnsafeSorterSpillWriter.md) is created

## <span id="addUpdatedBlockStatusToTaskMetrics"> Recording Updated BlockStatus In Current Task's TaskMetrics

```scala
addUpdatedBlockStatusToTaskMetrics(
  blockId: BlockId,
  status: BlockStatus): Unit
```

`addUpdatedBlockStatusToTaskMetrics` [takes an active `TaskContext`](../scheduler/TaskContext.md#get) (if available) and [records updated `BlockStatus` for `Block`](../executor/TaskMetrics.md#incUpdatedBlockStatuses) (in the [task's `TaskMetrics`](../scheduler/TaskContext.md#taskMetrics)).

`addUpdatedBlockStatusToTaskMetrics` is used when BlockManager [doPutBytes](#doPutBytes) (for a block that was successfully stored), [doPut](#doPut), [doPutIterator](#doPutIterator), [removes blocks from memory](#dropFromMemory) (possibly spilling it to disk) and [removes block from memory and disk](#removeBlock).

## <span id="shuffleMetricsSource"> Requesting Shuffle-Related Spark Metrics Source

```scala
shuffleMetricsSource: Source
```

`shuffleMetricsSource` requests the [ShuffleClient](#shuffleClient) for the [shuffle metrics](ShuffleClient.md#shuffleMetrics) and creates a [ShuffleMetricsSource](ShuffleMetricsSource.md) with the [source name](ShuffleMetricsSource.md#sourceName) based on [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property:

* **ExternalShuffle** when [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property is on (`true`)

* **NettyBlockTransfer** when [spark.shuffle.service.enabled](../configuration-properties.md#spark.shuffle.service.enabled) configuration property is off (`false`)

`shuffleMetricsSource` is used when [Executor](../executor/Executor.md) is created (for non-local / cluster modes).

## <span id="replicate"> Replicating Block To Peers

```scala
replicate(
  blockId: BlockId,
  data: BlockData,
  level: StorageLevel,
  classTag: ClassTag[_],
  existingReplicas: Set[BlockManagerId] = Set.empty): Unit
```

`replicate`...FIXME

`replicate` is used when `BlockManager` is requested to [doPutBytes](#doPutBytes), [doPutIterator](#doPutIterator) and [replicateBlock](#replicateBlock).

## <span id="replicateBlock"> replicateBlock

```scala
replicateBlock(
  blockId: BlockId,
  existingReplicas: Set[BlockManagerId],
  maxReplicas: Int): Unit
```

`replicateBlock`...FIXME

`replicateBlock` is used when `BlockManagerSlaveEndpoint` is requested to [handle a ReplicateBlock message](BlockManagerSlaveEndpoint.md#ReplicateBlock).

## <span id="putIterator"> putIterator

```scala
putIterator[T: ClassTag](
  blockId: BlockId,
  values: Iterator[T],
  level: StorageLevel,
  tellMaster: Boolean = true): Boolean
```

`putIterator`...FIXME

`putIterator` is used when:

* `BlockManager` is requested to [putSingle](#putSingle)

## <span id="putSingle"> putSingle Method

```scala
putSingle[T: ClassTag](
  blockId: BlockId,
  value: T,
  level: StorageLevel,
  tellMaster: Boolean = true): Boolean
```

`putSingle`...FIXME

`putSingle` is used when `TorrentBroadcast` is requested to [write the blocks](../core/TorrentBroadcast.md#writeBlocks) and [readBroadcastBlock](../core/TorrentBroadcast.md#readBroadcastBlock).

## <span id="getRemoteBytes"> Fetching Block From Remote Nodes

```scala
getRemoteBytes(
  blockId: BlockId): Option[ChunkedByteBuffer]
```

`getRemoteBytes`...FIXME

`getRemoteBytes` is used when:

* `BlockManager` is requested to [getRemoteValues](#getRemoteValues)

* `TorrentBroadcast` is requested to [readBlocks](../core/TorrentBroadcast.md#readBlocks)

* `TaskResultGetter` is requested to [enqueuing a successful IndirectTaskResult](../scheduler/TaskResultGetter.md#enqueueSuccessfulTask)

## <span id="getOrElseUpdate"> Getting Block From Block Managers Or Computing and Storing It Otherwise

```scala
getOrElseUpdate[T](
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[T],
  makeIterator: () => Iterator[T]): Either[BlockResult, Iterator[T]]
```

!!! note
    _I think_ it is fair to say that `getOrElseUpdate` is like [getOrElseUpdate]({{ scala.api }}/scala/collection/mutable/Map.html#getOrElseUpdate(key:K,op:=%3EV):V) of [scala.collection.mutable.Map]({{ scala.api }}/scala/collection/mutable/Map.html) in Scala.

    ```scala
    getOrElseUpdate(key: K, op: ⇒ V): V
    ```

    Quoting the official scaladoc:

    > If given key `K` is already in this map, `getOrElseUpdate` returns the associated value `V`.

    > Otherwise, `getOrElseUpdate` computes a value `V` from given expression `op`, stores with the key `K` in the map and returns that value.

    Since `BlockManager` is a key-value store of blocks of data identified by a block ID that seems to fit so well.

`getOrElseUpdate` first attempts to [get the block](#get) by the `BlockId` (from the local block manager first and, if unavailable, requesting remote peers).

`getOrElseUpdate` gives the `BlockResult` of the block if found.

If however the block was not found (in any block manager in a Spark cluster), `getOrElseUpdate` [doPutIterator](#doPutIterator) (for the input `BlockId`, the `makeIterator` function and the `StorageLevel`).

`getOrElseUpdate` branches off per the result.

For `None`, `getOrElseUpdate` [getLocalValues](#getLocalValues) for the `BlockId` and eventually returns the `BlockResult` (unless terminated by a `SparkException` due to some internal error).

For `Some(iter)`, `getOrElseUpdate` returns an iterator of `T` values.

`getOrElseUpdate` is used when `RDD` is requested to [get or compute an RDD partition](../rdd/RDD.md#getOrCompute) (for a `RDDBlockId` with a RDD ID and a partition index).

## <span id="doPutIterator"> doPutIterator

```scala
doPutIterator[T](
  blockId: BlockId,
  iterator: () => Iterator[T],
  level: StorageLevel,
  classTag: ClassTag[T],
  tellMaster: Boolean = true,
  keepReadLock: Boolean = false): Option[PartiallyUnrolledIterator[T]]
```

`doPutIterator` simply <<doPut, doPut>> with the `putBody` function that accepts a `BlockInfo` and does the following:

. `putBody` branches off per whether the `StorageLevel` indicates to use a StorageLevel.md#useMemory[memory] or simply a StorageLevel.md#useDisk[disk], i.e.

* When the input `StorageLevel` indicates to StorageLevel.md#useMemory[use a memory] for storage in StorageLevel.md#deserialized[deserialized] format, `putBody` requests <<memoryStore, MemoryStore>> to MemoryStore.md#putIteratorAsValues[putIteratorAsValues] (for the `BlockId` and with the `iterator` factory function).
+
If the <<memoryStore, MemoryStore>> returned a correct value, the internal `size` is set to the value.
+
If however the <<memoryStore, MemoryStore>> failed to give a correct value, FIXME

* When the input `StorageLevel` indicates to StorageLevel.md#useMemory[use memory] for storage in StorageLevel.md#deserialized[serialized] format, `putBody`...FIXME

* When the input `StorageLevel` does not indicate to use memory for storage but StorageLevel.md#useDisk[disk] instead, `putBody`...FIXME

. `putBody` requests the <<getCurrentBlockStatus, current block status>>

. Only when the block was successfully stored in either the memory or disk store:

* `putBody` <<reportBlockStatus, reports the block status>> to the <<master, BlockManagerMaster>> when the input `tellMaster` flag (default: enabled) and the `tellMaster` flag of the block info are both enabled.

* `putBody` <<addUpdatedBlockStatusToTaskMetrics, addUpdatedBlockStatusToTaskMetrics>> (with the `BlockId` and `BlockStatus`)

* `putBody` prints out the following DEBUG message to the logs:
+
```
Put block [blockId] locally took [time] ms
```

* When the input `StorageLevel` indicates to use StorageLevel.md#replication[replication], `putBody` <<doGetLocalBytes, doGetLocalBytes>> followed by <<replicate, replicate>> (with the input `BlockId` and the `StorageLevel` as well as the `BlockData` to replicate)

* With a successful replication, `putBody` prints out the following DEBUG message to the logs:
+
```
Put block [blockId] remotely took [time] ms
```

. In the end, `putBody` may or may not give a `PartiallyUnrolledIterator` if...FIXME

NOTE: `doPutIterator` is used when BlockManager is requested to <<getOrElseUpdate, get a block from block managers or computing and storing it otherwise>> and <<putIterator, putIterator>>.

## <span id="dropFromMemory"> Dropping Block from Memory

```scala
dropFromMemory(
  blockId: BlockId,
  data: () => Either[Array[T], ChunkedByteBuffer]): StorageLevel
```

`dropFromMemory` prints out the following INFO message to the logs:

```
Dropping block [blockId] from memory
```

`dropFromMemory` then asserts that the given block is BlockInfoManager.md#assertBlockIsLockedForWriting[locked for writing].

If the block's StorageLevel.md[StorageLevel] uses disks and the internal DiskStore.md[DiskStore] object (`diskStore`) does not contain the block, it is saved then. You should see the following INFO message in the logs:

```
Writing block [blockId] to disk
```

CAUTION: FIXME Describe the case with saving a block to disk.

The block's memory size is fetched and recorded (using `MemoryStore.getSize`).

The block is MemoryStore.md#remove[removed from memory] if exists. If not, you should see the following WARN message in the logs:

```
Block [blockId] could not be dropped from memory as it does not exist
```

It then <<getCurrentBlockStatus, calculates the current storage status of the block>> and <<reportBlockStatus, reports it to the driver>>. It only happens when `info.tellMaster`.

CAUTION: FIXME When would `info.tellMaster` be `true`?

A block is considered updated when it was written to disk or removed from memory or both. If either happened, the executor:TaskMetrics.md#incUpdatedBlockStatuses[current TaskContext metrics are updated with the change].

In the end, `dropFromMemory` returns the current storage level of the block.

`dropFromMemory` is part of the [BlockEvictionHandler](BlockEvictionHandler.md#dropFromMemory) abstraction.

## <span id="releaseLock"> releaseLock Method

```scala
releaseLock(
  blockId: BlockId,
  taskAttemptId: Option[Long] = None): Unit
```

releaseLock requests the [BlockInfoManager](#blockInfoManager) to [unlock the given block](BlockInfoManager.md#unlock).

releaseLock is part of the [BlockDataManager](BlockDataManager.md#releaseLock) abstraction.

## <span id="putBlockDataAsStream"> putBlockDataAsStream

```scala
putBlockDataAsStream(
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[_]): StreamCallbackWithID
```

`putBlockDataAsStream`...FIXME

`putBlockDataAsStream` is part of the [BlockDataManager](BlockDataManager.md#putBlockDataAsStream) abstraction.

## <span id="maxMemory"> Maximum Memory

Total maximum value that BlockManager can ever possibly use (that depends on <<memoryManager, MemoryManager>> and may vary over time).

Total available memory:MemoryManager.md#maxOnHeapStorageMemory[on-heap] and memory:MemoryManager.md#maxOffHeapStorageMemory[off-heap] memory for storage (in bytes)

## <span id="maxOffHeapMemory"> Maximum Off-Heap Memory

## <span id="maxOnHeapMemory"> Maximum On-Heap Memory

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.BlockManager=ALL
```

Refer to [Logging](../spark-logging.md).
