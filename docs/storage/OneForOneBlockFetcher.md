= OneForOneBlockFetcher

*OneForOneBlockFetcher* is...FIXME

== [[creating-instance]] Creating Instance

OneForOneBlockFetcher takes the following to be created:

* [[client]] TransportClient
* [[appId]] Application ID
* [[execId]] Executor ID
* [[blockIds]] Block IDs
* [[listener]] core:BlockFetchingListener.md[]
* [[transportConf]] network:TransportConf.md[]
* [[downloadFileManager]] DownloadFileManager

OneForOneBlockFetcher is created when storage:NettyBlockTransferService.md#fetchBlocks[NettyBlockTransferService] and storage:ExternalShuffleClient.md#fetchBlocks[ExternalShuffleClient] are requested to fetch blocks.

== [[openMessage]] OpenBlocks Message

OneForOneBlockFetcher creates a OpenBlocks message (for the given <<appId, application>>, <<execId, executor>> and <<blockIds, blocks>>) when <<creating-instance, created>>.

The OpenBlocks message is posted when OneForOneBlockFetcher is requested to <<start, start>>.

== [[start]] start Method

[source,java]
----
void start()
----

start...FIXME

start is used when storage:NettyBlockTransferService.md#fetchBlocks[NettyBlockTransferService] and storage:ExternalShuffleClient.md#fetchBlocks[ExternalShuffleClient] are requested to fetch blocks.
