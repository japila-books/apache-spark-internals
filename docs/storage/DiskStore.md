# DiskStore

`DiskStore` manages data blocks on disk for [BlockManager](BlockManager.md#diskStore).

![DiskStore and BlockManager](../images/storage/DiskStore-BlockManager.png)

## Creating Instance

`DiskStore` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="diskManager"> [DiskBlockManager](DiskBlockManager.md)
* <span id="securityManager"> `SecurityManager`

`DiskStore` is created for [BlockManager](BlockManager.md#diskStore).

## <span id="blockSizes"> Block Sizes

```scala
blockSizes: ConcurrentHashMap[BlockId, Long]
```

`DiskStore` uses `ConcurrentHashMap` ([Java]({{ java.api }}/java.base/java/util/concurrent/ConcurrentHashMap.html)) as a registry of [block](BlockId)s and the data size (on disk).

A new entry is added when [put](#put) and [moveFileToBlock](#moveFileToBlock).

An entry is removed when [remove](#remove).

## <span id="putBytes"> putBytes

```scala
putBytes(
  blockId: BlockId,
  bytes: ChunkedByteBuffer): Unit
```

`putBytes` [put](#put) the block and writes the buffer out (to the given channel).

`putBytes` is used when:

* `ByteBufferBlockStoreUpdater` is requested to [saveToDiskStore](ByteBufferBlockStoreUpdater.md#saveToDiskStore)
* `BlockManager` is requested to [dropFromMemory](BlockManager.md#dropFromMemory)

## <span id="getBytes"> getBytes

```scala
getBytes(
  blockId: BlockId): BlockData
getBytes(
  f: File,
  blockSize: Long): BlockData
```

`getBytes` requests the [DiskBlockManager](#diskManager) for the [block file](DiskBlockManager.md#getFile) and the [size](#getSize).

`getBytes` requests the [SecurityManager](#securityManager) for `getIOEncryptionKey` and returns a `EncryptedBlockData` if available or a `DiskBlockData` otherwise.

`getBytes` is used when:

* `TempFileBasedBlockStoreUpdater` is requested to [blockData](TempFileBasedBlockStoreUpdater.md#blockData)
* `BlockManager` is requested to [getLocalValues](BlockManager.md#getLocalValues), [doGetLocalBytes](BlockManager.md#doGetLocalBytes)

## <span id="getSize"> getSize

```scala
getSize(
  blockId: BlockId): Long
```

`getSize` looks up the block in the [blockSizes](#blockSizes) registry.

`getSize` is used when:

* `BlockManager` is requested to [getStatus](BlockManager.md#getStatus), [getCurrentBlockStatus](BlockManager.md#getCurrentBlockStatus), [doPutIterator](BlockManager.md#doPutIterator)
* `DiskStore` is requested for the [block bytes](#getBytes)

## <span id="moveFileToBlock"> moveFileToBlock

```scala
moveFileToBlock(
  sourceFile: File,
  blockSize: Long,
  targetBlockId: BlockId): Unit
```

`moveFileToBlock`...FIXME

`moveFileToBlock` is used when:

* `TempFileBasedBlockStoreUpdater` is requested to [saveToDiskStore](TempFileBasedBlockStoreUpdater.md#saveToDiskStore)

## <span id="contains"> Checking if Block File Exists

```scala
contains(
  blockId: BlockId): Boolean
```

`contains` requests the [DiskBlockManager](#diskManager) for the [block file](DiskBlockManager.md#getFile) and checks whether the file actually exists or not.

`contains` is used when:

* `BlockManager` is requested to [getStatus](BlockManager.md#getStatus), [getCurrentBlockStatus](BlockManager.md#getCurrentBlockStatus), [getLocalValues](BlockManager.md#getLocalValues), [doGetLocalBytes](BlockManager.md#doGetLocalBytes), [dropFromMemory](BlockManager.md#dropFromMemory)
* `DiskStore` is requested to [put](#put)

## <span id="put"> Persisting Block to Disk

```scala
put(
  blockId: BlockId)(
  writeFunc: WritableByteChannel => Unit): Unit
```

`put` prints out the following DEBUG message to the logs:

```text
Attempting to put block [blockId]
```

`put` requests the [DiskBlockManager](#diskManager) for the [block file](DiskBlockManager.md#getFile) for the input [block](BlockId.md).

`put` [opens the block file for writing](#openForWrite) (wrapped into a `CountingWritableChannel` to count the bytes written). `put` executes the given `writeFunc` function (with the `WritableByteChannel` of the block file) and saves the bytes written (to the [blockSizes](#blockSizes) registry).

In the end, `put` prints out the following DEBUG message to the logs:

```text
Block [fileName] stored as [size] file on disk in [time] ms
```

In case of any exception, `put` [deletes the block file](#remove).

`put` throws an `IllegalStateException` when the [block is already stored](#contains):

```text
Block [blockId] is already present in the disk store
```

`put` is used when:

* `BlockManager` is requested to [doPutIterator](BlockManager.md#doPutIterator) and [dropFromMemory](BlockManager.md#dropFromMemory)
* `DiskStore` is requested to [putBytes](#putBytes)

## <span id="remove"> Removing Block

```scala
remove(
  blockId: BlockId): Boolean
```

`remove`...FIXME

`remove` is used when:

* `BlockManager` is requested to [removeBlockInternal](BlockManager.md#removeBlockInternal)
* `DiskStore` is requested to [put](#put) (and an `IOException` is thrown)

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.DiskStore` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.DiskStore=ALL
```

Refer to [Logging](../spark-logging.md).
