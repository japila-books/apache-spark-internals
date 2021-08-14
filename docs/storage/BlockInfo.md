# BlockInfo

`BlockInfo` is a metadata of [data block](BlockId.md)s (stored in [MemoryStore](MemoryStore.md) or [DiskStore](DiskStore.md)).

## Creating Instance

`BlockInfo` takes the following to be created:

* <span id="level"> [StorageLevel](StorageLevel.md)
* <span id="classTag"> `ClassTag` ([Scala]({{ scala.api }}/scala/reflect/ClassTag.html))
* <span id="tellMaster"> `tellMaster` flag

`BlockInfo` is created when:

* `BlockManager` is requested to [doPut](BlockManager.md#doPut)

## <span id="size"><span id="_size"> Block Size

`BlockInfo` knows the size of the block (in bytes).

The size is `0` by default and changes when:

* `BlockStoreUpdater` is requested to [save](BlockStoreUpdater.md#save)
* `BlockManager` is requested to [doPutIterator](BlockManager.md#doPutIterator)

## <span id="readerCount"> Reader Count

`readerCount` is the number of times that this block has been locked for reading

`readerCount` is `0` by default.

`readerCount` changes back to `0` when:

* `BlockInfoManager` is requested to [remove a block](BlockInfoManager.md#removeBlock) and [clear](BlockInfoManager.md#clear)

`readerCount` is incremented when a [read lock is acquired](BlockInfoManager.md#lockForReading) and decreases when the following happens:

* `BlockInfoManager` is requested to [release a lock](BlockInfoManager.md#unlock) and [releaseAllLocksForTask](BlockInfoManager.md#releaseAllLocksForTask)

## <span id="writerTask"><span id="NO_WRITER"> Writer Task

`writerTask` attribute is the task ID that owns the [write lock for the block](BlockInfoManager.md#lockForWriting) or the following:

* <span id="NO_WRITER"> `-1` for no writers and hence no write lock in use
* <span id="NON_TASK_WRITER"> `-1024` for non-task threads (by a driver thread or by unit test code)

`writerTask` is assigned a task ID when:

* `BlockInfoManager` is requested to [lockForWriting](BlockInfoManager.md#lockForWriting), [unlock](#unlock), [releaseAllLocksForTask](#releaseAllLocksForTask), [removeBlock](#removeBlock), [clear](#clear)
