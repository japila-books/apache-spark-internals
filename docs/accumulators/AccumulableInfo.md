# AccumulableInfo

`AccumulableInfo` represents an update to an [AccumulatorV2](AccumulatorV2.md).

`AccumulableInfo` is used to transfer accumulator updates from executors to the driver every executor heartbeat or when a task finishes.

## Creating Instance

`AccumulableInfo` takes the following to be created:

* <span id="id"> Accumulator ID
* <span id="name"> Name
* <span id="update"> Partial Update
* <span id="value"> Partial Value
* [internal](#internal) flag
* <span id="countFailedValues"> `countFailedValues` flag
* <span id="metadata"> Metadata (default: `None`)

`AccumulableInfo` is created when:

* `AccumulatorV2` is requested to [convert itself to an AccumulableInfo](AccumulatorV2.md#toInfo)
* `JsonProtocol` is requested to [accumulableInfoFromJson](../history-server/JsonProtocol.md#accumulableInfoFromJson)
* `SQLMetric` ([Spark SQL]({{ book.spark_sql }}/physical-operators/SQLMetric)) is requested to convert itself to an `AccumulableInfo`

## <span id="internal"> internal Flag

```scala
internal: Boolean
```

`AccumulableInfo` is given an `internal` flag when [created](#creating-instance).

`internal` flag denotes whether this accumulator is internal.

`internal` is used when:

* `LiveEntityHelpers` is requested for `newAccumulatorInfos`
* `JsonProtocol` is requested to [accumulableInfoToJson](../history-server/JsonProtocol.md#accumulableInfoToJson)
