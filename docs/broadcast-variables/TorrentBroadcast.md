# TorrentBroadcast

`TorrentBroadcast` is a Broadcast.md[] that uses a BitTorrent-like protocol for broadcast blocks distribution.

![TorrentBroadcast -- Broadcasting using BitTorrent](../images/sparkcontext-broadcast-bittorrent.png)

When a SparkContext.md#broadcast[broadcast variable is created (using `SparkContext.broadcast`)] on the driver, a <<creating-instance, new instance of TorrentBroadcast is created>>.

[source, scala]
----
// On the driver
val sc: SparkContext = ???
val anyScalaValue = ???
val b = sc.broadcast(anyScalaValue) // <-- TorrentBroadcast is created
----

A broadcast variable is stored on the driver's storage:BlockManager.md[BlockManager] as a single value and separately as broadcast blocks (after it was <<blockifyObject, divided into broadcast blocks, i.e. blockified>>). The broadcast block size is the value of core:broadcast-variables/BroadcastManager.md#spark_broadcast_blockSize[spark.broadcast.blockSize] Spark property.

![TorrentBroadcast puts broadcast and the chunks to driver's BlockManager](../images/sparkcontext-broadcast-bittorrent-newBroadcast.png)

NOTE: `TorrentBroadcast`-based broadcast variables are created using [TorrentBroadcastFactory](TorrentBroadcastFactory.md).

## Creating Instance

TorrentBroadcast takes the following to be created:

* [[obj]] Object (the value) to be broadcast
* [[id]] ID

TorrentBroadcast is created when TorrentBroadcastFactory is requested for a [new broadcast variable](TorrentBroadcastFactory.md#newBroadcast).

== [[_value]] Transient Lazy Broadcast Value

[source, scala]
----
_value: T
----

TorrentBroadcast uses `_value` internal registry for the value that is <<readBroadcastBlock, computed>> on demand (and cached afterwards).

`_value` is a `@transient private lazy val` and uses two Scala language features:

* It is not serialized when the TorrentBroadcast is serialized to be sent over the wire to executors (and has to be <<readBroadcastBlock, re-computed>> afterwards)

* It is lazily instantiated when first requested and cached afterwards

== [[numBlocks]] numBlocks Internal Value

TorrentBroadcast uses `numBlocks` internal value for the total number of blocks it contains. It is <<writeBlocks, initialized>> when TorrentBroadcast is <<creating-instance, created>>.

== [[getValue]] Getting Value of Broadcast Variable

[source, scala]
----
def getValue(): T
----

getValue returns the <<_value, _value>>.

getValue is part of the Broadcast.md#getValue[Broadcast] abstraction.

== [[broadcastId]] BroadcastBlockId

TorrentBroadcast uses a storage:BlockId.md#BroadcastBlockId[BroadcastBlockId] for...FIXME

== [[readBroadcastBlock]] readBroadcastBlock Internal Method

[source, scala]
----
readBroadcastBlock(): T
----

readBroadcastBlock SparkEnv.md#get[uses the SparkEnv] to access SparkEnv.md#broadcastManager[BroadcastManager] that is requested for broadcast-variables/BroadcastManager.md#cachedValues[cached broadcast values].

readBroadcastBlock looks up the <<broadcastId, BroadcastBlockId>> in the cached broadcast values and returns it if found.

If not found, readBroadcastBlock requests the SparkEnv for the core:SparkEnv.md#conf[SparkConf] and <<setConf, setConf>>.

readBroadcastBlock SparkEnv.md#get[uses the SparkEnv] to access SparkEnv.md#blockManager[BlockManager].

readBroadcastBlock requests the BlockManager for storage:BlockManager.md#getLocalValues[getLocalValues].

If the broadcast data was available locally, readBroadcastBlock <<releaseLock, releases a lock>> for the broadcast and returns the value.

If however the broadcast data was not found locally, you should see the following INFO message in the logs:

[source,plaintext]
----
Started reading broadcast variable [id]
----

readBroadcastBlock <<readBlocks, reads blocks (as chunks)>> of the broadcast.

You should see the following INFO message in the logs:

[source,plaintext]
----
Reading broadcast variable [id] took [usedTimeMs]
----

readBroadcastBlock <<unBlockifyObject, _unblockifies_ the collection of `ByteBuffer` blocks>>

NOTE: readBroadcastBlock uses the core:SparkEnv.md#serializer[current `Serializer`] and the internal io:CompressionCodec.md[CompressionCodec] to bring all the blocks together as one single broadcast variable.

readBroadcastBlock storage:BlockManager.md#putSingle[stores the broadcast variable with `MEMORY_AND_DISK` storage level to the local `BlockManager`]. When storing the broadcast variable was unsuccessful, a `SparkException` is thrown.

[source,plaintext]
----
Failed to store [broadcastId] in BlockManager
----

The broadcast variable is returned.

readBroadcastBlock is used when TorrentBroadcast is requested for the <<_value, broadcast value>>.

== [[setConf]] setConf Internal Method

[source, scala]
----
setConf(
  conf: SparkConf): Unit
----

setConf uses the input `conf` SparkConf.md[SparkConf] to set compression codec and the block size.

Internally, setConf reads core:broadcast-variables/BroadcastManager.md#spark.broadcast.compress[spark.broadcast.compress] configuration property and if enabled (which it is by default) sets a io:CompressionCodec.md#createCodec[CompressionCodec] (as an internal `compressionCodec` property).

setConf also reads core:broadcast-variables/BroadcastManager.md#spark_broadcast_blockSize[spark.broadcast.blockSize] Spark property and sets the block size (as the internal `blockSize` property).

setConf is executed when <<creating-instance, TorrentBroadcast is created>> or <<readBroadcastBlock, re-created when deserialized on executors>>.

== [[writeBlocks]] Storing Broadcast and Blocks to BlockManager

[source, scala]
----
writeBlocks(
  value: T): Int
----

writeBlocks stores the given value (that is the <<obj, broadcast value>>) and the blocks in storage:BlockManager.md[]. writeBlocks returns the <<numBlocks, number of blocks of the broadcast>> (was divided into).

Internally, writeBlocks uses the core:SparkEnv.md#get[SparkEnv] to access core:SparkEnv.md#blockManager[BlockManager].

writeBlocks requests the BlockManager to storage:BlockManager.md#putSingle[putSingle] (with MEMORY_AND_DISK storage level).

writeBlocks <<blockifyObject, blockify>> the given value (of the <<blockSize, block size>>, the system core:SparkEnv.md#serializer[Serializer], and the optional <<compressionCodec, compressionCodec>>).

For every block, writeBlocks creates a storage:BlockId.md#BroadcastBlockId[BroadcastBlockId] for the <<id, broadcast variable ID>> and `piece[index]` identifier, and requests the BlockManager to storage:BlockManager.md#putBytes[putBytes] (with MEMORY_AND_DISK_SER storage level).

The entire broadcast value is stored in the local BlockManager with MEMORY_AND_DISK storage level whereas the blocks with MEMORY_AND_DISK_SER storage level.

With <<checksumEnabled, checksumEnabled>> writeBlocks...FIXME

In case of an error while storing the value or the blocks, writeBlocks throws a SparkException:

[source,plaintext]
----
Failed to store [pieceId] of [broadcastId] in local BlockManager
----

writeBlocks is used when TorrentBroadcast is <<creating-instance, created>> for the <<numBlocks, numBlocks>> internal registry (that happens on the driver only).

== [[blockifyObject]] Chunking Broadcast Variable Into Blocks

[source, scala]
----
blockifyObject[T](
  obj: T,
  blockSize: Int,
  serializer: Serializer,
  compressionCodec: Option[CompressionCodec]): Array[ByteBuffer]
----

blockifyObject divides (aka _blockifies_) the input `obj` value into blocks (`ByteBuffer` chunks). blockifyObject uses the given serializer:Serializer.md[] to write the value in a serialized format to a `ChunkedByteBufferOutputStream` of the given `blockSize` size with the optional io:CompressionCodec.md[CompressionCodec].

blockifyObject is used when TorrentBroadcast is requested to <<writeBlocks, stores itself as blocks to a local BlockManager>>.

== [[doUnpersist]] `doUnpersist` Method

[source, scala]
----
doUnpersist(blocking: Boolean): Unit
----

`doUnpersist` <<unpersist, removes all the persisted state associated with a broadcast variable on executors>>.

NOTE: `doUnpersist` is part of the Broadcast.md#contract[`Broadcast` Variable Contract] and is executed from <<unpersist, unpersist>> method.

== [[doDestroy]] `doDestroy` Method

[source, scala]
----
doDestroy(blocking: Boolean): Unit
----

`doDestroy` <<unpersist, removes all the persisted state associated with a broadcast variable on all the nodes in a Spark application>>, i.e. the driver and executors.

NOTE: `doDestroy` is executed when Broadcast.md#destroy-internal[`Broadcast` removes the persisted data and metadata related to a broadcast variable].

== [[unpersist]] unpersist Utility

[source, scala]
----
unpersist(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
----

unpersist removes all broadcast blocks from executors and, with the given removeFromDriver flag enabled, from the driver.

When executed, unpersist prints out the following DEBUG message in the logs:

[source,plaintext]
----
Unpersisting TorrentBroadcast [id]
----

unpersist requests storage:BlockManagerMaster.md#removeBroadcast[`BlockManagerMaster` to remove the `id` broadcast].

NOTE: unpersist uses core:SparkEnv.md#blockManager[`SparkEnv` to get the `BlockManagerMaster`] (through `blockManager` property).

`unpersist` is used when:

* `TorrentBroadcast` is requested to <<doUnpersist, unpersist a broadcast variable on executors>> and <<doDestroy, remove a broadcast variable from the driver and executors>>

* `TorrentBroadcastFactory` is requested to [unbroadcast](TorrentBroadcastFactory.md#unbroadcast)

== [[readBlocks]] Reading Broadcast Blocks

[source, scala]
----
readBlocks(): Array[BlockData]
----

readBlocks creates a local array of storage:BlockData.md[]s for <<numBlocks, numBlocks>> elements (that is later modified and returned).

readBlocks uses the core:SparkEnv.md[] to access core:SparkEnv.md#blockManager[BlockManager] (that is later used to fetch local or remote blocks).

For every block (randomly-chosen by block ID between 0 and <<numBlocks, numBlocks>>), readBlocks creates a storage:BlockId.md#BroadcastBlockId[BroadcastBlockId] for the <<id, id>> (of the broadcast variable) and the chunk identified by the `piece` prefix followed by the ID.

readBlocks prints out the following DEBUG message to the logs:

[source,plaintext]
----
Reading piece [pieceId] of [broadcastId]
----

readBlocks first tries to look up the piece locally by requesting the BlockManager to storage:BlockManager.md#getLocalBytes[getLocalBytes] and, if found, stores the reference in the local block array (for the piece ID) and <<releaseLock, releaseLock>> for the chunk.

If not found locally, readBlocks requests the BlockManager to storage:BlockManager.md#getRemoteBytes[getRemoteBytes].

readBlocks...FIXME

readBlocks throws a SparkException for blocks neither available locally nor remotely:

[source,plaintext]
----
Failed to get [pieceId] of [broadcastId]
----

readBlocks is used when TorrentBroadcast is requested to <<readBroadcastBlock, readBroadcastBlock>>.

== [[unBlockifyObject]] unBlockifyObject Utility

[source, scala]
----
unBlockifyObject[T: ClassTag](
  blocks: Array[InputStream],
  serializer: Serializer,
  compressionCodec: Option[CompressionCodec]): T
----

unBlockifyObject...FIXME

unBlockifyObject is used when TorrentBroadcast is requested to <<readBroadcastBlock, readBroadcastBlock>>.

== [[releaseLock]] releaseLock Internal Method

[source, scala]
----
releaseLock(
  blockId: BlockId): Unit
----

releaseLock...FIXME

releaseLock is used when TorrentBroadcast is requested to <<readBroadcastBlock, readBroadcastBlock>> and <<readBlocks, readBlocks>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.broadcast.TorrentBroadcast` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.broadcast.TorrentBroadcast=ALL
----

Refer to spark-logging.md[Logging].
