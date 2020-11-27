= NettyBlockRpcServer

NettyBlockRpcServer is an network:RpcHandler.md[] to handle <<messages, messages>> for storage:NettyBlockTransferService.md[NettyBlockTransferService].

.NettyBlockRpcServer and NettyBlockTransferService
image::NettyBlockRpcServer.png[align="center"]

== [[creating-instance]] Creating Instance

NettyBlockRpcServer takes the following to be created:

* [[appId]] Application ID
* [[serializer]] serializer:Serializer.md[]
* [[blockManager]] storage:BlockDataManager.md[]

NettyBlockRpcServer is created when NettyBlockTransferService is requested to storage:NettyBlockTransferService.md#init[initialize].

== [[streamManager]] OneForOneStreamManager

NettyBlockRpcServer uses a network:OneForOneStreamManager.md[] for...FIXME

== [[receive]] Receiving RPC Messages

[source, scala]
----
receive(
  client: TransportClient,
  rpcMessage: ByteBuffer,
  responseContext: RpcResponseCallback): Unit
----

receive...FIXME

receive is part of network:RpcHandler.md#receive[RpcHandler] abstraction.

== [[messages]] Messages

=== [[OpenBlocks]] OpenBlocks

[source,java]
----
OpenBlocks(
  String appId,
  String execId,
  String[] blockIds)
----

When received, NettyBlockRpcServer requests the <<blockManager, BlockDataManager>> for storage:BlockDataManager.md#getBlockData[block data] for every block id in the message. The block data is a collection of network:ManagedBuffer.md[] for every block id in the incoming message.

NettyBlockRpcServer then network:OneForOneStreamManager.md#registerStream[registers a stream of ``ManagedBuffer``s (for the blocks) with the internal `StreamManager`] under `streamId`.

NOTE: The internal `StreamManager` is network:OneForOneStreamManager.md[OneForOneStreamManager] and is created when <<creating-instance, NettyBlockRpcServer is created>>.

You should see the following TRACE message in the logs:

[source,plaintext]
----
NettyBlockRpcServer: Registered streamId [streamId]  with [size] buffers
----

In the end, NettyBlockRpcServer responds with a `StreamHandle` (with the `streamId` and the number of blocks). The response is serialized as a `ByteBuffer`.

Posted when OneForOneBlockFetcher is requested to storage:OneForOneBlockFetcher.md#start[start].

=== [[UploadBlock]] UploadBlock

[source,java]
----
UploadBlock(
  String appId,
  String execId,
  String blockId,
  byte[] metadata,
  byte[] blockData)
----

When received, NettyBlockRpcServer deserializes the `metadata` of the input message to get the storage:StorageLevel.md[StorageLevel] and `ClassTag` of the block being uploaded.

NettyBlockRpcServer creates a storage:BlockId.md[] for the block id and requests the <<blockManager, BlockDataManager>> to storage:BlockDataManager.md#putBlockData[store the block].

In the end, NettyBlockRpcServer responds with a `0`-capacity `ByteBuffer`.

Posted when NettyBlockTransferService is requested to storage:NettyBlockTransferService.md#uploadBlock[upload a block].

== [[receiveStream]] Receiving RPC Message with Streamed Data

[source, scala]
----
receiveStream(
  client: TransportClient,
  messageHeader: ByteBuffer,
  responseContext: RpcResponseCallback): StreamCallbackWithID
----

receiveStream...FIXME

receiveStream is part of network:RpcHandler.md#receive[RpcHandler] abstraction.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.network.netty.NettyBlockRpcServer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.network.netty.NettyBlockRpcServer=ALL
----

Refer to spark-logging.md[Logging].
