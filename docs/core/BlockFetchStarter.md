# BlockFetchStarter

*BlockFetchStarter* is the <<contract, contract>> of...FIXME...to <<createAndStart, createAndStart>>.

[[contract]]
[[createAndStart]]
[source, java]
----
void createAndStart(String[] blockIds, BlockFetchingListener listener)
   throws IOException, InterruptedException;
----

`createAndStart` is used when:

* `NettyBlockTransferService` is requested to storage:NettyBlockTransferService.md#fetchBlocks[fetchBlocks] (when network:TransportConf.md#io.maxRetries[maxIORetries] is `0`)

* `RetryingBlockFetcher` is requested to core:RetryingBlockFetcher.md#fetchAllOutstanding[fetchAllOutstanding]
