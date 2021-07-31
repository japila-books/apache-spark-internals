# BlockFetchingListener

`BlockFetchingListener` is an [extension](#contract) of the `EventListener` ([Java]({{ java.api }}/java.base/java/util/EventListener.html)) abstraction that want to be notified about [block fetch success](#onBlockFetchSuccess) and [failures](#onBlockFetchFailure).

`BlockFetchingListener` is used to create a [OneForOneBlockFetcher](../storage/OneForOneBlockFetcher.md), `OneForOneBlockPusher` and [RetryingBlockFetcher](RetryingBlockFetcher.md).

## Contract

### <span id="onBlockFetchFailure"> onBlockFetchFailure

```java
void onBlockFetchFailure(
  String blockId,
  Throwable exception)
```

### <span id="onBlockFetchSuccess"> onBlockFetchSuccess

```java
void onBlockFetchSuccess(
  String blockId,
  ManagedBuffer data)
```

## Implementations

* "Unnamed" in [ShuffleBlockFetcherIterator](../storage/ShuffleBlockFetcherIterator.md#sendRequest)
* "Unnamed" in [BlockTransferService](../storage/BlockTransferService.md#fetchBlockSync)
* [RetryingBlockFetchListener](RetryingBlockFetcher.md#RetryingBlockFetchListener)
