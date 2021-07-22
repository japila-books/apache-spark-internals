# RpcEnv

`RpcEnv` is an [abstraction](#contract) of [RPC environments](#implementations).

## Contract

### <span id="address"> address

```scala
address: RpcAddress
```

[RpcAddress](RpcAddress.md) of this RPC environments

### <span id="asyncSetupEndpointRefByURI"> asyncSetupEndpointRefByURI

```scala
asyncSetupEndpointRefByURI(
  uri: String): Future[RpcEndpointRef]
```

Looking up a [RpcEndpointRef](RpcEndpointRef.md) of the RPC endpoint by URI (asynchronously)

Used when:

* `WorkerWatcher` is created
* `CoarseGrainedExecutorBackend` is requested to [onStart](../executor/CoarseGrainedExecutorBackend.md#onStart)
* `RpcEnv` is requested to [setupEndpointRefByURI](#setupEndpointRefByURI)

### <span id="awaitTermination"> awaitTermination

```scala
awaitTermination(): Unit
```

Blocks the current thread till the RPC environment terminates

Used when:

* `SparkEnv` is requested to [stop](../SparkEnv.md#stop)
* `ClientApp` is requested to [start](../spark-standalone/ClientApp.md#start)
* `LocalSparkCluster` is requested to [stop](../spark-standalone/LocalSparkCluster.md#stop)
* [Master](../spark-standalone/Master.md) and [Worker](../spark-standalone/Worker.md) are launched
* `CoarseGrainedExecutorBackend` is requested to [run](../executor/CoarseGrainedExecutorBackend.md#run)

### <span id="deserialize"> deserialize

```scala
deserialize[T](
  deserializationAction: () => T): T
```

Used when:

* `PersistenceEngine` is requested to `readPersistedData`
* `NettyRpcEnv` is requested to [deserialize](NettyRpcEnv.md#deserialize)

### <span id="endpointRef"> endpointRef

```scala
endpointRef(
  endpoint: RpcEndpoint): RpcEndpointRef
```

Used when:

* `RpcEndpoint` is requested for the [RpcEndpointRef to itself](RpcEndpoint.md#self)

### <span id="fileServer"> RpcEnvFileServer

```scala
fileServer: RpcEnvFileServer
```

[RpcEnvFileServer](RpcEnvFileServer.md) of this RPC environment

Used when:

* `SparkContext` is requested to [addFile](../SparkContext.md#addFile), [addJar](../SparkContext.md#addJar) and is [created](../SparkContext-creating-instance-internals.md#spark.repl.class.outputDir) (and registers the REPL's output directory)

### <span id="openChannel"> openChannel

```scala
openChannel(
  uri: String): ReadableByteChannel
```

Opens a channel to download a file at the given URI

Used when:

* `Utils` utility is used to [doFetchFile](../Utils.md#doFetchFile)
* `ExecutorClassLoader` is requested to `getClassFileInputStreamFromSparkRPC`

### <span id="setupEndpoint"> setupEndpoint

```scala
setupEndpoint(
  name: String,
  endpoint: RpcEndpoint): RpcEndpointRef
```

### <span id="shutdown"> shutdown

```scala
shutdown(): Unit
```

Shuts down this RPC environment asynchronously (and to make sure this `RpcEnv` exits successfully, use [awaitTermination](#awaitTermination))

Used when:

* `SparkEnv` is requested to [stop](../SparkEnv.md#stop)
* `LocalSparkCluster` is requested to [stop](../spark-standalone/LocalSparkCluster.md#stop)
* `DriverWrapper` is launched
* `CoarseGrainedExecutorBackend` is [launched](../executor/CoarseGrainedExecutorBackend.md#run)
* `NettyRpcEnvFactory` is requested to [create an RpcEnv](NettyRpcEnvFactory.md#create) (in server mode and failed to assign a port)

### <span id="stop"> Stopping RpcEndpointRef

```scala
stop(
  endpoint: RpcEndpointRef): Unit
```

Used when:

* `SparkContext` is requested to [stop](../SparkContext.md#stop)
* `RpcEndpoint` is requested to [stop](RpcEndpoint.md#stop)
* `BlockManager` is requested to [stop](../storage/BlockManager.md#stop)
* _in Spark SQL_

## Implementations

* [NettyRpcEnv](NettyRpcEnv.md)

## Creating Instance

`RpcEnv` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)

`RpcEnv` is created using [RpcEnv.create](#create) utility.

??? note "Abstract Class"
    `RpcEnv` is an abstract class and cannot be created directly. It is created indirectly for the [concrete RpcEnvs](#implementations).

## <span id="create"> Creating RpcEnv

```scala
create(
  name: String,
  host: String,
  port: Int,
  conf: SparkConf,
  securityManager: SecurityManager,
  clientMode: Boolean = false): RpcEnv // (1)
create(
  name: String,
  bindAddress: String,
  advertiseAddress: String,
  port: Int,
  conf: SparkConf,
  securityManager: SecurityManager,
  numUsableCores: Int,
  clientMode: Boolean): RpcEnv
```

1. Uses `0` for `numUsableCores`

`create` creates a [NettyRpcEnvFactory](NettyRpcEnvFactory.md) and requests it to [create an RpcEnv](NettyRpcEnvFactory.md#create) (with a new [RpcEnvConfig](RpcEnvConfig.md) with all the given arguments).

`create` is used when:

* `SparkEnv` utility is requested to [create a SparkEnv](../SparkEnv.md#create) (`clientMode` flag is turned on for executors and off for the driver)
* With `clientMode` flag `true`:

    * `CoarseGrainedExecutorBackend` is requested to [run](../executor/CoarseGrainedExecutorBackend.md#run)
    * `ClientApp` is requested to [start](../spark-standalone/ClientApp.md)
    * Spark Standalone's `Master` is requested to [startRpcEnvAndEndpoint](../spark-standalone/Master.md#startRpcEnvAndEndpoint)
    * Spark Standalone's `Worker` is requested to [startRpcEnvAndEndpoint](../spark-standalone/Worker.md#startRpcEnvAndEndpoint)
    * `DriverWrapper` is launched
    * `ApplicationMaster` (Spark on YARN) is requested to `runExecutorLauncher` (in client deploy mode)

## <span id="defaultLookupTimeout"> Default Endpoint Lookup Timeout

`RpcEnv` uses the default lookup timeout for...FIXME

When a remote endpoint is resolved, a local RPC environment connects to the remote one (**endpoint lookup**). To configure the time needed for the endpoint lookup you can use the following settings.

It is a prioritized list of **lookup timeout** properties (the higher on the list, the more important):

* [spark.rpc.lookupTimeout](../configuration-properties.md#spark.rpc.lookupTimeout)
* [spark.network.timeout](#spark.network.timeout)
