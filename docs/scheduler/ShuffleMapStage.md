# ShuffleMapStage

`ShuffleMapStage` is a [Stage](Stage.md).

`ShuffleMapStage` (_shuffle map stage_ or simply _map stage_) is one of the two types of [Stage](Stage.md)s in a physical execution DAG (beside a [ResultStage](ResultStage.md)).

!!! note
    The **logical DAG** or **logical execution plan** is the [RDD lineage](../rdd/lineage.md).

`ShuffleMapStage` corresponds to (and is associated with) a [ShuffleDependency](#shuffleDep).

`ShuffleMapStage` can be [submitted independently](DAGScheduler.md#submitMapStage) (from a [ResultStage](ResultStage.md)).

## Creating Instance

`ShuffleMapStage` takes the following to be created:

* <span id="id"> Stage ID
* <span id="rdd"> [RDD](../rdd/ShuffleDependency.md#rdd) (of the [ShuffleDependency](#shuffleDep))
* <span id="numTasks"> Number of tasks
* <span id="parents"> Parent [Stage](Stage.md)s
* <span id="firstJobId"> First Job ID (of the [ActiveJob](ActiveJob.md) that created it)
* <span id="callSite"> `CallSite`
* <span id="shuffleDep"> [ShuffleDependency](../rdd/ShuffleDependency.md)
* <span id="mapOutputTrackerMaster"> [MapOutputTrackerMaster](MapOutputTrackerMaster.md)
* <span id="resourceProfileId"> Resource Profile ID

`ShuffleMapStage` is created when:

* `DAGScheduler` is requested to [plan a ShuffleDependency for execution](DAGScheduler.md#createShuffleMapStage)

## <span id="findMissingPartitions"> Missing Partitions

```scala
findMissingPartitions(): Seq[Int]
```

`findMissingPartitions` requests the [MapOutputTrackerMaster](#mapOutputTrackerMaster) for the [missing partitions](MapOutputTrackerMaster.md#findMissingPartitions) (of the [ShuffleDependency](#shuffleDep)) and returns them.

If not available (`MapOutputTrackerMaster` does not track the `ShuffleDependency`), `findMissingPartitions` simply assumes that all the [partitions](Stage.md#numPartitions) are missing.

`findMissingPartitions` is part of the [Stage](Stage.md#findMissingPartitions) abstraction.

## ShuffleMapStage Ready

When "executed", a `ShuffleMapStage` saves **map output files** (for reduce tasks).

When [all partitions have shuffle map outputs available](#isAvailable), `ShuffleMapStage` is considered **ready** (_done_ or _available_).

### <span id="isAvailable"> isAvailable

```scala
isAvailable: Boolean
```

`isAvailable` is `true` when the `ShuffleMapStage` is ready and all partitions have shuffle outputs (i.e. the [numAvailableOutputs](#numAvailableOutputs) is exactly the [numPartitions](Stage.md#numPartitions)).

`isAvailable` is used when:

* `DAGScheduler` is requested to [getMissingParentStages](DAGScheduler.md#getMissingParentStages), [handleMapStageSubmitted](DAGScheduler.md#handleMapStageSubmitted), [submitMissingTasks](DAGScheduler.md#submitMissingTasks), [processShuffleMapStageCompletion](DAGScheduler.md#processShuffleMapStageCompletion), [markMapStageJobsAsFinished](DAGScheduler.md#markMapStageJobsAsFinished) and [stageDependsOn](DAGScheduler.md#stageDependsOn)

### <span id="numAvailableOutputs"> Available Outputs

```scala
numAvailableOutputs: Int
```

`numAvailableOutputs` requests the [MapOutputTrackerMaster](#mapOutputTrackerMaster) to [getNumAvailableOutputs](MapOutputTrackerMaster.md#getNumAvailableOutputs) (for the [shuffleId](../rdd/ShuffleDependency.md#shuffleId) of the [ShuffleDependency](#shuffleDep)).

`numAvailableOutputs` is used when:

* `DAGScheduler` is requested to [submitMissingTasks](DAGScheduler.md#submitMissingTasks)
* `ShuffleMapStage` is requested to [isAvailable](#isAvailable)

## <span id="_mapStageJobs"><span id="mapStageJobs"> Active Jobs

`ShuffleMapStage` defines `_mapStageJobs` internal registry of [ActiveJob](ActiveJob.md)s to track jobs that were submitted to execute the stage independently.

A new job is registered (_added_) in [addActiveJob](#addActiveJob).

An active job is deregistered (_removed_) in [removeActiveJob](#removeActiveJob).

### <span id="addActiveJob"> addActiveJob

```scala
addActiveJob(
  job: ActiveJob): Unit
```

`addActiveJob` adds the given [ActiveJob](ActiveJob.md) to (the front of) the [_mapStageJobs](#_mapStageJobs) list.

`addActiveJob` is used when:

* `DAGScheduler` is requested to [handleMapStageSubmitted](DAGScheduler.md#handleMapStageSubmitted)

### <span id="removeActiveJob"> removeActiveJob

```scala
removeActiveJob(
  job: ActiveJob): Unit
```

`removeActiveJob` removes the [ActiveJob](ActiveJob.md) from the [_mapStageJobs](#_mapStageJobs) registry.

`removeActiveJob` is used when:

* `DAGScheduler` is requested to [cleanupStateForJobAndIndependentStages](DAGScheduler.md#cleanupStateForJobAndIndependentStages)

### <span id="mapStageJobs"> mapStageJobs

```scala
mapStageJobs: Seq[ActiveJob]
```

`mapStageJobs` returns the [_mapStageJobs](#_mapStageJobs) list.

`mapStageJobs` is used when:

* `DAGScheduler` is requested to [markMapStageJobsAsFinished](DAGScheduler.md#markMapStageJobsAsFinished)

## Demo: ShuffleMapStage Sharing

A `ShuffleMapStage` can be shared across multiple jobs (if these jobs reuse the same RDDs).

![Skipped Stages are already-computed ShuffleMapStages](../images/scheduler/dagscheduler-webui-skipped-stages.png)

```scala
val keyValuePairs = sc.parallelize(0 to 5).map((_, 1))
val rdd = keyValuePairs.sortByKey()  // (1)

scala> println(rdd.toDebugString)
(6) ShuffledRDD[4] at sortByKey at <console>:39 []
 +-(16) MapPartitionsRDD[1] at map at <console>:39 []
    |   ParallelCollectionRDD[0] at parallelize at <console>:39 []

rdd.count  // (2)
rdd.count  // (3)
```

1. Shuffle at `sortByKey()`
1. Submits a job with two stages (and two to be executed)
1. Intentionally repeat the last action that submits a new job with two stages with one being shared as already-computed
