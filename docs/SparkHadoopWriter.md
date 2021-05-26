# SparkHadoopWriter Utility

## <span id="write"> Writing Key-Value RDD Out (As Hadoop OutputFormat)

```scala
write[K, V: ClassTag](
  rdd: RDD[(K, V)],
  config: HadoopWriteConfigUtil[K, V]): Unit
```

`write` [runs a Spark job](SparkContext.md#runJob) to [write out partition records](#executeTask) (for all partitions of the given key-value `RDD`) with the given [HadoopWriteConfigUtil](HadoopWriteConfigUtil.md) and a [HadoopMapReduceCommitProtocol](HadoopMapReduceCommitProtocol.md) committer.

The number of writer tasks (_parallelism_) is the number of the partitions in the given key-value `RDD`.

### <span id="write-internals"> Internals

<span id="write-commitJobId">
Internally, `write` uses the id of the given RDD as the `commitJobId`.

<span id="write-jobTrackerId">
`write` creates a `jobTrackerId` with the current date.

<span id="write-jobContext">
`write` requests the given `HadoopWriteConfigUtil` to [create a Hadoop JobContext](HadoopWriteConfigUtil.md#createJobContext) (for the [jobTrackerId](#write-jobTrackerId) and [commitJobId](#write-commitJobId)).

`write` requests the given `HadoopWriteConfigUtil` to [initOutputFormat](HadoopWriteConfigUtil.md#initOutputFormat) with the Hadoop [JobContext]({{ hadoop.api }}/api/org/apache/hadoop/mapreduce/JobContext.html).

`write` requests the given `HadoopWriteConfigUtil` to [assertConf](HadoopWriteConfigUtil.md#assertConf).

`write` requests the given `HadoopWriteConfigUtil` to [create a HadoopMapReduceCommitProtocol committer](HadoopWriteConfigUtil.md#createCommitter) for the [commitJobId](#write-commitJobId).

`write` requests the `HadoopMapReduceCommitProtocol` to [setupJob](HadoopMapReduceCommitProtocol.md#setupJob) (with the [jobContext](#write-jobContext)).

<span id="write-runJob"><span id="write-executeTask">
`write` uses the `SparkContext` (of the given RDD) to [run a Spark job asynchronously](SparkContext.md#runJob) for the given RDD with the [executeTask](#executeTask) partition function.

<span id="write-commitJob">
In the end, `write` requests the [HadoopMapReduceCommitProtocol](#write-committer) to [commit the job](HadoopMapReduceCommitProtocol.md#commitJob) and prints out the following INFO message to the logs:

```text
Job [getJobID] committed.
```

### <span id="write-Throwable"> Throwables

In case of any `Throwable`, `write` prints out the following ERROR message to the logs:

```text
Aborting job [getJobID].
```

<span id="write-abortJob">
`write` requests the [HadoopMapReduceCommitProtocol](#write-committer) to [abort the job](HadoopMapReduceCommitProtocol.md#abortJob) and throws a `SparkException`:

```text
Job aborted.
```

### <span id="write-usage"> Usage

`write` is used when:

* [PairRDDFunctions.saveAsNewAPIHadoopDataset](rdd/PairRDDFunctions.md#saveAsNewAPIHadoopDataset)
* [PairRDDFunctions.saveAsHadoopDataset](rdd/PairRDDFunctions.md#saveAsHadoopDataset)

### <span id="executeTask"> Writing RDD Partition

```scala
executeTask[K, V: ClassTag](
  context: TaskContext,
  config: HadoopWriteConfigUtil[K, V],
  jobTrackerId: String,
  commitJobId: Int,
  sparkPartitionId: Int,
  sparkAttemptNumber: Int,
  committer: FileCommitProtocol,
  iterator: Iterator[(K, V)]): TaskCommitMessage
```

!!! FIXME
    Review Me

`executeTask` requests the given `HadoopWriteConfigUtil` to [create a TaskAttemptContext](HadoopWriteConfigUtil.md#createTaskAttemptContext).

`executeTask` requests the given `FileCommitProtocol` to [set up a task](FileCommitProtocol.md#setupTask) with the `TaskAttemptContext`.

`executeTask` requests the given `HadoopWriteConfigUtil` to [initWriter](HadoopWriteConfigUtil.md#initWriter) (with the `TaskAttemptContext` and the given `sparkPartitionId`).

`executeTask` [initHadoopOutputMetrics](#initHadoopOutputMetrics).

`executeTask` writes all rows of the RDD partition (from the given `Iterator[(K, V)]`). `executeTask` requests the given `HadoopWriteConfigUtil` to [write](HadoopWriteConfigUtil.md#write). In the end, `executeTask` requests the given `HadoopWriteConfigUtil` to [closeWriter](HadoopWriteConfigUtil.md#closeWriter) and the given `FileCommitProtocol` to [commit the task](FileCommitProtocol.md#commitTask).

`executeTask` updates metrics about writing data to external systems (*bytesWritten* and *recordsWritten*) every few records and at the end.

In case of any errors, `executeTask` requests the given `HadoopWriteConfigUtil` to [closeWriter](HadoopWriteConfigUtil.md#closeWriter) and the given `FileCommitProtocol` to [abort the task](FileCommitProtocol.md#abortTask). In the end, `executeTask` prints out the following ERROR message to the logs:

```text
Task [taskAttemptID] aborted.
```

`executeTask` is used when:

* `SparkHadoopWriter` utility is used to [write](#write)

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.io.SparkHadoopWriter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.internal.io.SparkHadoopWriter=ALL
```

Refer to [Logging](spark-logging.md).
