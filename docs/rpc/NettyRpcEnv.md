= NettyRpcEnv

*NettyRpcEnv* is an rpc:RpcEnv.md[] using https://netty.io/[Netty] (_"an asynchronous event-driven network application framework for rapid development of maintainable high performance protocol servers & clients"_).

== [[creating-instance]] Creating Instance

NettyRpcEnv takes the following to be created:

* [[conf]] ROOT:SparkConf.md[]
* [[javaSerializerInstance]] JavaSerializerInstance
* [[host]] Host name
* [[securityManager]] SecurityManager
* [[numUsableCores]] Number of CPU cores

NettyRpcEnv is created when NettyRpcEnvFactory is requested to rpc:NettyRpcEnvFactory.md#create[create an RpcEnv].

== [[streamManager]] NettyStreamManager

NettyRpcEnv creates a rpc:NettyStreamManager.md[] when <<creating-instance, created>>.

NettyStreamManager is used for the following:

* Create a NettyRpcHandler for the <<transportContext, TransportContext>>

* As the rpc:RpcEnv.md#fileServer[RpcEnvFileServer]

== [[transportContext]] TransportContext

NettyRpcEnv creates a network:TransportContext.md[].

== [[startServer]] Starting Server

[source,scala]
----
startServer(
  bindAddress: String,
  port: Int): Unit
----

startServer...FIXME

startServer is used when NettyRpcEnvFactory is requested to rpc:NettyRpcEnvFactory.md#create[create an RpcEnv] (in server mode).

== [[deserialize]] deserialize Method

[source,scala]
----
deserialize[T: ClassTag](
  client: TransportClient,
  bytes: ByteBuffer): T
----

deserialize...FIXME

deserialize is used when:

* RequestMessage utility is created

* NettyRpcEnv is requested to <<ask, ask>>
