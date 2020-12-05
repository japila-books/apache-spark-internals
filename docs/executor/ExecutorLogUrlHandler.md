# ExecutorLogUrlHandler

## Creating Instance

`ExecutorLogUrlHandler` takes the following to be created:

* <span id="logUrlPattern"> Optional Log URL Pattern

`ExecutorLogUrlHandler` is created for the following:

* [DriverEndpoint](../scheduler/DriverEndpoint.md#logUrlHandler)
* [HistoryAppStatusStore](../history-server/HistoryAppStatusStore.md#logUrlHandler)

## <span id="applyPattern"> Applying Pattern

```scala
applyPattern(
  logUrls: Map[String, String],
  attributes: Map[String, String]): Map[String, String]
```

`applyPattern` [doApplyPattern](#doApplyPattern) for [logUrlPattern](#logUrlPattern) defined or simply returns the given `logUrls` back.

`applyPattern` is used when:

* `DriverEndpoint` is requested to handle a [RegisterExecutor](../scheduler/DriverEndpoint.md#RegisterExecutor) message (and creates a [ExecutorData](../scheduler/ExecutorData.md))
* `HistoryAppStatusStore` is requested to [replaceLogUrls](../history-server/HistoryAppStatusStore.md#replaceLogUrls)

### <span id="doApplyPattern"> doApplyPattern

```scala
doApplyPattern(
  logUrls: Map[String, String],
  attributes: Map[String, String],
  urlPattern: String): Map[String, String]
```

`doApplyPattern`...FIXME
