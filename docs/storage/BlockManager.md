# BlockManager

`BlockManager` manages the storage for blocks (_chunks of data_) that can be stored in <<memoryStore, memory>> and on <<diskStore, disk>>.

![BlockManager and Stores](../images/storage/BlockManager.png)

`BlockManager` runs on the [driver](../driver.md) and [executors](../executor/Executor.md).

`BlockManager` provides interface for uploading and fetching blocks both locally and remotely using various stores, i.e. <<stores, memory, disk, and off-heap>>.

[[futureExecutionContext]]
BlockManager uses a Scala https://www.scala-lang.org/api/current/scala/concurrent/ExecutionContextExecutorService.html[ExecutionContextExecutorService] to execute *FIXME* asynchronously (on a thread pool with *block-manager-future* prefix and maximum of 128 threads).

*Cached blocks* are blocks with non-zero sum of memory and disk sizes.

TIP: Use webui:index.md[Web UI], esp. webui:spark-webui-storage.md[Storage] and webui:spark-webui-executors.md[Executors] tabs, to monitor the memory used.

TIP: Use tools:spark-submit.md[spark-submit]'s command-line options, i.e. tools:spark-submit.md#driver-memory[--driver-memory] for the driver and tools:spark-submit.md#executor-memory[--executor-memory] for executors or their equivalents as Spark properties, i.e. tools:spark-submit.md#spark.executor.memory[spark.executor.memory] and tools:spark-submit.md#spark_driver_memory[spark.driver.memory], to control the memory for storage memory.

When <<externalShuffleServiceEnabled, External Shuffle Service is enabled>>, BlockManager uses storage:ExternalShuffleClient.md[ExternalShuffleClient] to read other executors' shuffle files.

== [[creating-instance]] Creating Instance

BlockManager takes the following to be created:

* <<executorId, Executor ID>>
* <<rpcEnv, RpcEnv>>
* <<master, BlockManagerMaster>>
* [[serializerManager]] serializer:SerializerManager.md[]
* [[conf]] ROOT:SparkConf.md[]
* <<memoryManager, MemoryManager>>
* <<mapOutputTracker, MapOutputTracker>>
* <<shuffleManager, ShuffleManager>>
* <<blockTransferService, BlockTransferService>>
* [[securityManager]] SecurityManager
* [[numUsableCores]] Number of CPU cores (for an storage:ExternalShuffleClient.md[] with <<externalShuffleServiceEnabled, externalShuffleServiceEnabled>>)

When created, BlockManager sets <<externalShuffleServiceEnabled, externalShuffleServiceEnabled>> internal flag based on ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property.

BlockManager then creates an instance of DiskBlockManager.md[DiskBlockManager] (requesting `deleteFilesOnStop` when an external shuffle service is not in use).

BlockManager creates *block-manager-future* daemon cached thread pool with 128 threads maximum (as `futureExecutionContext`).

BlockManager calculates the maximum memory to use (as `maxMemory`) by requesting the maximum memory:MemoryManager.md#maxOnHeapStorageMemory[on-heap] and memory:MemoryManager.md#maxOffHeapStorageMemory[off-heap] storage memory from the assigned `MemoryManager`.

BlockManager calculates the port used by the external shuffle service (as `externalShuffleServicePort`).

NOTE: It is computed specially in Spark on YARN.

BlockManager creates a client to read other executors' shuffle files (as `shuffleClient`). If the external shuffle service is used an storage:ExternalShuffleClient.md[ExternalShuffleClient] is created or the input storage:BlockTransferService.md[BlockTransferService] is used.

BlockManager sets the ROOT:configuration-properties.md#spark.block.failures.beforeLocationRefresh[maximum number of failures] before this block manager refreshes the block locations from the driver (as `maxFailuresBeforeLocationRefresh`).

BlockManager registers a storage:BlockManagerSlaveEndpoint.md[] with the input ROOT:index.md[RpcEnv], itself, and scheduler:MapOutputTracker.md[MapOutputTracker] (as `slaveEndpoint`).

BlockManager is created when SparkEnv is core:SparkEnv.md#create-BlockManager[created] (for the driver and executors) when a Spark application starts.

.BlockManager and SparkEnv
image::BlockManager-SparkEnv.png[align="center"]

== [[BlockEvictionHandler]] BlockEvictionHandler

BlockManager is a storage:BlockEvictionHandler.md[] that can <<dropFromMemory, drop a block from memory>> (and store it on a disk when needed).

== [[shuffleClient]][[externalShuffleServiceEnabled]] ShuffleClient and External Shuffle Service

BlockManager manages the lifecycle of a storage:ShuffleClient.md[]:

* Creates when <<creating-instance, created>>

* storage:ShuffleClient.md#init[Inits] (and possibly <<registerWithExternalShuffleServer, registers with an external shuffle server>>) when requested to <<initialize, initialize>>

* Closes when requested to <<stop, stop>>

The ShuffleClient can be an storage:ExternalShuffleClient.md[] or the given <<blockTransferService, BlockTransferService>> based on ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property. When enabled, BlockManager uses the storage:ExternalShuffleClient.md[].

The ShuffleClient is available to other Spark services (using `shuffleClient` value) and is used when BlockStoreShuffleReader is requested to shuffle:BlockStoreShuffleReader.md#read[read combined key-value records for a reduce task].

When requested for <<shuffleMetricsSource, shuffle metrics>>, BlockManager simply requests storage:ShuffleClient.md#shuffleMetrics[them] from the ShuffleClient.

== [[rpcEnv]] BlockManager and RpcEnv

BlockManager is given a rpc:RpcEnv.md[] when <<creating-instance, created>>.

The RpcEnv is used to set up a <<slaveEndpoint, BlockManagerSlaveEndpoint>>.

== [[blockInfoManager]] BlockInfoManager

BlockManager creates a storage:BlockInfoManager.md[] when <<creating-instance, created>>.

BlockManager requests the BlockInfoManager to storage:BlockInfoManager.md#clear[clear] when requested to <<stop, stop>>.

BlockManager uses the BlockInfoManager to create a <<memoryStore, MemoryStore>>.

BlockManager uses the BlockInfoManager when requested for the following:

* <<reportAllBlocks, reportAllBlocks>>

* <<getStatus, getStatus>>

* <<getMatchingBlockIds, getMatchingBlockIds>>

* <<getLocalValues, getLocalValues>> and <<getLocalBytes, getLocalBytes>>

* <<doPut, doPut>>

* <<replicateBlock, replicateBlock>>

* <<dropFromMemory, dropFromMemory>>

* <<removeRdd, removeRdd>>, <<removeBroadcast, removeBroadcast>>, <<removeBlock, removeBlock>>, <<removeBlockInternal, removeBlockInternal>>

* <<downgradeLock, downgradeLock>>, <<releaseLock, releaseLock>>, <<registerTask, registerTask>>, <<releaseAllLocksForTask, releaseAllLocksForTask>>

== [[master]] BlockManager and BlockManagerMaster

BlockManager is given a storage:BlockManagerMaster.md[] when <<creating-instance, created>>.

