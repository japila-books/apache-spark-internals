= FileCommitProtocol

`FileCommitProtocol` is an <<contract, abstraction>> of <<implementations, committers>> that can setup, commit or abort a Spark job or task (while writing out a key-value RDD and the partitions).

`FileCommitProtocol` is used for xref:rdd:PairRDDFunctions.adoc#saveAsNewAPIHadoopDataset[saveAsNewAPIHadoopDataset] and xref:rdd:PairRDDFunctions.adoc#saveAsHadoopDataset[saveAsHadoopDataset] transformations (that use `SparkHadoopWriter` utility to <<spark-internal-io-SparkHadoopWriter.adoc#write, write a key-value RDD out>>).

A concrete <<implementations, FileCommitProtocol>> is created using <<instantiate, FileCommitProtocol.instantiate>> utility.

[[contract]]
.FileCommitProtocol Contract
[cols="30m,70",options="header",width="100%"]
|===
| Method
| Description

| abortJob
a| [[abortJob]]

[source, scala]
----
abortJob(
  jobContext: JobContext): Unit
----

Aborts a job

Used when:

* `SparkHadoopWriter` utility is used to <<spark-internal-io-SparkHadoopWriter.adoc#write, write a key-value RDD>>

* (Spark SQL) `FileFormatWriter` utility is used to write a result of a structured query

| abortTask
a| [[abortTask]]

[source, scala]
----
abortTask(
  taskContext: TaskAttemptContext): Unit
----

Intercepts that a Spark task is (about to be) aborted

Used when:

* `SparkHadoopWriter` utility is used to <<spark-internal-io-SparkHadoopWriter.adoc#executeTask, write an RDD partition>>

* (Spark SQL) `FileFormatDataWriter` is requested to abort (when `FileFormatWriter` utility is used to write a result of a structured query)

| commitJob
a| [[commitJob]]

[source, scala]
----
commitJob(
  jobContext: JobContext,
  taskCommits: Seq[TaskCommitMessage]): Unit
----

Used when:

* `SparkHadoopWriter` utility is used to <<spark-internal-io-SparkHadoopWriter.adoc#write, write a key-value RDD>>

* (Spark SQL) `FileFormatWriter` utility is used to write a result of a structured query

| commitTask
a| [[commitTask]]

[source, scala]
----
commitTask(
  taskContext: TaskAttemptContext): TaskCommitMessage
----

Used when:

* `SparkHadoopWriter` utility is used to <<spark-internal-io-SparkHadoopWriter.adoc#executeTask, write an RDD partition>>

* (Spark SQL) `FileFormatDataWriter` is requested to commit (when `FileFormatWriter` utility is used to write a result of a structured query)

| newTaskTempFile
a| [[newTaskTempFile]]

[source, scala]
----
newTaskTempFile(
  taskContext: TaskAttemptContext,
  dir: Option[String],
  ext: String): String
----

Used when:

* (Spark SQL) `SingleDirectoryDataWriter` and `DynamicPartitionDataWriter` are requested to `write` (and in turn `newOutputWriter`)

| newTaskTempFileAbsPath
a| [[newTaskTempFileAbsPath]]

[source, scala]
----
newTaskTempFileAbsPath(
  taskContext: TaskAttemptContext,
  absoluteDir: String,
  ext: String): String
----

Used when:

* (Spark SQL) `DynamicPartitionDataWriter` is requested to `write`

| onTaskCommit
a| [[onTaskCommit]]

[source, scala]
----
onTaskCommit(
  taskCommit: TaskCommitMessage): Unit = {}
----

Used when:

* (Spark SQL) `FileFormatWriter` is requested to `write`

| setupJob
a| [[setupJob]]

[source, scala]
----
setupJob(
  jobContext: JobContext): Unit
----

Used when:

* `SparkHadoopWriter` utility is used to <<spark-internal-io-SparkHadoopWriter.adoc#executeTask, write an RDD partition>> (while <<spark-internal-io-SparkHadoopWriter.adoc#write, writing out a key-value RDD>>)

* (Spark SQL) `FileFormatWriter` utility is used to write a result of a structured query

