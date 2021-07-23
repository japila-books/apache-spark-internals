# BlockTransferService

`BlockTransferService` is an [extension](#contract) of the [BlockStoreClient](BlockStoreClient.md) abstraction for [shuffle clients](#implementations) that can [fetch](#fetchBlocks) and [upload](#uploadBlock) blocks of data (synchronously or asynchronously).

`BlockTransferService` is a network service available by a [host name](#hostName) and a [port](#port).

`BlockTransferService` was introduced in [SPARK-3019 Pluggable block transfer interface (BlockTransferService)](https://issues.apache.org/jira/browse/SPARK-3019).

## Contract

### <span id="hostName"> Host Name

```scala
hostName: String
```

Host name this service is listening on

Used when:

* `BlockManager` is requested to [initialize](BlockManager.md#initialize)

### <span id="init"> Initializing

```scala
init(
  blockDataManager: BlockDataManager): Unit
```

Used when:

* `BlockManager` is requested to [initialize](BlockManager.md#initialize)

### <span id="port"> Port

```scala
port: Int
```

Used when:

* `BlockManager` is requested to [initialize](BlockManager.md#initialize)

### <span id="uploadBlock"> Uploading Block Asynchronously

```scala
uploadBlock(
  hostname: String,
  port: Int,
  execId: String,
  blockId: BlockId,
  blockData: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Future[Unit]
```

Used when:

* `BlockTransferService` is requested to [uploadBlockSync](#uploadBlockSync)

## Implementations

* [NettyBlockTransferService](NettyBlockTransferService.md)

## <span id="uploadBlockSync"> Uploading Block Synchronously

```scala
uploadBlockSync(
  hostname: String,
  port: Int,
  execId: String,
  blockId: BlockId,
  blockData: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Unit
```

`uploadBlockSync` [uploadBlock](#uploadBlock) and waits till it finishes.

`uploadBlockSync` is used when:

* `BlockManager` is requested to [replicate](BlockManager.md#replicate)
* `ShuffleMigrationRunnable` is requested to [run](ShuffleMigrationRunnable.md#run)
