= MemoryStore

*MemoryStore* manages blocks of data in memory for storage:BlockManager.md#memoryStore[BlockManager].

.MemoryStore and BlockManager
image::MemoryStore-BlockManager.png[align="center"]

== [[creating-instance]] Creating Instance

MemoryStore takes the following to be created:

* [[conf]] ROOT:SparkConf.md[]
* <<blockInfoManager, BlockInfoManager>>
* [[serializerManager]] serializer:SerializerManager.md[]
* [[memoryManager]] memory:MemoryManager.md[]
* [[blockEvictionHandler]] storage:BlockEvictionHandler.md[]

MemoryStore is created for storage:BlockManager.md#memoryStore[BlockManager].

.Creating MemoryStore
image::spark-MemoryStore.png[align="center"]

== [[blockInfoManager]] BlockInfoManager

MemoryStore is given a storage:BlockInfoManager.md[] when <<creating-instance, created>>.

MemoryStore uses the BlockInfoManager when requested to <<evictBlocksToFreeSpace, evictBlocksToFreeSpace>>.

== [[memoryStore]] Accessing MemoryStore

MemoryStore is available using storage:BlockManager.md#memoryStore[BlockManager.memoryStore] reference to other Spark services.

[source,scala]
----
import org.apache.spark.SparkEnv
SparkEnv.get.blockManager.memoryStore
----

== [[unrollMemoryThreshold]][[spark.storage.unrollMemoryThreshold]] spark.storage.unrollMemoryThreshold Configuration Property

MemoryStore uses ROOT:configuration-properties.md#spark.storage.unrollMemoryThreshold[spark.storage.unrollMemoryThreshold] configuration property for <<putIterator, putIterator>> and <<putIteratorAsBytes, putIteratorAsBytes>>.

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

== [[getValues]] getValues Method

[source, scala]
----
getValues(
  blockId: BlockId): Option[Iterator[_]]
----

getValues...FIXME

getValues is used when BlockManager is requested to storage:BlockManager.md#doGetLocalBytes[doGetLocalBytes], storage:BlockManager.md#getLocalValues[getLocalValues] and storage:BlockManager.md#maybeCacheDiskBytesInMemory[maybeCacheDiskBytesInMemory].

== [[getBytes]] getBytes Method

[source, scala]
----
getBytes(
  blockId: BlockId): Option[ChunkedByteBuffer]
----

getBytes...FIXME

getBytes is used when BlockManager is requested to storage:BlockManager.md#doGetLocalBytes[doGetLocalBytes], storage:BlockManager.md#getLocalValues[getLocalValues] and storage:BlockManager.md#maybeCacheDiskBytesInMemory[maybeCacheDiskBytesInMemory].

== [[putIteratorAsBytes]] putIteratorAsBytes Method

[source, scala]
----
putIteratorAsBytes[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T],
  memoryMode: MemoryMode): Either[PartiallySerializedBlock[T], Long]
----

putIteratorAsBytes...FIXME

putIteratorAsBytes is used when BlockManager is requested to storage:BlockManager.md#doPutIterator[doPutIterator].

== [[remove]] Dropping Block from Memory

[source, scala]
----
remove(
  blockId: BlockId): Boolean
----

remove removes the given storage:BlockId.md[] from the <<entries, entries>> internal registry and branches off based on whether the <<remove-block-removed, block was found and removed>> or <<remove-no-block, not>>.

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

remove is used when BlockManager is requested to storage:BlockManager.md#dropFromMemory[dropFromMemory] and storage:BlockManager.md#removeBlockInternal[removeBlockInternal].

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
`memoryMode` can be `ON_HEAP` or `OFF_HEAP` and is a property of a storage:StorageLevel.md[StorageLevel].

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

putBytes is used when BlockManager is requested to storage:BlockManager.md#doPutBytes[doPutBytes] and storage:BlockManager.md#maybeCacheDiskBytesInMemory[maybeCacheDiskBytesInMemory].

== [[evictBlocksToFreeSpace]] Evicting Blocks

[source, scala]
----
evictBlocksToFreeSpace(
  blockId: Option[BlockId],
  space: Long,
  memoryMode: MemoryMode): Long
----

evictBlocksToFreeSpace...FIXME

evictBlocksToFreeSpace is used when StorageMemoryPool is requested to memory:StorageMemoryPool.md#acquireMemory[acquireMemory] and memory:StorageMemoryPool.md#freeSpaceToShrinkPool[freeSpaceToShrinkPool].

== [[contains]] Checking Whether Block Exists In MemoryStore

[source, scala]
----
contains(
  blockId: BlockId): Boolean
----

contains is positive (`true`) when the <<entries, entries>> internal registry contains `blockId` key.

contains is used when...FIXME

== [[putIteratorAsValues]] putIteratorAsValues Method

[source, scala]
----
putIteratorAsValues[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T]): Either[PartiallyUnrolledIterator[T], Long]
----

putIteratorAsValues makes sure that the `BlockId` does not exist or throws an `IllegalArgumentException`:

```
requirement failed: Block [blockId] is already present in the MemoryStore
```

putIteratorAsValues <<reserveUnrollMemoryForThisTask, reserveUnrollMemoryForThisTask>> (with the <<unrollMemoryThreshold, initial memory threshold>> and `ON_HEAP` memory mode).

CAUTION: FIXME

putIteratorAsValues tries to put the `blockId` block in memory store as `values`.

putIteratorAsValues is used when BlockManager is requested to store storage:BlockManager.md#doPutBytes[bytes] or storage:BlockManager.md#doPutIterator[values] of a block or when storage:BlockManager.md#maybeCacheDiskValuesInMemory[attempting to cache spilled values read from disk].

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

== [[putIterator]] putIterator Internal Method

[source, scala]
----
putIterator[T](
  blockId: BlockId,
  values: Iterator[T],
  classTag: ClassTag[T],
  memoryMode: MemoryMode,
  valuesHolder: ValuesHolder[T]): Either[Long, Long]
----

putIterator...FIXME

putIterator is used when MemoryStore is requested to <<putIteratorAsValues, putIteratorAsValues>> and <<putIteratorAsBytes, putIteratorAsBytes>>.

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

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.memory.MemoryStore` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.storage.memory.MemoryStore=ALL
----

Refer to ROOT:spark-logging.md[Logging].

== [[internal-registries]] Internal Registries

=== [[entries]] MemoryEntries by BlockId

[source, scala]
----
entries: LinkedHashMap[BlockId, MemoryEntry[_]]
----

MemoryStore creates a Java {java-javadoc-url}/java/util/LinkedHashMap.html[LinkedHashMap] of `MemoryEntries` per storage:BlockId.md[] (with the initial capacity of `32` and the load factor of `0.75`) when <<creating-instance>>.

entries uses *access-order* ordering mode where the order of iteration is the order in which the entries were last accessed (from least-recently accessed to most-recently). That gives *LRU cache* behaviour when MemoryStore is requested to <<evictBlocksToFreeSpace, evict blocks>>.
