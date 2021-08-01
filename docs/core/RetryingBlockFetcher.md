# RetryingBlockFetcher

*RetryingBlockFetcher* is...FIXME

RetryingBlockFetcher is <<creating-instance, created>> and immediately <<start, started>> when:

* `NettyBlockTransferService` is requested to storage:NettyBlockTransferService.md#fetchBlocks[fetchBlocks] (when network:TransportConf.md#io.maxRetries[maxIORetries] is greater than `0` which it is by default)

RetryingBlockFetcher uses a <<fetchStarter, BlockFetchStarter>> to core:BlockFetchStarter.md#createAndStart[createAndStart] when requested to <<start, start>> and later <<initiateRetry, initiateRetry>>.

[[outstandingBlocksIds]]
RetryingBlockFetcher uses `outstandingBlocksIds` internal registry of outstanding block IDs to fetch that is initially the <<blockIds, block IDs to fetch>> when <<creating-instance, created>>.

At <<initiateRetry, initiateRetry>>, RetryingBlockFetcher prints out the following INFO message to the logs (with the number of <<outstandingBlocksIds, outstandingBlocksIds>>):

```
Retrying fetch ([retryCount]/[maxRetries]) for [size] outstanding blocks after [retryWaitTime] ms
```

On <<RetryingBlockFetchListener-onBlockFetchSuccess, onBlockFetchSuccess>> and <<RetryingBlockFetchListener-onBlockFetchFailure, onBlockFetchFailure>>, <<currentListener, RetryingBlockFetchListener>> removes the block ID from <<outstandingBlocksIds, outstandingBlocksIds>>.

[[currentListener]]
RetryingBlockFetcher uses a <<RetryingBlockFetchListener, RetryingBlockFetchListener>> to remove block IDs from the <<outstandingBlocksIds, outstandingBlocksIds>> internal registry.

== [[creating-instance]] Creating RetryingBlockFetcher Instance

RetryingBlockFetcher takes the following when created:

* [[conf]] network:TransportConf.md[]
* [[fetchStarter]] core:BlockFetchStarter.md[]
* [[blockIds]] Block IDs to fetch
* [[listener]] core:BlockFetchingListener.md[]

== [[start]] Starting RetryingBlockFetcher -- `start` Method

[source, java]
----
void start()
----

`start` simply <<fetchAllOutstanding, fetchAllOutstanding>>.

`start` is used when:

* `NettyBlockTransferService` is requested to storage:NettyBlockTransferService.md#fetchBlocks[fetchBlocks] (when network:TransportConf.md#io.maxRetries[maxIORetries] is greater than `0` which it is by default)

== [[initiateRetry]] `initiateRetry` Internal Method

[source, java]
----
synchronized void initiateRetry()
----

`initiateRetry`...FIXME

[NOTE]
====
`initiateRetry` is used when:

* RetryingBlockFetcher is requested to <<fetchAllOutstanding, fetchAllOutstanding>>

* `RetryingBlockFetchListener` is requested to <<RetryingBlockFetchListener-onBlockFetchFailure, onBlockFetchFailure>>
====

== [[fetchAllOutstanding]] `fetchAllOutstanding` Internal Method

[source, java]
----
void fetchAllOutstanding()
----

`fetchAllOutstanding` requests <<fetchStarter, BlockFetchStarter>> to core:BlockFetchStarter.md#createAndStart[createAndStart] for the <<outstandingBlocksIds, outstandingBlocksIds>>.

NOTE: `fetchAllOutstanding` is used when RetryingBlockFetcher is requested to <<start, start>> and <<initiateRetry, initiateRetry>>.

== [[RetryingBlockFetchListener]] RetryingBlockFetchListener

`RetryingBlockFetchListener` is a core:BlockFetchingListener.md[] that <<currentListener, RetryingBlockFetcher>> uses to remove block IDs from the <<outstandingBlocksIds, outstandingBlocksIds>> internal registry.

=== [[RetryingBlockFetchListener-onBlockFetchSuccess]] `onBlockFetchSuccess` Method

[source, scala]
----
void onBlockFetchSuccess(String blockId, ManagedBuffer data)
----

NOTE: `onBlockFetchSuccess` is part of core:BlockFetchingListener.md#onBlockFetchSuccess[BlockFetchingListener Contract].

`onBlockFetchSuccess`...FIXME

=== [[RetryingBlockFetchListener-onBlockFetchFailure]] `onBlockFetchFailure` Method

[source, scala]
----
void onBlockFetchFailure(String blockId, Throwable exception)
----

NOTE: `onBlockFetchFailure` is part of core:BlockFetchingListener.md#onBlockFetchFailure[BlockFetchingListener Contract].

`onBlockFetchFailure`...FIXME
