== [[StorageStatus]] StorageStatus

`StorageStatus` is a developer API that Spark uses to pass "just enough" information about registered storage:BlockManager.md[BlockManagers] in a Spark application between Spark services (mostly for monitoring purposes like spark-webui.md[web UI] or SparkListener.md[]s).

[NOTE]
====
There are two ways to access `StorageStatus` about all the known `BlockManagers` in a Spark application:

* SparkContext.md#getExecutorStorageStatus[SparkContext.getExecutorStorageStatus]

* Being a SparkListener.md[] and intercepting SparkListener.md#onBlockManagerAdded[onBlockManagerAdded] and SparkListener.md#onBlockManagerRemoved[onBlockManagerRemoved] events
====

`StorageStatus` is <<creating-instance, created>> when:

* `BlockManagerMasterEndpoint` storage:BlockManagerMasterEndpoint.md#storageStatus[is requested for storage status] (of every storage:BlockManager.md[BlockManager] in a Spark application)

[[internal-registries]]
.StorageStatus's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[_nonRddBlocks]] `_nonRddBlocks`
| Lookup table of `BlockIds` per `BlockId`.

Used when...FIXME

| [[_rddBlocks]] `_rddBlocks`
| Lookup table of `BlockIds` with `BlockStatus` per RDD id.

Used when...FIXME
|===

=== [[updateStorageInfo]] `updateStorageInfo` Internal Method

[source, scala]
----
updateStorageInfo(
  blockId: BlockId,
  newBlockStatus: BlockStatus): Unit
----

`updateStorageInfo`...FIXME

NOTE: `updateStorageInfo` is used when...FIXME

=== [[creating-instance]] Creating StorageStatus Instance

`StorageStatus` takes the following when created:

* [[blockManagerId]] storage:BlockManagerId.md[]
* [[maxMem]] Maximum memory -- storage:BlockManager.md#maxMemory[total available on-heap and off-heap memory for storage on the `BlockManager`]

`StorageStatus` initializes the <<internal-registries, internal registries and counters>>.

=== [[rddBlocksById]] Getting RDD Blocks For RDD -- `rddBlocksById` Method

[source, scala]
----
rddBlocksById(rddId: Int): Map[BlockId, BlockStatus]
----

`rddBlocksById` gives the blocks (as `BlockId` with their status as `BlockStatus`) that belong to `rddId` RDD.

=== [[removeBlock]] Removing Block (From Internal Registries) -- `removeBlock` Internal Method

[source, scala]
----
removeBlock(blockId: BlockId): Option[BlockStatus]
----

`removeBlock` removes `blockId` from <<_rddBlocks, _rddBlocks>> registry and returns it.

Internally, `removeBlock` <<updateStorageInfo, updates block status>> of `blockId` (to be empty, i.e. removed).

`removeBlock` branches off per the type of storage:BlockId.md[], i.e. `RDDBlockId` or not.

For a `RDDBlockId`, `removeBlock` finds the RDD in <<_rddBlocks, _rddBlocks>> and removes the `blockId`. `removeBlock` removes the RDD (from <<_rddBlocks, _rddBlocks>>) completely, if there are no more blocks registered.

For a non-``RDDBlockId``, `removeBlock` removes `blockId` from <<_nonRddBlocks, _nonRddBlocks>> registry.

=== [[addBlock]] Registering Status of Data Block -- `addBlock` Method

[source, scala]
----
addBlock(
  blockId: BlockId,
  blockStatus: BlockStatus): Unit
----

`addBlock`...FIXME

NOTE: `addBlock` is used when...FIXME

=== [[getBlock]] `getBlock` Method

[source, scala]
----
getBlock(blockId: BlockId): Option[BlockStatus]
----

`getBlock`...FIXME

NOTE: `getBlock` is used when...FIXME
