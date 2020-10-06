= NettyRpcEnvFactory

*NettyRpcEnvFactory* is an xref:rpc:RpcEnvFactory.adoc[] for a <<create, Netty-based RpcEnv>>.

== [[create]] Creating RpcEnv

[source,scala]
----
create(
  config: RpcEnvConfig): RpcEnv
----

create creates a JavaSerializerInstance (using a JavaSerializer).

NOTE: KryoSerializer is not supported.

create creates a xref:rpc:NettyRpcEnv.adoc[] with the JavaSerializerInstance. create uses the given xref:rpc:RpcEnvConfig.adoc[] for the xref:rpc:RpcEnvConfig.adoc#advertiseAddress[advertised address], xref:rpc:RpcEnvConfig.adoc#securityManager[SecurityManager] and xref:rpc:RpcEnvConfig.adoc#numUsableCores[number of CPU cores].

create returns the NettyRpcEnv unless the xref:rpc:RpcEnvConfig.adoc#clientMode[clientMode] is turned off (_server mode_).

In server mode, create attempts to start the NettyRpcEnv on a given port. create uses the given xref:rpc:RpcEnvConfig.adoc[] for the xref:rpc:RpcEnvConfig.adoc#port[port], xref:rpc:RpcEnvConfig.adoc#bindAddress[bind address], and xref:rpc:RpcEnvConfig.adoc#name[name]. With the port, the NettyRpcEnv is requested to xref:rpc:NettyRpcEnv.adoc#startServer[start a server].

create is part of the xref:rpc:RpcEnvFactory.adoc#create[RpcEnvFactory] abstraction.
