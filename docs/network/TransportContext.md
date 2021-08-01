# TransportContext

*TransportContext* is used to create a <<createServer, server>> or <<createClientFactory, ClientFactory>>.

== [[creating-instance]] Creating Instance

TransportContext takes the following to be created:

* [[conf]] network:TransportConf.md[]
* [[rpcHandler]] network:RpcHandler.md[]
* [[closeIdleConnections]] closeIdleConnections flag (default: `false`)

TransportContext is created when:

* YarnShuffleService is requested to spark-on-yarn:spark-yarn-YarnShuffleService.md#serviceInit[serviceInit]

== [[createClientFactory]] createClientFactory Method

[source,java]
----
TransportClientFactory createClientFactory(
  List<TransportClientBootstrap> bootstraps)
----

createClientFactory...FIXME

createClientFactory is used when TransportContext is requested to <<initializePipeline, initializePipeline>>.

== [[createChannelHandler]] createChannelHandler Method

[source, java]
----
TransportChannelHandler createChannelHandler(
  Channel channel,
  RpcHandler rpcHandler)
----

createChannelHandler...FIXME

createChannelHandler is used when TransportContext is requested to <<initializePipeline, initializePipeline>>.

== [[initializePipeline]] initializePipeline Method

[source, java]
----
TransportChannelHandler initializePipeline(
  SocketChannel channel) // <1>
TransportChannelHandler initializePipeline(
  SocketChannel channel,
  RpcHandler channelRpcHandler)
----
<1> Uses the <<rpcHandler, RpcHandler>>

initializePipeline...FIXME

initializePipeline is used when:

* `TransportServer` is requested to network:TransportServer.md#init[init]

* `TransportClientFactory` is requested to network:TransportClientFactory.md#createClient[createClient]

== [[createServer]] Creating Server

[source, java]
----
TransportServer createServer()
TransportServer createServer(
  int port,
  List<TransportServerBootstrap> bootstraps)
TransportServer createServer(
  List<TransportServerBootstrap> bootstraps)
TransportServer createServer(
  String host,
  int port,
  List<TransportServerBootstrap> bootstraps)
----

createServer simply creates a TransportServer (with the current TransportContext, the host, the port, the <<rpcHandler, RpcHandler>> and the bootstraps).

createServer is used when:

* `NettyBlockTransferService` is requested to storage:NettyBlockTransferService.md#createServer[createServer]

* `NettyRpcEnv` is requested to `startServer`

* `ExternalShuffleService` is requested to [start](../external-shuffle-service/ExternalShuffleService.md)

* Spark on YARN's `YarnShuffleService` is requested to `serviceInit`
