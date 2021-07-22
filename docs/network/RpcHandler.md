# RpcHandler

## Review Me

*RpcHandler* is the <<contract, base>> of...FIXME

[[ONE_WAY_CALLBACK]]
RpcHandler uses a <<OneWayRpcCallback, OneWayRpcCallback>> that...FIXME

[[contract]]
[source, java]
----
package org.apache.spark.network.server;

abstract class RpcHandler {
  // only required methods that have no implementation
  // the others follow
  abstract void receive(
    TransportClient client,
    ByteBuffer message,
    RpcResponseCallback callback);
  abstract StreamManager getStreamManager();
}
----

.(Subset of) RpcHandler Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `receive`
a| [[receive]] Used when:

* `AuthRpcHandler` is requested to `receive`

* `SaslRpcHandler` is requested to `receive` (after authentication is complete)

* `TransportRequestHandler` is requested to network:TransportRequestHandler.md#processRpcRequest[processRpcRequest]

| `getStreamManager`
| [[getStreamManager]] Used when...FIXME
|===

[[implementations]]
.RpcHandlers
[cols="1,2",options="header",width="100%"]
|===
| RpcHandler
| Description

| `AuthRpcHandler`
| [[AuthRpcHandler]]

| storage:NettyBlockRpcServer.md[]
| [[NettyBlockRpcServer]]

| `NettyRpcHandler`
| [[NettyRpcHandler]]

| `NoOpRpcHandler`
| [[NoOpRpcHandler]]

| `SaslRpcHandler`
| [[SaslRpcHandler]]
|===

== [[OneWayRpcCallback]] `OneWayRpcCallback` RpcResponseCallback

`OneWayRpcCallback` is a `RpcResponseCallback` that simply prints out the WARN and ERROR for the following methods `onSuccess` and `onFailure` respectively.

.void onSuccess(ByteBuffer response)
```
Response provided for one-way RPC.
```

.void onFailure(Throwable e)
```
Error response provided for one-way RPC.
```
