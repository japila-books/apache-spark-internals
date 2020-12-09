# KubernetesDriverEndpoint

`KubernetesDriverEndpoint` is a [DriverEndpoint](../scheduler/DriverEndpoint.md).

## <span id="onDisconnected"> Intercepting Executor Lost Event

```scala
onDisconnected(
  rpcAddress: RpcAddress): Unit
```

`onDisconnected` is part of the [RpcEndpoint](../rpc/RpcEndpoint.md#onDisconnected) abstraction.

`onDisconnected` [disables the executor](../scheduler/DriverEndpoint.md#disableExecutor) known by the [RpcAddress](../rpc/RpcAddress.md) (found in the [Executors by RpcAddress Registry](../scheduler/DriverEndpoint.md#addressToExecutorId) registry).
