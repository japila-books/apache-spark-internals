= BlockDataManager

*BlockDataManager* is an <<contract, abstraction>> of <<implementations, block data managers>> that manage storage for blocks of data (aka _block storage management API_).

BlockDataManager uses storage:BlockId.md[] to uniquely identify blocks of data and network:ManagedBuffer.md[] to represent them.

BlockDataManager is used to initialize a storage:BlockTransferService.md#init[].

BlockDataManager is used to create a storage:NettyBlockRpcServer.md[].

== [[contract]] Contract

=== [[getBlockData]] getBlockData

[source,scala]
----
getBlockData(
  blockId: BlockId): ManagedBuffer
----

Fetches a block data (as a network:ManagedBuffer.md[]) for the given storage:BlockId.md[]

Used when:

* NettyBlockRpcServer is requested to storage:NettyBlockRpcServer.md#OpenBlocks[handle a OpenBlocks message]

* ShuffleBlockFetcherIterator is requested to storage:ShuffleBlockFetcherIterator.md#fetchLocalBlocks[fetchLocalBlocks]

=== [[putBlockData]] putBlockData

[source, scala]
----
putBlockData(
  blockId: BlockId,
  data: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Boolean
----

Stores (_puts_) a block data (as a network:ManagedBuffer.md[]) for the given storage:BlockId.md[]. Returns `true` when completed successfully or `false` when failed.

Used when NettyBlockRpcServer is requested to storage:NettyBlockRpcServer.md#UploadBlock[handle an UploadBlock message]

=== [[putBlockDataAsStream]] putBlockDataAsStream

[source, scala]
----
putBlockDataAsStream(
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[_]): StreamCallbackWithID
----

Stores a block data that will be received as a stream

Used when NettyBlockRpcServer is requested to storage:NettyBlockRpcServer.md#receiveStream[receiveStream]

=== [[releaseLock]] releaseLock

[source, scala]
----
releaseLock(
  blockId: BlockId,
  taskAttemptId: Option[Long]): Unit
----

Releases a lock

Used when:

* TorrentBroadcast is requested to core:TorrentBroadcast.md#releaseLock[releaseLock]

* BlockManager is requested to storage:BlockManager.md#handleLocalReadFailure[handleLocalReadFailure], storage:BlockManager.md#getLocalValues[getLocalValues], storage:BlockManager.md#getOrElseUpdate[getOrElseUpdate], storage:BlockManager.md#doPut[doPut], and storage:BlockManager.md#releaseLockAndDispose[releaseLockAndDispose]

== [[implementations]] Available BlockDataManagers

storage:BlockManager.md[] is the default and only known BlockDataManager in Apache Spark.
