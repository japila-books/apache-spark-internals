= BlockInfoManager

*BlockInfoManager* is used by xref:storage:BlockManager.adoc[] (and xref:storage:MemoryStore.adoc#blockInfoManager[MemoryStore]) to manage <<infos, metadata of memory blocks>> and control concurrent access by locks for <<lockForReading, reading>> and <<lockForWriting, writing>>.

NOTE: *Locks* are the mechanism to control concurrent access to data and prevent destructive interaction between operations that use the same resource.

BlockInfoManager is used to create a xref:storage:MemoryStore.adoc#blockInfoManager[MemoryStore] and a BlockManagerManagedBuffer.

== [[creating-instance]] Creating Instance

BlockInfoManager takes no parameters to be created.

BlockInfoManager is created for xref:storage:BlockManager.adoc#blockInfoManager[BlockManager].

.BlockInfoManager and BlockManager
image::BlockInfoManager-BlockManager.png[align="center"]

== [[infos]] Block Metadata

[source,scala]
----
infos: Map[BlockId, BlockInfo]
----

BlockInfoManager uses a registry of xref:storage:BlockInfo.adoc[block metadata]s per xref:storage:BlockId.adoc[block].

== [[readLocksByTask]][[writeLocksByTask]] Read and Write Locks By Task

Tracks tasks (by TaskAttemptId) and the blocks they locked for reading (as xref:storage:BlockId.adoc[]).

Tracks tasks (by `TaskAttemptId`) and the blocks they locked for writing (as xref:storage:BlockId.adoc[]).

== [[registerTask]] Registering Task (Start of Execution)

[source,scala]
----
registerTask(
  taskAttemptId: Long): Unit
----

registerTask merely adds a new "empty" entry for the given task (by the task attempt ID) to <<readLocksByTask, readLocksByTask>> internal registry.

registerTask is used when:

* BlockInfoManager is <<creating-instance, created>>

* BlockManager is requested to xref:storage:BlockManager.adoc#registerTask[registerTask]

== [[downgradeLock]] Downgrading Exclusive Write Lock For Block to Shared Read Lock

[source, scala]
----
downgradeLock(
  blockId: BlockId): Unit
----

downgradeLock prints out the following TRACE message to the logs:

[source,plaintext]
----
Task [currentTaskAttemptId] downgrading write lock for [blockId]
----

downgradeLock...FIXME

downgradeLock is used when BlockManager is requested to xref:storage:BlockManager.adoc#doPut[doPut] and xref:storage:BlockManager.adoc#downgradeLock[downgradeLock].

== [[lockForReading]] Obtaining Read Lock For Block

[source, scala]
----
lockForReading(
  blockId: BlockId,
  blocking: Boolean = true): Option[BlockInfo]
----

lockForReading locks `blockId` memory block for reading when the block was registered earlier and no writer tasks use it.

When executed, lockForReading prints out the following TRACE message to the logs:

[source,plaintext]
----
Task [currentTaskAttemptId] trying to acquire read lock for [blockId]
----

lockForReading looks up the metadata of the `blockId` block (in <<infos, infos>> registry).

If no metadata could be found, it returns `None` which means that the block does not exist or was removed (and anybody could acquire a write lock).

Otherwise, when the metadata was found, i.e. registered, it checks so-called _writerTask_. Only when the xref:storage:BlockInfo.adoc#NO_WRITER[block has no writer tasks], a read lock can be acquired. If so, the `readerCount` of the block metadata is incremented and the block is recorded (in the internal <<readLocksByTask, readLocksByTask>> registry). You should see the following TRACE message in the logs:

[source,plaintext]
----
Task [taskAttemptId] acquired read lock for [blockId]
----

The `BlockInfo` for the `blockId` block is returned.

NOTE: `-1024` is a special `taskAttemptId`, _aka_ xref:storage:BlockInfo.adoc#NON_TASK_WRITER[NON_TASK_WRITER], used to mark a non-task thread, e.g. by a driver thread or by unit test code.

For blocks with xref:storage:BlockInfo.adoc#NO_WRITER[`writerTask` other than `NO_WRITER`], when `blocking` is enabled, lockForReading waits (until another thread invokes the `Object.notify` method or the `Object.notifyAll` methods for this object).

With `blocking` enabled, it will repeat the waiting-for-read-lock sequence until either `None` or the lock is obtained.

When `blocking` is disabled and the lock could not be obtained, `None` is returned immediately.

NOTE: lockForReading is a `synchronized` method, i.e. no two objects can use this and other instance methods.

lockForReading is used when:

* BlockInfoManager is requested to <<downgradeLock, downgradeLock>> and <<lockNewBlockForWriting, lockNewBlockForWriting>>

* BlockManager is requested to xref:storage:BlockManager.adoc#getLocalValues[getLocalValues], xref:storage:BlockManager.adoc#getLocalBytes[getLocalBytes] and xref:storage:BlockManager.adoc#replicateBlock[replicateBlock]

* BlockManagerManagedBuffer is requested to retain

== [[lockForWriting]] Obtaining Write Lock for Block

[source, scala]
----
lockForWriting(
  blockId: BlockId,
  blocking: Boolean = true): Option[BlockInfo]
----

lockForWriting prints out the following TRACE message to the logs:

[source,plaintext]
----
Task [currentTaskAttemptId] trying to acquire write lock for [blockId]
----

lockForWriting looks up `blockId` in the internal <<infos, infos>> registry. When no xref:storage:BlockInfo.adoc[] could be found, `None` is returned. Otherwise, xref:storage:BlockInfo.adoc#NO_WRITER[`blockId` block is checked for `writerTask` to be `BlockInfo.NO_WRITER`] with no readers (i.e. `readerCount` is `0`) and only then the lock is returned.

When the write lock can be returned, `BlockInfo.writerTask` is set to `currentTaskAttemptId` and a new binding is added to the internal <<writeLocksByTask, writeLocksByTask>> registry. You should see the following TRACE message in the logs:

[source,plaintext]
----
Task [currentTaskAttemptId] acquired write lock for [blockId]
----

If, for some reason, xref:storage:BlockInfo.adoc#writerTask[`blockId` has a writer] or the number of readers is positive (i.e. `BlockInfo.readerCount` is greater than `0`), the method will wait (based on the input `blocking` flag) and attempt the write lock acquisition process until it finishes with a write lock.

NOTE: (deadlock possible) The method is `synchronized` and can block, i.e. `wait` that causes the current thread to wait until another thread invokes `Object.notify` or `Object.notifyAll` methods for this object.

lockForWriting returns `None` for no `blockId` in the internal <<infos, infos>> registry or when `blocking` flag is disabled and the write lock could not be acquired.

lockForWriting is used when:

* BlockInfoManager is requested to <<lockNewBlockForWriting, lockNewBlockForWriting>>

* BlockManager is requested to xref:storage:BlockManager.adoc#removeBlock[removeBlock]

* MemoryStore is requested to xref:storage:MemoryStore.adoc#evictBlocksToFreeSpace[evictBlocksToFreeSpace]

== [[lockNewBlockForWriting]] Obtaining Write Lock for New Block

[source, scala]
----
lockNewBlockForWriting(
  blockId: BlockId,
  newBlockInfo: BlockInfo): Boolean
----

lockNewBlockForWriting obtains a write lock for `blockId` but only when the method could register the block.

NOTE: lockNewBlockForWriting is similar to <<lockForWriting, lockForWriting>> method but for brand new blocks.

When executed, lockNewBlockForWriting prints out the following TRACE message to the logs:

[source,plaintext]
----
Task [currentTaskAttemptId] trying to put [blockId]
----

If <<lockForReading, some other thread has already created the block>>, it finishes returning `false`. Otherwise, when the block does not exist, `newBlockInfo` is recorded in the internal <<infos, infos>> registry and <<lockForWriting, the block is locked for this client for writing>>. It then returns `true`.

NOTE: lockNewBlockForWriting executes itself in `synchronized` block so once the BlockInfoManager is locked the other internal registries should be available only for the currently-executing thread.

lockNewBlockForWriting is used when BlockManager is requested to xref:storage:BlockManager.adoc#doPut[doPut].

== [[unlock]] Releasing Lock on Block

[source, scala]
----
unlock(
  blockId: BlockId): Unit
----

unlock prints out the following TRACE message to the logs:

[source,plaintext]
----
Task [currentTaskAttemptId] releasing lock for [blockId]
----

unlock gets the metadata for `blockId`. It may throw a `IllegalStateException` if the block was not found.

If the xref:storage:BlockInfo.adoc#writerTask[writer task] for the block is not xref:storage:BlockInfo.adoc#NO_WRITER[NO_WRITER], it becomes so and the `blockId` block is removed from the internal <<writeLocksByTask, writeLocksByTask>> registry for the <<currentTaskAttemptId, current task attempt>>.

Otherwise, if the writer task is indeed `NO_WRITER`, it is assumed that the xref:storage:BlockInfo.adoc#readerCount[`blockId` block is locked for reading]. The `readerCount` counter is decremented for the `blockId` block and the read lock removed from the internal <<readLocksByTask, readLocksByTask>> registry for the <<currentTaskAttemptId, current task attempt>>.

In the end, unlock wakes up all the threads waiting for the BlockInfoManager (using Java's link:++https://docs.oracle.com/javase/8/docs/api/java/lang/Object.html#notifyAll--++[Object.notifyAll]).

CAUTION: FIXME What threads could wait?

unlock is used when:

* BlockInfoManager is requested to <<downgradeLock, downgradeLock>>

* BlockManager is requested to xref:storage:BlockManager.adoc#releaseLock[releaseLock] and xref:storage:BlockManager.adoc#doPut[doPut]

* BlockManagerManagedBuffer is requested to release

* MemoryStore is requested to xref:storage:MemoryStore.adoc#evictBlocksToFreeSpace[evictBlocksToFreeSpace]

== [[releaseAllLocksForTask]] Releasing All Locks Obtained by Task

[source,scala]
----
releaseAllLocksForTask(
  taskAttemptId: TaskAttemptId): Seq[BlockId]
----

releaseAllLocksForTask...FIXME

releaseAllLocksForTask is used when BlockManager is requested to xref:storage:BlockManager.adoc#releaseAllLocksForTask[releaseAllLocksForTask].

== [[removeBlock]] Removing Block

[source,scala]
----
removeBlock(
  blockId: BlockId): Unit
----

removeBlock...FIXME

removeBlock is used when:

* BlockManager is requested to xref:storage:BlockManager.adoc#removeBlockInternal[removeBlockInternal]

* MemoryStore is requested to xref:storage:MemoryStore.adoc#evictBlocksToFreeSpace[evictBlocksToFreeSpace]

== [[assertBlockIsLockedForWriting]] assertBlockIsLockedForWriting Method

[source,scala]
----
assertBlockIsLockedForWriting(
  blockId: BlockId): BlockInfo
----

assertBlockIsLockedForWriting...FIXME

assertBlockIsLockedForWriting is used when BlockManager is requested to xref:storage:BlockManager.adoc#dropFromMemory[dropFromMemory] and xref:storage:BlockManager.adoc#removeBlockInternal[removeBlockInternal].

== [[currentTaskAttemptId]] currentTaskAttemptId Internal Method

[source, scala]
----
currentTaskAttemptId: Long /* TaskAttemptId */
----

currentTaskAttemptId...FIXME

currentTaskAttemptId is used when...FIXME

== [[clear]] Deleting All State

[source,scala]
----
clear(): Unit
----

clear...FIXME

clear is used when BlockManager is requested to <<stop, stop>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockInfoManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.storage.BlockInfoManager=ALL
----

Refer to xref:ROOT:spark-logging.adoc[Logging].
