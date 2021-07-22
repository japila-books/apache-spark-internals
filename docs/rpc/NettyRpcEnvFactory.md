# NettyRpcEnvFactory

`NettyRpcEnvFactory` is an [RpcEnvFactory](RpcEnvFactory.md) for a [Netty-based RpcEnv](#create).

## <span id="create"> Creating RpcEnv

```scala
create(
  config: RpcEnvConfig): RpcEnv
```

`create` creates a [JavaSerializerInstance](../serializer/JavaSerializerInstance.md) (using a JavaSerializer).

!!! note
    `KryoSerializer` is not supported.

create creates a rpc:NettyRpcEnv.md[] with the JavaSerializerInstance. create uses the given rpc:RpcEnvConfig.md[] for the rpc:RpcEnvConfig.md#advertiseAddress[advertised address], rpc:RpcEnvConfig.md#securityManager[SecurityManager] and rpc:RpcEnvConfig.md#numUsableCores[number of CPU cores].

create returns the NettyRpcEnv unless the rpc:RpcEnvConfig.md#clientMode[clientMode] is turned off (_server mode_).

In server mode, create attempts to start the NettyRpcEnv on a given port. create uses the given rpc:RpcEnvConfig.md[] for the rpc:RpcEnvConfig.md#port[port], rpc:RpcEnvConfig.md#bindAddress[bind address], and rpc:RpcEnvConfig.md#name[name]. With the port, the NettyRpcEnv is requested to rpc:NettyRpcEnv.md#startServer[start a server].

create is part of the rpc:RpcEnvFactory.md#create[RpcEnvFactory] abstraction.
