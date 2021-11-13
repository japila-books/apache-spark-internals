# Stage

`Stage` is an [abstraction](#contract) of [steps](#implementations) in a physical execution plan.

!!! note
    The **logical DAG** or **logical execution plan** is the [RDD lineage](../rdd/lineage.md).

Indirectly, a `Stage` is a set of parallel tasks - one task per partition (of an RDD that computes partial results of a function executed as part of a Spark job).

![Stage, tasks and submitting a job](../images/scheduler/stage-tasks.png)

In other words, a Spark job is a computation "sliced" (not to use the reserved term _partitioned_) into stages.

## Contract

### <span id="findMissingPartitions"> Missing Partitions

```scala
findMissingPartitions(): Seq[Int]
```

Missing partitions (IDs of the partitions of the [RDD](#rdd) that are missing and need to be computed)

Used when:

* `DAGScheduler` is requested to [submit missing tasks](DAGScheduler.md#submitMissingTasks)

## Implementations

* [ResultStage](ResultStage.md)
* [ShuffleMapStage](ShuffleMapStage.md)

## Creating Instance

`Stage` takes the following to be created:

* [Stage ID](#id)
* [RDD](#rdd)
* <span id="numTasks"> Number of tasks
* <span id="parents"> Parent `Stage`s
* <span id="firstJobId"> First Job ID
* <span id="callSite"> `CallSite`
* <span id="resourceProfileId"> Resource Profile ID

!!! note "Abstract Class"
    `Stage` is an abstract class and cannot be created directly. It is created indirectly for the [concrete Stages](#implementations).

## <span id="rdd"> RDD

`Stage` is given a [RDD](../rdd/RDD.md) when [created](#creating-instance).

## <span id="id"> Stage ID

`Stage` is given an unique ID when [created](#creating-instance).

!!! note
    `DAGScheduler` uses [nextStageId](DAGScheduler.md#nextStageId) internal counter to track the number of [stage submissions](DAGScheduler.md#submitStage).

## <span id="makeNewStageAttempt"> Making New Stage Attempt

```scala
makeNewStageAttempt(
  numPartitionsToCompute: Int,
  taskLocalityPreferences: Seq[Seq[TaskLocation]] = Seq.empty): Unit
```

`makeNewStageAttempt` creates a new [TaskMetrics](../executor/TaskMetrics.md) and requests it to [register itself](../executor/TaskMetrics.md#register) with the [SparkContext](../rdd/RDD.md#sparkContext) of the [RDD](#rdd).

`makeNewStageAttempt` [creates a StageInfo](StageInfo.md#fromStage) from this `Stage` (and the [nextAttemptId](#nextAttemptId)). This `StageInfo` is saved in the [_latestInfo](#_latestInfo) internal registry.

In the end, `makeNewStageAttempt` increments the [nextAttemptId](#nextAttemptId) internal counter.

!!! note
    `makeNewStageAttempt` returns `Unit` (nothing) and its purpose is to update the [latest StageInfo](#_latestInfo) internal registry.

`makeNewStageAttempt` is used when:

* `DAGScheduler` is requested to [submit the missing tasks of a stage](DAGScheduler.md#submitMissingTasks)
