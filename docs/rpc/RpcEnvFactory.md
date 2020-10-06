= RpcEnvFactory

RpcEnvFactory is an abstraction of <<implementations, factories>> to <<create, create RpcEnvs>>.

== [[implementations]] Available RpcEnvFactories

xref:rpc:NettyRpcEnvFactory.adoc[] is the default and only known RpcEnvFactory in Apache Spark (as of https://github.com/apache/spark/commit/4f5a24d7e73104771f233af041eeba4f41675974[this commit]).

== [[create]] Creating RpcEnv

[source,scala]
----
create(
  config: RpcEnvConfig): RpcEnv
----

create is used when RpcEnv utility is requested to xref:rpc:RpcEnv.adoc#create[create an RpcEnv].
