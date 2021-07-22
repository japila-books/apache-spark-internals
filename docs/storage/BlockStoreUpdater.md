# BlockStoreUpdater

`BlockStoreUpdater` is an [abstraction](#contract) of [block store updaters](#implementations) that [store blocks](#save) (from bytes, whether they start in memory or on disk).

`BlockStoreUpdater` is an internal class of [BlockManager](BlockManager.md).

## Contract

### <span id="blockData"> blockData

```scala
blockData(): BlockData
```

[BlockData](BlockData.md)

Used when:

* `BlockStoreUpdater` is requested to [save](#save)
* `TempFileBasedBlockStoreUpdater` is requested to `readToByteBuffer`

### <span id="readToByteBuffer"> readToByteBuffer

```scala
readToByteBuffer(): ChunkedByteBuffer
```

Used when:

* `BlockStoreUpdater` is requested to [save](#save)

### <span id="saveToDiskStore"> saveToDiskStore

```scala
saveToDiskStore(): Unit
```

Used when:

* `BlockStoreUpdater` is requested to [save](#save)

## Implementations

* `ByteBufferBlockStoreUpdater`
* `TempFileBasedBlockStoreUpdater`

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

## <span id="save"> Storing Block Data

```scala
save(): Boolean
```

`save`...FIXME

`save` is used when:

* `BlockManager` is requested to [putBlockDataAsStream](BlockManager.md#putBlockDataAsStream) and [putBytes](BlockManager.md#putBytes)
