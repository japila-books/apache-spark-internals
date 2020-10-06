= NettyStreamManager

*NettyStreamManager* is a network:StreamManager.md[].

== [[creating-instance]] Creating Instance

NettyStreamManager takes the following to be created:

* [[rpcEnv]] rpc:NettyRpcEnv.md[]

NettyStreamManager is created for rpc:NettyRpcEnv.md#streamManager[NettyRpcEnv].

== [[registerStream]] registerStream Method

[source,java]
----
long registerStream(
  String appId,
  Iterator<ManagedBuffer> buffers)
----

registerStream...FIXME

registerStream is used when...FIXME
