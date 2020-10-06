= NettyRpcEnv

*NettyRpcEnv* is an xref:rpc:RpcEnv.adoc[] using https://netty.io/[Netty] (_"an asynchronous event-driven network application framework for rapid development of maintainable high performance protocol servers & clients"_).

== [[creating-instance]] Creating Instance

NettyRpcEnv takes the following to be created:

* [[conf]] xref:ROOT:SparkConf.adoc[]
* [[javaSerializerInstance]] JavaSerializerInstance
* [[host]] Host name
* [[securityManager]] SecurityManager
* [[numUsableCores]] Number of CPU cores

NettyRpcEnv is created when NettyRpcEnvFactory is requested to xref:rpc:NettyRpcEnvFactory.adoc#create[create an RpcEnv].

== [[streamManager]] NettyStreamManager

NettyRpcEnv creates a xref:rpc:NettyStreamManager.adoc[] when <<creating-instance, created>>.

NettyStreamManager is used for the following:

* Create a NettyRpcHandler for the <<transportContext, TransportContext>>

* As the xref:rpc:RpcEnv.adoc#fileServer[RpcEnvFileServer]

== [[transportContext]] TransportContext

NettyRpcEnv creates a xref:network:TransportContext.adoc[].

== [[startServer]] Starting Server

[source,scala]
----
startServer(
  bindAddress: String,
  port: Int): Unit
----

startServer...FIXME

startServer is used when NettyRpcEnvFactory is requested to xref:rpc:NettyRpcEnvFactory.adoc#create[create an RpcEnv] (in server mode).

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
