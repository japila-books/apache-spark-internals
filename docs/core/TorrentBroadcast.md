= TorrentBroadcast

*TorrentBroadcast* is a xref:ROOT:Broadcast.adoc[] that uses a BitTorrent-like protocol for broadcast blocks distribution.

.TorrentBroadcast -- Broadcasting using BitTorrent
image::sparkcontext-broadcast-bittorrent.png[align="center"]

When a xref:ROOT:SparkContext.adoc#broadcast[broadcast variable is created (using `SparkContext.broadcast`)] on the driver, a <<creating-instance, new instance of TorrentBroadcast is created>>.

[source, scala]
----
// On the driver
val sc: SparkContext = ???
val anyScalaValue = ???
val b = sc.broadcast(anyScalaValue) // <-- TorrentBroadcast is created
----

A broadcast variable is stored on the driver's xref:storage:BlockManager.adoc[BlockManager] as a single value and separately as broadcast blocks (after it was <<blockifyObject, divided into broadcast blocks, i.e. blockified>>). The broadcast block size is the value of xref:core:BroadcastManager.adoc#spark_broadcast_blockSize[spark.broadcast.blockSize] Spark property.

.TorrentBroadcast puts broadcast and the chunks to driver's BlockManager
image::sparkcontext-broadcast-bittorrent-newBroadcast.png[align="center"]

NOTE: TorrentBroadcast-based broadcast variables are created using xref:core:TorrentBroadcastFactory.adoc[TorrentBroadcastFactory].

== [[creating-instance]] Creating Instance

TorrentBroadcast takes the following to be created:

* [[obj]] Object (the value) to be broadcast
* [[id]] ID

TorrentBroadcast is created when TorrentBroadcastFactory is requested for a xref:core:TorrentBroadcastFactory.adoc#newBroadcast[new broadcast variable].

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

getValue is part of the xref:ROOT:Broadcast.adoc#getValue[Broadcast] abstraction.

== [[broadcastId]] BroadcastBlockId

TorrentBroadcast uses a xref:storage:BlockId.adoc#BroadcastBlockId[BroadcastBlockId] for...FIXME

== [[readBroadcastBlock]] readBroadcastBlock Internal Method

[source, scala]
----
readBroadcastBlock(): T
----

readBroadcastBlock xref:SparkEnv.adoc#get[uses the SparkEnv] to access xref:SparkEnv.adoc#broadcastManager[BroadcastManager] that is requested for xref:BroadcastManager.adoc#cachedValues[cached broadcast values].

readBroadcastBlock looks up the <<broadcastId, BroadcastBlockId>> in the cached broadcast values and returns it if found.

If not found, readBroadcastBlock requests the SparkEnv for the xref:core:SparkEnv.adoc#conf[SparkConf] and <<setConf, setConf>>.

readBroadcastBlock xref:SparkEnv.adoc#get[uses the SparkEnv] to access xref:SparkEnv.adoc#blockManager[BlockManager].

readBroadcastBlock requests the BlockManager for xref:storage:BlockManager.adoc#getLocalValues[getLocalValues].

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

NOTE: readBroadcastBlock uses the xref:core:SparkEnv.adoc#serializer[current `Serializer`] and the internal xref:io:CompressionCodec.adoc[CompressionCodec] to bring all the blocks together as one single broadcast variable.

readBroadcastBlock xref:storage:BlockManager.adoc#putSingle[stores the broadcast variable with `MEMORY_AND_DISK` storage level to the local `BlockManager`]. When storing the broadcast variable was unsuccessful, a `SparkException` is thrown.

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

setConf uses the input `conf` xref:ROOT:SparkConf.adoc[SparkConf] to set compression codec and the block size.

Internally, setConf reads xref:core:BroadcastManager.adoc#spark.broadcast.compress[spark.broadcast.compress] configuration property and if enabled (which it is by default) sets a xref:io:CompressionCodec.adoc#createCodec[CompressionCodec] (as an internal `compressionCodec` property).

setConf also reads xref:core:BroadcastManager.adoc#spark_broadcast_blockSize[spark.broadcast.blockSize] Spark property and sets the block size (as the internal `blockSize` property).

setConf is executed when <<creating-instance, TorrentBroadcast is created>> or <<readBroadcastBlock, re-created when deserialized on executors>>.

== [[writeBlocks]] Storing Broadcast and Blocks to BlockManager

[source, scala]
----
writeBlocks(
  value: T): Int
----

