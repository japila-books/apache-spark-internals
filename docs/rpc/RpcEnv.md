# RpcEnv

RpcEnv is an <<contract, abstraction>> of <<implementations, RPC systems>>.

== [[implementations]] Available RpcEnvs

rpc:NettyRpcEnv.md[] is the default and only known RpcEnv in Apache Spark.

== [[contract]] Contract

=== [[address]] address Method

[source,scala]
----
address: RpcAddress
----

rpc:RpcAddress.md[] of the RPC system

=== [[asyncSetupEndpointRefByURI]] asyncSetupEndpointRefByURI Method

[source,scala]
----
asyncSetupEndpointRefByURI(
  uri: String): Future[RpcEndpointRef]
----

Sets up an RPC endpoing by URI (asynchronously) and returns rpc:RpcEndpointRef.md[]

Used when:

* WorkerWatcher is created

* CoarseGrainedExecutorBackend is requested to executor:CoarseGrainedExecutorBackend.md#onStart[onStart]

* RpcEnv is requested to <<setupEndpointRefByURI, setupEndpointRefByURI>>

=== [[awaitTermination]] awaitTermination Method

[source,scala]
----
awaitTermination(): Unit
----

Waits till the RPC system terminates

Used when:

* SparkEnv is requested to core:SparkEnv.md#stop[stop]

* ClientApp is requested to start

* LocalSparkCluster is requested to stop

* (Spark Standalone) Master and Worker are launched

* CoarseGrainedExecutorBackend standalone application is launched

=== [[deserialize]] deserialize Method

[source,scala]
----
deserialize[T](
  deserializationAction: () => T): T
----

Used when:

* PersistenceEngine is requested to readPersistedData

* NettyRpcEnv is requested to rpc:NettyRpcEnv.md#deserialize[deserialize]

=== [[endpointRef]] endpointRef Method

[source,scala]
----
endpointRef(
  endpoint: RpcEndpoint): RpcEndpointRef
----

Used when RpcEndpoint is requested for the rpc:RpcEndpoint.md#self[RpcEndpointRef to itself]

=== [[fileServer]] RpcEnvFileServer

[source,scala]
----
fileServer: RpcEnvFileServer
----

rpc:RpcEnvFileServer.md[] of the RPC system

