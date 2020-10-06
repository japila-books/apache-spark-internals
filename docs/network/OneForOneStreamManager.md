= OneForOneStreamManager

*OneForOneStreamManager* is a network:StreamManager.md[].

== [[creating-instance]] Creating Instance

OneForOneStreamManager takes no arguments to be created.

OneForOneStreamManager is created for deploy:ExternalShuffleBlockHandler.md[] and storage:ExternalShuffleClient.md[ExternalShuffleClient] (indirectly via NoOpRpcHandler).

== [[registerStream]] registerStream Method

[source,java]
----
long registerStream(
  String appId,
  Iterator<ManagedBuffer> buffers)
----

registerStream...FIXME

registerStream is used when...FIXME
