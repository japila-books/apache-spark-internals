# BlockStoreClient

`BlockStoreClient` is an [abstraction](#contract) of [block clients](#implementations) that can [fetch blocks from a remote node](#fetchBlocks).

`BlockStoreClient` is a Java [Closeable]({{ java.api }}/java.base/java/io/Closeable.html).

## Contract

### <span id="fetchBlocks"> fetchBlocks

```java
void fetchBlocks(
  String host,
  int port,
  String execId,
  String[] blockIds,
  BlockFetchingListener listener,
  DownloadFileManager downloadFileManager)
```

Fetches blocks from a remote node

Used when:

* `BlockTransferService` is requested to [fetchBlockSync](BlockTransferService.md#fetchBlockSync)
* `ShuffleBlockFetcherIterator` is requested to [sendRequest](ShuffleBlockFetcherIterator.md#sendRequest)

### <span id="shuffleMetrics"> shuffleMetrics

```java
MetricSet shuffleMetrics()
```

Shuffle `MetricsSet`

Default: (empty)

Used when:

* `BlockManager` is requested for a [Shuffle Metrics Source](BlockManager.md#shuffleMetricsSource)

## Implementations

* [BlockTransferService](BlockTransferService.md)
* [ExternalBlockStoreClient](ExternalBlockStoreClient.md)
