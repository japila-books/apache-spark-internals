# HadoopWriteConfigUtil

`HadoopWriteConfigUtil[K, V]` is an [abstraction](#contract) of [writer configurers](#implementations) for [SparkHadoopWriter](SparkHadoopWriter.md) to [write a key-value RDD](SparkHadoopWriter.md#write) (for [RDD.saveAsNewAPIHadoopDataset](rdd/PairRDDFunctions.md#saveAsNewAPIHadoopDataset) and [RDD.saveAsHadoopDataset](rdd/PairRDDFunctions.md#saveAsHadoopDataset) operators).

## Contract

### <span id="assertConf"> assertConf

```scala
assertConf(
  jobContext: JobContext,
  conf: SparkConf): Unit
```

### <span id="closeWriter"> closeWriter

```scala
closeWriter(
  taskContext: TaskAttemptContext): Unit
```

### <span id="createCommitter"> createCommitter

```scala
createCommitter(
  jobId: Int): HadoopMapReduceCommitProtocol
```

Creates a [HadoopMapReduceCommitProtocol](HadoopMapReduceCommitProtocol.md) committer

Used when:

* `SparkHadoopWriter` is requested to [write data out](SparkHadoopWriter.md#write)

### <span id="createJobContext"> createJobContext

```scala
createJobContext(
  jobTrackerId: String,
  jobId: Int): JobContext
```

### <span id="createTaskAttemptContext"> createTaskAttemptContext

```scala
createTaskAttemptContext(
  jobTrackerId: String,
  jobId: Int,
  splitId: Int,
  taskAttemptId: Int): TaskAttemptContext
```

Creates a Hadoop [TaskAttemptContext]({{ hadoop.api }}/org/apache/hadoop/mapreduce/TaskAttemptContext.html)

### <span id="initOutputFormat"> initOutputFormat

```scala
initOutputFormat(
  jobContext: JobContext): Unit
```

### <span id="initWriter"> initWriter

```scala
initWriter(
  taskContext: TaskAttemptContext,
  splitId: Int): Unit
```

### <span id="write"> write

```scala
write(
  pair: (K, V)): Unit
```

Writes out the key-value pair

Used when:

* `SparkHadoopWriter` is requested to [executeTask](SparkHadoopWriter.md#executeTask)

## Implementations

* [HadoopMapReduceWriteConfigUtil](HadoopMapReduceWriteConfigUtil.md)
* [HadoopMapRedWriteConfigUtil](HadoopMapRedWriteConfigUtil.md)
