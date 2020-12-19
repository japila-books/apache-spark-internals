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