writeBlocks stores the given value (that is the <<obj, broadcast value>>) and the blocks in xref:storage:BlockManager.adoc[]. writeBlocks returns the <<numBlocks, number of blocks of the broadcast>> (was divided into).

Internally, writeBlocks uses the xref:core:SparkEnv.adoc#get[SparkEnv] to access xref:core:SparkEnv.adoc#blockManager[BlockManager].

writeBlocks requests the BlockManager to xref:storage:BlockManager.adoc#putSingle[putSingle] (with MEMORY_AND_DISK storage level).

writeBlocks <<blockifyObject, blockify>> the given value (of the <<blockSize, block size>>, the system xref:core:SparkEnv.adoc#serializer[Serializer], and the optional <<compressionCodec, compressionCodec>>).

For every block, writeBlocks creates a xref:storage:BlockId.adoc#BroadcastBlockId[BroadcastBlockId] for the <<id, broadcast variable ID>> and `piece[index]` identifier, and requests the BlockManager to xref:storage:BlockManager.adoc#putBytes[putBytes] (with MEMORY_AND_DISK_SER storage level).

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

blockifyObject divides (aka _blockifies_) the input `obj` value into blocks (`ByteBuffer` chunks). blockifyObject uses the given xref:serializer:Serializer.adoc[] to write the value in a serialized format to a `ChunkedByteBufferOutputStream` of the given `blockSize` size with the optional xref:io:CompressionCodec.adoc[CompressionCodec].

blockifyObject is used when TorrentBroadcast is requested to <<writeBlocks, stores itself as blocks to a local BlockManager>>.

== [[doUnpersist]] `doUnpersist` Method

[source, scala]
----
doUnpersist(blocking: Boolean): Unit
----

`doUnpersist` <<unpersist, removes all the persisted state associated with a broadcast variable on executors>>.

NOTE: `doUnpersist` is part of the xref:ROOT:Broadcast.adoc#contract[`Broadcast` Variable Contract] and is executed from <<unpersist, unpersist>> method.

== [[doDestroy]] `doDestroy` Method

[source, scala]
----
doDestroy(blocking: Boolean): Unit
----

`doDestroy` <<unpersist, removes all the persisted state associated with a broadcast variable on all the nodes in a Spark application>>, i.e. the driver and executors.

NOTE: `doDestroy` is executed when xref:ROOT:Broadcast.adoc#destroy-internal[`Broadcast` removes the persisted data and metadata related to a broadcast variable].

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

unpersist requests xref:storage:BlockManagerMaster.adoc#removeBroadcast[`BlockManagerMaster` to remove the `id` broadcast].

NOTE: unpersist uses xref:core:SparkEnv.adoc#blockManager[`SparkEnv` to get the `BlockManagerMaster`] (through `blockManager` property).

unpersist is used when:

* TorrentBroadcast is requested to <<doUnpersist, unpersist a broadcast variable on executors>> and <<doDestroy, remove a broadcast variable from the driver and executors>>

* TorrentBroadcastFactory is requested to xref:TorrentBroadcastFactory.adoc#unbroadcast[unbroadcast]

== [[readBlocks]] Reading Broadcast Blocks

[source, scala]
----
readBlocks(): Array[BlockData]
----

readBlocks creates a local array of xref:storage:BlockData.adoc[]s for <<numBlocks, numBlocks>> elements (that is later modified and returned).

readBlocks uses the xref:core:SparkEnv.adoc[] to access xref:core:SparkEnv.adoc#blockManager[BlockManager] (that is later used to fetch local or remote blocks).

For every block (randomly-chosen by block ID between 0 and <<numBlocks, numBlocks>>), readBlocks creates a xref:storage:BlockId.adoc#BroadcastBlockId[BroadcastBlockId] for the <<id, id>> (of the broadcast variable) and the chunk identified by the `piece` prefix followed by the ID.

readBlocks prints out the following DEBUG message to the logs:

[source,plaintext]
----
Reading piece [pieceId] of [broadcastId]
----

readBlocks first tries to look up the piece locally by requesting the BlockManager to xref:storage:BlockManager.adoc#getLocalBytes[getLocalBytes] and, if found, stores the reference in the local block array (for the piece ID) and <<releaseLock, releaseLock>> for the chunk.

If not found locally, readBlocks requests the BlockManager to xref:storage:BlockManager.adoc#getRemoteBytes[getRemoteBytes].

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

Refer to xref:ROOT:spark-logging.adoc[Logging].
