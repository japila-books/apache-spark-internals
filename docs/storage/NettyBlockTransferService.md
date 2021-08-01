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

## Logging

Enable `ALL` logging level for `org.apache.spark.network.netty.NettyBlockTransferService` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.netty.NettyBlockTransferService=ALL
```

Refer to [Logging](../spark-logging.md).

## Review Me

== [[transportConf]][[transportContext]] TransportConf, TransportContext

NettyBlockTransferService creates a network:TransportConf.md[] for *shuffle* module (using network:SparkTransportConf.md#fromSparkConf[SparkTransportConf] utility) when <<creating-instance, created>>.

NettyBlockTransferService uses the TransportConf for the following:

* Create a network:TransportContext.md[] when requested to <<init, initialize>>

* Create a storage:OneForOneBlockFetcher.md[] and a core:RetryingBlockFetcher.md[RetryingBlockFetcher] when requested to <<fetchBlocks, fetch blocks>>

NettyBlockTransferService uses the TransportContext to create the <<clientFactory, TransportClientFactory>> and the <<server, TransportServer>>.

== [[clientFactory]] TransportClientFactory

NettyBlockTransferService creates a network:TransportClientFactory.md[] when requested to <<init, initialize>>.

NettyBlockTransferService uses the TransportClientFactory for the following:

* <<shuffleMetrics, Shuffle metrics>>

* <<fetchBlocks, Fetching blocks>>

* <<uploadBlock, Uploading blocks>>

NettyBlockTransferService requests the TransportClientFactory to network:TransportClientFactory.md#close[close] when requested to <<close, close>>.

== [[server]] TransportServer

NettyBlockTransferService <<createServer, creates a TransportServer>> when requested to <<init, initialize>>.

NettyBlockTransferService uses the TransportServer for the following:

* <<shuffleMetrics, Shuffle metrics>>

* <<port, Port>>

NettyBlockTransferService requests the TransportServer to network:TransportServer.md#close[close] when requested to <<close, close>>.

== [[port]] Port

NettyBlockTransferService simply requests the <<server, TransportServer>> for the network:TransportServer.md#getPort[port].

== [[fetchBlocks]] Fetching Blocks

[source, scala]
----
fetchBlocks(
  host: String,
  port: Int,
  execId: String,
  blockIds: Array[String],
  listener: BlockFetchingListener): Unit
----

When executed, fetchBlocks prints out the following TRACE message in the logs:

```
TRACE Fetch blocks from [host]:[port] (executor id [execId])
```

fetchBlocks then creates a `RetryingBlockFetcher.BlockFetchStarter` where `createAndStart` method...FIXME

Depending on the maximum number of acceptable IO exceptions (such as connection timeouts) per request, if the number is greater than `0`, fetchBlocks creates a core:RetryingBlockFetcher.md#creating-instance[RetryingBlockFetcher] and core:RetryingBlockFetcher.md#start[starts] it immediately.

NOTE: `RetryingBlockFetcher` is created with the `RetryingBlockFetcher.BlockFetchStarter` created earlier, the input `blockIds` and `listener`.

If however the number of retries is not greater than `0` (it could be `0` or less), the `RetryingBlockFetcher.BlockFetchStarter` created earlier is started (with the input `blockIds` and `listener`).

In case of any `Exception`, you should see the following ERROR message in the logs and the input `BlockFetchingListener` gets notified (using `onBlockFetchFailure` for every block id).

```
ERROR Exception while beginning fetchBlocks
```

fetchBlocks is part of storage:BlockTransferService.md#fetchBlocks[BlockTransferService] abstraction.

== [[init]] Initializing NettyBlockTransferService

[source, scala]
----
init(
  blockDataManager: BlockDataManager): Unit
----

init creates a storage:NettyBlockRpcServer.md[] (for the SparkConf.md#getAppId[application id], a JavaSerializer and the given storage:BlockDataManager.md[BlockDataManager]) that is used to create a <<transportContext, TransportContext>>.

init creates the internal `clientFactory` and a server.

CAUTION: FIXME What's the "a server"?

In the end, you should see the INFO message in the logs:

```
Server created on [hostName]:[port]
```

NOTE: `hostname` is given when core:SparkEnv.md#NettyBlockTransferService[NettyBlockTransferService is created] and is controlled by spark-driver.md#spark_driver_host[`spark.driver.host` Spark property] for the driver and differs per deployment environment for executors (as controlled by executor:CoarseGrainedExecutorBackend.md#main[`--hostname` for `CoarseGrainedExecutorBackend`]).

init is part of the storage:BlockTransferService.md#init[BlockTransferService] abstraction.

== [[uploadBlock]] Uploading Block

[source, scala]
----
uploadBlock(
  hostname: String,
  port: Int,
  execId: String,
  blockId: BlockId,
  blockData: ManagedBuffer,
  level: StorageLevel,
  classTag: ClassTag[_]): Future[Unit]
----

Internally, uploadBlock creates a `TransportClient` client to send a <<UploadBlock, `UploadBlock` message>> (to the input `hostname` and `port`).

NOTE: `UploadBlock` message is processed by storage:NettyBlockRpcServer.md[NettyBlockRpcServer].

The `UploadBlock` message holds the <<appId, application id>>, the input `execId` and `blockId`. It also holds the serialized bytes for block metadata with `level` and `classTag` serialized (using the internal `JavaSerializer`) as well as the serialized bytes for the input `blockData` itself (this time however the serialization uses storage:BlockDataManager.md#ManagedBuffer[`ManagedBuffer.nioByteBuffer` method]).

The entire `UploadBlock` message is further serialized before sending (using `TransportClient.sendRpc`).

CAUTION: FIXME Describe `TransportClient` and `clientFactory.createClient`.

When `blockId` block was successfully uploaded, you should see the following TRACE message in the logs:

```
TRACE NettyBlockTransferService: Successfully uploaded block [blockId]
```

When an upload failed, you should see the following ERROR message in the logs:

```
ERROR Error while uploading block [blockId]
```

uploadBlock is part of the storage:BlockTransferService.md#uploadBlock[BlockTransferService] abstraction.

== [[UploadBlock]] UploadBlock Message

`UploadBlock` is a `BlockTransferMessage` that describes a block being uploaded, i.e. send over the wire from a <<uploadBlock, NettyBlockTransferService>> to a storage:NettyBlockRpcServer.md#UploadBlock[NettyBlockRpcServer].

.`UploadBlock` Attributes
[cols="1,2",options="header",width="100%"]
|===
| Attribute | Description
| `appId` | The application id (the block belongs to)
| `execId` | The executor id
| `blockId` | The block id
| `metadata` |
| `blockData` | The block data as an array of bytes
|===

As an `Encodable`, `UploadBlock` can calculate the encoded size and do encoding and decoding itself to or from a `ByteBuf`, respectively.

== [[createServer]] createServer Internal Method

[source, scala]
----
createServer(
  bootstraps: List[TransportServerBootstrap]): TransportServer
----

createServer...FIXME

createServer is used when NettyBlockTransferService is requested to <<init, initialize>>.
