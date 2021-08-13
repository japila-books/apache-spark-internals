# BlockInfoManager

`BlockInfoManager` is used by [BlockManager](BlockManager.md) (and [MemoryStore](MemoryStore.md#blockInfoManager)) to manage [metadata of memory blocks](#infos) and control concurrent access by [locks](#locks) for [reading](#lockForReading) and [writing](#lockForWriting).

`BlockInfoManager` is used to create a [MemoryStore](MemoryStore.md#blockInfoManager) and a `BlockManagerManagedBuffer`.

## Creating Instance

`BlockInfoManager` takes no arguments to be created.

`BlockInfoManager` is created for [BlockManager](BlockManager.md#blockInfoManager)

![BlockInfoManager and BlockManager](../images/storage/BlockInfoManager-BlockManager.png)

## <span id="infos"> Block Metadata

```scala
infos: HashMap[BlockId, BlockInfo]
```

`BlockInfoManager` uses a registry of [block metadata](BlockInfo.md)s per [block](BlockId.md).

## Locks

**Locks** are the mechanism to control concurrent access to data and prevent destructive interaction between operations that use the same resource.

`BlockInfoManager` uses [read](#readLocksByTask) and [write](#writeLocksByTask) locks by task attempts.

### <span id="readLocksByTask"> Read Locks

```scala
readLocksByTask: HashMap[TaskAttemptId, ConcurrentHashMultiset[BlockId]]
```

`BlockInfoManager` uses `readLocksByTask` registry to track tasks (by `TaskAttemptId`) and the blocks they locked for reading (as [BlockId](BlockId.md)s).

A new entry is added when `BlockInfoManager` is requested to [register a task](#registerTask) (attempt).

A new `BlockId` is added to an existing task attempt in [lockForReading](#lockForReading).

### <span id="writeLocksByTask"> Write Locks

Tracks tasks (by `TaskAttemptId`) and the blocks they locked for writing (as BlockId.md[]).

## <span id="registerTask"> Registering Task (Execution Attempt)

```scala
registerTask(
  taskAttemptId: Long): Unit
```

`registerTask` registers a new "empty" entry for the given task (by the task attempt ID) to the [readLocksByTask](#readLocksByTask) internal registry.

`registerTask` is used when:

* `BlockInfoManager` is [created](#creating-instance)
* `BlockManager` is requested to [registerTask](BlockManager.md#registerTask)

## <span id="downgradeLock"> Downgrading Exclusive Write Lock to Shared Read Lock

```scala
downgradeLock(
  blockId: BlockId): Unit
```

`downgradeLock` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] downgrading write lock for [blockId]
```

`downgradeLock`...FIXME

`downgradeLock` is used when:

* `BlockManager` is requested to [doPut](BlockManager.md#doPut) and [downgradeLock](BlockManager.md#downgradeLock)

## <span id="lockForReading"> Obtaining Read Lock for Block

```scala
lockForReading(
  blockId: BlockId,
  blocking: Boolean = true): Option[BlockInfo]
```

`lockForReading` locks a given memory block for reading when the block was registered earlier and no writer tasks use it.

When executed, `lockForReading` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] trying to acquire read lock for [blockId]
```

`lockForReading` looks up the metadata of the `blockId` block (in the [infos](#infos) registry).

If no metadata could be found, `lockForReading` returns `None` which means that the block does not exist or was removed (and anybody could acquire a write lock).

Otherwise, when the metadata was found (i.e. registered) `lockForReading` checks so-called _writerTask_. Only when the [block has no writer tasks](BlockInfo.md#NO_WRITER), a read lock can be acquired. If so, the `readerCount` of the block metadata is incremented and the block is recorded (in the internal [readLocksByTask](#readLocksByTask) registry). `lockForReading` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] acquired read lock for [blockId]
```

The `BlockInfo` for the `blockId` block is returned.

!!! note
    `-1024` is a special `taskAttemptId` ([NON_TASK_WRITER](BlockInfo.md#NON_TASK_WRITER)) used to mark a non-task thread, e.g. by a driver thread or by unit test code.

For blocks with `writerTask` other than [NO_WRITER](BlockInfo.md#NO_WRITER), when `blocking` is enabled, `lockForReading` waits (until another thread invokes the `Object.notify` method or the `Object.notifyAll` methods for this object).

With `blocking` enabled, it will repeat the waiting-for-read-lock sequence until either `None` or the lock is obtained.

When `blocking` is disabled and the lock could not be obtained, `None` is returned immediately.

!!! note
    `lockForReading` is a `synchronized` method, i.e. no two objects can use this and other instance methods.

`lockForReading` is used when:

* `BlockInfoManager` is requested to [downgradeLock](#downgradeLock) and [lockNewBlockForWriting](#lockNewBlockForWriting)
* `BlockManager` is requested to [getLocalValues](BlockManager.md#getLocalValues), [getLocalBytes](BlockManager.md#getLocalBytes) and [replicateBlock](BlockManager.md#replicateBlock)
* `BlockManagerManagedBuffer` is requested to `retain`

## <span id="lockForWriting"> Obtaining Write Lock for Block

```scala
lockForWriting(
  blockId: BlockId,
  blocking: Boolean = true): Option[BlockInfo]
```

`lockForWriting` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] trying to acquire write lock for [blockId]
```

`lockForWriting` finds the `blockId` (in the [infos](#infos) registry). When no [BlockInfo](BlockInfo.md) could be found, `None` is returned. Otherwise, [`blockId` block is checked for `writerTask` to be `BlockInfo.NO_WRITER`](BlockInfo.md#NO_WRITER) with no readers (i.e. `readerCount` is `0`) and only then the lock is returned.

When the write lock can be returned, `BlockInfo.writerTask` is set to `currentTaskAttemptId` and a new binding is added to the internal [writeLocksByTask](#writeLocksByTask) registry. `lockForWriting` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] acquired write lock for [blockId]
```

If, for some reason, BlockInfo.md#writerTask[`blockId` has a writer] or the number of readers is positive (i.e. `BlockInfo.readerCount` is greater than `0`), the method will wait (based on the input `blocking` flag) and attempt the write lock acquisition process until it finishes with a write lock.

NOTE: (deadlock possible) The method is `synchronized` and can block, i.e. `wait` that causes the current thread to wait until another thread invokes `Object.notify` or `Object.notifyAll` methods for this object.

`lockForWriting` returns `None` for no `blockId` in the internal [infos](#infos) registry or when `blocking` flag is disabled and the write lock could not be acquired.

`lockForWriting` is used when:

* `BlockInfoManager` is requested to [lockNewBlockForWriting](#lockNewBlockForWriting)
* `BlockManager` is requested to [removeBlock](BlockManager.md#removeBlock)
* `MemoryStore` is requested to [evictBlocksToFreeSpace](MemoryStore.md#evictBlocksToFreeSpace)

## <span id="lockNewBlockForWriting"> Obtaining Write Lock for New Block

```scala
lockNewBlockForWriting(
  blockId: BlockId,
  newBlockInfo: BlockInfo): Boolean
```

`lockNewBlockForWriting` obtains a write lock for `blockId` but only when the method could register the block.

!!! note
    `lockNewBlockForWriting` is similar to [lockForWriting](#lockForWriting) method but for brand new blocks.

When executed, `lockNewBlockForWriting` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] trying to put [blockId]
```

If [some other thread has already created the block](#lockForReading), `lockNewBlockForWriting` finishes returning `false`. Otherwise, when the block does not exist, `newBlockInfo` is recorded in the [infos](#infos) internal registry and the block is [locked for this client for writing](#lockForWriting). `lockNewBlockForWriting` then returns `true`.

!!! note
    `lockNewBlockForWriting` executes itself in `synchronized` block so once the `BlockInfoManager` is locked the other internal registries should be available for the current thread only.

`lockNewBlockForWriting` is used when:

* `BlockManager` is requested to [doPut](BlockManager.md#doPut)

## <span id="unlock"> Releasing Lock on Block

```scala
unlock(
  blockId: BlockId,
  taskAttemptId: Option[TaskAttemptId] = None): Unit
```

`unlock` prints out the following TRACE message to the logs:

```text
Task [currentTaskAttemptId] releasing lock for [blockId]
```

`unlock` gets the metadata for `blockId` (and throws an `IllegalStateException` if the block was not found).

If the [writer task](BlockInfo.md#writerTask) for the block is not [NO_WRITER](BlockInfo.md#NO_WRITER), it becomes so and the `blockId` block is removed from the internal [writeLocksByTask](#writeLocksByTask) registry for the [current task attempt](#currentTaskAttemptId).

Otherwise, if the writer task is indeed `NO_WRITER`, the block is assumed [locked for reading](BlockInfo.md#readerCount). The `readerCount` counter is decremented for the `blockId` block and the read lock removed from the internal [readLocksByTask](#readLocksByTask) registry for the task attempt.

In the end, `unlock` wakes up all the threads waiting for the `BlockInfoManager`.

`unlock` is used when:

* `BlockInfoManager` is requested to [downgradeLock](#downgradeLock)
* `BlockManager` is requested to [releaseLock](BlockManager.md#releaseLock) and [doPut](BlockManager.md#doPut)
* `BlockManagerManagedBuffer` is requested to `release`
* `MemoryStore` is requested to [evictBlocksToFreeSpace](MemoryStore.md#evictBlocksToFreeSpace)

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockInfoManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.BlockInfoManager=ALL
```

Refer to [Logging](../spark-logging.md).
