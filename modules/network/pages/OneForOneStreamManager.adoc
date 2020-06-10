= OneForOneStreamManager

*OneForOneStreamManager* is a xref:network:StreamManager.adoc[].

== [[creating-instance]] Creating Instance

OneForOneStreamManager takes no arguments to be created.

OneForOneStreamManager is created for xref:deploy:ExternalShuffleBlockHandler.adoc[] and xref:storage:ExternalShuffleClient.adoc[ExternalShuffleClient] (indirectly via NoOpRpcHandler).

== [[registerStream]] registerStream Method

[source,java]
----
long registerStream(
  String appId,
  Iterator<ManagedBuffer> buffers)
----

registerStream...FIXME

registerStream is used when...FIXME
