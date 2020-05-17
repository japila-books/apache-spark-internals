= RpcEnvConfig
:page-toclevels: -1

[[creating-instance]]
*RpcEnvConfig* is a configuration of an xref:rpc:RpcEnv.adoc[]:

* [[conf]] xref:ROOT:SparkConf.adoc[]
* [[name]] System Name
* [[bindAddress]] Bind Address
* [[advertiseAddress]] Advertised Address
* [[port]] Port
* [[securityManager]] SecurityManager
* [[numUsableCores]] Number of CPU cores
* <<clientMode, clientMode flag>>

RpcEnvConfig is created when RpcEnv utility is used to xref:rpc:RpcEnv.adoc#create[create an RpcEnv] (using xref:rpc:RpcEnvFactory.adoc[]).

== [[clientMode]] Client Mode

When an RPC Environment is initialized xref:core:SparkEnv.adoc#createDriverEnv[as part of the initialization of the driver] or xref:core:SparkEnv.adoc#createExecutorEnv[executors] (using `RpcEnv.create`), `clientMode` is `false` for the driver and `true` for executors.

Copied (almost verbatim) from https://issues.apache.org/jira/browse/SPARK-10997[SPARK-10997 Netty-based RPC env should support a "client-only" mode] and the link:https://github.com/apache/spark/commit/71d1c907dec446db566b19f912159fd8f46deb7d[commit]:

"Client mode" means the RPC env will not listen for incoming connections.

This allows certain processes in the Spark stack (such as Executors or tha YARN client-mode AM) to act as pure clients when using the netty-based RPC backend, reducing the number of sockets Spark apps need to use and also the number of open ports.

The AM connects to the driver in "client mode", and that connection is used for all driver -- AM communication, and so the AM is properly notified when the connection goes down.

In "general", non-YARN case, `clientMode` flag is therefore enabled for executors and disabled for the driver.

In Spark on YARN in link:spark-deploy-mode.adoc#client[`client` deploy mode], `clientMode` flag is however enabled explicitly when Spark on YARN's link:spark-yarn-applicationmaster.adoc#runExecutorLauncher-sparkYarnAM[ApplicationMaster] creates the `sparkYarnAM` RPC Environment.
