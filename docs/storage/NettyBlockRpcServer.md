# NettyBlockRpcServer

`NettyBlockRpcServer` is a [RpcHandler](../network/RpcHandler.md) to handle [messages](#messages) for [NettyBlockTransferService](NettyBlockTransferService.md).

![NettyBlockRpcServer and NettyBlockTransferService](../images/storage/NettyBlockRpcServer.png)

## Creating Instance

`NettyBlockRpcServer` takes the following to be created:

* <span id="appId"> Application ID
* <span id="serializer"> [Serializer](../serializer/Serializer.md)
* <span id="blockManager"> [BlockDataManager](BlockDataManager.md)

`NettyBlockRpcServer` is created when:

* `NettyBlockTransferService` is requested to [initialize](NettyBlockTransferService.md#init)

## <span id="streamManager"> OneForOneStreamManager

`NettyBlockRpcServer` uses a [OneForOneStreamManager](../network/OneForOneStreamManager.md).

## <span id="receive"> Receiving RPC Messages

```scala
receive(
  client: TransportClient,
  rpcMessage: ByteBuffer,
  responseContext: RpcResponseCallback): Unit
```

`receive` is part of the [RpcHandler](../network/RpcHandler.md#receive) abstraction.

`receive` deserializes the incoming RPC message (from `ByteBuffer` to `BlockTransferMessage`) and prints out the following TRACE message to the logs:

```text
Received request: [message]
```

`receive` handles the message.

### <span id="FetchShuffleBlocks"> FetchShuffleBlocks

`FetchShuffleBlocks` carries the following:

* Application ID
* Executor ID
* Shuffle ID
* Map IDs (`long[]`)
* Reduce IDs (`long[][]`)
* `batchFetchEnabled` flag

When received, `receive`...FIXME

`receive` prints out the following TRACE message in the logs:

```text
Registered streamId [streamId] with [numBlockIds] buffers
```

In the end, `receive` responds with a `StreamHandle` (with the `streamId` and the number of blocks). The response is serialized to a `ByteBuffer`.

`FetchShuffleBlocks` is posted when:

* `OneForOneBlockFetcher` is requested to [createFetchShuffleBlocksMsgAndBuildBlockIds](../storage/OneForOneBlockFetcher.md#createFetchShuffleBlocksMsgAndBuildBlockIds)

### <span id="GetLocalDirsForExecutors"> GetLocalDirsForExecutors

### <span id="OpenBlocks"> OpenBlocks

`OpenBlocks` carries the following:

* Application ID
* Executor ID
* Block IDs

When received, `receive`...FIXME

`receive` prints out the following TRACE message in the logs:

```text
Registered streamId [streamId] with [blocksNum] buffers
```

In the end, `receive` responds with a `StreamHandle` (with the `streamId` and the number of blocks). The response is serialized to a `ByteBuffer`.

`OpenBlocks` is posted when:

* `OneForOneBlockFetcher` is requested to [start](../storage/OneForOneBlockFetcher.md#start)

### <span id="UploadBlock"> UploadBlock

`UploadBlock` carries the following:

* Application ID
* Executor ID
* Block ID
* Metadata (`byte[]`)
* Block Data (`byte[]`)

When received, `receive` deserializes the `metadata` to get the [StorageLevel](StorageLevel.md) and `ClassTag` of the block being uploaded.

`receive`...FIXME

`UploadBlock` is posted when:

* `NettyBlockTransferService` is requested to [upload a block](../storage/NettyBlockTransferService.md#uploadBlock)

## <span id="receiveStream"> receiveStream

```scala
receiveStream(
  client: TransportClient,
  messageHeader: ByteBuffer,
  responseContext: RpcResponseCallback): StreamCallbackWithID
```

`receiveStream` is part of the [RpcHandler](../network/RpcHandler.md#receiveStream) abstraction.

`receiveStream`...FIXME

## Logging

Enable `ALL` logging level for `org.apache.spark.network.netty.NettyBlockRpcServer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.netty.NettyBlockRpcServer=ALL
```

Refer to [Logging](../spark-logging.md).
