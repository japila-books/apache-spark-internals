# ShuffleWriteProcessor

`ShuffleWriteProcessor` controls write behavior in [ShuffleMapTask](../scheduler/ShuffleMapTask.md)s while [writing partition records out to the shuffle system](#write).

`ShuffleWriteProcessor` is used to create a [ShuffleDependency](../rdd/ShuffleDependency.md#shuffleWriterProcessor).

## Creating Instance

`ShuffleWriteProcessor` takes no arguments to be created.

`ShuffleWriteProcessor` is created when:

* `ShuffleDependency` is [created](../rdd/ShuffleDependency.md#shuffleWriterProcessor)
* `ShuffleExchangeExec` ([Spark SQL]({{ book.spark_sql }}/physical-operators/ShuffleExchangeExec/)) physical operator is requested to `createShuffleWriteProcessor`

## <span id="write"> Writing Partition Records to Shuffle System

```scala
write(
  rdd: RDD[_],
  dep: ShuffleDependency[_, _, _],
  mapId: Long,
  context: TaskContext,
  partition: Partition): MapStatus
```

`write` requests the [ShuffleManager](ShuffleManager.md) for the [ShuffleWriter](ShuffleManager.md#getWriter) for the [ShuffleHandle](#shuffleHandle) (of the given [ShuffleDependency](../rdd/ShuffleDependency.md)).

`write` requests the `ShuffleWriter` to [write out records](ShuffleWriter.md#write) (of the given [Partition](../rdd/Partition.md) and [RDD](../rdd/RDD.md)).

In the end, `write` requests the `ShuffleWriter` to [stop](ShuffleWriter.md#stop) (with the `success` flag enabled).

In case of any `Exception`s, `write` requests the `ShuffleWriter` to [stop](ShuffleWriter.md#stop) (with the `success` flag disabled).

`write` is used when `ShuffleMapTask` is requested to [run](../scheduler/ShuffleMapTask.md#runTask).

### <span id="createMetricsReporter"> Creating MetricsReporter

```scala
createMetricsReporter(
  context: TaskContext): ShuffleWriteMetricsReporter
```

`createMetricsReporter` creates a [ShuffleWriteMetricsReporter](ShuffleWriteMetricsReporter.md) from the given [TaskContext](../scheduler/TaskContext.md).

`createMetricsReporter` requests the given [TaskContext](../scheduler/TaskContext.md) for [TaskMetrics](../executor/TaskMetrics.md#taskMetrics) and then for the [ShuffleWriteMetrics](../executor/TaskMetrics.md#shuffleWriteMetrics).
