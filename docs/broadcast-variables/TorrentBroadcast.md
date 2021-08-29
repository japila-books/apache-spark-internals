# TorrentBroadcast

`TorrentBroadcast` is a [Broadcast](Broadcast.md) that uses a BitTorrent-like protocol for broadcast blocks distribution.

![TorrentBroadcast -- Broadcasting using BitTorrent](../images/sparkcontext-broadcast-bittorrent.png)

## Creating Instance

`TorrentBroadcast` takes the following to be created:

* <span id="obj"> Broadcast Value (of type `T`)
* <span id="id"> Identifier

`TorrentBroadcast` is created when:

* `TorrentBroadcastFactory` is requested for a [new broadcast variable](TorrentBroadcastFactory.md#newBroadcast)

## <span id="broadcastId"> BroadcastBlockId

`TorrentBroadcast` creates a [BroadcastBlockId](../storage/BlockId.md#BroadcastBlockId) (with the [id](#id)) when [created](#creating-instance)

## <span id="numBlocks"> Number of Block Chunks

`TorrentBroadcast` uses `numBlocks` for the number of blocks of a broadcast variable (that [was blockified into](#writeBlocks) when [created](#creating-instance)).

## <span id="_value"> Transient Lazy Broadcast Value

```scala
_value: T
```

`TorrentBroadcast` uses `_value` transient registry for the value that is [computed](#readBroadcastBlock) on demand (and cached afterwards).

`_value` is a `@transient private lazy val` and uses the following Scala language features:

1. It is not serialized when the `TorrentBroadcast` is serialized to be sent over the wire to executors (and has to be [re-computed](#readBroadcastBlock) afterwards)
1. It is lazily instantiated when first requested and cached afterwards

## <span id="getValue"> Value

```scala
getValue(): T
```

`getValue` uses the [_value](#_value) transient registry for the value if available (non-`null`).

Otherwise, `getValue` [reads the broadcast block](#readBroadcastBlock) (from the local [BroadcastManager](BroadcastManager.md), [BlockManager](../storage/BlockManager.md) or falls back to [readBlocks](#readBlocks)).

`getValue` saves the object in the [_value](#_value) registry.

---

`getValue` is part of the [Broadcast](Broadcast.md#getValue) abstraction.

### <span id="readBroadcastBlock"> Reading Broadcast Block

```scala
readBroadcastBlock(): T
```

`readBroadcastBlock` looks up the [BroadcastBlockId](#broadcastId) in (the cache of) [BroadcastManager](BroadcastManager.md) and returns the value if found.

Otherwise, `readBroadcastBlock` [setConf](#setConf) and requests the [BlockManager](../storage/BlockManager.md) for the [locally-stored broadcast data](../storage/BlockManager.md#getLocalValues).

If the broadcast block is found locally, `readBroadcastBlock` requests the `BroadcastManager` to [cache it](BroadcastManager.md#cachedValues) and returns the value.

If not found locally, `readBroadcastBlock` multiplies the [numBlocks](#numBlocks) by the [blockSize](#blockSize) for an estimated size of the broadcast block. `readBroadcastBlock` prints out the following INFO message to the logs:

```text
Started reading broadcast variable [id] with [numBlocks] pieces
(estimated total size [estimatedTotalSize])
```

`readBroadcastBlock` [readBlocks](#readBlocks) and prints out the following INFO message to the logs:

```text
Reading broadcast variable [id] took [time] ms
```

`readBroadcastBlock` [unblockifies the block chunks into an object](#unBlockifyObject) (using the [Serializer](../serializer/Serializer.md) and the [CompressionCodec](#compressionCodec)).

`readBroadcastBlock` requests the [BlockManager](../storage/BlockManager.md) to [store the merged copy](../storage/BlockManager.md#putSingle) (so other tasks on this executor don't need to re-fetch it). `readBroadcastBlock` uses `MEMORY_AND_DISK` storage level and the `tellMaster` flag off.

`readBroadcastBlock` requests the `BroadcastManager` to [cache it](BroadcastManager.md#cachedValues) and returns the value.

### <span id="unBlockifyObject"> Unblockifying Broadcast Value

```scala
unBlockifyObject(
  blocks: Array[InputStream],
  serializer: Serializer,
  compressionCodec: Option[CompressionCodec]): T
```

`unBlockifyObject`...FIXME

### <span id="readBlocks"> Reading Broadcast Block Chunks

```scala
readBlocks(): Array[BlockData]
```

`readBlocks` creates a collection of [BlockData](../storage/BlockData.md)s for [numBlocks](#numBlocks) block chunks.

For every block (randomly-chosen by block ID between 0 and [numBlocks](#numBlocks)), `readBlocks` creates a [BroadcastBlockId](../storage/BlockId.md#BroadcastBlockId) for the [id](#id) (of the broadcast variable) and the chunk (identified by the `piece` prefix followed by the ID).

`readBlocks` prints out the following DEBUG message to the logs:

```text
Reading piece [pieceId] of [broadcastId]
```

`readBlocks` first tries to look up the piece locally by requesting the `BlockManager` to [getLocalBytes](../storage/BlockManager.md#getLocalBytes) and, if found, stores the reference in the local block array (for the piece ID).

If not found in the local `BlockManager`, `readBlocks` requests the `BlockManager` to [getRemoteBytes](../storage/BlockManager.md#getRemoteBytes).

With [checksumEnabled](#checksumEnabled), `readBlocks`...FIXME

`readBlocks` requests the `BlockManager` to [store the chunk](../storage/BlockManager.md#putBytes) (so other tasks on this executor don't need to re-fetch it) using `MEMORY_AND_DISK_SER` storage level and reporting to the driver (so other executors can pull these chunks from this executor as well).

`readBlocks` creates a [ByteBufferBlockData](../storage/BlockData.md#ByteBufferBlockData) for the chunk (and stores it in the `blocks` array).

---

`readBlocks` throws a `SparkException` for blocks neither available locally nor remotely:

```text
Failed to get [pieceId] of [broadcastId]
```

## <span id="compressionCodec"> CompressionCodec

```scala
compressionCodec: Option[CompressionCodec]
```

`TorrentBroadcast` uses the [spark.broadcast.compress](../configuration-properties.md#spark.broadcast.compress) configuration property for the [CompressionCodec](../CompressionCodec.md) to use for [writeBlocks](#writeBlocks) and [readBroadcastBlock](#readBroadcastBlock).

## <span id="blockSize"> Broadcast Block Chunk Size

`TorrentBroadcast` uses the [spark.broadcast.blockSize](../configuration-properties.md#spark.broadcast.blockSize) configuration property for the size of the chunks (_pieces_) of a broadcast block.

`TorrentBroadcast` uses the size for [writeBlocks](#writeBlocks) and [readBroadcastBlock](#readBroadcastBlock).

## <span id="writeBlocks"> Persisting Broadcast (to BlockManager)

```scala
writeBlocks(
  value: T): Int
```

`writeBlocks` returns the [number of blocks](#numBlocks) (_chunks_) this broadcast variable ([was blockified into](#blockifyObject)).

The whole broadcast value is stored in the local `BlockManager` with `MEMORY_AND_DISK` storage level while the block chunks with `MEMORY_AND_DISK_SER` storage level.

`writeBlocks` is used when:

* `TorrentBroadcast` is [created](#numBlocks) (that happens on the driver only)

---

`writeBlocks` requests the [BlockManager](../storage/BlockManager.md) to [store the given broadcast value](../storage/BlockManager.md#putSingle) (to be identified as the [broadcastId](#broadcastId) and with the `MEMORY_AND_DISK` storage level).

`writeBlocks` [blockify the object](#blockifyObject) (into chunks of the [block size](#blockSize), the [Serializer](../serializer/Serializer.md), and the optional [compressionCodec](#compressionCodec)).

With [checksumEnabled](#checksumEnabled) `writeBlocks`...FIXME

For every block, `writeBlocks` creates a [BroadcastBlockId](../storage/BlockId.md#BroadcastBlockId) for the [id](#id) and `piece[index]` identifier, and requests the `BlockManager` to [store the chunk bytes](../storage/BlockManager.md#putBytes) (with `MEMORY_AND_DISK_SER` storage level and reporting to the driver).

### <span id="blockifyObject"> Blockifying Broadcast Variable

```scala
blockifyObject(
  obj: T,
  blockSize: Int,
  serializer: Serializer,
  compressionCodec: Option[CompressionCodec]): Array[ByteBuffer]
```

`blockifyObject` divides (_blockifies_) the input `obj` broadcast value into blocks (`ByteBuffer` chunks). `blockifyObject` uses the given [Serializer](../serializer/Serializer.md) to write the value in a serialized format to a `ChunkedByteBufferOutputStream` of the given `blockSize` size with the optional [CompressionCodec](../CompressionCodec.md).

### <span id="writeBlocks-exceptions"> Error Handling

In case of any error, `writeBlocks` prints out the following ERROR message to the logs and requests the local `BlockManager` to [remove the broadcast](../storage/BlockManager.md#removeBroadcast).

```text
Store broadcast [broadcastId] fail, remove all pieces of the broadcast
```

---

In case of an error while storing the value itself, `writeBlocks` throws a `SparkException`:

```text
Failed to store [broadcastId] in BlockManager
```

---

In case of an error while storing the chunks of the blockified value, `writeBlocks` throws a `SparkException`:

```text
Failed to store [pieceId] of [broadcastId] in local BlockManager
```

## <span id="doDestroy"> Destroying Variable

```scala
doDestroy(
  blocking: Boolean): Unit
```

`doDestroy` [removes the persisted state](#unpersist) (associated with the broadcast variable) on all the nodes in a Spark application (the driver and executors).

`doDestroy` is part of the [Broadcast](Broadcast.md#doDestroy) abstraction.

## <span id="doUnpersist"> Unpersisting Variable

```scala
doUnpersist(
  blocking: Boolean): Unit
```

`doUnpersist` [removes the persisted state](#unpersist) (associated with the broadcast variable) on executors only.

`doUnpersist` is part of the [Broadcast](Broadcast.md#doUnpersist) abstraction.

## <span id="unpersist"> Removing Persisted State (Broadcast Blocks) of Broadcast Variable

```scala
unpersist(
  id: Long,
  removeFromDriver: Boolean,
  blocking: Boolean): Unit
```

`unpersist` prints out the following DEBUG message to the logs:

```text
Unpersisting TorrentBroadcast [id]
```

In the end, `unpersist` requests the [BlockManagerMaster](../storage/BlockManagerMaster.md) to [remove the blocks of the given broadcast](../storage/BlockManagerMaster.md#removeBroadcast).

`unpersist` is used when:

* `TorrentBroadcast` is requested to [unpersist](#doUnpersist) and [destroy](#doDestroy)
* `TorrentBroadcastFactory` is requested to [unbroadcast](TorrentBroadcastFactory.md#unbroadcast)

## <span id="setConf"> setConf

```scala
setConf(
  conf: SparkConf): Unit
```

`setConf` uses the given [SparkConf](../SparkConf.md) to initialize the [compressionCodec](#compressionCodec), the [blockSize](#blockSize) and the [checksumEnabled](#checksumEnabled).

`setConf` is used when:

* `TorrentBroadcast` is [created](#creating-instance) and [re-created](#readBroadcastBlock) (when deserialized on executors)

## Logging

Enable `ALL` logging level for `org.apache.spark.broadcast.TorrentBroadcast` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.broadcast.TorrentBroadcast=ALL
```

Refer to [Logging](../spark-logging.md).
