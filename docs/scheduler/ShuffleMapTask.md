# ShuffleMapTask

`ShuffleMapTask` is a [Task](Task.md) to produce a [MapStatus](MapStatus.md) (`Task[MapStatus]`).

`ShuffleMapTask` is one of the two types of [Task](Task.md)s. When [executed](#runTask), `ShuffleMapTask` writes the result of executing a [serialized task code](#taskBinary) over the records (of a [RDD partition](#partition)) to the [shuffle system](../shuffle/ShuffleManager.md) and returns a [MapStatus](MapStatus.md) (with the [BlockManager](../storage/BlockManager.md) and estimated size of the result shuffle blocks).

![ShuffleMapTask and DAGScheduler](../images/scheduler/ShuffleMapTask.png)

## Creating Instance

`ShuffleMapTask` takes the following to be created:

* <span id="stageId"> Stage ID
* <span id="stageAttemptId"> Stage Attempt ID
* [Broadcast variable with a serialized task binary](#taskBinary)
* <span id="partition"> [Partition](../rdd/Partition.md)
* <span id="locs"> [TaskLocation](TaskLocation.md)s
* <span id="localProperties"> [Local Properties](../SparkContext.md#localProperties)
* <span id="serializedTaskMetrics"> Serialized task metrics
* <span id="jobId"> [Job ID](ActiveJob.md) (default: `None`)
* <span id="appId"> Application ID (default: `None`)
* <span id="appAttemptId"> Application Attempt ID (default: `None`)
* <span id="isBarrier"> `isBarrier` Flag (default: `false`)

`ShuffleMapTask` is created when `DAGScheduler` is requested to [submit tasks for all missing partitions of a ShuffleMapStage](DAGScheduler.md#submitMissingTasks).

## <span id="taskBinary"> Serialized Task Binary

```scala
taskBinary: Broadcast[Array[Byte]]
```

`ShuffleMapTask` is given a [broadcast variable](../broadcast-variables/index.md) with a reference to a serialized task binary.

[runTask](#runTask) expects that the serialized task binary is a tuple of an [RDD](../rdd/RDD.md) and a [ShuffleDependency](../rdd/ShuffleDependency.md).

## <span id="runTask"> Running Task

```scala
runTask(
  context: TaskContext): MapStatus
```

`runTask` writes the result (_records_) of executing the [serialized task code](#taskBinary) over the records (in the [RDD partition](#partition)) to the [shuffle system](../shuffle/ShuffleManager.md) and returns a [MapStatus](MapStatus.md) (with the [BlockManager](../storage/BlockManager.md) and an estimated size of the result shuffle blocks).

Internally, `runTask` requests the [SparkEnv](../SparkEnv.md) for the new instance of [closure serializer](../SparkEnv.md#closureSerializer) and requests it to [deserialize](../serializer/Serializer.md#deserialize) the [serialized task code](#taskBinary) (into a tuple of a [RDD](../rdd/RDD.md) and a [ShuffleDependency](../rdd/ShuffleDependency.md)).

`runTask` measures the [thread](Task.md#_executorDeserializeTime) and [CPU](Task.md#_executorDeserializeCpuTime) deserialization times.

`runTask` requests the [SparkEnv](../SparkEnv.md) for the [ShuffleManager](../SparkEnv.md#shuffleManager) and requests it for a [ShuffleWriter](../shuffle/ShuffleManager.md#getWriter) (for the [ShuffleHandle](../rdd/ShuffleDependency.md#shuffleHandle) and the [partition](Task.md#partitionId)).

`runTask` then requests the [RDD](#rdd) for the [records](../rdd/RDD.md#iterator) (of the [partition](#partition)) that the `ShuffleWriter` is requested to [write out](../shuffle/ShuffleWriter.md#write) (to the shuffle system).

In the end, `runTask` requests the `ShuffleWriter` to [stop](../shuffle/ShuffleWriter.md#stop) (with the `success` flag on) and returns the [shuffle map output status](MapStatus.md).

!!! note
    This is the moment in ``Task``'s lifecycle (and its corresponding RDD) when a [RDD partition is computed](../rdd/index.md#iterator) and in turn becomes a sequence of records (i.e. real data) on an executor.

In case of any exceptions, `runTask` requests the `ShuffleWriter` to [stop](../shuffle/ShuffleWriter.md#stop) (with the `success` flag off) and (re)throws the exception.

`runTask` may also print out the following DEBUG message to the logs when the `ShuffleWriter` could not be [stopped](../shuffle/ShuffleWriter.md#stop).

```text
Could not stop writer
```

`runTask` is part of the [Task](Task.md#runTask) abstraction.

## <span id="preferredLocations"><span id="preferredLocs">  Preferred Locations

```scala
preferredLocations: Seq[TaskLocation]
```

`preferredLocations` is part of the [Task](Task.md#preferredLocations) abstraction.

`preferredLocations` returns `preferredLocs` internal property.

`ShuffleMapTask` tracks [TaskLocation](TaskLocation.md)s as unique entries in the given [locs](#locs) (with the only rule that when `locs` is not defined, it is empty, and no task location preferences are defined).

`ShuffleMapTask` initializes the `preferredLocs` internal property when [created](#creating-instance)

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.ShuffleMapTask` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.ShuffleMapTask=ALL
```

Refer to [Logging](../spark-logging.md).
