# MemoryStore

`MemoryStore` manages blocks of data in memory for [BlockManager](BlockManager.md#memoryStore).

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

## <span id="entries"><span id="MemoryEntry"> Blocks

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

* `StorageMemoryPool` is requested to [acquireMemory](../memory/StorageMemoryPool.md#acquireMemory) and [freeSpaceToShrinkPool](../memory/StorageMemoryPool.md#freeSpaceToShrinkPool)

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

## <span id="getValues"> Deserialized Block Values

```scala
getValues(
  blockId: BlockId): Option[Iterator[_]]
```

`getValues` returns the values of the [DeserializedMemoryEntry](#DeserializedMemoryEntry) of a block (if found in the [entries](#entries) registry).

`getValues` is used (for blocks with a [deserialized and in-memory storage level](StorageLevel.md)) when:

* `BlockManager` is requested for the [serialized bytes of a block (from a local block manager)](BlockManager.md#doGetLocalBytes), [getLocalValues](BlockManager.md#getLocalValues), [maybeCacheDiskBytesInMemory](BlockManager.md#maybeCacheDiskBytesInMemory)

## <span id="putIteratorAsValues"> putIteratorAsValues

```scala
putIteratorAsValues[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T]): Either[PartiallyUnrolledIterator[T], Long]
```

`putIteratorAsValues`...FIXME

`putIteratorAsValues` is used when:

* `BlockStoreUpdater` is requested to [saveDeserializedValuesToMemoryStore](BlockStoreUpdater.md#saveDeserializedValuesToMemoryStore)
* `BlockManager` is requested to [doPutIterator](BlockManager.md#doPutIterator) and [maybeCacheDiskValuesInMemory](BlockManager.md#maybeCacheDiskValuesInMemory)

## <span id="putIteratorAsBytes"> putIteratorAsBytes

```scala
putIteratorAsBytes[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T],
  memoryMode: MemoryMode): Either[PartiallySerializedBlock[T], Long]
```

`putIteratorAsBytes`...FIXME

`putIteratorAsBytes` is used when:

* `BlockManager` is requested to [doPutIterator](BlockManager.md#doPutIterator)

## <span id="putIterator"> putIterator

```scala
putIterator[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T],
  memoryMode: MemoryMode,
  valuesHolder: ValuesHolder[T]): Either[Long, Long]
```

`putIterator`...FIXME

`putIterator` is used when:

* `MemoryStore` is requested to [putIteratorAsValues](#putIteratorAsValues) and [putIteratorAsBytes](#putIteratorAsBytes)

## <span id="putBytes"> putBytes

```scala
putBytes[T: ClassTag](
  blockId: BlockId,
  size: Long,
  memoryMode: MemoryMode,
  _bytes: () => ChunkedByteBuffer): Boolean
```

`putBytes`...FIXME

`putBytes` is used when:

* `BlockStoreUpdater` is requested to [saveSerializedValuesToMemoryStore](BlockStoreUpdater.md#saveSerializedValuesToMemoryStore)
* `BlockManager` is requested to [maybeCacheDiskBytesInMemory](BlockManager.md#maybeCacheDiskBytesInMemory)

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.memory.MemoryStore` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.memory.MemoryStore=ALL
```

Refer to [Logging](../spark-logging.md).

## Review Me

== [[unrollMemoryThreshold]][[spark.storage.unrollMemoryThreshold]] spark.storage.unrollMemoryThreshold Configuration Property

MemoryStore uses configuration-properties.md#spark.storage.unrollMemoryThreshold[spark.storage.unrollMemoryThreshold] configuration property for <<putIterator, putIterator>> and <<putIteratorAsBytes, putIteratorAsBytes>>.

== [[releaseUnrollMemoryForThisTask]] releaseUnrollMemoryForThisTask Method

[source, scala]
----
releaseUnrollMemoryForThisTask(
  memoryMode: MemoryMode,
  memory: Long = Long.MaxValue): Unit
----

releaseUnrollMemoryForThisTask...FIXME

releaseUnrollMemoryForThisTask is used when:

* Task is requested to scheduler:Task.md#run[run] (and cleans up after itself)

* MemoryStore is requested to <<putIterator, putIterator>>

* PartiallyUnrolledIterator is requested to releaseUnrollMemory

* PartiallySerializedBlock is requested to discard and finishWritingToStream

== [[remove]] Dropping Block from Memory

[source, scala]
----
remove(
  blockId: BlockId): Boolean
----

remove removes the given BlockId.md[] from the <<entries, entries>> internal registry and branches off based on whether the <<remove-block-removed, block was found and removed>> or <<remove-no-block, not>>.

=== [[remove-block-removed]] Block Removed

When found and removed, remove requests the <<memoryManager, MemoryManager>> to memory:MemoryManager.md#releaseStorageMemory[releaseStorageMemory] and prints out the following DEBUG message to the logs:

[source,plaintext]
----
Block [blockId] of size [size] dropped from memory (free [memory])
----

remove returns `true`.

=== [[remove-no-block]] No Block Removed

If no BlockId was registered and removed, remove returns `false`.

=== [[remove-usage]] Usage

remove is used when BlockManager is requested to BlockManager.md#dropFromMemory[dropFromMemory] and BlockManager.md#removeBlockInternal[removeBlockInternal].

== [[putBytes]] Acquiring Storage Memory for Blocks

[source, scala]
----
putBytes[T: ClassTag](
  blockId: BlockId,
  size: Long,
  memoryMode: MemoryMode,
  _bytes: () => ChunkedByteBuffer): Boolean
----

putBytes requests memory:MemoryManager.md#acquireStorageMemory[storage memory  for `blockId` from `MemoryManager`] and registers the block in <<entries, entries>> internal registry.

Internally, putBytes first makes sure that `blockId` block has not been registered already in <<entries, entries>> internal registry.

putBytes then requests memory:MemoryManager.md#acquireStorageMemory[`size` memory for the `blockId` block in a given `memoryMode` from the current `MemoryManager`].

[NOTE]
====
`memoryMode` can be `ON_HEAP` or `OFF_HEAP` and is a property of a StorageLevel.md[StorageLevel].

```
import org.apache.spark.storage.StorageLevel._
scala> MEMORY_AND_DISK.useOffHeap
res0: Boolean = false

scala> OFF_HEAP.useOffHeap
res1: Boolean = true
```
====

If successful, putBytes "materializes" `_bytes` byte buffer and makes sure that the size is exactly `size`. It then registers a `SerializedMemoryEntry` (for the bytes and `memoryMode`) for `blockId` in the internal <<entries, entries>> registry.

You should see the following INFO message in the logs:

```
Block [blockId] stored as bytes in memory (estimated size [size], free [bytes])
```

putBytes returns `true` only after `blockId` was successfully registered in the internal <<entries, entries>> registry.

putBytes is used when BlockManager is requested to BlockManager.md#doPutBytes[doPutBytes] and BlockManager.md#maybeCacheDiskBytesInMemory[maybeCacheDiskBytesInMemory].

== [[contains]] Checking Whether Block Exists In MemoryStore

[source, scala]
----
contains(
  blockId: BlockId): Boolean
----

contains is positive (`true`) when the <<entries, entries>> internal registry contains `blockId` key.

contains is used when...FIXME

== [[reserveUnrollMemoryForThisTask]] `reserveUnrollMemoryForThisTask` Method

[source, scala]
----
reserveUnrollMemoryForThisTask(
  blockId: BlockId,
  memory: Long,
  memoryMode: MemoryMode): Boolean
----

`reserveUnrollMemoryForThisTask` acquires a lock on <<memoryManager, MemoryManager>> and requests it to memory:MemoryManager.md#acquireUnrollMemory[acquireUnrollMemory].

NOTE: `reserveUnrollMemoryForThisTask` is used when MemoryStore is requested to <<putIteratorAsValues, putIteratorAsValues>> and <<putIteratorAsBytes, putIteratorAsBytes>>.

== [[maxMemory]] Total Amount Of Memory Available For Storage

[source, scala]
----
maxMemory: Long
----

`maxMemory` requests the <<memoryManager, MemoryManager>> for the current memory:MemoryManager.md#maxOnHeapStorageMemory[maxOnHeapStorageMemory] and memory:MemoryManager.md#maxOffHeapStorageMemory[maxOffHeapStorageMemory], and simply returns their sum.

[TIP]
====
Enable INFO <<logging, logging>> to find the `maxMemory` in the logs when MemoryStore is <<creating-instance, created>>:

```
MemoryStore started with capacity [maxMemory] MB
```
====

NOTE: `maxMemory` is used for <<logging, logging>> purposes only.

== [[logUnrollFailureMessage]] logUnrollFailureMessage Internal Method

[source, scala]
----
logUnrollFailureMessage(
  blockId: BlockId,
  finalVectorSize: Long): Unit
----

logUnrollFailureMessage...FIXME

logUnrollFailureMessage is used when MemoryStore is requested to <<putIterator, putIterator>>.

== [[logMemoryUsage]] logMemoryUsage Internal Method

[source, scala]
----
logMemoryUsage(): Unit
----

logMemoryUsage...FIXME

logMemoryUsage is used when MemoryStore is requested to <<logUnrollFailureMessage, logUnrollFailureMessage>>.

== [[memoryUsed]] Total Memory Used

[source, scala]
----
memoryUsed: Long
----

memoryUsed requests the <<memoryManager, MemoryManager>> for the memory:MemoryManager.md#storageMemoryUsed[storageMemoryUsed].

memoryUsed is used when MemoryStore is requested for <<blocksMemoryUsed, blocksMemoryUsed>> and to <<logMemoryUsage, logMemoryUsage>>.

== [[blocksMemoryUsed]] Memory Used for Caching Blocks

[source, scala]
----
blocksMemoryUsed: Long
----

blocksMemoryUsed is the <<memoryUsed, total memory used>> without the <<currentUnrollMemory, current memory used for unrolling>>.

blocksMemoryUsed is used for logging purposes when MemoryStore is requested to <<putBytes, putBytes>>, <<putIterator, putIterator>>, <<remove, remove>>, <<evictBlocksToFreeSpace, evictBlocksToFreeSpace>> and <<logMemoryUsage, logMemoryUsage>>.
