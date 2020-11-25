# JobWaiter

`JobWaiter` is a [JobListener](JobListener.md) to listen to task events and to know when [all have finished successfully or not](#jobPromise).

## Creating Instance

`JobWaiter` takes the following to be created:

* <span id="dagScheduler"> [DAGScheduler](DAGScheduler.md)
* <span id="jobId"> Job ID
* <span id="totalTasks"> Total number of tasks
* <span id="resultHandler"> Result Handler Function (`(Int, T) => Unit`)

`JobWaiter` is created when `DAGScheduler` is requested to submit a [job](DAGScheduler.md#submitJob) or a [map stage](DAGScheduler.md#submitMapStage).

## <span id="jobPromise"> Scala Promise

```scala
jobPromise: Promise[Unit]
```

`jobPromise` is a Scala [Promise]({{ scala.api }}/scala/concurrent/Promise.html) that is completed when [all tasks have finished successfully](#taskSucceeded) or [failed with an exception](#jobFailed).

## <span id="taskSucceeded"> taskSucceeded

```scala
taskSucceeded(
  index: Int,
  result: Any): Unit
```

`taskSucceeded` executes the [Result Handler Function](#resultHandler) with the given `index` and `result`.

`taskSucceeded` marks the waiter finished successfully when all [tasks](#totalTasks) have finished.

`taskSucceeded` is part of the [JobListener](JobListener.md#taskSucceeded) abstraction.

## <span id="jobFailed"> jobFailed

```scala
jobFailed(
  exception: Exception): Unit
```

`jobFailed` marks the waiter failed.

`jobFailed` is part of the [JobListener](JobListener.md#jobFailed) abstraction.