== [[BlockDataManager]] BlockManager as BlockDataManager

BlockManager is a storage:BlockDataManager.md[].

== [[mapOutputTracker]] BlockManager and MapOutputTracker

BlockManager is given a scheduler:MapOutputTracker.md[] when <<creating-instance, created>>.

== [[executorId]] Executor ID

BlockManager is given an Executor ID when <<creating-instance, created>>.

The Executor ID is one of the following:

* *driver* (`SparkContext.DRIVER_IDENTIFIER`) for the driver

* Value of executor:CoarseGrainedExecutorBackend.md#executor-id[--executor-id] command-line argument for executor:CoarseGrainedExecutorBackend.md[] executors (or spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md[MesosExecutorBackend])

== [[slaveEndpoint]] BlockManagerEndpoint RPC Endpoint

BlockManager requests the <<rpcEnv, RpcEnv>> to rpc:RpcEnv.md#setupEndpoint[register] a storage:BlockManagerSlaveEndpoint.md[] under the name *BlockManagerEndpoint[ID]*.

The RPC endpoint is used when BlockManager is requested to <<initialize, initialize>> and <<reregister, reregister>> (to register the BlockManager on an executor with the <<master, BlockManagerMaster>> on the driver).

The endpoint is stopped (by requesting the <<rpcEnv, RpcEnv>> to rpc:RpcEnv.md#stop[stop the reference]) when BlockManager is requested to <<stop, stop>>.

== [[SparkEnv]] Accessing BlockManager Using SparkEnv

BlockManager is available using core:SparkEnv.md#blockManager[SparkEnv] on the driver and executors.

[source,plaintext]
----
import org.apache.spark.SparkEnv
val bm = SparkEnv.get.blockManager

scala> :type bm
org.apache.spark.storage.BlockManager
----

== [[blockTransferService]] BlockTransferService

BlockManager is given a storage:BlockTransferService.md[BlockTransferService] when <<creating-instance, created>>.

BlockTransferService is used as the <<shuffleClient, ShuffleClient>> when BlockManager is configured with no external shuffle service (based on ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property).

BlockTransferService is storage:BlockTransferService.md#init[initialized] when BlockManager <<initialize, is>>.

BlockTransferService is storage:BlockTransferService.md#close[closed] when BlockManager is requested to <<stop, stop>>.

BlockTransferService is used when BlockManager is requested to <<getRemoteBytes, fetching a block from>> or <<replicate, replicate a block to>> remote block managers.

== [[memoryManager]] MemoryManager

BlockManager is given a memory:MemoryManager.md[MemoryManager] when <<creating-instance, created>>.

BlockManager uses the MemoryManager for the following:

* Create the <<memoryStore, MemoryStore>> (that is then assigned to memory:MemoryManager.md#setMemoryStore[MemoryManager] as a "circular dependency")

* Initialize <<maxOnHeapMemory, maxOnHeapMemory>> and <<maxOffHeapMemory, maxOffHeapMemory>> (for reporting)

== [[shuffleManager]] ShuffleManager

BlockManager is given a shuffle:ShuffleManager.md[ShuffleManager] when <<creating-instance, created>>.

BlockManager uses the ShuffleManager for the following:

* <<getBlockData, Retrieving a block data>> (for shuffle blocks)

* <<getLocalBytes, Retrieving a non-shuffle block data>> (for shuffle blocks anyway)

* <<registerWithExternalShuffleServer, Registering an executor with a local external shuffle service>> (when <<initialize, initialized>> on an executor with <<externalShuffleServiceEnabled, externalShuffleServiceEnabled>>)

== [[diskBlockManager]] DiskBlockManager

BlockManager creates a DiskBlockManager.md[DiskBlockManager] when <<creating-instance, created>>.

.DiskBlockManager and BlockManager
image::DiskBlockManager-BlockManager.png[align="center"]

BlockManager uses the BlockManager for the following:

* Creating a <<diskStore, DiskStore>>

* <<registerWithExternalShuffleServer, Registering an executor with a local external shuffle service>> (when <<initialize, initialized>> on an executor with <<externalShuffleServiceEnabled, externalShuffleServiceEnabled>>)

The BlockManager is available as `diskBlockManager` reference to other Spark systems.

[source, scala]
----
import org.apache.spark.SparkEnv
SparkEnv.get.blockManager.diskBlockManager
----

== [[memoryStore]] MemoryStore

BlockManager creates a storage:MemoryStore.md[] when <<creating-instance, created>> (with the <<blockInfoManager, BlockInfoManager>>, the <<serializerManager, SerializerManager>>, the <<memoryManager, MemoryManager>> and itself as a storage:BlockEvictionHandler.md[]).

.MemoryStore and BlockManager
image::MemoryStore-BlockManager.png[align="center"]

BlockManager requests the <<memoryManager, MemoryManager>> to memory:MemoryManager.md#setMemoryStore[use] the MemoryStore.

BlockManager uses the MemoryStore for the following:

* <<getStatus, getStatus>> and <<getCurrentBlockStatus, getCurrentBlockStatus>>

* <<getLocalValues, getLocalValues>>

* <<doGetLocalBytes, doGetLocalBytes>>

* <<doPutBytes, doPutBytes>> and <<doPutIterator, doPutIterator>>

* <<maybeCacheDiskBytesInMemory, maybeCacheDiskBytesInMemory>> and <<maybeCacheDiskValuesInMemory, maybeCacheDiskValuesInMemory>>

* <<dropFromMemory, dropFromMemory>>

* <<removeBlockInternal, removeBlockInternal>>

The MemoryStore is requested to storage:MemoryStore.md#clear[clear] when BlockManager is requested to <<stop, stop>>.

The MemoryStore is available as `memoryStore` private reference to other Spark services.

[source, scala]
----
import org.apache.spark.SparkEnv
SparkEnv.get.blockManager.memoryStore
----

The MemoryStore is used (via `SparkEnv.get.blockManager.memoryStore` reference) when Task is requested to scheduler:Task.md#run[run] (that has finished and requests the MemoryStore to storage:MemoryStore.md#releaseUnrollMemoryForThisTask[releaseUnrollMemoryForThisTask]).

== [[diskStore]] DiskStore

BlockManager creates a DiskStore.md[DiskStore] (with the <<diskBlockManager, DiskBlockManager>>) when <<creating-instance, created>>.

.DiskStore and BlockManager
image::DiskStore-BlockManager.png[align="center"]

BlockManager uses the DiskStore when requested to <<getStatus, getStatus>>, <<getCurrentBlockStatus, getCurrentBlockStatus>>, <<getLocalValues, getLocalValues>>, <<doGetLocalBytes, doGetLocalBytes>>, <<doPutBytes, doPutBytes>>, <<doPutIterator, doPutIterator>>, <<dropFromMemory, dropFromMemory>>, <<removeBlockInternal, removeBlockInternal>>.

== [[metrics]] Performance Metrics

BlockManager uses spark-BlockManager-BlockManagerSource.md[BlockManagerSource] to report metrics under the name *BlockManager*.

== [[getPeers]] getPeers Internal Method

[source,scala]
----
getPeers(
  forceFetch: Boolean): Seq[BlockManagerId]
----

getPeers...FIXME

getPeers is used when BlockManager is requested to <<replicateBlock, replicateBlock>> and <<replicate, replicate>>.

== [[releaseAllLocksForTask]] Releasing All Locks For Task

[source,scala]
----
releaseAllLocksForTask(
  taskAttemptId: Long): Seq[BlockId]
----

releaseAllLocksForTask...FIXME

releaseAllLocksForTask is used when TaskRunner is requested to executor:TaskRunner.md#run[run] (at the end of a task).

== [[stop]] Stopping BlockManager

[source, scala]
----
stop(): Unit
----

stop...FIXME

stop is used when SparkEnv is requested to core:SparkEnv.md#stop[stop].

== [[getMatchingBlockIds]] Getting IDs of Existing Blocks (For a Given Filter)

[source, scala]
----
getMatchingBlockIds(
  filter: BlockId => Boolean): Seq[BlockId]
----

getMatchingBlockIds...FIXME

getMatchingBlockIds is used when BlockManagerSlaveEndpoint is requested to storage:BlockManagerSlaveEndpoint.md#GetMatchingBlockIds[handle a GetMatchingBlockIds message].

== [[getLocalValues]] Getting Local Block

[source, scala]
----
getLocalValues(
  blockId: BlockId): Option[BlockResult]
----

getLocalValues prints out the following DEBUG message to the logs:

```
Getting local block [blockId]
```

getLocalValues storage:BlockInfoManager.md#lockForReading[obtains a read lock for `blockId`].

When no `blockId` block was found, you should see the following DEBUG message in the logs and getLocalValues returns "nothing" (i.e. `NONE`).

```
Block [blockId] was not found
```

When the `blockId` block was found, you should see the following DEBUG message in the logs:

```
Level for block [blockId] is [level]
```

If `blockId` block has memory level and storage:MemoryStore.md#contains[is registered in `MemoryStore`], getLocalValues returns a <<BlockResult, BlockResult>> as `Memory` read method and with a `CompletionIterator` for an interator:

1. storage:MemoryStore.md#getValues[Values iterator from `MemoryStore` for `blockId`] for "deserialized" persistence levels.
2. Iterator from serializer:SerializerManager.md#dataDeserializeStream[`SerializerManager` after the data stream has been deserialized] for the `blockId` block and storage:MemoryStore.md#getBytes[the bytes for `blockId` block] for "serialized" persistence levels.

getLocalValues is used when:

* TorrentBroadcast is requested to core:TorrentBroadcast.md#readBroadcastBlock[readBroadcastBlock]

* BlockManager is requested to <<get, get>> and <<getOrElseUpdate, getOrElseUpdate>>

=== [[maybeCacheDiskValuesInMemory]] maybeCacheDiskValuesInMemory Internal Method

[source,scala]
----
maybeCacheDiskValuesInMemory[T](
  blockInfo: BlockInfo,
  blockId: BlockId,
  level: StorageLevel,
  diskIterator: Iterator[T]): Iterator[T]
----

maybeCacheDiskValuesInMemory...FIXME

maybeCacheDiskValuesInMemory is used when BlockManager is requested to <<getLocalValues, getLocalValues>>.

== [[getRemoteValues]] `getRemoteValues` Internal Method

[source, scala]
----
getRemoteValues[T: ClassTag](blockId: BlockId): Option[BlockResult]
----

`getRemoteValues`...FIXME

== [[get]] Retrieving Block from Local or Remote Block Managers

[source, scala]
----
get[T: ClassTag](blockId: BlockId): Option[BlockResult]
----

`get` attempts to get the `blockId` block from a local block manager first before requesting it from remote block managers.

Internally, `get` tries to <<getLocalValues, get the block from the local BlockManager>>. If the block was found, you should see the following INFO message in the logs and `get` returns the local <<BlockResult, BlockResult>>.

```
INFO Found block [blockId] locally
```

If however the block was not found locally, `get` tries to <<getRemoteValues, get the block from remote block managers>>. If retrieved from a remote block manager, you should see the following INFO message in the logs and `get` returns the remote <<BlockResult, BlockResult>>.

```
INFO Found block [blockId] remotely
```

In the end, `get` returns "nothing" (i.e. `NONE`) when the `blockId` block was not found either in the local BlockManager or any remote BlockManager.

[NOTE]
====
`get` is used when:

* BlockManager is requested to <<getOrElseUpdate, getOrElseUpdate>> and <<getSingle, getSingle>>
====

== [[getBlockData]] Retrieving Block Data

[source, scala]
----
getBlockData(
  blockId: BlockId): ManagedBuffer
----

NOTE: `getBlockData` is part of the storage:BlockDataManager.md#getBlockData[BlockDataManager] contract.

For a BlockId.md[] of a shuffle (a ShuffleBlockId), getBlockData requests the <<shuffleManager, ShuffleManager>> for the shuffle:ShuffleManager.md#shuffleBlockResolver[ShuffleBlockResolver] that is then requested for shuffle:ShuffleBlockResolver.md#getBlockData[getBlockData].

Otherwise, getBlockData <<getLocalBytes, getLocalBytes>> for the given BlockId.

If found, getBlockData creates a new BlockManagerManagedBuffer (with the <<blockInfoManager, BlockInfoManager>>, the input BlockId, the retrieved BlockData and the dispose flag enabled).

If not found, getBlockData <<reportBlockStatus, informs the BlockManagerMaster>> that the block could not be found (and that the master should no longer assume the block is available on this executor) and throws a BlockNotFoundException.

NOTE: `getBlockData` is executed for shuffle blocks or local blocks that the BlockManagerMaster knows this executor really has (unless BlockManagerMaster is outdated).

== [[getLocalBytes]] Retrieving Non-Shuffle Local Block Data

[source, scala]
----
getLocalBytes(
  blockId: BlockId): Option[BlockData]
----

`getLocalBytes`...FIXME

[NOTE]
====
`getLocalBytes` is used when:

* TorrentBroadcast is requested to core:TorrentBroadcast.md#readBlocks[readBlocks]

* BlockManager is requested for the <<getBlockData, block data>> (of a non-shuffle block)
====

== [[removeBlockInternal]] removeBlockInternal Internal Method

[source, scala]
----
removeBlockInternal(
  blockId: BlockId,
  tellMaster: Boolean): Unit
----

removeBlockInternal...FIXME

removeBlockInternal is used when BlockManager is requested to <<doPut, doPut>> and <<removeBlock, removeBlock>>.

== [[stores]] Stores

A *Store* is the place where blocks are held.

There are the following possible stores:

* storage:MemoryStore.md[MemoryStore] for memory storage level.
* DiskStore.md[DiskStore] for disk storage level.
* `ExternalBlockStore` for OFF_HEAP storage level.

== [[putBlockData]] Storing Block Data Locally

[source, scala]
----
putBlockData(
  blockId: BlockId,
  data: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Boolean
----

`putBlockData` simply <<putBytes, stores `blockId` locally>> (given the given storage `level`).

NOTE: `putBlockData` is part of the storage:BlockDataManager.md#putBlockData[BlockDataManager Contract].

Internally, `putBlockData` wraps `ChunkedByteBuffer` around `data` buffer's NIO `ByteBuffer` and calls <<putBytes, putBytes>>.

== [[putBytes]] Storing Block Bytes Locally

[source, scala]
----
putBytes(
  blockId: BlockId,
  bytes: ChunkedByteBuffer,
  level: StorageLevel,
  tellMaster: Boolean = true): Boolean
----

`putBytes` makes sure that the `bytes` are not `null` and <<doPutBytes, doPutBytes>>.

[NOTE]
====
`putBytes` is used when:

* BlockManager is requested to <<putBlockData, puts a block data locally>>

* `TaskRunner` is requested to executor:TaskRunner.md#run-result-sent-via-blockmanager[run] (and the result size is above executor:Executor.md#maxDirectResultSize[maxDirectResultSize])

* `TorrentBroadcast` is requested to core:TorrentBroadcast.md#writeBlocks[writeBlocks] and core:TorrentBroadcast.md#readBlocks[readBlocks]
====

=== [[doPutBytes]] `doPutBytes` Internal Method

[source, scala]
----
doPutBytes[T](
  blockId: BlockId,
  bytes: ChunkedByteBuffer,
  level: StorageLevel,
  classTag: ClassTag[T],
  tellMaster: Boolean = true,
  keepReadLock: Boolean = false): Boolean
----

`doPutBytes` calls the internal helper <<doPut, doPut>> with a function that accepts a `BlockInfo` and does the uploading.

Inside the function, if the storage:StorageLevel.md[storage `level`]'s replication is greater than 1, it immediately starts <<replicate, replication>> of the `blockId` block on a separate thread (from `futureExecutionContext` thread pool). The replication uses the input `bytes` and `level` storage level.

For a memory storage level, the function checks whether the storage `level` is deserialized or not. For a deserialized storage `level`, ``BlockManager``'s serializer:SerializerManager.md#dataDeserializeStream[`SerializerManager` deserializes `bytes` into an iterator of values] that storage:MemoryStore.md#putIteratorAsValues[`MemoryStore` stores]. If however the storage `level` is not deserialized, the function requests storage:MemoryStore.md#putBytes[`MemoryStore` to store the bytes]

If the put did not succeed and the storage level is to use disk, you should see the following WARN message in the logs:

```
WARN BlockManager: Persisting block [blockId] to disk instead.
```

And DiskStore.md#putBytes[`DiskStore` stores the bytes].

NOTE: DiskStore.md[DiskStore] is requested to store the bytes of a block with memory and disk storage level only when storage:MemoryStore.md[MemoryStore] has failed.

If the storage level is to use disk only, DiskStore.md#putBytes[`DiskStore` stores the bytes].

`doPutBytes` requests <<getCurrentBlockStatus, current block status>> and if the block was successfully stored, and the driver should know about it (`tellMaster`), the function <<reportBlockStatus, reports the current storage status of the block to the driver>>. The executor:TaskMetrics.md#incUpdatedBlockStatuses[current `TaskContext` metrics are updated with the updated block status] (only when executed inside a task where `TaskContext` is available).

You should see the following DEBUG message in the logs:

```
DEBUG BlockManager: Put block [blockId] locally took [time] ms
```

The function waits till the earlier asynchronous replication finishes for a block with replication level greater than `1`.

The final result of `doPutBytes` is the result of storing the block successful or not (as computed earlier).

NOTE: `doPutBytes` is used exclusively when BlockManager is requested to <<putBytes, putBytes>>.

== [[doPut]] doPut Internal Method

[source, scala]
----
doPut[T](
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[_],
  tellMaster: Boolean,
  keepReadLock: Boolean)(putBody: BlockInfo => Option[T]): Option[T]
----

doPut executes the input `putBody` function with a storage:BlockInfo.md[] being a new `BlockInfo` object (with `level` storage level) that storage:BlockInfoManager.md#lockNewBlockForWriting[`BlockInfoManager` managed to create a write lock for].

If the block has already been created (and storage:BlockInfoManager.md#lockNewBlockForWriting[`BlockInfoManager` did not manage to create a write lock for]), the following WARN message is printed out to the logs:

[source,plaintext]
----
Block [blockId] already exists on this machine; not re-adding it
----

doPut <<releaseLock, releases the read lock for the block>> when `keepReadLock` flag is disabled and returns `None` immediately.

If however the write lock has been given, doPut executes `putBody`.

If the result of `putBody` is `None` the block is considered saved successfully.

For successful save and `keepReadLock` enabled, storage:BlockInfoManager.md#downgradeLock[`BlockInfoManager` is requested to downgrade an exclusive write lock for `blockId` to a shared read lock].

For successful save and `keepReadLock` disabled, storage:BlockInfoManager.md#unlock[`BlockInfoManager` is requested to release lock on `blockId`].

For unsuccessful save, <<removeBlockInternal, the block is removed from memory and disk stores>> and the following WARN message is printed out to the logs:

[source,plaintext]
----
Putting block [blockId] failed
----

In the end, doPut prints out the following DEBUG message to the logs:

[source,plaintext]
----
Putting block [blockId] [withOrWithout] replication took [usedTime] ms
----

doPut is used when BlockManager is requested to <<doPutBytes, doPutBytes>> and <<doPutIterator, doPutIterator>>.

== [[removeBlock]] Removing Block From Memory and Disk

[source, scala]
----
removeBlock(
  blockId: BlockId,
  tellMaster: Boolean = true): Unit
----

removeBlock removes the `blockId` block from the storage:MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore].

When executed, it prints out the following DEBUG message to the logs:

```
Removing block [blockId]
```

It requests storage:BlockInfoManager.md[] for lock for writing for the `blockId` block. If it receives none, it prints out the following WARN message to the logs and quits.

```
Asked to remove block [blockId], which does not exist
```

Otherwise, with a write lock for the block, the block is removed from storage:MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore] (see storage:MemoryStore.md#remove[Removing Block in `MemoryStore`] and DiskStore.md#remove[Removing Block in `DiskStore`]).

If both removals fail, it prints out the following WARN message:

```
Block [blockId] could not be removed as it was not found in either the disk, memory, or external block store
```

The block is removed from storage:BlockInfoManager.md[].

removeBlock then <<getCurrentBlockStatus, calculates the current block status>> that is used to <<reportBlockStatus, report the block status to the driver>> (if the input `tellMaster` and the info's `tellMaster` are both enabled, i.e. `true`) and the executor:TaskMetrics.md#incUpdatedBlockStatuses[current TaskContext metrics are updated with the change].

removeBlock is used when:

* BlockManager is requested to <<handleLocalReadFailure, handleLocalReadFailure>>, <<removeRdd, remove an RDD>> and <<removeBroadcast, broadcast>>

* BlockManagerSlaveEndpoint is requested to handle a storage:BlockManagerSlaveEndpoint.md#RemoveBlock[RemoveBlock] message

== [[removeRdd]] Removing RDD Blocks

[source, scala]
----
removeRdd(rddId: Int): Int
----

`removeRdd` removes all the blocks that belong to the `rddId` RDD.

It prints out the following INFO message to the logs:

```
INFO Removing RDD [rddId]
```

It then requests RDD blocks from storage:BlockInfoManager.md[] and <<removeBlock, removes them (from memory and disk)>> (without informing the driver).

The number of blocks removed is the final result.

NOTE: It is used by storage:BlockManagerSlaveEndpoint.md#RemoveRdd[`BlockManagerSlaveEndpoint` while handling `RemoveRdd` messages].

== [[removeBroadcast]] Removing All Blocks of Broadcast Variable

[source, scala]
----
removeBroadcast(broadcastId: Long, tellMaster: Boolean): Int
----

`removeBroadcast` removes all the blocks of the input `broadcastId` broadcast.

Internally, it starts by printing out the following DEBUG message to the logs:

```
Removing broadcast [broadcastId]
```

It then requests all the storage:BlockId.md#BroadcastBlockId[BroadcastBlockId] objects that belong to the `broadcastId` broadcast from storage:BlockInfoManager.md[] and <<removeBlock, removes them (from memory and disk)>>.

The number of blocks removed is the final result.

NOTE: It is used by storage:BlockManagerSlaveEndpoint.md#RemoveBroadcast[`BlockManagerSlaveEndpoint` while handling `RemoveBroadcast` messages].

== [[shuffleServerId]] BlockManagerId of Shuffle Server

BlockManager uses storage:BlockManagerId.md[] for the location (address) of the server that serves shuffle files of this executor.

The BlockManagerId is either the BlockManagerId of the external shuffle service (when <<externalShuffleServiceEnabled, enabled>>) or the <<blockManagerId, blockManagerId>>.

The BlockManagerId of the Shuffle Server is used for the location of a scheduler:MapStatus.md[shuffle map output] when:

* BypassMergeSortShuffleWriter is requested to shuffle:BypassMergeSortShuffleWriter.md#write[write partition records to a shuffle file]

* UnsafeShuffleWriter is requested to shuffle:UnsafeShuffleWriter.md#closeAndWriteOutput[close and write output]

== [[getStatus]] getStatus Method

[source,scala]
----
getStatus(
  blockId: BlockId): Option[BlockStatus]
----

getStatus...FIXME

getStatus is used when BlockManagerSlaveEndpoint is requested to handle storage:BlockManagerSlaveEndpoint.md#GetBlockStatus[GetBlockStatus] message.

== [[initialize]] Initializing BlockManager

[source, scala]
----
initialize(
  appId: String): Unit
----

initialize initializes a BlockManager on the driver and executors (see ROOT:SparkContext.md#creating-instance[Creating SparkContext Instance] and executor:Executor.md#creating-instance[Creating Executor Instance], respectively).

NOTE: The method must be called before a BlockManager can be considered fully operable.

initialize does the following in order:

1. Initializes storage:BlockTransferService.md#init[BlockTransferService]
2. Initializes the internal shuffle client, be it storage:ExternalShuffleClient.md[ExternalShuffleClient] or storage:BlockTransferService.md[BlockTransferService].
3. BlockManagerMaster.md#registerBlockManager[Registers itself with the driver's `BlockManagerMaster`] (using the `id`, `maxMemory` and its `slaveEndpoint`).
+
The `BlockManagerMaster` reference is passed in when the <<creating-instance, BlockManager is created>> on the driver and executors.
4. Sets <<shuffleServerId, shuffleServerId>> to an instance of storage:BlockManagerId.md[] given an executor id, host name and port for storage:BlockTransferService.md[BlockTransferService].
5. It creates the address of the server that serves this executor's shuffle files (using <<shuffleServerId, shuffleServerId>>)

CAUTION: FIXME Review the initialize procedure again

CAUTION: FIXME Describe `shuffleServerId`. Where is it used?

If the <<externalShuffleServiceEnabled, External Shuffle Service is used>>, initialize prints out the following INFO message to the logs:

[source,plaintext]
----
external shuffle service port = [externalShuffleServicePort]
----

It BlockManagerMaster.md#registerBlockManager[registers itself to the driver's BlockManagerMaster] passing the storage:BlockManagerId.md[], the maximum memory (as `maxMemory`), and the storage:BlockManagerSlaveEndpoint.md[].

Ultimately, if the initialization happens on an executor and the <<externalShuffleServiceEnabled, External Shuffle Service is used>>, it <<registerWithExternalShuffleServer, registers to the shuffle service>>.

`initialize` is used when [SparkContext](../SparkContext.md) is created and when an executor:Executor.md#creating-instance[`Executor` is created] (for executor:CoarseGrainedExecutorBackend.md#RegisteredExecutor[CoarseGrainedExecutorBackend] and spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md[MesosExecutorBackend]).

== [[registerWithExternalShuffleServer]] Registering Executor's BlockManager with External Shuffle Server

[source, scala]
----
registerWithExternalShuffleServer(): Unit
----

registerWithExternalShuffleServer is an internal helper method to register the BlockManager for an executor with an deploy:ExternalShuffleService.md[external shuffle server].

NOTE: It is executed when a <<initialize, BlockManager is initialized on an executor and an external shuffle service is used>>.

When executed, you should see the following INFO message in the logs:

```
Registering executor with local external shuffle service.
```

It uses <<shuffleClient, shuffleClient>> to storage:ExternalShuffleClient.md#registerWithShuffleServer[register the block manager] using <<shuffleServerId, shuffleServerId>> (i.e. the host, the port and the executorId) and a `ExecutorShuffleInfo`.

NOTE: The `ExecutorShuffleInfo` uses `localDirs` and `subDirsPerLocalDir` from DiskBlockManager.md[DiskBlockManager] and the class name of the constructor shuffle:ShuffleManager.md[ShuffleManager].

It tries to register at most 3 times with 5-second sleeps in-between.

NOTE: The maximum number of attempts and the sleep time in-between are hard-coded, i.e. they are not configured.

Any issues while connecting to the external shuffle service are reported as ERROR messages in the logs:

```
Failed to connect to external shuffle server, will retry [#attempts] more times after waiting 5 seconds...
```

registerWithExternalShuffleServer is used when BlockManager is requested to <<initialize, initialize>> (when executed on an executor with <<externalShuffleServiceEnabled, externalShuffleServiceEnabled>>).

== [[reregister]] Re-registering BlockManager with Driver and Reporting Blocks

[source, scala]
----
reregister(): Unit
----

When executed, reregister prints the following INFO message to the logs:

```
BlockManager [blockManagerId] re-registering with master
```

reregister then BlockManagerMaster.md#registerBlockManager[registers itself to the driver's `BlockManagerMaster`] (just as it was when <<initialize, BlockManager was initializing>>). It passes the storage:BlockManagerId.md[], the maximum memory (as `maxMemory`), and the storage:BlockManagerSlaveEndpoint.md[].

reregister will then report all the local blocks to the BlockManagerMaster.md[BlockManagerMaster].

You should see the following INFO message in the logs:

```
Reporting [blockInfoManager.size] blocks to the master.
```

For each block metadata (in storage:BlockInfoManager.md[]) it <<getCurrentBlockStatus, gets block current status>> and <<tryToReportBlockStatus, tries to send it to the BlockManagerMaster>>.

If there is an issue communicating to the BlockManagerMaster.md[BlockManagerMaster], you should see the following ERROR message in the logs:

```
Failed to report [blockId] to master; giving up.
```

After the ERROR message, reregister stops reporting.

reregister is used when a executor:Executor.md#heartbeats-and-active-task-metrics[`Executor` was informed to re-register while sending heartbeats].

== [[getCurrentBlockStatus]] Calculate Current Block Status

[source, scala]
----
getCurrentBlockStatus(
  blockId: BlockId,
  info: BlockInfo): BlockStatus
----

getCurrentBlockStatus gives the current `BlockStatus` of the `BlockId` block (with the block's current storage:StorageLevel.md[StorageLevel], memory and disk sizes). It uses storage:MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore] for size and other information.

NOTE: Most of the information to build `BlockStatus` is already in `BlockInfo` except that it may not necessarily reflect the current state per storage:MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore].

Internally, it uses the input storage:BlockInfo.md[] to know about the block's storage level. If the storage level is not set (i.e. `null`), the returned `BlockStatus` assumes the storage:StorageLevel.md[default `NONE` storage level] and the memory and disk sizes being `0`.

If however the storage level is set, getCurrentBlockStatus uses storage:MemoryStore.md[MemoryStore] and DiskStore.md[DiskStore] to check whether the block is stored in the storages or not and request for their sizes in the storages respectively (using their `getSize` or assume `0`).

NOTE: It is acceptable that the `BlockInfo` says to use memory or disk yet the block is not in the storages (yet or anymore). The method will give current status.

getCurrentBlockStatus is used when <<reregister, executor's BlockManager is requested to report the current status of the local blocks to the master>>, <<doPutBytes, saving a block to a storage>> or <<dropFromMemory, removing a block from memory only>> or <<removeBlock, both, i.e. from memory and disk>>.

== [[reportAllBlocks]] reportAllBlocks Internal Method

[source, scala]
----
reportAllBlocks(): Unit
----

reportAllBlocks...FIXME

reportAllBlocks is used when BlockManager is requested to <<reregister, re-register all blocks to the driver>>.

== [[reportBlockStatus]] Reporting Current Storage Status of Block to Driver

[source, scala]
----
reportBlockStatus(
  blockId: BlockId,
  info: BlockInfo,
  status: BlockStatus,
  droppedMemorySize: Long = 0L): Unit
----

reportBlockStatus is an internal method for <<tryToReportBlockStatus, reporting a block status to the driver>> and if told to re-register it prints out the following INFO message to the logs:

```
Got told to re-register updating block [blockId]
```

It does asynchronous reregistration (using `asyncReregister`).

In either case, it prints out the following DEBUG message to the logs:

```
Told master about block [blockId]
```

reportBlockStatus is used when BlockManager is requested to <<getBlockData, getBlockData>>, <<doPutBytes, doPutBytes>>, <<doPutIterator, doPutIterator>>, <<dropFromMemory, dropFromMemory>> and <<removeBlockInternal, removeBlockInternal>>.

== [[tryToReportBlockStatus]] Reporting Block Status Update to Driver

[source, scala]
----
def tryToReportBlockStatus(
  blockId: BlockId,
  info: BlockInfo,
  status: BlockStatus,
  droppedMemorySize: Long = 0L): Boolean
----

tryToReportBlockStatus BlockManagerMaster.md#updateBlockInfo[reports block status update] to <<master, BlockManagerMaster>> and returns its response.

tryToReportBlockStatus is used when BlockManager is requested to <<reportAllBlocks, reportAllBlocks>> or <<reportBlockStatus, reportBlockStatus>>.

== [[execution-context]] Execution Context

*block-manager-future* is the execution context for...FIXME

== [[ByteBuffer]] ByteBuffer

The underlying abstraction for blocks in Spark is a `ByteBuffer` that limits the size of a block to 2GB (`Integer.MAX_VALUE` - see http://stackoverflow.com/q/8076472/1305344[Why does FileChannel.map take up to Integer.MAX_VALUE of data?] and https://issues.apache.org/jira/browse/SPARK-1476[SPARK-1476 2GB limit in spark for blocks]). This has implication not just for managed blocks in use, but also for shuffle blocks (memory mapped blocks are limited to 2GB, even though the API allows for `long`), ser-deser via byte array-backed output streams.

== [[BlockResult]] BlockResult

`BlockResult` is a description of a fetched block with the `readMethod` and `bytes`.

== [[registerTask]] Registering Task

[source, scala]
----
registerTask(
  taskAttemptId: Long): Unit
----

registerTask requests the <<blockInfoManager, BlockInfoManager>> to storage:BlockInfoManager.md#registerTask[register a given task].

registerTask is used when Task is requested to scheduler:Task.md#run[run] (at the start of a task).

== [[getDiskWriter]] Creating DiskBlockObjectWriter

[source, scala]
----
getDiskWriter(
  blockId: BlockId,
  file: File,
  serializerInstance: SerializerInstance,
  bufferSize: Int,
  writeMetrics: ShuffleWriteMetrics): DiskBlockObjectWriter
----

getDiskWriter creates a storage:DiskBlockObjectWriter.md[DiskBlockObjectWriter] (with ROOT:configuration-properties.md#spark.shuffle.sync[spark.shuffle.sync] configuration property for syncWrites argument).

getDiskWriter uses the <<serializerManager, SerializerManager>> of the BlockManager.

getDiskWriter is used when:

* BypassMergeSortShuffleWriter is requested to shuffle:BypassMergeSortShuffleWriter.md#write[write records (of a partition)]

* ShuffleExternalSorter is requested to shuffle:ShuffleExternalSorter.md#writeSortedFile[writeSortedFile]

* ExternalAppendOnlyMap is requested to shuffle:ExternalAppendOnlyMap.md#spillMemoryIteratorToDisk[spillMemoryIteratorToDisk]

* ExternalSorter is requested to shuffle:ExternalSorter.md#spillMemoryIteratorToDisk[spillMemoryIteratorToDisk] and shuffle:ExternalSorter.md#writePartitionedFile[writePartitionedFile]

* memory:UnsafeSorterSpillWriter.md[UnsafeSorterSpillWriter] is created

== [[addUpdatedBlockStatusToTaskMetrics]] Recording Updated BlockStatus In Current Task's TaskMetrics

[source, scala]
----
addUpdatedBlockStatusToTaskMetrics(
  blockId: BlockId,
  status: BlockStatus): Unit
----

addUpdatedBlockStatusToTaskMetrics spark-TaskContext.md#get[takes an active `TaskContext`] (if available) and executor:TaskMetrics.md#incUpdatedBlockStatuses[records updated `BlockStatus` for `Block`] (in the spark-TaskContext.md#taskMetrics[task's `TaskMetrics`]).

addUpdatedBlockStatusToTaskMetrics is used when BlockManager <<doPutBytes, doPutBytes>> (for a block that was successfully stored), <<doPut, doPut>>, <<doPutIterator, doPutIterator>>, <<dropFromMemory, removes blocks from memory>> (possibly spilling it to disk) and <<removeBlock, removes block from memory and disk>>.

== [[shuffleMetricsSource]] Requesting Shuffle-Related Spark Metrics Source

[source, scala]
----
shuffleMetricsSource: Source
----

shuffleMetricsSource requests the <<shuffleClient, ShuffleClient>> for the storage:ShuffleClient.md#shuffleMetrics[shuffle metrics] and creates a storage:ShuffleMetricsSource.md[] with the storage:ShuffleMetricsSource.md#sourceName[source name] based on ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property:

* *ExternalShuffle* when ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property is on (`true`)

* *NettyBlockTransfer* when ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property is off (`false`)

shuffleMetricsSource is used when Executor is executor:Executor.md#creating-instance[created] (for non-local / cluster modes).

== [[replicate]] Replicating Block To Peers

[source, scala]
----
replicate(
  blockId: BlockId,
  data: BlockData,
  level: StorageLevel,
  classTag: ClassTag[_],
  existingReplicas: Set[BlockManagerId] = Set.empty): Unit
----

replicate...FIXME

replicate is used when BlockManager is requested to <<doPutBytes, doPutBytes>>, <<doPutIterator, doPutIterator>> and <<replicateBlock, replicateBlock>>.

== [[replicateBlock]] replicateBlock Method

[source, scala]
----
replicateBlock(
  blockId: BlockId,
  existingReplicas: Set[BlockManagerId],
  maxReplicas: Int): Unit
----

replicateBlock...FIXME

replicateBlock is used when BlockManagerSlaveEndpoint is requested to storage:BlockManagerSlaveEndpoint.md#ReplicateBlock[handle a ReplicateBlock message].

== [[putIterator]] `putIterator` Method

[source, scala]
----
putIterator[T: ClassTag](
  blockId: BlockId,
  values: Iterator[T],
  level: StorageLevel,
  tellMaster: Boolean = true): Boolean
----

`putIterator`...FIXME

[NOTE]
====
`putIterator` is used when:

* BlockManager is requested to <<putSingle, putSingle>>

* Spark Streaming's `BlockManagerBasedBlockHandler` is requested to `storeBlock`
====

== [[putSingle]] putSingle Method

[source, scala]
----
putSingle[T: ClassTag](
  blockId: BlockId,
  value: T,
  level: StorageLevel,
  tellMaster: Boolean = true): Boolean
----

putSingle...FIXME

putSingle is used when TorrentBroadcast is requested to core:TorrentBroadcast.md#writeBlocks[write the blocks] and core:TorrentBroadcast.md#readBroadcastBlock[readBroadcastBlock].

== [[getRemoteBytes]] Fetching Block From Remote Nodes

[source, scala]
----
getRemoteBytes(blockId: BlockId): Option[ChunkedByteBuffer]
----

`getRemoteBytes`...FIXME

[NOTE]
====
`getRemoteBytes` is used when:

* BlockManager is requested to <<getRemoteValues, getRemoteValues>>

* `TorrentBroadcast` is requested to core:TorrentBroadcast.md#readBlocks[readBlocks]

* `TaskResultGetter` is requested to scheduler:TaskResultGetter.md#enqueueSuccessfulTask[enqueuing a successful IndirectTaskResult]
====

== [[getRemoteValues]] `getRemoteValues` Internal Method

[source, scala]
----
getRemoteValues[T: ClassTag](blockId: BlockId): Option[BlockResult]
----

`getRemoteValues`...FIXME

NOTE: `getRemoteValues` is used exclusively when BlockManager is requested to <<get, get a block by BlockId>>.

== [[getSingle]] `getSingle` Method

[source, scala]
----
getSingle[T: ClassTag](blockId: BlockId): Option[T]
----

`getSingle`...FIXME

NOTE: `getSingle` is used exclusively in Spark tests.

== [[getOrElseUpdate]] Getting Block From Block Managers Or Computing and Storing It Otherwise

[source, scala]
----
getOrElseUpdate[T](
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[T],
  makeIterator: () => Iterator[T]): Either[BlockResult, Iterator[T]]
----

[NOTE]
====
_I think_ it is fair to say that `getOrElseUpdate` is like ++https://www.scala-lang.org/api/current/scala/collection/mutable/Map.html#getOrElseUpdate(key:K,op:=%3EV):V++[getOrElseUpdate] of https://www.scala-lang.org/api/current/scala/collection/mutable/Map.html[scala.collection.mutable.Map] in Scala.

[source, scala]
----
getOrElseUpdate(key: K, op: ⇒ V): V
----

Quoting the official scaladoc:

If given key `K` is already in this map, `getOrElseUpdate` returns the associated value `V`.

Otherwise, `getOrElseUpdate` computes a value `V` from given expression `op`, stores with the key `K` in the map and returns that value.

Since BlockManager is a key-value store of blocks of data identified by a block ID that works just fine.
====

`getOrElseUpdate` first attempts to <<get, get the block>> by the `BlockId` (from the local block manager first and, if unavailable, requesting remote peers).

[TIP]
====
Enable `INFO` logging level for `org.apache.spark.storage.BlockManager` logger to see what happens when BlockManager tries to <<get, get a block>>.

See <<logging, logging>> in this document.
====

`getOrElseUpdate` gives the `BlockResult` of the block if found.

If however the block was not found (in any block manager in a Spark cluster), `getOrElseUpdate` <<doPutIterator, doPutIterator>> (for the input `BlockId`, the `makeIterator` function and the `StorageLevel`).

`getOrElseUpdate` branches off per the result.

For `None`, `getOrElseUpdate` <<getLocalValues, getLocalValues>> for the `BlockId` and eventually returns the `BlockResult` (unless terminated by a `SparkException` due to some internal error).

For `Some(iter)`, `getOrElseUpdate` returns an iterator of `T` values.

NOTE: `getOrElseUpdate` is used exclusively when `RDD` is requested to rdd:RDD.md#getOrCompute[get or compute an RDD partition] (for a `RDDBlockId` with a RDD ID and a partition index).

== [[doPutIterator]] doPutIterator Internal Method

[source, scala]
----
doPutIterator[T](
  blockId: BlockId,
  iterator: () => Iterator[T],
  level: StorageLevel,
  classTag: ClassTag[T],
  tellMaster: Boolean = true,
  keepReadLock: Boolean = false): Option[PartiallyUnrolledIterator[T]]
----

`doPutIterator` simply <<doPut, doPut>> with the `putBody` function that accepts a `BlockInfo` and does the following:

. `putBody` branches off per whether the `StorageLevel` indicates to use a storage:StorageLevel.md#useMemory[memory] or simply a storage:StorageLevel.md#useDisk[disk], i.e.

* When the input `StorageLevel` indicates to storage:StorageLevel.md#useMemory[use a memory] for storage in storage:StorageLevel.md#deserialized[deserialized] format, `putBody` requests <<memoryStore, MemoryStore>> to storage:MemoryStore.md#putIteratorAsValues[putIteratorAsValues] (for the `BlockId` and with the `iterator` factory function).
+
If the <<memoryStore, MemoryStore>> returned a correct value, the internal `size` is set to the value.
+
If however the <<memoryStore, MemoryStore>> failed to give a correct value, FIXME

* When the input `StorageLevel` indicates to storage:StorageLevel.md#useMemory[use memory] for storage in storage:StorageLevel.md#deserialized[serialized] format, `putBody`...FIXME

* When the input `StorageLevel` does not indicate to use memory for storage but storage:StorageLevel.md#useDisk[disk] instead, `putBody`...FIXME

. `putBody` requests the <<getCurrentBlockStatus, current block status>>

. Only when the block was successfully stored in either the memory or disk store:

* `putBody` <<reportBlockStatus, reports the block status>> to the <<master, BlockManagerMaster>> when the input `tellMaster` flag (default: enabled) and the `tellMaster` flag of the block info are both enabled.

* `putBody` <<addUpdatedBlockStatusToTaskMetrics, addUpdatedBlockStatusToTaskMetrics>> (with the `BlockId` and `BlockStatus`)

* `putBody` prints out the following DEBUG message to the logs:
+
```
Put block [blockId] locally took [time] ms
```

* When the input `StorageLevel` indicates to use storage:StorageLevel.md#replication[replication], `putBody` <<doGetLocalBytes, doGetLocalBytes>> followed by <<replicate, replicate>> (with the input `BlockId` and the `StorageLevel` as well as the `BlockData` to replicate)

* With a successful replication, `putBody` prints out the following DEBUG message to the logs:
+
```
Put block [blockId] remotely took [time] ms
```

. In the end, `putBody` may or may not give a `PartiallyUnrolledIterator` if...FIXME

NOTE: `doPutIterator` is used when BlockManager is requested to <<getOrElseUpdate, get a block from block managers or computing and storing it otherwise>> and <<putIterator, putIterator>>.

== [[dropFromMemory]] Dropping Block from Memory

[source,scala]
----
dropFromMemory(
  blockId: BlockId,
  data: () => Either[Array[T], ChunkedByteBuffer]): StorageLevel
----

dropFromMemory prints out the following INFO message to the logs:

[source,plaintext]
----
Dropping block [blockId] from memory
----

dropFromMemory then asserts that the given block is storage:BlockInfoManager.md#assertBlockIsLockedForWriting[locked for writing].

If the block's storage:StorageLevel.md[StorageLevel] uses disks and the internal DiskStore.md[DiskStore] object (`diskStore`) does not contain the block, it is saved then. You should see the following INFO message in the logs:

```
Writing block [blockId] to disk
```

CAUTION: FIXME Describe the case with saving a block to disk.

The block's memory size is fetched and recorded (using `MemoryStore.getSize`).

The block is storage:MemoryStore.md#remove[removed from memory] if exists. If not, you should see the following WARN message in the logs:

```
Block [blockId] could not be dropped from memory as it does not exist
```

It then <<getCurrentBlockStatus, calculates the current storage status of the block>> and <<reportBlockStatus, reports it to the driver>>. It only happens when `info.tellMaster`.

CAUTION: FIXME When would `info.tellMaster` be `true`?

A block is considered updated when it was written to disk or removed from memory or both. If either happened, the executor:TaskMetrics.md#incUpdatedBlockStatuses[current TaskContext metrics are updated with the change].

In the end, dropFromMemory returns the current storage level of the block.

dropFromMemory is part of the storage:BlockEvictionHandler.md#dropFromMemory[BlockEvictionHandler] abstraction.

== [[handleLocalReadFailure]] `handleLocalReadFailure` Internal Method

[source, scala]
----
handleLocalReadFailure(blockId: BlockId): Nothing
----

`handleLocalReadFailure`...FIXME

NOTE: `handleLocalReadFailure` is used when...FIXME

== [[releaseLockAndDispose]] releaseLockAndDispose Method

[source, scala]
----
releaseLockAndDispose(
  blockId: BlockId,
  data: BlockData,
  taskAttemptId: Option[Long] = None): Unit
----

releaseLockAndDispose...FIXME

releaseLockAndDispose is used when...FIXME

== [[releaseLock]] releaseLock Method

[source, scala]
----
releaseLock(
  blockId: BlockId,
  taskAttemptId: Option[Long] = None): Unit
----

releaseLock requests the <<blockInfoManager, BlockInfoManager>> to storage:BlockInfoManager.md#unlock[unlock the given block].

releaseLock is part of the storage:BlockDataManager.md#releaseLock[BlockDataManager] abstraction.

== [[putBlockDataAsStream]] putBlockDataAsStream Method

[source,scala]
----
putBlockDataAsStream(
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[_]): StreamCallbackWithID
----

putBlockDataAsStream...FIXME

putBlockDataAsStream is part of the storage:BlockDataManager.md#putBlockDataAsStream[BlockDataManager] abstraction.

== [[downgradeLock]] downgradeLock Method

[source, scala]
----
downgradeLock(
  blockId: BlockId): Unit
----

downgradeLock requests the <<blockInfoManager, BlockInfoManager>> to storage:BlockInfoManager.md#downgradeLock[downgradeLock] for the given storage:BlockId.md[block].

downgradeLock seems _not_ to be used.

== [[blockIdsToLocations]] blockIdsToLocations Utility

[source,scala]
----
blockIdsToLocations(
  blockIds: Array[BlockId],
  env: SparkEnv,
  blockManagerMaster: BlockManagerMaster = null): Map[BlockId, Seq[String]]
----

blockIdsToLocations...FIXME

blockIdsToLocations is used in the _now defunct_ Spark Streaming (when BlockRDD is requested for _locations).

=== [[getLocationBlockIds]] getLocationBlockIds Internal Method

[source,scala]
----
getLocationBlockIds(
  blockIds: Array[BlockId]): Array[Seq[BlockManagerId]]
----

getLocationBlockIds...FIXME

getLocationBlockIds is used when BlockManager utility is requested to <<blockIdsToLocations, blockIdsToLocations>> (for the _now defunct_ Spark Streaming).

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.storage.BlockManager=ALL
----

Refer to ROOT:spark-logging.md[Logging].

== [[internal-properties]] Internal Properties

=== [[maxMemory]] Maximum Memory

Total maximum value that BlockManager can ever possibly use (that depends on <<memoryManager, MemoryManager>> and may vary over time).

Total available memory:MemoryManager.md#maxOnHeapStorageMemory[on-heap] and memory:MemoryManager.md#maxOffHeapStorageMemory[off-heap] memory for storage (in bytes)

=== [[maxOffHeapMemory]] Maximum Off-Heap Memory

=== [[maxOnHeapMemory]] Maximum On-Heap Memory
