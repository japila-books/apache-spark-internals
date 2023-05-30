# SparkCoreErrors

## numPartitionsGreaterThanMaxNumConcurrentTasksError { #numPartitionsGreaterThanMaxNumConcurrentTasksError }

```scala
numPartitionsGreaterThanMaxNumConcurrentTasksError(
  numPartitions: Int,
  maxNumConcurrentTasks: Int): Throwable
```

`numPartitionsGreaterThanMaxNumConcurrentTasksError` creates a [BarrierJobSlotsNumberCheckFailed](barrier-execution-mode/BarrierJobSlotsNumberCheckFailed.md) with the given input arguments.

---

`numPartitionsGreaterThanMaxNumConcurrentTasksError` is used when:

* `DAGScheduler` is requested to [checkBarrierStageWithNumSlots](scheduler/DAGScheduler.md#checkBarrierStageWithNumSlots)