Used when SparkContext.md[] is created (and registers the REPL's output directory) and requested to SparkContext.md#addFile[addFile] or SparkContext.md#addJar[addJar]

=== [[openChannel]] openChannel Method

[source,scala]
----
openChannel(
  uri: String): ReadableByteChannel
----

Opens a channel to download a file from the given URI

Used when:

* Utils utility is used to doFetchFile

* ExecutorClassLoader is requested to getClassFileInputStreamFromSparkRPC

## <span id="setupEndpoint"> setupEndpoint

```scala
setupEndpoint(
  name: String,
  endpoint: RpcEndpoint): RpcEndpointRef
```

Used when:

* [SparkContext](../SparkContext.md) is created

* SparkEnv utility is used to core:SparkEnv.md#create[create a SparkEnv] (and register the BlockManagerMaster, MapOutputTracker and OutputCommitCoordinator RPC endpoints on the driver)

* ClientApp is requested to start (and register the client RPC endpoint)

* StandaloneAppClient is requested to start (and register the AppClient RPC endpoint)

* (Spark Standalone) Master is requested to startRpcEnvAndEndpoint (and register the Master RPC endpoint)

* (Spark Standalone) Worker is requested to startRpcEnvAndEndpoint (and register the Worker RPC endpoint)

* DriverWrapper standalone application is launched (and registers the workerWatcher RPC endpoint)

* CoarseGrainedExecutorBackend standalone application is launched (and registers the Executor and WorkerWatcher RPC endpoints)

* TaskSchedulerImpl is requested to scheduler:TaskSchedulerImpl.md#maybeInitBarrierCoordinator[maybeInitBarrierCoordinator]

* CoarseGrainedSchedulerBackend is requested to scheduler:CoarseGrainedSchedulerBackend.md#createDriverEndpointRef[createDriverEndpointRef] (and registers the CoarseGrainedScheduler RPC endpoint)

* LocalSchedulerBackend is requested to spark-local:spark-LocalSchedulerBackend.md#start[start] (and registers the LocalSchedulerBackendEndpoint RPC endpoint)

* storage:BlockManager.md#slaveEndpoint[BlockManager] is created (and registers the BlockManagerEndpoint RPC endpoint)

* (Spark on YARN) ApplicationMaster is requested to spark-on-yarn:spark-yarn-applicationmaster.md#createAllocator[createAllocator] (and registers the YarnAM RPC endpoint)

* (Spark on YARN) spark-on-yarn:spark-yarn-yarnschedulerbackend.md#yarnSchedulerEndpointRef[YarnSchedulerBackend] is created (and registers the YarnScheduler RPC endpoint)

=== [[setupEndpointRef]] setupEndpointRef Method

[source,scala]
----
setupEndpointRef(
  address: RpcAddress,
  endpointName: String): RpcEndpointRef
----

setupEndpointRef creates an RpcEndpointAddress (for the given rpc:RpcAddress.md[] and endpoint name) and <<setupEndpointRefByURI, setupEndpointRefByURI>>.

setupEndpointRef is used when:

* ClientApp is requested to start

* ClientEndpoint is requested to tryRegisterAllMasters

* Worker is requested to tryRegisterAllMasters and reregisterWithMaster

* RpcUtils utility is used to rpc:RpcUtils.md#makeDriverRef[makeDriverRef]

* (Spark on YARN) ApplicationMaster is requested to spark-on-yarn:spark-yarn-applicationmaster.md#runDriver[runDriver] and spark-on-yarn:spark-yarn-applicationmaster.md#runExecutorLauncher[runExecutorLauncher]

=== [[setupEndpointRefByURI]] setupEndpointRefByURI Method

[source,scala]
----
setupEndpointRefByURI(
  uri: String): RpcEndpointRef
----

setupEndpointRefByURI <<asyncSetupEndpointRefByURI, asyncSetupEndpointRefByURI>> by the given URI and waits for the result or <<defaultLookupTimeout, defaultLookupTimeout>>.

setupEndpointRefByURI is used when:

* CoarseGrainedExecutorBackend standalone application is executor:CoarseGrainedExecutorBackend.md#run[launched]

* RpcEnv is requested to <<setupEndpointRef, setupEndpointRef>>

=== [[shutdown]] shutdown Method

[source,scala]
----
shutdown(): Unit
----

Shuts down the RPC system

Used when:

* SparkEnv is requested to core:SparkEnv.md#stop[stop]

* LocalSparkCluster is requested to spark-standalone:spark-standalone-LocalSparkCluster.md#stop[stop]

* DriverWrapper is launched

* CoarseGrainedExecutorBackend is executor:CoarseGrainedExecutorBackend.md#run[launched]

* NettyRpcEnvFactory is requested to rpc:NettyRpcEnvFactory.md#create[create an RpcEnv] (in server mode and failed to assign a port)

=== [[stop]] Stopping RpcEndpointRef

[source,scala]
----
stop(
  endpoint: RpcEndpointRef): Unit
----

Used when:

* SparkContext is requested to SparkContext.md#stop[stop]

* RpcEndpoint is requested to rpc:RpcEndpoint.md#stop[stop]

* BlockManager is requested to storage:BlockManager.md#stop[stop]

== [[defaultLookupTimeout]] Default Endpoint Lookup Timeout

RpcEnv uses the default lookup timeout for...FIXME

When a remote endpoint is resolved, a local RPC environment connects to the remote one. It is called *endpoint lookup*. To configure the time needed for the endpoint lookup you can use the following settings.

It is a prioritized list of *lookup timeout* properties (the higher on the list, the more important):

* configuration-properties.md#spark.rpc.lookupTimeout[spark.rpc.lookupTimeout]
* <<spark.network.timeout, spark.network.timeout>>

Their value can be a number alone (seconds) or any number with time suffix, e.g. `50s`, `100ms`, or `250us`. See <<settings, Settings>>.

== [[creating-instance]] Creating Instance

RpcEnv takes the following to be created:

* [[conf]] SparkConf.md[]

RpcEnv is created using <<create, RpcEnv.create>> utility.

RpcEnv is an abstract class and cannot be created directly. It is created indirectly for the <<implementations, concrete RpcEnvs>>.

== [[create]] Creating RpcEnv

[source,scala]
----
create(
  name: String,
  host: String,
  port: Int,
  conf: SparkConf,
  securityManager: SecurityManager,
  clientMode: Boolean = false): RpcEnv // <1>
create(
  name: String,
  bindAddress: String,
  advertiseAddress: String,
  port: Int,
  conf: SparkConf,
  securityManager: SecurityManager,
  numUsableCores: Int,
  clientMode: Boolean): RpcEnv
----
<1> Uses 0 for numUsableCores

create creates a rpc:NettyRpcEnvFactory.md[] and requests to rpc:NettyRpcEnvFactory.md#create[create an RpcEnv] (with an rpc:RpcEnvConfig.md[] with all the given arguments).

create is used when:

* SparkEnv utility is requested to core:SparkEnv.md#create[create a SparkEnv] (clientMode flag is turned on for executors and off for the driver)

* With clientMode flag turned on:

** (Spark on YARN) ApplicationMaster is requested to spark-on-yarn:spark-yarn-applicationmaster.md#runExecutorLauncher[runExecutorLauncher] (in client deploy mode with clientMode flag is turned on)

** ClientApp is requested to start

** (Spark Standalone) Master is requested to startRpcEnvAndEndpoint

** DriverWrapper standalone application is launched

** (Spark Standalone) Worker is requested to startRpcEnvAndEndpoint

** CoarseGrainedExecutorBackend is requested to executor:CoarseGrainedExecutorBackend.md#run[run]
