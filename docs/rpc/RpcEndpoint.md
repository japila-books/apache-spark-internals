# RpcEndpoint

`RpcEndpoint` is an [abstraction](#contract) of [RPC endpoints](#implementations) that are registered to an [RpcEnv](#rpcEnv) to process [one-](#receive) (_fire-and-forget_) or [two-way](#receiveAndReply) messages.

## Contract

### <span id="onConnected"> onConnected

```scala
onConnected(
  remoteAddress: RpcAddress): Unit
```

Invoked when [RpcAddress](RpcAddress.md) is connected to the current node

Used when:

* `Inbox` is requested to process a `RemoteProcessConnected` message

### <span id="onDisconnected"> onDisconnected

```scala
onDisconnected(
  remoteAddress: RpcAddress): Unit
```

Used when:

* `Inbox` is requested to process a `RemoteProcessDisconnected` message

### <span id="onError"> onError

```scala
onError(
  cause: Throwable): Unit
```

Used when:

* `Inbox` is requested to process a message that threw a `NonFatal` exception

### <span id="onNetworkError"> onNetworkError

```scala
onNetworkError(
  cause: Throwable,
  remoteAddress: RpcAddress): Unit
```

Used when:

* `Inbox` is requested to process a `RemoteProcessConnectionError` message

### <span id="onStart"> onStart

```scala
onStart(): Unit
```

Used when:

* `Inbox` is requested to process an `OnStart` message

### <span id="onStop"> onStop

```scala
onStop(): Unit
```

Used when:

* `Inbox` is requested to process an `OnStop` message

### <span id="receive"> Processing One-Way Messages

```scala
receive: PartialFunction[Any, Unit]
```

Used when:

* `Inbox` is requested to process an `OneWayMessage` message

### <span id="receiveAndReply"> Processing Two-Way Messages

```scala
receiveAndReply(
  context: RpcCallContext): PartialFunction[Any, Unit]
```

Used when:

* `Inbox` is requested to process a `RpcMessage` message

### <span id="rpcEnv"> RpcEnv

```scala
rpcEnv: RpcEnv
```

[RpcEnv](RpcEnv.md) this `RpcEndpoint` is registered to

## Implementations

* AMEndpoint
* <span id="IsolatedRpcEndpoint"> IsolatedRpcEndpoint
* [MapOutputTrackerMasterEndpoint](../scheduler/MapOutputTrackerMasterEndpoint.md)
* OutputCommitCoordinatorEndpoint
* RpcEndpointVerifier
* <span id="ThreadSafeRpcEndpoint"> ThreadSafeRpcEndpoint
* WorkerWatcher

## <span id="self"> self

```scala
self: RpcEndpointRef
```

`self` requests the [RpcEnv](#rpcEnv) for the [RpcEndpointRef](RpcEnv.md#endpointRef) of this `RpcEndpoint`.

`self` throws an `IllegalArgumentException` when the [RpcEnv](#rpcEnv) has not been initialized:

```text
rpcEnv has not been initialized
```

## <span id="stop"> Stopping RpcEndpoint

```scala
stop(): Unit
```

`stop` requests the [RpcEnv](#rpcEnv) to [stop](RpcEnv.md#stop) this [RpcEndpoint](#self)
