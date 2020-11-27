# ReliableCheckpointRDD

`ReliableCheckpointRDD` is an [CheckpointRDD](CheckpointRDD.md).

## Creating Instance

ReliableCheckpointRDD takes the following to be created:

* [[sc]] SparkContext.md[]
* [[checkpointPath]] Checkpoint Directory (on a Hadoop DFS-compatible file system)
* <<_partitioner, Partitioner>>

ReliableCheckpointRDD is created when:

* ReliableCheckpointRDD utility is used to <<writeRDDToCheckpointDirectory, created one>>.

* SparkContext is requested to SparkContext.md#checkpointFile[checkpointFile]

== [[checkpointPartitionerFileName]] Checkpointed Partitioner File

ReliableCheckpointRDD uses *_partitioner* as the name of the file in the <<checkpointPath, checkpoint directory>> with the <<partitioner, Partitioner>> serialized to.

== [[partitioner]] Partitioner

ReliableCheckpointRDD can be given a rdd:Partitioner.md[Partitioner] to be created.

When rdd:RDD.md#partitioner[requested for the Partitioner] (as an RDD), ReliableCheckpointRDD returns the one it was created with or <<readCheckpointedPartitionerFile, reads the partitioner from the given RDD checkpoint directory, if exists>>.

== [[writeRDDToCheckpointDirectory]] Writing RDD to Checkpoint Directory

[source, scala]
----
writeRDDToCheckpointDirectory[T: ClassTag](
  originalRDD: RDD[T],
  checkpointDir: String,
  blockSize: Int = -1): ReliableCheckpointRDD[T]
----

writeRDDToCheckpointDirectory...FIXME

writeRDDToCheckpointDirectory is used when ReliableRDDCheckpointData is requested to rdd:ReliableRDDCheckpointData.md#doCheckpoint[doCheckpoint].

== [[writePartitionerToCheckpointDir]] Writing Partitioner to Checkpoint Directory

[source,scala]
----
writePartitionerToCheckpointDir(
  sc: SparkContext,
  partitioner: Partitioner,
  checkpointDirPath: Path): Unit
----

writePartitionerToCheckpointDir creates the <<checkpointPartitionerFileName, partitioner file>> with the buffer size based on configuration-properties.md#spark.buffer.size[spark.buffer.size] configuration property.

writePartitionerToCheckpointDir requests the core:SparkEnv.md#serializer[default Serializer] for a new serializer:Serializer.md#newInstance[SerializerInstance].

writePartitionerToCheckpointDir requests the SerializerInstance to serializer:SerializerInstance.md#serializeStream[serialize the output stream] and serializer:DeserializationStream.md#writeObject[writes] the given Partitioner.

In the end, writePartitionerToCheckpointDir prints out the following DEBUG message to the logs:

[source,plaintext]
----
Written partitioner to [partitionerFilePath]
----

In case of any non-fatal exception, writePartitionerToCheckpointDir prints out the following DEBUG message to the logs:

[source,plaintext]
----
Error writing partitioner [partitioner] to [checkpointDirPath]
----

writePartitionerToCheckpointDir is used when ReliableCheckpointRDD is requested to <<writeRDDToCheckpointDirectory, write the RDD to the checkpoint directory>>.

== [[readCheckpointedPartitionerFile]] Reading Partitioner from Checkpointed Directory

[source,scala]
----
readCheckpointedPartitionerFile(
  sc: SparkContext,
  checkpointDirPath: String): Option[Partitioner]
----

readCheckpointedPartitionerFile opens the <<checkpointPartitionerFileName, partitioner file>> with the buffer size based on configuration-properties.md#spark.buffer.size[spark.buffer.size] configuration property.

readCheckpointedPartitionerFile requests the core:SparkEnv.md#serializer[default Serializer] for a new serializer:Serializer.md#newInstance[SerializerInstance].

readCheckpointedPartitionerFile requests the SerializerInstance to serializer:SerializerInstance.md#deserializeStream[deserialize the input stream] and serializer:DeserializationStream.md#readObject[read the Partitioner] from the partitioner file.

readCheckpointedPartitionerFile prints out the following DEBUG message to the logs and returns the partitioner.

[source,plaintext]
----
Read partitioner from [partitionerFilePath]
----

In case of FileNotFoundException or any non-fatal exceptions, readCheckpointedPartitionerFile prints out a corresponding message to the logs and returns None.

readCheckpointedPartitionerFile is used when ReliableCheckpointRDD is requested for the <<partitioner, Partitioner>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.rdd.ReliableCheckpointRDD$` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.rdd.ReliableCheckpointRDD$=ALL
----

Refer to spark-logging.md[Logging].
