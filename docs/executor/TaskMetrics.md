---
tags:
  - DeveloperApi
---

# TaskMetrics

`TaskMetrics` is a collection of [metrics](#metrics) ([accumulators](../accumulators/index.md)) tracked during execution of a [task](#Task).

## Creating Instance

`TaskMetrics` takes no input arguments to be created.

`TaskMetrics` is created when:

* `Stage` is requested to [makeNewStageAttempt](../scheduler/Stage.md#makeNewStageAttempt)

## Metrics

### <span id="shuffleWriteMetrics"> ShuffleWriteMetrics

[ShuffleWriteMetrics](ShuffleWriteMetrics.md)

* shuffle.write.bytesWritten
* shuffle.write.recordsWritten
* shuffle.write.writeTime

`ShuffleWriteMetrics` is exposed using Dropwizard metrics system using [ExecutorSource](ExecutorSource.md) (when `TaskRunner` is about to finish [running](TaskRunner.md#run)):

* shuffleBytesWritten
* shuffleRecordsWritten
* shuffleWriteTime

`ShuffleWriteMetrics` can be monitored using:

* [StatsReportListener](../StatsReportListener.md) (when a [stage completes](../StatsReportListener.md#onStageCompleted))
    * shuffle bytes written
* [JsonProtocol](../history-server/JsonProtocol.md) (when requested to [taskMetricsToJson](../history-server/JsonProtocol.md#taskMetricsToJson))
    * Shuffle Bytes Written
    * Shuffle Write Time
    * Shuffle Records Written

`shuffleWriteMetrics` is used when:

* `ShuffleWriteProcessor` is requested for a [ShuffleWriteMetricsReporter](../shuffle/ShuffleWriteProcessor.md#createMetricsReporter)
* `SortShuffleWriter` is [created](../shuffle/SortShuffleWriter.md#writeMetrics)
* `AppStatusListener` is requested to [handle a SparkListenerTaskEnd](../status/AppStatusListener.md#onTaskEnd)
* `LiveTask` is requested to `updateMetrics`
* `ExternalSorter` is requested to [writePartitionedFile](../shuffle/ExternalSorter.md#writePartitionedFile) (to create a [DiskBlockObjectWriter](../storage/DiskBlockObjectWriter.md#writeMetrics)), [writePartitionedMapOutput](../shuffle/ExternalSorter.md#writePartitionedMapOutput)
* `ShuffleExchangeExec` ([Spark SQL]({{ book.spark_sql }}/physical-operators/ShuffleExchangeExec)) is requested for a `ShuffleWriteProcessor` (to create a [ShuffleDependency](../rdd/ShuffleDependency.md#shuffleWriterProcessor))

### <span id="_memoryBytesSpilled"><span id="memoryBytesSpilled"><span id="incMemoryBytesSpilled"><span id="MEMORY_BYTES_SPILLED"> Memory Bytes Spilled

Number of in-memory bytes spilled by the tasks (of a stage)

`_memoryBytesSpilled` is a `LongAccumulator` with `internal.metrics.memoryBytesSpilled` name.

`memoryBytesSpilled` metric is exposed using [ExecutorSource](ExecutorSource.md) as [memoryBytesSpilled](ExecutorSource.md#METRIC_MEMORY_BYTES_SPILLED) (using Dropwizard metrics system).

#### memoryBytesSpilled

```scala
memoryBytesSpilled: Long
```

`memoryBytesSpilled` is the sum of all memory bytes spilled across all tasks.

---

`memoryBytesSpilled` is used when:

* `SpillListener` is requested to [onStageCompleted](../SpillListener.md#onStageCompleted)
* `TaskRunner` is requested to [run](TaskRunner.md#run) (and updates task metrics in the Dropwizard metrics system)
* `LiveTask` is requested to `updateMetrics`
* `JsonProtocol` is requested to [taskMetricsToJson](../history-server/JsonProtocol.md#taskMetricsToJson)

#### incMemoryBytesSpilled

```scala
incMemoryBytesSpilled(
  v: Long): Unit
```

`incMemoryBytesSpilled` adds the `v` value to the [_memoryBytesSpilled](#_memoryBytesSpilled) metric.

---

`incMemoryBytesSpilled` is used when:

* `Aggregator` is requested to [updateMetrics](../rdd/Aggregator.md#updateMetrics)
* `BasePythonRunner.ReaderIterator` is requested to `handleTimingData`
* `CoGroupedRDD` is requested to [compute a partition](../rdd/CoGroupedRDD.md#compute)
* `ShuffleExternalSorter` is requested to [spill](../shuffle/ShuffleExternalSorter.md#spill)
* `JsonProtocol` is requested to [taskMetricsFromJson](../history-server/JsonProtocol.md#taskMetricsFromJson)
* `ExternalSorter` is requested to [insertAllAndUpdateMetrics](../shuffle/ExternalSorter.md#insertAllAndUpdateMetrics), [writePartitionedFile](../shuffle/ExternalSorter.md#writePartitionedFile), [writePartitionedMapOutput](../shuffle/ExternalSorter.md#writePartitionedMapOutput)
* `UnsafeExternalSorter` is requested to [createWithExistingInMemorySorter](../memory/UnsafeExternalSorter.md#createWithExistingInMemorySorter), [spill](../memory/UnsafeExternalSorter.md#spill)
* `UnsafeExternalSorter.SpillableIterator` is requested to `spill`

## <span id="TaskContext"> TaskContext

`TaskMetrics` is available using [TaskContext.taskMetrics](../scheduler/TaskContext.md#taskMetrics).

```scala
TaskContext.get.taskMetrics
```

## <span id="Serializable"> Serializable

`TaskMetrics` is a `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)).

## <span id="Task"> Task

`TaskMetrics` is part of [Task](../scheduler/Task.md#metrics).

```scala
task.metrics
```

## <span id="SparkListener"> SparkListener

`TaskMetrics` is available using [SparkListener](../SparkListener.md) and intercepting [SparkListenerTaskEnd](../SparkListenerTaskEnd.md) events.

## <span id="StatsReportListener"> StatsReportListener

[StatsReportListener](../StatsReportListener.md) can be used for summary statistics at runtime (after a stage completes).

## Spark History Server

Spark History Server uses [EventLoggingListener](../history-server/EventLoggingListener.md) to intercept post-execution statistics (incl. `TaskMetrics`).
