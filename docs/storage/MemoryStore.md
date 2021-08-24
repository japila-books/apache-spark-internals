# MemoryStore

`MemoryStore` manages [blocks of data](#entries) in memory for [BlockManager](BlockManager.md#memoryStore).

![MemoryStore and BlockManager](../images/storage/MemoryStore-BlockManager.png)

## Creating Instance

`MemoryStore` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* [BlockInfoManager](#blockInfoManager)
* <span id="serializerManager"> [SerializerManager](../serializer/SerializerManager.md)
* <span id="memoryManager"> [MemoryManager](../memory/MemoryManager.md)
* <span id="blockEvictionHandler"> [BlockEvictionHandler](BlockEvictionHandler.md)

`MemoryStore` is created when:

* `BlockManager` is [created](BlockManager.md#memoryStore)

![Creating MemoryStore](../images/storage/spark-MemoryStore.png)

## <span id="entries"><span id="MemoryEntry"><span id="contains"> Blocks

```scala
entries: LinkedHashMap[BlockId, MemoryEntry[_]]
```

`MemoryStore` creates a `LinkedHashMap` ([Java]({{ java.api }}/java.base/java/util/LinkedHashMap.html)) of blocks (as `MemoryEntries` per [BlockId](BlockId.md)) when [created](#creating-instance).

`entries` uses **access-order** ordering mode where the order of iteration is the order in which the entries were last accessed (from least-recently accessed to most-recently). That gives **LRU cache** behaviour when `MemoryStore` is requested to [evict blocks](#evictBlocksToFreeSpace).

`MemoryEntries` are added in [putBytes](#putBytes) and [putIterator](#putIterator).

`MemoryEntries` are removed in [remove](#remove), [clear](#clear), and while [evicting blocks to free up memory](#evictBlocksToFreeSpace).

### <span id="DeserializedMemoryEntry"> DeserializedMemoryEntry

`DeserializedMemoryEntry` is a `MemoryEntry` for block values with the following:

* `Array[T]` (for the values)
* `size`
* `ON_HEAP` memory mode

### <span id="SerializedMemoryEntry"> SerializedMemoryEntry

`SerializedMemoryEntry` is a `MemoryEntry` for block bytes with the following:

* `ChunkedByteBuffer` (for the serialized values)
* `size`
* `MemoryMode`

## <span id="unrollMemoryThreshold"> spark.storage.unrollMemoryThreshold

`MemoryStore` uses [spark.storage.unrollMemoryThreshold](../configuration-properties.md#spark.storage.unrollMemoryThreshold) configuration property when requested for the following:

* [putIterator](#putIterator)
* [putIteratorAsBytes](#putIteratorAsBytes)

## <span id="evictBlocksToFreeSpace"> Evicting Blocks

```scala
evictBlocksToFreeSpace(
  blockId: Option[BlockId],
  space: Long,
  memoryMode: MemoryMode): Long
```

`evictBlocksToFreeSpace` finds blocks to evict in the [entries](#entries) registry (based on least-recently accessed order and until the required `space` to free up is met or there are no more blocks).

Once done, `evictBlocksToFreeSpace` returns the memory freed up.

When there is enough blocks to drop to free up memory, `evictBlocksToFreeSpace` prints out the following INFO message to the logs:

```text
[n] blocks selected for dropping ([freedMemory]) bytes)
```

`evictBlocksToFreeSpace` [drops the blocks](#dropBlock) one by one.

`evictBlocksToFreeSpace` prints out the following INFO message to the logs:

```text
After dropping [n] blocks, free memory is [memory]
```

When there is not enough blocks to drop to make room for the given block (if any), `evictBlocksToFreeSpace` prints out the following INFO message to the logs:

```text
Will not store [blockId]
```

`evictBlocksToFreeSpace` is used when:

* `StorageMemoryPool` is requested to [acquire memory](../memory/StorageMemoryPool.md#acquireMemory) and [free up space to shrink pool](../memory/StorageMemoryPool.md#freeSpaceToShrinkPool)

### <span id="dropBlock"> Dropping Block

```scala
dropBlock[T](
  blockId: BlockId,
  entry: MemoryEntry[T]): Unit
```

`dropBlock` requests the [BlockEvictionHandler](#blockEvictionHandler) to [drop the block from memory](BlockEvictionHandler.md#dropFromMemory).

If the block is no longer available in any other store, `dropBlock` requests the [BlockInfoManager](#blockInfoManager) to [remove the block (info)](BlockInfoManager.md#removeBlock).

## <span id="blockInfoManager"> BlockInfoManager

`MemoryStore` is given a [BlockInfoManager](BlockInfoManager.md) when [created](#creating-instance).

`MemoryStore` uses the `BlockInfoManager` when requested to [evict blocks](#evictBlocksToFreeSpace).

## Accessing MemoryStore

`MemoryStore` is available to other Spark services using [BlockManager.memoryStore](BlockManager.md#memoryStore).

```scala
import org.apache.spark.SparkEnv
SparkEnv.get.blockManager.memoryStore
```

## <span id="getBytes"> Serialized Block Bytes

```scala
getBytes(
  blockId: BlockId): Option[ChunkedByteBuffer]
```

`getBytes` returns the bytes of the [SerializedMemoryEntry](#SerializedMemoryEntry) of a block (if found in the [entries](#entries) registry).

`getBytes` is used (for blocks with a [serialized and in-memory storage level](StorageLevel.md)) when:

* `BlockManager` is requested for the [serialized bytes of a block (from a local block manager)](BlockManager.md#doGetLocalBytes), [getLocalValues](BlockManager.md#getLocalValues), [maybeCacheDiskBytesInMemory](BlockManager.md#maybeCacheDiskBytesInMemory)

## <span id="getValues"> Fetching Deserialized Block Values

```scala
getValues(
  blockId: BlockId): Option[Iterator[_]]
```

`getValues` returns the values of the [DeserializedMemoryEntry](#DeserializedMemoryEntry) of the given block (if available in the [entries](#entries) registry).

`getValues` is used (for blocks with a [deserialized and in-memory storage level](StorageLevel.md)) when:

* `BlockManager` is requested for the [serialized bytes of a block (from a local block manager)](BlockManager.md#doGetLocalBytes), [getLocalValues](BlockManager.md#getLocalValues), [maybeCacheDiskBytesInMemory](BlockManager.md#maybeCacheDiskBytesInMemory)

## <span id="putIteratorAsBytes"> putIteratorAsBytes

```scala
putIteratorAsBytes[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T],
  memoryMode: MemoryMode): Either[PartiallySerializedBlock[T], Long]
```

`putIteratorAsBytes` requires that the [block is not already stored](#contains).

`putIteratorAsBytes` [putIterator](#putIterator) (with the given [BlockId](BlockId.md), the values, the `MemoryMode` and a new `SerializedValuesHolder`).

If successful, `putIteratorAsBytes` returns the estimated size of the block. Otherwise, a `PartiallySerializedBlock`.

---

`putIteratorAsBytes` prints out the following WARN message to the logs when the [initial memory threshold](#unrollMemoryThreshold) is too large:

```text
Initial memory threshold of [initialMemoryThreshold] is too large to be set as chunk size.
Chunk size has been capped to "MAX_ROUNDED_ARRAY_LENGTH"
```

---

`putIteratorAsBytes` is used when:

* `BlockManager` is requested to [doPutIterator](BlockManager.md#doPutIterator) (for a block with [StorageLevel](StorageLevel.md) with [useMemory](StorageLevel.md#useMemory) and [serialized](StorageLevel.md#deserialized))

## <span id="putIteratorAsValues"> putIteratorAsValues

```scala
putIteratorAsValues[T](
  blockId: BlockId,
  values: Iterator[T],
  memoryMode: MemoryMode,
  classTag: ClassTag[T]): Either[PartiallyUnrolledIterator[T], Long]
```

`putIteratorAsValues` [putIterator](#putIterator) (with the given [BlockId](BlockId.md), the values, the `MemoryMode` and a new `DeserializedValuesHolder`).

If successful, `putIteratorAsValues` returns the estimated size of the block. Otherwise, a `PartiallyUnrolledIterator`.

`putIteratorAsValues` is used when:

* `BlockStoreUpdater` is requested to [saveDeserializedValuesToMemoryStore](BlockStoreUpdater.md#saveDeserializedValuesToMemoryStore)
* `BlockManager` is requested to [doPutIterator](BlockManager.md#doPutIterator) and [maybeCacheDiskValuesInMemory](BlockManager.md#maybeCacheDiskValuesInMemory)

## <span id="putIterator"> putIterator

```scala
putIterator[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T],
  memoryMode: MemoryMode,
  valuesHolder: ValuesHolder[T]): Either[Long, Long]
```

`putIterator` returns the (estimated) size of the block (as `Right`) or the `unrollMemoryUsedByThisBlock` (as `Left`).

`putIterator` requires that the [block is not already in the MemoryStore](#contains).

`putIterator` [reserveUnrollMemoryForThisTask](#reserveUnrollMemoryForThisTask) (with the [spark.storage.unrollMemoryThreshold](../configuration-properties.md#spark.storage.unrollMemoryThreshold) for the initial memory threshold).

If `putIterator` did not manage to reserve the memory for unrolling (computing block in memory), it prints out the following WARN message to the logs:

```text
Failed to reserve initial memory threshold of [initialMemoryThreshold]
for computing block [blockId] in memory.
```

`putIterator` requests the `ValuesHolder` to `storeValue` for every value in the given `values` iterator. `putIterator` checks memory usage regularly (whether it may have exceeded the threshold) and [reserveUnrollMemoryForThisTask](#reserveUnrollMemoryForThisTask) when needed.

`putIterator` requests the `ValuesHolder` for a `MemoryEntryBuilder` (`getBuilder`) that in turn is requested to `build` a `MemoryEntry`.

`putIterator` [releaseUnrollMemoryForThisTask](#releaseUnrollMemoryForThisTask).

`putIterator` requests the [MemoryManager](#memoryManager) to [acquireStorageMemory](../memory/MemoryManager.md#acquireStorageMemory) and stores the block (in the [entries](#entries) registry).

In the end, `putIterator` prints out the following INFO message to the logs:

```text
Block [blockId] stored as values in memory (estimated size [size], free [free])
```

---

In case of `putIterator` not having enough memory to store the block, `putIterator` [logUnrollFailureMessage](#logUnrollFailureMessage) and returns the `unrollMemoryUsedByThisBlock`.

---

`putIterator` is used when:

* `MemoryStore` is requested to [putIteratorAsValues](#putIteratorAsValues) and [putIteratorAsBytes](#putIteratorAsBytes)

### <span id="logUnrollFailureMessage"> logUnrollFailureMessage

```scala
logUnrollFailureMessage(
  blockId: BlockId,
  finalVectorSize: Long): Unit
```

`logUnrollFailureMessage` prints out the following WARN message to the logs and [logMemoryUsage](#logMemoryUsage).

```text
Not enough space to cache [blockId] in memory! (computed [size] so far)
```

### <span id="logMemoryUsage"> logMemoryUsage

```scala
logMemoryUsage(): Unit
```

`logMemoryUsage` prints out the following INFO message to the logs (with the [blocksMemoryUsed](#blocksMemoryUsed), [currentUnrollMemory](#currentUnrollMemory), [numTasksUnrolling](#numTasksUnrolling), [memoryUsed](#memoryUsed), and [maxMemory](#maxMemory)):

```text
Memory use = [blocksMemoryUsed] (blocks) + [currentUnrollMemory]
(scratch space shared across [numTasksUnrolling] tasks(s)) = [memoryUsed].
Storage limit = [maxMemory].
```

## <span id="putBytes"> Storing Block

```scala
putBytes[T: ClassTag](
  blockId: BlockId,
  size: Long,
  memoryMode: MemoryMode,
  _bytes: () => ChunkedByteBuffer): Boolean
```

`putBytes` returns `true` only after there was enough memory to store the block ([BlockId](BlockId.md)) in [entries](#entries) registry.

---

`putBytes` asserts that the block is not [stored](#contains) yet.

`putBytes` requests the [MemoryManager](#memoryManager) for [memory](../memory/MemoryManager.md#acquireStorageMemory) (to store the block) and, when successful, adds the block to the [entries](#entries) registry (as a [SerializedMemoryEntry](#SerializedMemoryEntry) with the `_bytes` and the `MemoryMode`).

In the end, `putBytes` prints out the following INFO message to the logs:

```text
Block [blockId] stored as bytes in memory (estimated size [size], free [size])
```

`putBytes` is used when:

* `BlockStoreUpdater` is requested to [save serialized values (to MemoryStore)](BlockStoreUpdater.md#saveSerializedValuesToMemoryStore)
* `BlockManager` is requested to [maybeCacheDiskBytesInMemory](BlockManager.md#maybeCacheDiskBytesInMemory)

## <span id="blocksMemoryUsed"> Memory Used for Caching Blocks

```scala
blocksMemoryUsed: Long
```

`blocksMemoryUsed` is the [total memory used](#memoryUsed) without (_minus_) the [memory used for unrolling](#currentUnrollMemory).

`blocksMemoryUsed` is used for logging purposes (when `MemoryStore` is requested to [putBytes](#putBytes), [putIterator](#putIterator), [remove](#remove), [evictBlocksToFreeSpace](#evictBlocksToFreeSpace) and [logMemoryUsage](#logMemoryUsage)).

## <span id="memoryUsed"> Total Storage Memory in Use

```scala
memoryUsed: Long
```

`memoryUsed` requests the [MemoryManager](#memoryManager) for the [total storage memory](../memory/MemoryManager.md#storageMemoryUsed).

`memoryUsed` is used when:

* `MemoryStore` is requested for [blocksMemoryUsed](#blocksMemoryUsed) and to [logMemoryUsage](#logMemoryUsage)

## <span id="maxMemory"> Maximum Storage Memory

```scala
maxMemory: Long
```

`maxMemory` is the total amount of memory available for storage (in bytes) and is the sum of the [maxOnHeapStorageMemory](../memory/MemoryManager.md#maxOnHeapStorageMemory) and [maxOffHeapStorageMemory](../memory/MemoryManager.md#maxOffHeapStorageMemory) of the [MemoryManager](#memoryManager).

!!! tip
    Enable [INFO](#logging) logging for `MemoryStore` to print out the `maxMemory` to the logs when [created](#creating-instance):

    ```text
    MemoryStore started with capacity [maxMemory] MB
    ```

`maxMemory` is used when:

* `MemoryStore` is requested for the [blocksMemoryUsed](#blocksMemoryUsed) and to [logMemoryUsage](#logMemoryUsage)

## <span id="remove"> Dropping Block from Memory

```scala
remove(
  blockId: BlockId): Boolean
```

`remove` returns `true` when the given block ([BlockId](BlockId.md)) was (found and) removed from the [entries](#entries) registry successfully and the [memory released](../memory/MemoryManager.md#releaseStorageMemory) (from the [MemoryManager](#memoryManager)).

---

`remove` removes (_drops_) the block ([BlockId](BlockId.md)) from the [entries](#entries) registry.

If found and removed, `remove` requests the [MemoryManager](#memoryManager) to [releaseStorageMemory](../memory/MemoryManager.md#releaseStorageMemory) and prints out the following DEBUG message to the logs (with the [maxMemory](#maxMemory) and [blocksMemoryUsed](#blocksMemoryUsed)):

```text
Block [blockId] of size [size] dropped from memory (free [memory])
```

`remove` is used when:

* `BlockManager` is requested to [dropFromMemory](BlockManager.md#dropFromMemory) and [removeBlockInternal](BlockManager.md#removeBlockInternal)

## <span id="releaseUnrollMemoryForThisTask"> Releasing Unroll Memory for Task

```scala
releaseUnrollMemoryForThisTask(
  memoryMode: MemoryMode,
  memory: Long = Long.MaxValue): Unit
```

`releaseUnrollMemoryForThisTask` finds the task attempt ID of the current task.

`releaseUnrollMemoryForThisTask` uses the [onHeapUnrollMemoryMap](#onHeapUnrollMemoryMap) or [offHeapUnrollMemoryMap](#offHeapUnrollMemoryMap) based on the given `MemoryMode`.

(Only when the unroll memory map contains the task attempt ID) `releaseUnrollMemoryForThisTask` descreases the memory registered in the unroll memory map by the given memory amount and requests the [MemoryManager](#memoryManager) to [releaseUnrollMemory](../memory/MemoryManager.md#releaseUnrollMemory). In the end, `releaseUnrollMemoryForThisTask` removes the task attempt ID (entry) from the unroll memory map if the memory used is `0`.

`releaseUnrollMemoryForThisTask` is used when:

* `Task` is requested to [run](../scheduler/Task.md#run) (and is about to finish)
* `MemoryStore` is requested to [putIterator](#putIterator)
* `PartiallyUnrolledIterator` is requested to `releaseUnrollMemory`
* `PartiallySerializedBlock` is requested to `discard` and `finishWritingToStream`

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.memory.MemoryStore` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.memory.MemoryStore=ALL
```

Refer to [Logging](../spark-logging.md).
