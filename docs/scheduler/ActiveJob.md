# ActiveJob

`ActiveJob` (_job_, _action job_) is a top-level work item (computation) submitted to [DAGScheduler](DAGScheduler.md) for execution (usually to compute the result of an `RDD` action).

![RDD actions submit jobs to DAGScheduler](../images/scheduler/action-job.png)

Executing a job is equivalent to computing the partitions of the RDD an action has been executed upon. The number of partitions (`numPartitions`) to compute in a job depends on the type of a stage ([ResultStage](ResultStage.md) or [ShuffleMapStage](ShuffleMapStage.md)).

A job starts with a single target RDD, but can ultimately include other `RDD`s that are all part of [RDD lineage](../rdd/lineage.md).

The parent stages are always [ShuffleMapStage](ShuffleMapStage.md)s.

![Computing a job is computing the partitions of an RDD](../images/scheduler/rdd-job-partitions.png)

!!! note
    Not always all partitions have to be computed for [ResultStage](ResultStage.md)s (e.g. for actions like `first()` and `lookup()`).

## Creating Instance

`ActiveJob` takes the following to be created:

* <span id="jobId"> Job ID
* [Final Stage](#finalStage)
* <span id="callSite"> `CallSite`
* <span id="listener"> [JobListener](JobListener.md)
* <span id="properties"> `Properties`

`ActiveJob` is created when:

* `DAGScheduler` is requested to [handleJobSubmitted](DAGScheduler.md#handleJobSubmitted) and [handleMapStageSubmitted](DAGScheduler.md#handleMapStageSubmitted)

## <span id="finalStage"> Final Stage

`ActiveJob` is given a [Stage](Stage.md) when [created](#creating-instance) that determines a logical type:

1. **Map-Stage Job** that computes the map output files for a [ShuffleMapStage](ShuffleMapStage.md) (for `submitMapStage`) before any downstream stages are submitted
1. **Result job** that computes a [ResultStage](ResultStage.md) to execute an action

## <Span id="finished"> Finished (Computed) Partitions

`ActiveJob` uses `finished` registry of flags to track partitions that have already been computed (`true`) or not (`false`).
