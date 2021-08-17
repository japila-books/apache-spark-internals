# ByteBufferBlockStoreUpdater

`ByteBufferBlockStoreUpdater` is a [BlockStoreUpdater](BlockStoreUpdater.md) (that [BlockManager](BlockManager.md) uses for storing a block from bytes already in [memory](#bytes)).

## Creating Instance

`ByteBufferBlockStoreUpdater` takes the following to be created:

* <span id="blockId"> [BlockId](BlockId.md)
* <span id="level"> [StorageLevel](StorageLevel.md)
* <span id="classTag"> `ClassTag` ([Scala]({{ scala.api }}/scala/reflect/ClassTag.html))
* <span id="bytes"> `ChunkedByteBuffer`
* <span id="tellMaster"> `tellMaster` flag (default: `true`)
* <span id="keepReadLock"> `keepReadLock` flag (default: `false`)

`ByteBufferBlockStoreUpdater` is created when:

* `BlockManager` is requested to [store a block (bytes) locally](BlockManager.md#putBytes)

## <span id="blockData"> Block Data

```scala
blockData(): BlockData
```

`blockData` creates a `ByteBufferBlockData` (with the [ChunkedByteBuffer](#bytes)).

`blockData` is part of the [BlockStoreUpdater](BlockStoreUpdater.md#blockData) abstraction.

## <span id="readToByteBuffer"> readToByteBuffer

```scala
readToByteBuffer(): ChunkedByteBuffer
```

`readToByteBuffer` simply gives the [ChunkedByteBuffer](#bytes) (it was created with).

`readToByteBuffer` is part of the [BlockStoreUpdater](BlockStoreUpdater.md#readToByteBuffer) abstraction.

## <span id="saveToDiskStore"> Storing Block to Disk

```scala
saveToDiskStore(): Unit
```

`saveToDiskStore` requests the [DiskStore](BlockManager.md#diskStore) (of the parent [BlockManager](BlockManager.md)) to [putBytes](DiskStore.md#putBytes) (with the [BlockId](#blockId) and the [ChunkedByteBuffer](#bytes)).

`saveToDiskStore` is part of the [BlockStoreUpdater](BlockStoreUpdater.md#saveToDiskStore) abstraction.
