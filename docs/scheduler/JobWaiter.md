= [[JobWaiter]] JobWaiter

[source, scala]
----
JobWaiter[T](
  dagScheduler: DAGScheduler,
  val jobId: Int,
  totalTasks: Int,
  resultHandler: (Int, T) => Unit)
extends JobListener
----

`JobWaiter` is a scheduler:spark-scheduler-JobListener.md[JobListener] that is used when `DAGScheduler` scheduler:DAGScheduler.md#submitJob[submits a job] or scheduler:DAGScheduler.md#submitMapStage[submits a map stage].

You can use a `JobWaiter` to block until the job finishes executing or to cancel it.

While the methods execute, scheduler:DAGSchedulerEventProcessLoop.md#JobSubmitted[`JobSubmitted`] and scheduler:DAGSchedulerEventProcessLoop.md#MapStageSubmitted[MapStageSubmitted] events are posted that reference the `JobWaiter`.

As a `JobListener`, `JobWaiter` gets notified about task completions or failures, using `taskSucceeded` and `jobFailed`, respectively. When the total number of tasks (that equals the number of partitions to compute) equals the number of `taskSucceeded`, the `JobWaiter` instance is marked successful. A `jobFailed` event marks the `JobWaiter` instance failed.
