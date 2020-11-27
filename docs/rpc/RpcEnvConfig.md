= RpcEnvConfig
:page-toclevels: -1

[[creating-instance]]
*RpcEnvConfig* is a configuration of an rpc:RpcEnv.md[]:

* [[conf]] SparkConf.md[]
* [[name]] System Name
* [[bindAddress]] Bind Address
* [[advertiseAddress]] Advertised Address
* [[port]] Port
* [[securityManager]] SecurityManager
* [[numUsableCores]] Number of CPU cores
* <<clientMode, clientMode flag>>

RpcEnvConfig is created when RpcEnv utility is used to rpc:RpcEnv.md#create[create an RpcEnv] (using rpc:RpcEnvFactory.md[]).

== [[clientMode]] Client Mode

When an RPC Environment is initialized core:SparkEnv.md#createDriverEnv[as part of the initialization of the driver] or core:SparkEnv.md#createExecutorEnv[executors] (using `RpcEnv.create`), `clientMode` is `false` for the driver and `true` for executors.

Copied (almost verbatim) from https://issues.apache.org/jira/browse/SPARK-10997[SPARK-10997 Netty-based RPC env should support a "client-only" mode] and the https://github.com/apache/spark/commit/71d1c907dec446db566b19f912159fd8f46deb7d[commit]:

"Client mode" means the RPC env will not listen for incoming connections.

This allows certain processes in the Spark stack (such as Executors or tha YARN client-mode AM) to act as pure clients when using the netty-based RPC backend, reducing the number of sockets Spark apps need to use and also the number of open ports.

The AM connects to the driver in "client mode", and that connection is used for all driver -- AM communication, and so the AM is properly notified when the connection goes down.

In "general", non-YARN case, `clientMode` flag is therefore enabled for executors and disabled for the driver.

In Spark on YARN in spark-deploy-mode.md#client[`client` deploy mode], `clientMode` flag is however enabled explicitly when Spark on YARN's spark-yarn-applicationmaster.md#runExecutorLauncher-sparkYarnAM[ApplicationMaster] creates the `sparkYarnAM` RPC Environment.
