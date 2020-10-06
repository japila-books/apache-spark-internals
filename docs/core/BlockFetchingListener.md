= BlockFetchingListener

*BlockFetchingListener* is the <<contract, contract>> of <<implementations, EventListeners>> that want to be notified about <<onBlockFetchSuccess, onBlockFetchSuccess>> and <<onBlockFetchFailure, onBlockFetchFailure>>.

BlockFetchingListener is used when:

* storage:ShuffleClient.md#fetchBlocks[ShuffleClient], storage:BlockTransferService.md#fetchBlocks[BlockTransferService], storage:NettyBlockTransferService.md#fetchBlocks[NettyBlockTransferService], and storage:ExternalShuffleClient.md#fetchBlocks[ExternalShuffleClient] are requested to fetch a sequence of blocks

* `BlockFetchStarter` is requested to core:BlockFetchStarter.md#createAndStart[createAndStart]

* core:RetryingBlockFetcher.md[] and storage:OneForOneBlockFetcher.md[] are created

[[contract]]
[source, java]
----
package org.apache.spark.network.shuffle;

interface BlockFetchingListener extends EventListener {
  void onBlockFetchSuccess(String blockId, ManagedBuffer data);
  void onBlockFetchFailure(String blockId, Throwable exception);
}
----

.BlockFetchingListener Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `onBlockFetchSuccess`
| [[onBlockFetchSuccess]] Used when...FIXME

| `onBlockFetchFailure`
| [[onBlockFetchFailure]] Used when...FIXME
|===

[[implementations]]
.BlockFetchingListeners
[cols="1,2",options="header",width="100%"]
|===
| BlockFetchingListener
| Description

| core:RetryingBlockFetcher.md#RetryingBlockFetchListener[RetryingBlockFetchListener]
| [[RetryingBlockFetchListener]]

| "Unnamed" in storage:ShuffleBlockFetcherIterator.md#sendRequest[ShuffleBlockFetcherIterator]
| [[ShuffleBlockFetcherIterator]]

| "Unnamed" in storage:BlockTransferService.md#fetchBlockSync[BlockTransferService]
| [[BlockTransferService]]
|===
