= ExternalShuffleClient

*ExternalShuffleClient* is a xref:storage:ShuffleClient.adoc[] that...FIXME

== [[init]] Initializing ExternalShuffleClient

[source,java]
----
void init(
  String appId)
----

init...FIXME

init is part of the xref:storage:ShuffleClient.adoc#init[ShuffleClient] abstraction.

== [[registerWithShuffleServer]] Register Block Manager with Shuffle Server

[source, java]
----
void registerWithShuffleServer(
  String host,
  int port,
  String execId,
  ExecutorShuffleInfo executorInfo)
----

registerWithShuffleServer...FIXME

registerWithShuffleServer is used when...FIXME

== [[fetchBlocks]] Fetching Blocks

[source, java]
----
void fetchBlocks(
  String host,
  int port,
  String execId,
  String[] blockIds,
  BlockFetchingListener listener,
  TempFileManager tempFileManager)
----

fetchBlocks...FIXME

fetchBlocks is part of xref:storage:ShuffleClient.adoc#fetchBlocks[ShuffleClient] abstraction.
