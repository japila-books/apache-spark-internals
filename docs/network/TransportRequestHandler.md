# TransportRequestHandler

`TransportRequestHandler` is a network:MessageHandler.md[] of <<handle, RequestMessage messages>> from Netty's <<channel, Channel>>.

== [[creating-instance]] Creating Instance

TransportRequestHandler takes the following to be created:

* [[channel]] Netty's https://netty.io/4.1/api/io/netty/channel/Channel.html[Channel]
* [[reverseClient]] TransportClient
* [[rpcHandler]] network:RpcHandler.md[]
* [[maxChunksBeingTransferred]] Maximum number of chunks allowed to be transferred at the same time

TransportRequestHandler is created when TransportContext is requested to network:TransportContext.md#createChannelHandler[create a ChannelHandler].

== [[processRpcRequest]] processRpcRequest Internal Method

[source, java]
----
void processRpcRequest(
  RpcRequest req)
----

processRpcRequest...FIXME

processRpcRequest is used when TransportRequestHandler is requested to <<handle, handle a request>>.

== [[processFetchRequest]] processFetchRequest Internal Method

[source, java]
----
void processFetchRequest(
  ChunkFetchRequest req)
----

processFetchRequest...FIXME

processFetchRequest is used when TransportRequestHandler is requested to <<handle, handle a request>>.

== [[processOneWayMessage]] `processOneWayMessage` Internal Method

[source, java]
----
void processOneWayMessage(OneWayMessage req)
----

`processOneWayMessage`...FIXME

NOTE: `processOneWayMessage` is used exclusively when TransportRequestHandler is requested to <<handle, handle>> a `OneWayMessage` request.

== [[processStreamRequest]] `processStreamRequest` Internal Method

[source, java]
----
void processStreamRequest(final StreamRequest req)
----

`processStreamRequest`...FIXME

NOTE: `processStreamRequest` is used exclusively when TransportRequestHandler is requested to <<handle, handle>> a `StreamRequest` request.

== [[handle]] Handling RequestMessages -- handle Method

[source, java]
----
void handle(RequestMessage request)
----

handle branches off per the type of the input `RequestMessage`:

* For `ChunkFetchRequest` requests, handle <<processFetchRequest, processFetchRequest>>

* For `RpcRequest` requests, handle <<processRpcRequest, processRpcRequest>>

* For `OneWayMessage` requests, handle <<processOneWayMessage, processOneWayMessage>>

* For `StreamRequest` requests, handle <<processStreamRequest, processStreamRequest>>

For unknown requests, handle simply throws a `IllegalArgumentException`.

```
Unknown request type: [request]
```

handle is part of network:MessageHandler.md#handle[MessageHandler] abstraction.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.network.server.TransportRequestHandler` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.network.server.TransportRequestHandler=ALL
----

Refer to spark-logging.md[Logging].
