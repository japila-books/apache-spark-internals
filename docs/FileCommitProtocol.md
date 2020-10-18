# FileCommitProtocol

`FileCommitProtocol` is an [abstraction](#contract) of [file committers](#implementations) that can setup, commit or abort a Spark job or task (while writing out a pair RDD and partitions).

`FileCommitProtocol` is used for [RDD.saveAsNewAPIHadoopDataset](rdd/PairRDDFunctions.md#saveAsNewAPIHadoopDataset) and [RDD.saveAsHadoopDataset](rdd/PairRDDFunctions.md#saveAsHadoopDataset) transformations (that use `SparkHadoopWriter` utility to [write a key-value RDD out](SparkHadoopWriter.md#write)).

`FileCommitProtocol` is created using [FileCommitProtocol.instantiate](#instantiate) utility.

## Contract

### <span id="abortJob"> Aborting Job

```scala
abortJob(
  jobContext: JobContext): Unit
```

Aborts a job

Used when:

* `SparkHadoopWriter` utility is used to [write a key-value RDD](SparkHadoopWriter.md#write) (and writing fails)
* (Spark SQL) `FileFormatWriter` utility is used to write a result of a structured query (and writing fails)
* (Spark SQL) `FileBatchWrite` is requested to `abort`

### <span id="abortTask"> Aborting Task

```scala
abortTask(
  taskContext: TaskAttemptContext): Unit
```

Abort a task

Used when:

* `SparkHadoopWriter` utility is used to [write an RDD partition](SparkHadoopWriter.md#executeTask)
* (Spark SQL) `FileFormatDataWriter` is requested to `abort`

### <span id="commitJob"> Committing Job

```scala
commitJob(
  jobContext: JobContext,
  taskCommits: Seq[TaskCommitMessage]): Unit
```

Commits a job after the writes succeed

Used when:

* `SparkHadoopWriter` utility is used to [write a key-value RDD](SparkHadoopWriter.md#write)
* (Spark SQL) `FileFormatWriter` utility is used to write a result of a structured query
* (Spark SQL) `FileBatchWrite` is requested to `commit`

### <span id="commitTask"> Committing Task

```scala
commitTask(
  taskContext: TaskAttemptContext): TaskCommitMessage
```

Used when:

* `SparkHadoopWriter` utility is used to [write an RDD partition](SparkHadoopWriter.md#executeTask)
* (Spark SQL) `FileFormatDataWriter` is requested to `commit`

### <span id="deleteWithJob"> Deleting Path with Job

```scala
deleteWithJob(
  fs: FileSystem,
  path: Path,
  recursive: Boolean): Boolean
```

`deleteWithJob` requests the given Hadoop [FileSystem]({{ hadoop.api }}/org/apache/hadoop/fs/FileSystem.html) to delete a `path` directory.

Used when `InsertIntoHadoopFsRelationCommand` logical command (Spark SQL) is executed

### <span id="newTaskTempFile"> newTaskTempFile

```scala
newTaskTempFile(
  taskContext: TaskAttemptContext,
  dir: Option[String],
  ext: String): String
```

Used when:

* (Spark SQL) `SingleDirectoryDataWriter` and `DynamicPartitionDataWriter` are requested to `write` (and in turn `newOutputWriter`)

### <span id="newTaskTempFileAbsPath"> newTaskTempFileAbsPath

```scala
newTaskTempFileAbsPath(
  taskContext: TaskAttemptContext,
  absoluteDir: String,
  ext: String): String
```

Used when:

* (Spark SQL) `DynamicPartitionDataWriter` is requested to `write`

### <span id="onTaskCommit"> On Task Committed

```scala
onTaskCommit(
  taskCommit: TaskCommitMessage): Unit
```

Used when:

* (Spark SQL) `FileFormatWriter` is requested to `write`

### <span id="setupJob"> Setting Up Job

```scala
setupJob(
  jobContext: JobContext): Unit
```

Used when:

* `SparkHadoopWriter` utility is used to [write an RDD partition](SparkHadoopWriter.md#executeTask) (while [writing out a key-value RDD](SparkHadoopWriter.md#write))
* (Spark SQL) `FileFormatWriter` utility is used to write a result of a structured query
* (Spark SQL) `FileWriteBuilder` is requested to `buildForBatch`

### <span id="setupTask"> Setting Up Task

```scala
setupTask(
  taskContext: TaskAttemptContext): Unit
```

Sets up the task with the Hadoop [TaskAttemptContext]({{ hadoop.api }}/org/apache/hadoop/mapreduce/TaskAttemptContext.html)

Used when:

* `SparkHadoopWriter` is requested to [write an RDD partition](SparkHadoopWriter.md#executeTask) (while [writing out a key-value RDD](SparkHadoopWriter.md#write))
* (Spark SQL) `FileFormatWriter` utility is used to write out a RDD partition (while writing out a result of a structured query)
* (Spark SQL) `FileWriterFactory` is requested to `createWriter`

## Implementations

* [HadoopMapReduceCommitProtocol](HadoopMapReduceCommitProtocol.md)
* `ManifestFileCommitProtocol` (qv. [Spark Structured Streaming]({{ book.structured_streaming }}/datasources/file/ManifestFileCommitProtocol))

## <span id="instantiate"> Instantiating FileCommitProtocol Committer

```scala
instantiate(
  className: String,
  jobId: String,
  outputPath: String,
  dynamicPartitionOverwrite: Boolean = false): FileCommitProtocol
```

`instantiate` prints out the following DEBUG message to the logs:

```text
Creating committer [className]; job [jobId]; output=[outputPath]; dynamic=[dynamicPartitionOverwrite]
```

`instantiate` tries to find a constructor method that takes three arguments (two of type `String` and one `Boolean`) for the given `jobId`, `outputPath` and `dynamicPartitionOverwrite` flag. If found, `instantiate` prints out the following DEBUG message to the logs:

```text
Using (String, String, Boolean) constructor
```

In case of `NoSuchMethodException`, `instantiate` prints out the following DEBUG message to the logs:

```text
Falling back to (String, String) constructor
```

`instantiate` tries to find a constructor method that takes two arguments (two of type `String`) for the given `jobId` and `outputPath`.

With two `String` arguments, `instantiate` requires that the given `dynamicPartitionOverwrite` flag is disabled (`false`) or throws an `IllegalArgumentException`:

```text
requirement failed: Dynamic Partition Overwrite is enabled but the committer [className] does not have the appropriate constructor
```

`instantiate` is used when:

* [HadoopMapRedWriteConfigUtil](HadoopMapRedWriteConfigUtil.md#createCommitter) and [HadoopMapReduceWriteConfigUtil](HadoopMapReduceWriteConfigUtil.md#createCommitter) are requested to create a [HadoopMapReduceCommitProtocol](HadoopMapReduceCommitProtocol.md) committer
* (Spark SQL) `InsertIntoHadoopFsRelationCommand`, `InsertIntoHiveDirCommand`, and `InsertIntoHiveTable` logical commands are executed
* ([Spark Structured Streaming]({{ book.structured_streaming }}/datasources/file/FileStreamSink/#addBatch)) `FileStreamSink` is requested to write out a micro-batch data

## Logging

Enable `ALL` logging level for `org.apache.spark.internal.io.FileCommitProtocol` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.internal.io.FileCommitProtocol=ALL
```

Refer to [Logging](spark-logging.md).
