# BlockEvictionHandler

`BlockEvictionHandler` is an [abstraction](#contract) of [block eviction handlers](#implementations) that can [drop blocks from memory](#dropFromMemory).

## Contract

### <span id="dropFromMemory"> Dropping Block from Memory

```scala
dropFromMemory[T: ClassTag](
  blockId: BlockId,
  data: () => Either[Array[T], ChunkedByteBuffer]): StorageLevel
```

Used when:

* `MemoryStore` is requested to [evict blocks](MemoryStore.md#evictBlocksToFreeSpace)

## Implementations

* [BlockManager](BlockManager.md)
