# JobListener

`JobListener` is an [abstraction](#contract) of [listeners](#implementations) that listen for [job completion](#taskSucceeded) or [failure](#jobFailed) events (after submitting a job to the [DAGScheduler](DAGScheduler.md)).

## Contract

### <span id="taskSucceeded"> taskSucceeded

```scala
taskSucceeded(
  index: Int,
  result: Any): Unit
```

Used when `DAGScheduler` is requested to [handleTaskCompletion](DAGScheduler.md#handleTaskCompletion) or [markMapStageJobAsFinished](DAGScheduler.md#markMapStageJobAsFinished)

### <span id="jobFailed"> jobFailed

```scala
jobFailed(
  exception: Exception): Unit
```

Used when `DAGScheduler` is requested to [cleanUpAfterSchedulerStop](DAGScheduler.md#cleanUpAfterSchedulerStop), [handleJobSubmitted](DAGScheduler.md#handleJobSubmitted), [handleMapStageSubmitted](DAGScheduler.md#handleMapStageSubmitted), [handleTaskCompletion](DAGScheduler.md#handleTaskCompletion) or [failJobAndIndependentStages](DAGScheduler.md#failJobAndIndependentStages)

## Implementations

* ApproximateActionListener
* [JobWaiter](JobWaiter.md)
