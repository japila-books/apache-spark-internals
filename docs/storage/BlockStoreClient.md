# BlockStoreClient

`BlockStoreClient` is an [abstraction](#contract) of [block clients](#implementations) that can [fetch blocks from a remote node](#fetchBlocks) (an executor or an external service).

`BlockStoreClient` is a Java [Closeable]({{ java.api }}/java.base/java/io/Closeable.html).

!!! note
    `BlockStoreClient` was known previously as `ShuffleClient` ([SPARK-28593](https://issues.apache.org/jira/browse/SPARK-28593)).

## Contract

### <span id="fetchBlocks"> Fetching Blocks

```java
void fetchBlocks(
  String host,
  int port,
  String execId,
  String[] blockIds,
  BlockFetchingListener listener,
  DownloadFileManager downloadFileManager)
```

Fetches blocks from a remote node (using [DownloadFileManager](../shuffle/DownloadFileManager.md))

Used when:

* `BlockTransferService` is requested to [fetchBlockSync](BlockTransferService.md#fetchBlockSync)
* `ShuffleBlockFetcherIterator` is requested to [sendRequest](ShuffleBlockFetcherIterator.md#sendRequest)

### <span id="shuffleMetrics"> Shuffle Metrics

```java
MetricSet shuffleMetrics()
```

Shuffle `MetricsSet`

Default: (empty)

Used when:

* `BlockManager` is requested for the [Shuffle Metrics Source](BlockManager.md#shuffleMetricsSource)

## Implementations

* [BlockTransferService](BlockTransferService.md)
* [ExternalBlockStoreClient](ExternalBlockStoreClient.md)
