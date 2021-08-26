# ResultTask

`ResultTask[T, U]` is a [Task](Task.md) that [executes](#runTask) a partition processing function on a [partition](#partition) with records (of type `T`) to produce a result (of type `U`) that is sent back to the driver.

```text
T -- [ResultTask] --> U
```

## Creating Instance

`ResultTask` takes the following to be created:

* <span id="stageId"> [Stage](Stage.md) ID
* <span id="stageAttemptId"> Stage Attempt ID
* <span id="taskBinary"> [Broadcast variable](../broadcast-variables/index.md) with a serialized task (`Broadcast[Array[Byte]]`)
* <span id="partition"> [Partition](../rdd/Partition.md) to compute
* <span id="locs"> [TaskLocation](../scheduler/TaskLocation.md)
* <span id="outputId"> Output ID
* <span id="localProperties"> [Local Properties](../SparkContext.md#localProperties)
* <span id="serializedTaskMetrics"> Serialized [TaskMetrics](../executor/TaskMetrics.md) (`Array[Byte]`)
* <span id="jobId"> [ActiveJob](ActiveJob.md) ID (optional)
* <span id="appId"> Application ID (optional)
* <span id="appAttemptId"> Application Attempt ID (optional)
* <span id="isBarrier"> `isBarrier` flag (default: `false`)

`ResultTask` is created when:

* `DAGScheduler` is requested to [submit missing tasks](DAGScheduler.md#submitMissingTasks) of a [ResultStage](ResultStage.md)

## <span id="runTask"> Running Task

```scala
runTask(
  context: TaskContext): U
```

`runTask` is part of the [Task](Task.md#runTask) abstraction.

`runTask` deserializes a [RDD](../rdd/RDD.md) and a partition processing function from the [broadcast variable](#taskBinary) (using the [Closure Serializer](../SparkEnv.md#closureSerializer)).

In the end, `runTask` executes the function (on the records from the [partition](#partition) of the `RDD`).
