= TransportClientFactory

*TransportClientFactory* is...FIXME

== [[createUnmanagedClient]] `createUnmanagedClient` Method

[source, java]
----
TransportClient createUnmanagedClient(String remoteHost, int remotePort)
  throws IOException, InterruptedException
----

`createUnmanagedClient`...FIXME

NOTE: `createUnmanagedClient` is used when...FIXME

== [[createClient]] `createClient` Internal Method

[source, java]
----
TransportClient createClient(String remoteHost, int remotePort)
  throws IOException, InterruptedException
TransportClient createClient(InetSocketAddress address)
  throws IOException, InterruptedException
----

`createClient`...FIXME

`createClient` is used when:

* `NettyBlockTransferService` is requested to storage:NettyBlockTransferService.md#fetchBlocks[fetchBlocks] and storage:NettyBlockTransferService.md#uploadBlock[uploadBlock]

* `NettyRpcEnv` is requested to `createClient` and `downloadClient`

* TransportClientFactory is requested to <<createUnmanagedClient, createUnmanagedClient>>.
