= NettyStreamManager

*NettyStreamManager* is a xref:network:StreamManager.adoc[].

== [[creating-instance]] Creating Instance

NettyStreamManager takes the following to be created:

* [[rpcEnv]] xref:rpc:NettyRpcEnv.adoc[]

NettyStreamManager is created for xref:rpc:NettyRpcEnv.adoc#streamManager[NettyRpcEnv].

== [[registerStream]] registerStream Method

[source,java]
----
long registerStream(
  String appId,
  Iterator<ManagedBuffer> buffers)
----

registerStream...FIXME

registerStream is used when...FIXME
