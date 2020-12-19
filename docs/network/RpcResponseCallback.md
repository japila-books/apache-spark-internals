= RpcResponseCallback

RpcResponseCallback is the <<contract, contract>> of...FIXME

[[contract]]
[source, java]
----
package org.apache.spark.network.client;

interface RpcResponseCallback {
  void onSuccess(ByteBuffer response);
  void onFailure(Throwable e);
}
----

.RpcResponseCallback Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `onSuccess`
a| [[onSuccess]] Used when:

* `NettyBlockRpcServer` is requested to storage:NettyBlockRpcServer.md#receive[receive RPC messages] (i.e. `OpenBlocks` and `UploadBlock` messages)

* `RemoteNettyRpcCallContext` is requested to `send`

* `TransportResponseHandler` is requested to handle a `RpcResponse` message

* `AuthRpcHandler` and `SaslRpcHandler` are requested to `receive`

| `onFailure`
| [[onFailure]] Used when...FIXME
|===

[[implementations]]
.RpcResponseCallbacks
[cols="1,2",options="header",width="100%"]
|===
| RpcResponseCallback
| Description

| "Unnamed" in NettyBlockTransferService
|

| "Unnamed" in TransportRequestHandler
|

| "Unnamed" in TransportClient
|

| "Unnamed" in storage:OneForOneBlockFetcher.md[]
|

| `OneWayRpcCallback`
| [[OneWayRpcCallback]]

| `RegisterDriverCallback`
| [[RegisterDriverCallback]]

| `RpcOutboxMessage`
| [[RpcOutboxMessage]]
|===
