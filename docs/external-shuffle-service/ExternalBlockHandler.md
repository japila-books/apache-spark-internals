# ExternalBlockHandler

`ExternalBlockHandler` is an [RpcHandler](../network/RpcHandler.md).

## Creating Instance

`ExternalBlockHandler` takes the following to be created:

* <span id="conf"> [TransportConf](../network/TransportConf.md)
* <span id="registeredExecutorFile"> `registeredExecutor` File (Java's [File]({{ java.api }}/java.base/java/io/File.html))

`ExternalBlockHandler` creates the following:

* [ShuffleMetrics](#metrics)
* [OneForOneStreamManager](#streamManager)
* [ExternalShuffleBlockResolver](#blockManager)

`ExternalBlockHandler` is created when:

* `ExternalShuffleService` is requested for an [ExternalBlockHandler](ExternalShuffleService.md#newShuffleBlockHandler)
* `YarnShuffleService` is requested to `serviceInit`

## <span id="streamManager"> OneForOneStreamManager

`ExternalBlockHandler` can be given or creates an [OneForOneStreamManager](../network/OneForOneStreamManager.md) to be [created](#creating-instance).

## <span id="blockManager"> ExternalShuffleBlockResolver

`ExternalBlockHandler` can be given or creates an [ExternalShuffleBlockResolver](ExternalShuffleBlockResolver.md) to be [created](#creating-instance).

## <span id="receive"><span id="handleMessage"><span id="messages"> Messages

### <span id="FetchShuffleBlocks"> FetchShuffleBlocks

Request to read a set of blocks

"Posted" (created) when:

* `OneForOneBlockFetcher` is requested to [createFetchShuffleBlocksMsg](../storage/OneForOneBlockFetcher.md#createFetchShuffleBlocksMsg)

When received, `ExternalBlockHandler` requests the [OneForOneStreamManager](#streamManager) to [registerStream](../network/OneForOneStreamManager.md#registerStream) (with a `ShuffleManagedBufferIterator`).

`ExternalBlockHandler` prints out the following TRACE message to the logs:

```text
Registered streamId [streamId] with [numBlockIds] buffers for client [clientId] from host [remoteAddress]
```

In the end, `ExternalBlockHandler` responds with a `StreamHandle` (of `streamId` and `numBlockIds`).

### <span id="GetLocalDirsForExecutors"> GetLocalDirsForExecutors

### <span id="OpenBlocks"> OpenBlocks

!!! note
    For backward compatibility and like [FetchShuffleBlocks](#FetchShuffleBlocks).

### <span id="RegisterExecutor"> RegisterExecutor

### <span id="RemoveBlocks"> RemoveBlocks

## <span id="metrics"> ShuffleMetrics

## <span id="executorRemoved"> Executor Removed Notification

```java
void executorRemoved(
  String executorId,
  String appId)
```

`executorRemoved` requests the [ExternalShuffleBlockResolver](#blockManager) to [executorRemoved](ExternalShuffleBlockResolver.md#executorRemoved).

`executorRemoved` is used when:

* `ExternalShuffleService` is requested to [executorRemoved](ExternalShuffleService.md#executorRemoved)

## <span id="applicationRemoved"> Application Finished Notification

```java
void applicationRemoved(
  String appId,
  boolean cleanupLocalDirs)
```

`applicationRemoved` requests the [ExternalShuffleBlockResolver](#blockManager) to [applicationRemoved](ExternalShuffleBlockResolver.md#applicationRemoved).

`applicationRemoved` is used when:

* `ExternalShuffleService` is requested to [applicationRemoved](ExternalShuffleService.md#applicationRemoved)
* `YarnShuffleService` (Spark on YARN) is requested to `stopApplication`

## Logging

Enable `ALL` logging level for `org.apache.spark.network.shuffle.ExternalBlockHandler` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.network.shuffle.ExternalBlockHandler=ALL
```

Refer to [Logging](../spark-logging.md).
