# StorageMemoryPool

`StorageMemoryPool` is a [MemoryPool](MemoryPool.md).

## Creating Instance

`StorageMemoryPool` takes the following to be created:

* <span id="lock"> Lock Object
* <span id="memoryMode"> `MemoryMode` (`ON_HEAP` or `OFF_HEAP`)

`StorageMemoryPool` is created when:

* `MemoryManager` is created (and initializes [on-heap](MemoryManager.md#onHeapStorageMemoryPool) and [off-heap](MemoryManager.md#offHeapStorageMemoryPool) storage memory pools)

## <span id="_memoryStore"><span id="memoryStore"><span id="setMemoryStore"> MemoryStore

`StorageMemoryPool` is given a [MemoryStore](../storage/MemoryStore.md) when `MemoryManager` is requested to [associate one with the on- and off-heap storage memory pools](MemoryManager.md#setMemoryStore).

`StorageMemoryPool` uses the `MemoryStore` (to [evict blocks](../storage/MemoryStore.md#evictBlocksToFreeSpace)) when requested to:

* [Acquire Memory](#acquireMemory)
* [Free Space to Shrink Pool](#freeSpaceToShrinkPool)

## <span id="memoryUsed"><span id="_memoryUsed"> Size of Memory Used

`StorageMemoryPool` keeps track of the size of the memory [acquired](#acquireMemory).

The size descreases when `StorageMemoryPool` is requested to [releaseMemory](#releaseMemory) or [releaseAllMemory](#releaseAllMemory).

`memoryUsed` is part of the [MemoryPool](MemoryPool.md#memoryUsed) abstraction.

## <span id="acquireMemory"> Acquiring Memory

```scala
acquireMemory(
  blockId: BlockId,
  numBytes: Long): Boolean
acquireMemory(
  blockId: BlockId,
  numBytesToAcquire: Long,
  numBytesToFree: Long): Boolean
```

`acquireMemory`...FIXME

`acquireMemory` is used when:

* `UnifiedMemoryManager` is requested to [acquire storage memory](UnifiedMemoryManager.md#acquireStorageMemory)

## <span id="freeSpaceToShrinkPool"> Freeing Space to Shrink Pool

```scala
freeSpaceToShrinkPool(
  spaceToFree: Long): Long
```

`freeSpaceToShrinkPool`...FIXME

`freeSpaceToShrinkPool` is used when:

* `UnifiedMemoryManager` is requested to [acquire execution memory](UnifiedMemoryManager.md#acquireExecutionMemory)
