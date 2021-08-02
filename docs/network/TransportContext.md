# TransportContext

## Creating Instance

`TransportContext` takes the following to be created:

* <span id="conf"> [TransportConf](TransportConf.md)
* <span id="rpcHandler"> [RpcHandler](RpcHandler.md)
* <span id="closeIdleConnections"> `closeIdleConnections` flag
* <span id="isClientOnly"> `isClientOnly` flag

`TransportContext` is created when:

* `ExternalBlockStoreClient` is requested to [init](../storage/ExternalBlockStoreClient.md#init)
* `ExternalShuffleService` is requested to [start](../external-shuffle-service/ExternalShuffleService.md#start)
* `NettyBlockTransferService` is requested to [init](../storage/NettyBlockTransferService.md#init)
* `NettyRpcEnv` is [created](../rpc/NettyRpcEnv.md#transportContext) and requested to [downloadClient](../rpc/NettyRpcEnv.md#downloadClient)
* `YarnShuffleService` (Spark on YARN) is requested to `serviceInit`

## <span id="createServer"> Creating Server

```java
TransportServer createServer(
  int port,
  List<TransportServerBootstrap> bootstraps)
TransportServer createServer(
  String host,
  int port,
  List<TransportServerBootstrap> bootstraps)
```

`createServer` creates a [TransportServer](TransportServer.md) (with the [RpcHandler](#rpcHandler) and the input arguments).

`createServer` is used when:

* `YarnShuffleService` (Spark on YARN) is requested to `serviceInit`
* `ExternalShuffleService` is requested to [start](../external-shuffle-service/ExternalShuffleService.md#start)
* `NettyBlockTransferService` is requested to [createServer](../storage/NettyBlockTransferService.md#createServer)
* `NettyRpcEnv` is requested to [startServer](../rpc/NettyRpcEnv.md#startServer)

## <span id="createClientFactory"> Creating TransportClientFactory

```java
TransportClientFactory createClientFactory(
  List<TransportClientBootstrap> bootstraps)
```

`createClientFactory`...FIXME

`createClientFactory` is used when:

* `ExternalBlockStoreClient` is requested to [init](../storage/ExternalBlockStoreClient.md#init)
* `NettyBlockTransferService` is requested to [init](../storage/NettyBlockTransferService.md#init)
* `NettyRpcEnv` is [created](../rpc/NettyRpcEnv.md#clientFactory) and requested to [downloadClient](../rpc/NettyRpcEnv.md#downloadClient)
