# NettyRpcEnv

`NettyRpcEnv` is an [RpcEnv](RpcEnv.md) that uses [Netty](https://netty.io/) (_"an asynchronous event-driven network application framework for rapid development of maintainable high performance protocol servers & clients"_).

## Creating Instance

`NettyRpcEnv` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="javaSerializerInstance"> [JavaSerializerInstance](../serializer/JavaSerializerInstance.md)
* <span id="host"> Host Name
* <span id="securityManager"> `SecurityManager`
* <span id="numUsableCores"> Number of CPU Cores

`NettyRpcEnv` is created when:

* `NettyRpcEnvFactory` is requested to [create an RpcEnv](NettyRpcEnvFactory.md#create)
