# AccumulatorV2

`AccumulatorV2[IN, OUT]` is an [abstraction](#contract) of [accumulators](#implementations)

`AccumulatorV2` is a Java [Serializable]({{ java.api }}/java.base/java/io/Serializable.html).

## Contract

### <span id="add"> Adding Value

```scala
add(
  v: IN): Unit
```

Accumulates (_adds_) the given `v` value to this accumulator

### <span id="copy"> Copying Accumulator

```scala
copy(): AccumulatorV2[IN, OUT]
```

### <span id="isZero"> Is Zero Value

```scala
isZero: Boolean
```

### <span id="merge"> Merging Updates

```scala
merge(
  other: AccumulatorV2[IN, OUT]): Unit
```

### <span id="reset"> Resetting Accumulator

```scala
reset(): Unit
```

### <span id="value"> Value

```scala
value: OUT
```

The current value of this accumulator

Used when:

* `TaskRunner` is requested to [collectAccumulatorsAndResetStatusOnFailure](../executor/TaskRunner.md#collectAccumulatorsAndResetStatusOnFailure)
* `AccumulatorSource` is requested to [register](AccumulatorSource.md#register)
* `DAGScheduler` is requested to [update accumulators](../scheduler/DAGScheduler.md#updateAccumulators)
* `TaskSchedulerImpl` is requested to [executorHeartbeatReceived](../scheduler/TaskSchedulerImpl.md#executorHeartbeatReceived)
* `TaskSetManager` is requested to [handleSuccessfulTask](../scheduler/TaskSetManager.md#handleSuccessfulTask)
* `JsonProtocol` is requested to [taskEndReasonFromJson](../history-server/JsonProtocol.md#taskEndReasonFromJson)
* _others_

## Implementations

* AggregatingAccumulator ([Spark SQL]({{ book.spark_sql }}/physical-operators/CollectMetricsExec/#accumulator))
* CollectionAccumulator
* DoubleAccumulator
* EventTimeStatsAccum ([Spark Structured Streaming]({{ book.structured_streaming }}/EventTimeStatsAccum))
* LongAccumulator
* SetAccumulator (Spark SQL)
* SQLMetric ([Spark SQL]({{ book.spark_sql }}/physical-operators/SQLMetric))

## <span id="toInfo"> Converting this Accumulator to AccumulableInfo

```scala
toInfo(
  update: Option[Any],
  value: Option[Any]): AccumulableInfo
```

`toInfo` determines whether the accumulator is internal based on the [name](#name) (and whether it uses the [internal.metrics](InternalAccumulator.md#METRICS_PREFIX) prefix) and uses it to create an [AccumulableInfo](AccumulableInfo.md).

`toInfo` is used when:

* `TaskRunner` is requested to [collectAccumulatorsAndResetStatusOnFailure](../executor/TaskRunner.md#collectAccumulatorsAndResetStatusOnFailure)
* `DAGScheduler` is requested to [updateAccumulators](../scheduler/DAGScheduler.md#updateAccumulators)
* `TaskSchedulerImpl` is requested to [executorHeartbeatReceived](../scheduler/TaskSchedulerImpl.md#executorHeartbeatReceived)
* `JsonProtocol` is requested to [taskEndReasonFromJson](../history-server/JsonProtocol.md#taskEndReasonFromJson)
* `SQLAppStatusListener` ([Spark SQL]({{ book.spark_sql }}/SQLAppStatusListener/)) is requested to handle a `SparkListenerTaskEnd` event (`onTaskEnd`)

## <span id="register"> Registering Accumulator

```scala
register(
  sc: SparkContext,
  name: Option[String] = None,
  countFailedValues: Boolean = false): Unit
```

`register`...FIXME

`register` is used when:

* `SparkContext` is requested to [register an accumulator](../SparkContext.md#register)
* `TaskMetrics` is requested to [register task accumulators](../executor/TaskMetrics.md#register)
* `CollectMetricsExec` ([Spark SQL]({{ book.spark_sql }}/physical-operators/CollectMetricsExec/)) is requested for an `AggregatingAccumulator`
* `SQLMetrics` ([Spark SQL]({{ book.spark_sql }}/physical-operators/SQLMetric)) is used to create a performance metric

## <span id="writeReplace"> Serializing AccumulatorV2

```scala
writeReplace(): Any
```

`writeReplace` is part of the `Serializable` ([Java]({{ java.api }}/java.base/java/io/Serializable.html)) abstraction (to designate an alternative object to be used when writing an object to the stream).

`writeReplace`...FIXME

## <span id="readObject"> Deserializing AccumulatorV2

```scala
readObject(
  in: ObjectInputStream): Unit
```

`readObject` is part of the `Serializable` ([Java]({{ java.api }}/java.base/java/io/Serializable.html)) abstraction (for special handling during deserialization).

`readObject` reads the non-static and non-transient fields of the `AccumulatorV2` from the given `ObjectInputStream`.

If the `atDriverSide` internal flag is turned on, `readObject` turns it off (to indicate `readObject` is executed on an executor). Otherwise, `atDriverSide` internal flag is turned on.

`readObject` requests the active [TaskContext](../scheduler/TaskContext.md#get) to [register this accumulator](../scheduler/TaskContext.md#registerAccumulator).
