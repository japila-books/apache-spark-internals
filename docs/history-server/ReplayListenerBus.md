# ReplayListenerBus

`ReplayListenerBus` is a [SparkListenerBus](../SparkListenerBus.md) that can [replay JSON-encoded `SparkListenerEvent` events](#replay).

`ReplayListenerBus` is used by [FsHistoryProvider](FsHistoryProvider.md).

## <span id="replay"> Replaying JSON-encoded SparkListenerEvents

```scala
replay(
  logData: InputStream,
  sourceName: String,
  maybeTruncated: Boolean = false): Unit
```

`replay` reads JSON-encoded SparkListener.md#SparkListenerEvent[SparkListenerEvent] events from `logData` (one event per line) and posts them to all registered [SparkListenerInterface](../SparkListenerInterface.md)s.

`replay` uses spark-history-server:JsonProtocol.md#sparkEventFromJson[`JsonProtocol` to convert JSON-encoded events to `SparkListenerEvent` objects].

NOTE: `replay` uses *jackson* from http://json4s.org/[json4s] library to parse the AST for JSON.

When there is an exception parsing a JSON event, you may see the following WARN message in the logs (for the last line) or a `JsonParseException`.

```
WARN Got JsonParseException from log file $sourceName at line [lineNumber], the file might not have finished writing cleanly.
```

Any other non-IO exceptions end up with the following ERROR messages in the logs:

```
ERROR Exception parsing Spark event log: [sourceName]
ERROR Malformed line #[lineNumber]: [currentLine]
```

NOTE: The `sourceName` input argument is only used for messages.
