= RpcEndpoint

RpcEndpoint is a <<contract, contract>> to define an RPC endpoint that can <<receive, receive>> *messages* using *callbacks*, i.e. *functions* to execute when a message arrives.

RpcEndpoint defines how to handle *messages* (what *functions* to execute given a message). RpcEndpoints register (with a name or uri) to `RpcEnv` to receive messages from rpc:RpcEndpointRef.md[RpcEndpointRefs].

[[contract]]
[source, scala]
----
package org.apache.spark.rpc

trait RpcEndpoint {
  def onConnected(remoteAddress: RpcAddress): Unit
  def onDisconnected(remoteAddress: RpcAddress): Unit
  def onError(cause: Throwable): Unit
  def onNetworkError(cause: Throwable, remoteAddress: RpcAddress): Unit
  def onStart(): Unit
  def onStop(): Unit
  def receive: PartialFunction[Any, Unit]
  def receiveAndReply(context: RpcCallContext): PartialFunction[Any, Unit]
  val rpcEnv: RpcEnv
}
----

RpcEndpoint lives in rpc:index.md[RpcEnv] after being registered by a name.

A RpcEndpoint can be registered to one and only one RpcEnv.

The lifecycle of a RpcEndpoint is `onStart`, `receive` and `onStop` in sequence.

`receive` can be called concurrently.

TIP: If you want `receive` to be thread-safe, use <<ThreadSafeRpcEndpoint, ThreadSafeRpcEndpoint>>.

`onError` method is called for any exception thrown.

.RpcEndpoint Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| [[receive]] `receive`
| Receives and processes a message
|===

NOTE: RpcEndpoint is a `private[spark]` contract.

== [[onStart]] Activating RPC Endpoint (Just Before Handling Messages)

CAUTION: FIXME

== [[stop]] Stopping RpcEndpoint

CAUTION: FIXME

== [[ThreadSafeRpcEndpoint]] ThreadSafeRpcEndpoint

ThreadSafeRpcEndpoint is an RpcEndpoint for endpoints that...FIXME
