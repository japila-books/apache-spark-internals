# BlockDataManager

`BlockDataManager` is an [abstraction](#contract) of [block data managers](#implementations) that manage storage for blocks of data (aka _block storage management API_).

`BlockDataManager` uses [BlockId](BlockId.md) to uniquely identify blocks of data and [ManagedBuffer](../network/ManagedBuffer.md) to represent them.

`BlockDataManager` is used to initialize a [BlockTransferService](BlockTransferService.md#init).

`BlockDataManager` is used to create a [NettyBlockRpcServer](NettyBlockRpcServer.md).

## Contract

### <span id="getHostLocalShuffleData"> getHostLocalShuffleData

```scala
getHostLocalShuffleData(
  blockId: BlockId,
  dirs: Array[String]): ManagedBuffer
```

Used when:

* `ShuffleBlockFetcherIterator` is requested to [fetchHostLocalBlock](ShuffleBlockFetcherIterator.md#fetchHostLocalBlock)

### <span id="getLocalBlockData"> getLocalBlockData

```scala
getLocalBlockData(
  blockId: BlockId): ManagedBuffer
```

Used when:

* `NettyBlockRpcServer` is requested to [receive a request](NettyBlockRpcServer.md#receive) (`OpenBlocks` and `FetchShuffleBlocks`)

### <span id="getLocalDiskDirs"> getLocalDiskDirs

```scala
getLocalDiskDirs: Array[String]
```

Used when:

* `NettyBlockRpcServer` is requested to [receive a GetLocalDirsForExecutors request](NettyBlockRpcServer.md#receive)

### <span id="putBlockData"> putBlockData

```scala
putBlockData(
  blockId: BlockId,
  data: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Boolean
```

Stores (_puts_) a block data (as a [ManagedBuffer](../network/ManagedBuffer.md)) for the given [BlockId](BlockId.md). Returns `true` when completed successfully or `false` when failed.

Used when:

* `NettyBlockRpcServer` is requested to [receive a UploadBlock request](NettyBlockRpcServer.md#UploadBlock)

### <span id="putBlockDataAsStream"> putBlockDataAsStream

```scala
putBlockDataAsStream(
  blockId: BlockId,
  level: StorageLevel,
  classTag: ClassTag[_]): StreamCallbackWithID
```

Used when:

* `NettyBlockRpcServer` is requested to [receiveStream](NettyBlockRpcServer.md#receiveStream)

### <span id="releaseLock"> releaseLock

```scala
releaseLock(
  blockId: BlockId,
  taskContext: Option[TaskContext]): Unit
```

Used when:

* `TorrentBroadcast` is requested to [releaseBlockManagerLock](../broadcast-variables/TorrentBroadcast.md#releaseBlockManagerLock)
* `BlockManager` is requested to [handleLocalReadFailure](BlockManager.md#handleLocalReadFailure), [getLocalValues](BlockManager.md#getLocalValues), [getOrElseUpdate](BlockManager.md#getOrElseUpdate), [doPut](BlockManager.md#doPut), [releaseLockAndDispose](BlockManager.md#releaseLockAndDispose)

## Implementations

* [BlockManager](BlockManager.md)
