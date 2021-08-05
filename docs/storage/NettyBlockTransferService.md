# NettyBlockTransferService

`NettyBlockTransferService` is a [BlockTransferService](BlockTransferService.md) that uses Netty for [uploading](#uploadBlock) and [fetching](#fetchBlocks) blocks of data.

![NettyBlockTransferService, SparkEnv and BlockManager](../images/storage/NettyBlockTransferService.png)

## Creating Instance

`NettyBlockTransferService` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="securityManager"> `SecurityManager`
* <span id="bindAddress"> Bind Address
* <span id="hostName"> Host Name
* <span id="_port"> Port
* <span id="numCores"> Number of CPU Cores
* <span id="driverEndPointRef"> Driver [RpcEndpointRef](../rpc/RpcEndpointRef.md)

`NettyBlockTransferService` is created when:

* `SparkEnv` utility is used to [create a SparkEnv](../SparkEnv.md#create-NettyBlockTransferService) (for the driver and executors and [creates a BlockManager](../SparkEnv.md#create-BlockManager))

## <span id="init"> Initializing

```scala
init(
  blockDataManager: BlockDataManager): Unit
```

`init` is part of the [BlockTransferService](BlockTransferService.md#init) abstraction.

`init` creates a [NettyBlockRpcServer](NettyBlockRpcServer.md) (with the [application ID](../SparkConf.md#getAppId), a `JavaSerializer` and the given [BlockDataManager](BlockDataManager.md)).

`init` creates a [TransportContext](../network/TransportContext.md) (with the `NettyBlockRpcServer` just created) and requests it for a [TransportClientFactory](../network/TransportContext.md#createClientFactory).

`init` [createServer](#createServer).

In the end, `init` prints out the following INFO message to the logs:

```text
Server created on [hostName]:[port]
```

## <span id="fetchBlocks"> Fetching Blocks

```scala
fetchBlocks(
  host: String,
  port: Int,
  execId: String,
  blockIds: Array[String],
  listener: BlockFetchingListener,
  tempFileManager: DownloadFileManager): Unit
```

`fetchBlocks` is part of the [BlockStoreClient](BlockStoreClient.md#fetchBlocks) abstraction.

`fetchBlocks` prints out the following TRACE message to the logs:

```text
Fetch blocks from [host]:[port] (executor id [execId])
```

`fetchBlocks` creates a [BlockFetchStarter](../core/BlockFetchStarter.md).

`fetchBlocks` requests the [TransportConf](#transportConf) for the [maxIORetries](../network/TransportConf.md#maxIORetries).

With the `maxIORetries` above zero, `fetchBlocks` creates a [RetryingBlockFetcher](../core/RetryingBlockFetcher.md) (with the `BlockFetchStarter`, the `blockIds` and the [BlockFetchingListener](../core/BlockFetchingListener.md)) and [starts it](../core/RetryingBlockFetcher.md#start).

Otherwise, `fetchBlocks` requests the `BlockFetchStarter` to [createAndStart](../core/BlockFetchStarter.md#createAndStart) (with the `blockIds` and the `BlockFetchingListener`).

In case of any `Exception`, `fetchBlocks` prints out the following ERROR message to the logs and the given `BlockFetchingListener` gets [notified](../core/BlockFetchingListener.md#onBlockFetchFailure).

```text
Exception while beginning fetchBlocks
```

## <span id="uploadBlock"> Uploading Block

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

`uploadBlock` is part of the [BlockTransferService](BlockTransferService.md#uploadBlock) abstraction.

`uploadBlock` creates a `TransportClient` (with the given `hostname` and `port`).

`uploadBlock` serializes the given [StorageLevel](StorageLevel.md) and `ClassTag` (using a `JavaSerializer`).

`uploadBlock` uses a stream to transfer shuffle blocks when one of the following holds:

1. The size of the block data (`ManagedBuffer`) is above [spark.network.maxRemoteBlockSizeFetchToMem](../configuration-properties.md#spark.network.maxRemoteBlockSizeFetchToMem) configuration property
1. The given [BlockId](BlockId.md) is a shuffle block

For stream transfer `uploadBlock` requests the `TransportClient` to `uploadStream`. Otherwise, `uploadBlock` requests the `TransportClient` to `sendRpc` a `UploadBlock` message.

!!! note
    `UploadBlock` message is processed by [NettyBlockRpcServer](NettyBlockRpcServer.md).

With the upload successful, `uploadBlock` prints out the following TRACE message to the logs:

```text
Successfully uploaded block [blockId] [as stream]
```

With the upload failed, `uploadBlock` prints out the following ERROR message to the logs:

```text
Error while uploading block [blockId] [as stream]
```

## Logging

Enable `ALL` logging level for `org.apache.spark.network.netty.NettyBlockTransferService` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.netty.NettyBlockTransferService=ALL
```

Refer to [Logging](../spark-logging.md).
