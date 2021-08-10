# StorageMemoryPool

`StorageMemoryPool` is a [MemoryPool](MemoryPool.md).

## Creating Instance

`StorageMemoryPool` takes the following to be created:

* <span id="lock"> Lock Object
* <span id="memoryMode"> `MemoryMode` (`ON_HEAP` or `OFF_HEAP`)

`StorageMemoryPool` is created when:

* `MemoryManager` is created (and initializes [on-heap](MemoryManager.md#onHeapStorageMemoryPool) and [off-heap](MemoryManager.md#offHeapStorageMemoryPool) storage memory pools)

## <span id="_memoryStore"><span id="memoryStore"><span id="setMemoryStore"> MemoryStore

`StorageMemoryPool` is given a [MemoryStore](../storage/MemoryStore.md) when `MemoryManager` is requested to [associate one with storage memory pools](MemoryManager.md#setMemoryStore).

`MemoryStore` is used when `StorageMemoryPool` is requested to:

* [Acquire Memory](#acquireMemory)
* [Free Space to Shrink Pool](#freeSpaceToShrinkPool)

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

## <span id="freeSpaceToShrinkPool"> freeSpaceToShrinkPool

```scala
freeSpaceToShrinkPool(
  spaceToFree: Long): Long
```

`freeSpaceToShrinkPool`...FIXME

`freeSpaceToShrinkPool` is used when:

* `UnifiedMemoryManager` is requested to [acquire execution memory](UnifiedMemoryManager.md#acquireExecutionMemory)
