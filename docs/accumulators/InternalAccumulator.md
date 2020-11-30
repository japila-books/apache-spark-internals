# InternalAccumulator

`InternalAccumulator` is an utility with field names for internal accumulators.

## <span id="METRICS_PREFIX"> internal.metrics Prefix

`internal.metrics.` is the prefix of metrics that are considered internal and should not be displayed in web UI.

`internal.metrics.` is used when:

* `AccumulatorV2` is requested to [convert itself to AccumulableInfo](AccumulatorV2.md#toInfo) and [writeReplace](AccumulatorV2.md#writeReplace)
* `JsonProtocol` is requested to [accumValueToJson](../history-server/JsonProtocol.md#accumValueToJson) and [accumValueFromJson](../history-server/JsonProtocol.md#accumValueFromJson)
