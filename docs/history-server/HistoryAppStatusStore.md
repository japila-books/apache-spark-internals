# HistoryAppStatusStore

`HistoryAppStatusStore` is an [AppStatusStore](../status/AppStatusStore.md) for [SparkUI](../webui/SparkUI.md)s in [Spark History Server](index.md).

## Creating Instance

`HistoryAppStatusStore` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="store"> [KVStore](../core/KVStore.md)

`HistoryAppStatusStore` is created when:

* `FsHistoryProvider` is requested for a [SparkUI](FsHistoryProvider.md#getAppUI) (of a Spark application)

## <span id="logUrlHandler"> ExecutorLogUrlHandler

```scala
logUrlHandler: ExecutorLogUrlHandler
```

`HistoryAppStatusStore` creates an [ExecutorLogUrlHandler](../executor/ExecutorLogUrlHandler.md) (for the [logUrlPattern](#logUrlPattern)) when [created](#creating-instance).

`HistoryAppStatusStore` uses it when requested to [replaceLogUrls](#replaceLogUrls).

## <span id="executorList"> executorList

```scala
executorList(
  exec: v1.ExecutorSummary,
  urlPattern: String): v1.ExecutorSummary
```

`executorList`...FIXME

`executorList` is part of the [AppStatusStore](../status/AppStatusStore.md#executorList) abstraction.

## <span id="executorSummary"> executorSummary

```scala
executorSummary(
  executorId: String): v1.ExecutorSummary
```

`executorSummary`...FIXME

`executorSummary` is part of the [AppStatusStore](../status/AppStatusStore.md#executorSummary) abstraction.

## <span id="replaceLogUrls"> replaceLogUrls

```scala
replaceLogUrls(
  exec: v1.ExecutorSummary,
  urlPattern: String): v1.ExecutorSummary
```

`replaceLogUrls`...FIXME

`replaceLogUrls` is used when `HistoryAppStatusStore` is requested to [executorList](#executorList) and [executorSummary](#executorSummary).
