# TempFileBasedBlockStoreUpdater

`TempFileBasedBlockStoreUpdater` is a [BlockStoreUpdater](BlockStoreUpdater.md) (that [BlockManager](BlockManager.md) uses for storing a block from bytes in a [local temporary file](#tmpFile)).

## Creating Instance

`TempFileBasedBlockStoreUpdater` takes the following to be created:

* <span id="blockId"> [BlockId](BlockId.md)
* <span id="level"> [StorageLevel](StorageLevel.md)
* <span id="classTag"> `ClassTag` ([Scala]({{ scala.api }}/scala/reflect/ClassTag.html))
* <span id="tmpFile"> Temporary File
* <span id="blockSize"> Block Size
* <span id="tellMaster"> `tellMaster` flag (default: `true`)
* <span id="keepReadLock"> `keepReadLock` flag (default: `false`)

`TempFileBasedBlockStoreUpdater` is created when:

* `BlockManager` is requested to [putBlockDataAsStream](BlockManager.md#putBlockDataAsStream)
* `PythonBroadcast` is requested to `readObject`

## <span id="blockData"> Block Data

```scala
blockData(): BlockData
```

`blockData` requests the [DiskStore](BlockManager.md#diskStore) (of the parent [BlockManager](BlockManager.md)) to [getBytes](DiskStore.md#getBytes) (with the [temp file](#tmpFile) and the [block size](#blockSize)).

`blockData` is part of the [BlockStoreUpdater](BlockStoreUpdater.md#blockData) abstraction.

## <span id="saveToDiskStore"> Storing Block to Disk

```scala
saveToDiskStore(): Unit
```

`saveToDiskStore` requests the [DiskStore](BlockManager.md#diskStore) (of the parent [BlockManager](BlockManager.md)) to [moveFileToBlock](DiskStore.md#moveFileToBlock).

`saveToDiskStore` is part of the [BlockStoreUpdater](BlockStoreUpdater.md#saveToDiskStore) abstraction.
