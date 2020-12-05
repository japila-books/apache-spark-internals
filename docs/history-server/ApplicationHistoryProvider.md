# ApplicationHistoryProvider

`ApplicationHistoryProvider` is an [abstraction](#contract) of [history providers](#implementations).

## Contract

### <span id="getApplicationInfo"> getApplicationInfo

```scala
getApplicationInfo(
  appId: String): Option[ApplicationInfo]
```

Used when...FIXME

### <span id="getAppUI"> getAppUI

```scala
getAppUI(
  appId: String,
  attemptId: Option[String]): Option[LoadedAppUI]
```

[SparkUI](../webui/SparkUI.md) for a given application (by `appId`)

Used when `HistoryServer` is requested for the [UI of a Spark application](HistoryServer.md#getAppUI)

### <span id="getListing"> getListing

```scala
getListing(): Iterator[ApplicationInfo]
```

Used when...FIXME

### <span id="onUIDetached"> onUIDetached

```scala
onUIDetached(
  appId: String,
  attemptId: Option[String],
  ui: SparkUI): Unit
```

Used when...FIXME

### <span id="writeEventLogs"> writeEventLogs

```scala
writeEventLogs(
  appId: String,
  attemptId: Option[String],
  zipStream: ZipOutputStream): Unit
```

Writes events to a stream

Used when...FIXME

## Implementations

* [FsHistoryProvider](FsHistoryProvider.md)
