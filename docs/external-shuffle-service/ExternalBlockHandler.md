# ExternalBlockHandler

`ExternalBlockHandler` is...FIXME

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

## <span id="metrics"> ShuffleMetrics

## <span id="streamManager"> OneForOneStreamManager

`ExternalBlockHandler` can be given or creates an [OneForOneStreamManager](../network/OneForOneStreamManager.md) to be [created](#creating-instance).

## <span id="blockManager"> ExternalShuffleBlockResolver

`ExternalBlockHandler` can be given or creates an [ExternalShuffleBlockResolver](ExternalShuffleBlockResolver.md) to be [created](#creating-instance).

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
