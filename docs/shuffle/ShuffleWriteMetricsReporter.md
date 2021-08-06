# ShuffleWriteMetricsReporter

`ShuffleWriteMetricsReporter` is an [abstraction](#contract) of [shuffle write metrics reporters](#implementations).

## Contract

### <span id="decBytesWritten"> decBytesWritten

```scala
decBytesWritten(
  v: Long): Unit
```

### <span id="decRecordsWritten"> decRecordsWritten

```scala
decRecordsWritten(
  v: Long): Unit
```

### <span id="incBytesWritten"> incBytesWritten

```scala
incBytesWritten(
  v: Long): Unit
```

### <span id="incRecordsWritten"> incRecordsWritten

```scala
incRecordsWritten(
  v: Long): Unit
```

### <span id="incWriteTime"> incWriteTime

```scala
incWriteTime(
  v: Long): Unit
```

Used when:

* `BypassMergeSortShuffleWriter` is requested to [write partition records](BypassMergeSortShuffleWriter.md#write) and [writePartitionedData](BypassMergeSortShuffleWriter.md#writePartitionedData)
* `UnsafeShuffleWriter` is requested to [mergeSpillsWithTransferTo](UnsafeShuffleWriter.md#mergeSpillsWithTransferTo)
* `DiskBlockObjectWriter` is requested to [commitAndGet](../storage/DiskBlockObjectWriter.md#commitAndGet)
* `TimeTrackingOutputStream` is requested to `write`, `flush`, and `close`

## Implementations

* [ShuffleWriteMetrics](../executor/ShuffleWriteMetrics.md)
* SQLShuffleWriteMetricsReporter ([Spark SQL]({{ book.spark_sql }}/physical-operators/SQLShuffleWriteMetricsReporter))