| setupTask
a| [[setupTask]]

[source, scala]
----
setupTask(
  taskContext: TaskAttemptContext): Unit
----

Sets up the task with the Hadoop https://hadoop.apache.org/docs/r2.7.3/api/org/apache/hadoop/mapreduce/TaskAttemptContext.html[TaskAttemptContext]

Used when:

* `SparkHadoopWriter` is requested to <<spark-internal-io-SparkHadoopWriter.adoc#executeTask, write an RDD partition>> (while <<spark-internal-io-SparkHadoopWriter.adoc#write, writing out a key-value RDD>>)

* (Spark SQL) `FileFormatWriter` utility is used to write out a RDD partition (while writing out a result of a structured query)

|===

[[implementations]]
.FileCommitProtocols
[cols="30,70",options="header",width="100%"]
|===
| FileCommitProtocol
| Description

| <<spark-internal-io-HadoopMapReduceCommitProtocol.adoc#, HadoopMapReduceCommitProtocol>>
| [[HadoopMapReduceCommitProtocol]]

| <<spark-internal-io-HadoopMapRedCommitProtocol.adoc#, HadoopMapRedCommitProtocol>>
| [[HadoopMapRedCommitProtocol]]

| `SQLHadoopMapReduceCommitProtocol`
| [[SQLHadoopMapReduceCommitProtocol]] Used for batch queries (Spark SQL)

| `ManifestFileCommitProtocol`
| [[ManifestFileCommitProtocol]] Used for streaming queries (Spark Structured Streaming)

|===

== [[instantiate]] Instantiating FileCommitProtocol Committer -- `instantiate` Utility

[source, scala]
----
instantiate(
  className: String,
  jobId: String,
  outputPath: String,
  dynamicPartitionOverwrite: Boolean = false): FileCommitProtocol
----

`instantiate` prints out the following DEBUG message to the logs:

```
Creating committer [className]; job [jobId]; output=[outputPath]; dynamic=[dynamicPartitionOverwrite]
```

`instantiate` tries to find a constructor method that takes three arguments (two of type `String` and one `Boolean`) for the given `jobId`, `outputPath` and `dynamicPartitionOverwrite` flag. If found, `instantiate` prints out the following DEBUG message to the logs:

```
Using (String, String, Boolean) constructor
```

In case of `NoSuchMethodException`, `instantiate` prints out the following DEBUG message to the logs:

```
Falling back to (String, String) constructor
```

`instantiate` tries to find a constructor method that takes two arguments (two of type `String`) for the given `jobId` and `outputPath`.

With two `String` arguments, `instantiate` requires that the given `dynamicPartitionOverwrite` flag is disabled (`false`) or throws an `IllegalArgumentException`:

[options="wrap"]
----
requirement failed: Dynamic Partition Overwrite is enabled but the committer [className] does not have the appropriate constructor
----

[NOTE]
====
`instantiate` is used when:

* <<spark-internal-io-HadoopMapRedWriteConfigUtil.adoc#createCommitter, HadoopMapRedWriteConfigUtil>> and <<spark-internal-io-HadoopMapReduceWriteConfigUtil.adoc#createCommitter, HadoopMapReduceWriteConfigUtil>> are requested to create a <<spark-internal-io-HadoopMapReduceCommitProtocol.adoc#, HadoopMapReduceCommitProtocol>> committer

* (Spark SQL) `InsertIntoHadoopFsRelationCommand`, `InsertIntoHiveDirCommand`, and `InsertIntoHiveTable` logical commands are executed

* (Spark Structured Streaming) `FileStreamSink` is requested to `addBatch`
====

== [[deleteWithJob]] `deleteWithJob` Method

[source, scala]
----
deleteWithJob(
  fs: FileSystem,
  path: Path,
  recursive: Boolean): Boolean
----

`deleteWithJob` simply requests the Hadoop https://hadoop.apache.org/docs/r2.7.3/api/org/apache/hadoop/fs/FileSystem.html[FileSystem] to delete a directory.

NOTE: `deleteWithJob` is used when `InsertIntoHadoopFsRelationCommand` logical command (Spark SQL) is executed.
