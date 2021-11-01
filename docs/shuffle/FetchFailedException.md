# FetchFailedException

`FetchFailedException` exception [may be thrown when a task runs](../executor/TaskRunner.md#run-FetchFailedException) (and `ShuffleBlockFetcherIterator` could not [fetch shuffle blocks](../storage/ShuffleBlockFetcherIterator.md#throwFetchFailedException)).

When `FetchFailedException` is reported, `TaskRunner` [catches it and notifies the ExecutorBackend](../executor/TaskRunner.md#run-FetchFailedException) (with `TaskState.FAILED` task state).

## Creating Instance

`FetchFailedException` takes the following to be created:

* <span id="bmAddress"> [BlockManagerId](../storage/BlockManagerId.md)
* <span id="shuffleId"> Shuffle ID
* <span id="mapId"> Map ID
* <span id="mapIndex"> Map Index
* <span id="reduceId"> Reduce ID
* <span id="message"> Error Message
* [Error Cause](#cause)

While being created, `FetchFailedException` requests the current [TaskContext](../scheduler/TaskContext.md#get) to [setFetchFailed](../scheduler/TaskContext.md#setFetchFailed).

`FetchFailedException` is created when:

* `ShuffleBlockFetcherIterator` is requested to [throw a FetchFailedException](../storage/ShuffleBlockFetcherIterator.md#throwFetchFailedException) (for a `ShuffleBlockId` or a `ShuffleBlockBatchId`)

## <span id="cause"> Error Cause

`FetchFailedException` can be given an error cause when [created](#creating-instance).

The root cause of the `FetchFailedException` is usually because the [Executor](../executor/Executor.md) (with the [BlockManager](../storage/BlockManager.md) for requested shuffle blocks) is lost and no longer available due to the following:

1. `OutOfMemoryError` could be thrown (aka _OOMed_) or some other unhandled exception
1. The cluster manager that manages the workers with the executors of your Spark application (e.g. Kubernetes, Hadoop YARN) enforces the container memory limits and eventually decides to kill the executor due to excessive memory usage

A solution is usually to tune the memory of your Spark application.

## <span id="TaskContext"> TaskContext

[TaskContext](../scheduler/TaskContext.md) comes with [setFetchFailed](../scheduler/TaskContext.md#setFetchFailed) and [fetchFailed](../scheduler/TaskContext.md#fetchFailed) to hold a `FetchFailedException` unmodified (regardless of what happens in a user code).
