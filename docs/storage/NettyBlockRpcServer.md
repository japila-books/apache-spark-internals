= NettyBlockRpcServer

NettyBlockRpcServer is an xref:network:RpcHandler.adoc[] to handle <<messages, messages>> for xref:storage:NettyBlockTransferService.adoc[NettyBlockTransferService].

.NettyBlockRpcServer and NettyBlockTransferService
image::NettyBlockRpcServer.png[align="center"]

== [[creating-instance]] Creating Instance

NettyBlockRpcServer takes the following to be created:

* [[appId]] Application ID
* [[serializer]] xref:serializer:Serializer.adoc[]
* [[blockManager]] xref:storage:BlockDataManager.adoc[]

NettyBlockRpcServer is created when NettyBlockTransferService is requested to xref:storage:NettyBlockTransferService.adoc#init[initialize].

== [[streamManager]] OneForOneStreamManager

NettyBlockRpcServer uses a xref:network:OneForOneStreamManager.adoc[] for...FIXME

== [[receive]] Receiving RPC Messages

[source, scala]
----
receive(
  client: TransportClient,
  rpcMessage: ByteBuffer,
  responseContext: RpcResponseCallback): Unit
----

receive...FIXME

receive is part of xref:network:RpcHandler.adoc#receive[RpcHandler] abstraction.

== [[messages]] Messages

=== [[OpenBlocks]] OpenBlocks

[source,java]
----
OpenBlocks(
  String appId,
  String execId,
  String[] blockIds)
----

When received, NettyBlockRpcServer requests the <<blockManager, BlockDataManager>> for xref:storage:BlockDataManager.adoc#getBlockData[block data] for every block id in the message. The block data is a collection of xref:network:ManagedBuffer.adoc[] for every block id in the incoming message.

NettyBlockRpcServer then xref:network:OneForOneStreamManager.adoc#registerStream[registers a stream of ``ManagedBuffer``s (for the blocks) with the internal `StreamManager`] under `streamId`.

NOTE: The internal `StreamManager` is xref:network:OneForOneStreamManager.adoc[OneForOneStreamManager] and is created when <<creating-instance, NettyBlockRpcServer is created>>.

You should see the following TRACE message in the logs:

[source,plaintext]
----
NettyBlockRpcServer: Registered streamId [streamId]  with [size] buffers
----

In the end, NettyBlockRpcServer responds with a `StreamHandle` (with the `streamId` and the number of blocks). The response is serialized as a `ByteBuffer`.

Posted when OneForOneBlockFetcher is requested to xref:storage:OneForOneBlockFetcher.adoc#start[start].

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

When received, NettyBlockRpcServer deserializes the `metadata` of the input message to get the xref:storage:StorageLevel.adoc[StorageLevel] and `ClassTag` of the block being uploaded.

NettyBlockRpcServer creates a xref:storage:BlockId.adoc[] for the block id and requests the <<blockManager, BlockDataManager>> to xref:storage:BlockDataManager.adoc#putBlockData[store the block].

In the end, NettyBlockRpcServer responds with a `0`-capacity `ByteBuffer`.

Posted when NettyBlockTransferService is requested to xref:storage:NettyBlockTransferService.adoc#uploadBlock[upload a block].

== [[receiveStream]] Receiving RPC Message with Streamed Data

[source, scala]
----
receiveStream(
  client: TransportClient,
  messageHeader: ByteBuffer,
  responseContext: RpcResponseCallback): StreamCallbackWithID
----

receiveStream...FIXME

receiveStream is part of xref:network:RpcHandler.adoc#receive[RpcHandler] abstraction.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.network.netty.NettyBlockRpcServer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.network.netty.NettyBlockRpcServer=ALL
----

Refer to xref:ROOT:spark-logging.adoc[Logging].
