= OneForOneBlockFetcher

*OneForOneBlockFetcher* is...FIXME

== [[creating-instance]] Creating Instance

OneForOneBlockFetcher takes the following to be created:

* [[client]] TransportClient
* [[appId]] Application ID
* [[execId]] Executor ID
* [[blockIds]] Block IDs
* [[listener]] xref:core:BlockFetchingListener.adoc[]
* [[transportConf]] xref:network:TransportConf.adoc[]
* [[downloadFileManager]] DownloadFileManager

OneForOneBlockFetcher is created when xref:storage:NettyBlockTransferService.adoc#fetchBlocks[NettyBlockTransferService] and xref:storage:ExternalShuffleClient.adoc#fetchBlocks[ExternalShuffleClient] are requested to fetch blocks.

== [[openMessage]] OpenBlocks Message

OneForOneBlockFetcher creates a OpenBlocks message (for the given <<appId, application>>, <<execId, executor>> and <<blockIds, blocks>>) when <<creating-instance, created>>.

The OpenBlocks message is posted when OneForOneBlockFetcher is requested to <<start, start>>.

== [[start]] start Method

[source,java]
----
void start()
----

start...FIXME

start is used when xref:storage:NettyBlockTransferService.adoc#fetchBlocks[NettyBlockTransferService] and xref:storage:ExternalShuffleClient.adoc#fetchBlocks[ExternalShuffleClient] are requested to fetch blocks.
