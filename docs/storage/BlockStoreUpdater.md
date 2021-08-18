# BlockStoreUpdater

`BlockStoreUpdater` is an [abstraction](#contract) of [block store updaters](#implementations) that [store blocks](#save) (from bytes, whether they start in memory or on disk).

`BlockStoreUpdater` is an internal class of [BlockManager](BlockManager.md).

## Contract

### <span id="blockData"> Block Data

```scala
blockData(): BlockData
```

[BlockData](BlockData.md)

Used when:

* `BlockStoreUpdater` is requested to [save](#save)
* `TempFileBasedBlockStoreUpdater` is requested to [readToByteBuffer](TempFileBasedBlockStoreUpdater.md#readToByteBuffer)

### <span id="readToByteBuffer"> readToByteBuffer

```scala
readToByteBuffer(): ChunkedByteBuffer
```

Used when:

* `BlockStoreUpdater` is requested to [save](#save)

### <span id="saveToDiskStore"> Storing Block to Disk

```scala
saveToDiskStore(): Unit
```

Used when:

* `BlockStoreUpdater` is requested to [save](#save)

## Implementations

* [ByteBufferBlockStoreUpdater](ByteBufferBlockStoreUpdater.md)
* [TempFileBasedBlockStoreUpdater](TempFileBasedBlockStoreUpdater.md)

## Creating Instance

`BlockStoreUpdater` takes the following to be created:

* <span id="blockSize"> Block Size
* <span id="blockId"> [BlockId](BlockId.md)
* <span id="level"> [StorageLevel](StorageLevel.md)
* <span id="classTag"> Scala's `ClassTag`
* <span id="tellMaster"> `tellMaster` flag
* <span id="keepReadLock"> `keepReadLock` flag

??? note "Abstract Class"
    `BlockStoreUpdater` is an abstract class and cannot be created directly. It is created indirectly for the [concrete BlockStoreUpdaters](#implementations).

## <span id="save"> Saving Block to Block Store

```scala
save(): Boolean
```

`save` [doPut](BlockManager.md#doPut) with the [putBody](#save-putBody) function.

`save` is used when:

* `BlockManager` is requested to [putBlockDataAsStream](BlockManager.md#putBlockDataAsStream) and [store block bytes locally](BlockManager.md#putBytes)

### <span id="save-putBody"> putBody Function

With the [StorageLevel](#level) with [replication](StorageLevel.md#replication) (above `1`), the `putBody` function triggers [replication](BlockManager.md#replicate) concurrently (using a `Future` ([Scala]({{ scala.api }}/scala/concurrent/Future.html)) on a separate thread from the [ExecutionContextExecutorService](BlockManager.md#futureExecutionContext)).

In general, `putBody` stores the block in the [MemoryStore](BlockManager.md#memoryStore) first (if requested based on [useMemory](StorageLevel.md#useMemory) of the [StorageLevel](#level)). `putBody` [saves to a DiskStore](#saveToDiskStore) (if [useMemory](StorageLevel.md#useMemory) is not specified or storing to the `MemoryStore` failed).

!!! note
    `putBody` stores the block in the `MemoryStore` only even if the [useMemory](StorageLevel.md#useMemory) and [useDisk](StorageLevel.md#useDisk) flags could both be turned on (`true`).

    Spark drops the block to disk later if the memory store can't hold it.

With the [useMemory](StorageLevel.md#useMemory) of the [StorageLevel](#level) set, `putBody` [saveDeserializedValuesToMemoryStore](#saveDeserializedValuesToMemoryStore) for [deserialized](StorageLevel.md#deserialized) storage level or [saveSerializedValuesToMemoryStore](#saveSerializedValuesToMemoryStore) otherwise.

`putBody` [saves to a DiskStore](#saveToDiskStore) when either of the following happens:

1. Storing in memory fails and the [useDisk](StorageLevel.md#useDisk) (of the [StorageLevel](#level)) is set
1. [useMemory](StorageLevel.md#useMemory) of the [StorageLevel](#level) is not set yet the [useDisk](StorageLevel.md#useDisk) is

`putBody` [getCurrentBlockStatus](BlockManager.md#getCurrentBlockStatus) and [checks if it is in either the memory or disk store](StorageLevel.md#isValid).

In the end, `putBody` [reportBlockStatus](BlockManager.md#reportBlockStatus) (if the given [tellMaster](#tellMaster) flag and the [tellMaster](#tellMaster) flag of the `BlockInfo` are both enabled) and [addUpdatedBlockStatusToTaskMetrics](BlockManager.md#addUpdatedBlockStatusToTaskMetrics).

`putBody` prints out the following DEBUG message to the logs:

```text
Put block [blockId] locally took [timeUsed] ms
```

---

`putBody` prints out the following WARN message to the logs when an attempt to store a block in memory fails and the [useDisk](StorageLevel.md#useDisk) is set:

```text
Persisting block [blockId] to disk instead.
```

## <span id="saveDeserializedValuesToMemoryStore"> Saving Deserialized Values to MemoryStore

```scala
saveDeserializedValuesToMemoryStore(
  inputStream: InputStream): Boolean
```

`saveDeserializedValuesToMemoryStore`...FIXME

`saveDeserializedValuesToMemoryStore` is used when:

* `BlockStoreUpdater` is requested to [save a block](#save) (with [memory deserialized storage level](StorageLevel.md))

## <span id="saveSerializedValuesToMemoryStore"> Saving Serialized Values to MemoryStore

```scala
saveSerializedValuesToMemoryStore(
  bytes: ChunkedByteBuffer): Boolean
```

`saveSerializedValuesToMemoryStore`...FIXME

`saveSerializedValuesToMemoryStore` is used when:

* `BlockStoreUpdater` is requested to [save a block](#save) (with [memory serialized storage level](StorageLevel.md))

## Logging

`BlockStoreUpdater` is an abstract class and logging is configured using the logger of the [implementations](#implementations).
