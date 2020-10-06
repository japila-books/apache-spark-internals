= ShuffleMapTask

ShuffleMapTask is one of the two types of scheduler:Task.md[tasks] that, when <<runTask, executed>>, writes the result of executing a <<taskBinary, serialized task code>> over the records (of a <<partition, RDD partition>>) to the shuffle:ShuffleManager.md[shuffle system] and returns a scheduler:MapStatus.md[MapStatus] (information about the storage:BlockManager.md[BlockManager] and estimated size of the result shuffle blocks).

.ShuffleMapTask and DAGScheduler
image::ShuffleMapTask.png[align="center"]

== [[creating-instance]] Creating Instance

ShuffleMapTask takes the following to be created:

* [[stageId]] Stage ID
* [[stageAttemptId]] Stage attempt ID
* <<taskBinary, Broadcast variable with a serialized task binary>>
* [[partition]] rdd:spark-rdd-Partition.md[Partition]
* [[locs]] scheduler:TaskLocation.md[TaskLocations]
* [[localProperties]] Task-specific local properties
* [[serializedTaskMetrics]] Serialized task metrics (`Array[Byte]`)
* [[jobId]] Optional scheduler:spark-scheduler-ActiveJob.md[job ID] (default: `None`)
* [[appId]] Optional application ID (default: `None`)
* [[appAttemptId]] Optional application attempt ID (default: `None`)
* [[isBarrier]] isBarrier flag (default: `false`)

ShuffleMapTask is created when DAGScheduler is requested to scheduler:DAGScheduler.md#submitMissingTasks[submit tasks for all missing partitions of a ShuffleMapStage].

== [[taskBinary]] Broadcast Variable and Serialized Task Binary

ShuffleMapTask is given a ROOT:Broadcast.md[] with a reference to a serialized task binary (`Broadcast[Array[Byte]]`).

<<runTask, runTask>> expects that the serialized task binary is a tuple of an rdd:RDD.md[RDD] and a rdd:ShuffleDependency.md[ShuffleDependency].

== [[runTask]] Running Task

[source, scala]
----
runTask(
  context: TaskContext): MapStatus
----

runTask writes the result (_records_) of executing the <<taskBinary, serialized task code>> over the records (in the <<partition, RDD partition>>) to the shuffle:ShuffleManager.md[shuffle system] and returns a scheduler:MapStatus.md[MapStatus] (with the storage:BlockManager.md[BlockManager] and an estimated size of the result shuffle blocks).

Internally, runTask requests the core:SparkEnv.md[SparkEnv] for the new instance of core:SparkEnv.md#closureSerializer[closure serializer] and requests it to serializer:Serializer.md#deserialize[deserialize] the <<taskBinary, taskBinary>> (into a tuple of a rdd:RDD.md[RDD] and a rdd:ShuffleDependency.md[ShuffleDependency]).

runTask measures the scheduler:Task.md#_executorDeserializeTime[thread] and scheduler:Task.md#_executorDeserializeCpuTime[CPU] deserialization times.

runTask requests the core:SparkEnv.md[SparkEnv] for the core:SparkEnv.md#shuffleManager[ShuffleManager] and requests it for a shuffle:ShuffleManager.md#getWriter[ShuffleWriter] (for the rdd:ShuffleDependency.md#shuffleHandle[ShuffleHandle], the scheduler:Task.md#partitionId[RDD partition], and the scheduler:spark-TaskContext.md[TaskContext]).

runTask then requests the <<rdd, RDD>> for the rdd:RDD.md#iterator[records] (of the <<partition, partition>>) that the `ShuffleWriter` is requested to shuffle:ShuffleWriter.md#write[write out] (to the shuffle system).

In the end, runTask requests the `ShuffleWriter` to shuffle:ShuffleWriter.md#stop[stop] (with the `success` flag on) and returns the scheduler:MapStatus.md[shuffle map output status].

NOTE: This is the moment in ``Task``'s lifecycle (and its corresponding RDD) when a rdd:index.md#iterator[RDD partition is computed] and in turn becomes a sequence of records (i.e. real data) on an executor.

In case of any exceptions, runTask requests the `ShuffleWriter` to shuffle:ShuffleWriter.md#stop[stop] (with the `success` flag off) and (re)throws the exception.

runTask may also print out the following DEBUG message to the logs when the `ShuffleWriter` could not be shuffle:ShuffleWriter.md#stop[stopped].

[source,plaintext]
----
Could not stop writer
----

runTask is part of scheduler:Task.md#runTask[Task] abstraction.

== [[preferredLocations]] preferredLocations Method

[source, scala]
----
preferredLocations: Seq[TaskLocation]
----

preferredLocations simply returns the <<preferredLocs, preferredLocs>> internal property.

preferredLocations is part of scheduler:Task.md#preferredLocations[Task] abstraction.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.ShuffleMapTask` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.scheduler.ShuffleMapTask=ALL
----

Refer to ROOT:spark-logging.md[Logging].

== [[preferredLocs]] Preferred Locations

scheduler:TaskLocation.md[TaskLocations] that are the unique entries in the given <<locs, locs>> with the only rule that when `locs` is not defined, it is empty, and no task location preferences are defined.

Initialized when ShuffleMapTask is <<creating-instance, created>>

Used exclusively when ShuffleMapTask is requested for the <<preferredLocations, preferred locations>>
