# ShuffleWriteProcessor

`ShuffleWriteProcessor` is used by [ShuffleMapTask](../scheduler/ShuffleMapTask.md) to [write partition records to the shuffle system](#write).

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
