# JsonProtocol Utility

`JsonProtocol` is an utility to convert [SparkListenerEvent](../SparkListenerEvent.md)s [to](#sparkEventToJson) and [from JSON format](#sparkEventFromJson).

## <span id="mapper"> ObjectMapper

`JsonProtocol` uses an Jackson Databind [ObjectMapper]({{ jackson.api }}/com/fasterxml/jackson/databind/ObjectMapper.html) for performing conversions to and from JSON.

## <span id="sparkEventToJson"> Converting Spark Event to JSON

```scala
sparkEventToJson(
  event: SparkListenerEvent): JValue
```

`sparkEventToJson` converts the given [SparkListenerEvent](../SparkListenerEvent.md) to JSON format.

`sparkEventToJson` is used when...FIXME

## <span id="sparkEventFromJson"> Converting JSON to Spark Event

```scala
sparkEventFromJson(
  json: JValue): SparkListenerEvent
```

`sparkEventFromJson` converts a JSON-encoded event to a [SparkListenerEvent](../SparkListenerEvent.md).

`sparkEventFromJson` is used when...FIXME
