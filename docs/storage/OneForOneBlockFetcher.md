# OneForOneBlockFetcher

## Creating Instance

`OneForOneBlockFetcher` takes the following to be created:

* <span id="client"> `TransportClient`
* <span id="appId"> Application ID
* <span id="execId"> Executor ID
* <span id="blockIds"> Block IDs (`String[]`)
* <span id="listener"> [BlockFetchingListener](../core/BlockFetchingListener.md)
* <span id="transportConf"> [TransportConf](../network/TransportConf.md)
* <span id="downloadFileManager"> [DownloadFileManager](../shuffle/DownloadFileManager.md)

`OneForOneBlockFetcher` is created when:

* `NettyBlockTransferService` is requested to [fetch blocks](NettyBlockTransferService.md#fetchBlocks)
* `ExternalBlockStoreClient` is requested to [fetch blocks](ExternalBlockStoreClient.md#fetchBlocks)

## <span id="createFetchShuffleBlocksMsg"> createFetchShuffleBlocksMsg

```java
FetchShuffleBlocks createFetchShuffleBlocksMsg(
  String appId,
  String execId,
  String[] blockIds)
```

`createFetchShuffleBlocksMsg`...FIXME

## <span id="start"> Starting

```java
void start()
```

`start` requests the [TransportClient](#client) to `sendRpc` the [BlockTransferMessage](#message)

`start`...FIXME

`start` is used when:

* `ExternalBlockStoreClient` is requested to [fetchBlocks](ExternalBlockStoreClient.md#fetchBlocks)
* `NettyBlockTransferService` is requested to [fetchBlocks](NettyBlockTransferService.md#fetchBlocks)

## Logging

Enable `ALL` logging level for `org.apache.spark.network.shuffle.OneForOneBlockFetcher` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.shuffle.OneForOneBlockFetcher=ALL
```

Refer to [Logging](../spark-logging.md).
