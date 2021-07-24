# OneForOneBlockFetcher

## Creating Instance

`OneForOneBlockFetcher` takes the following to be created:

* <span id="client"> `TransportClient`
* <span id="appId"> Application ID
* <span id="execId"> Executor ID
* <span id="blockIds"> Block IDs
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
