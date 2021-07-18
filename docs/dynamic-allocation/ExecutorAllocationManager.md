# ExecutorAllocationManager

`ExecutorAllocationManager` can be used to dynamically allocate [executors](../executor/Executor.md) based on processing workload.

`ExecutorAllocationManager` intercepts Spark events using the internal [ExecutorAllocationListener](ExecutorAllocationListener.md) that keeps track of the workload.

## Creating Instance

`ExecutorAllocationManager` takes the following to be created:

* [ExecutorAllocationClient](#client)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="cleaner"> [ContextCleaner](../core/ContextCleaner.md) (default: `None`)
* <span id="clock"> `Clock` (default: `SystemClock`)

`ExecutorAllocationManager` is created (and started) when [SparkContext](../SparkContext.md) is [created](../SparkContext-creating-instance-internals.md#ExecutorAllocationManager) (with [Dynamic Allocation of Executors](index.md) enabled)

### <span id="validateSettings"> Validating Configuration

```scala
validateSettings(): Unit
```

`validateSettings` makes sure that the [settings for dynamic allocation](index.md#settings) are correct.

`validateSettings` throws a `SparkException` when the following are not met:

* [spark.dynamicAllocation.minExecutors](configuration-properties.md#spark.dynamicAllocation.minExecutors) must be positive

* [spark.dynamicAllocation.maxExecutors](configuration-properties.md#spark.dynamicAllocation.maxExecutors) must be `0` or greater

* [spark.dynamicAllocation.minExecutors](configuration-properties.md#spark.dynamicAllocation.minExecutors) must be less than or equal to [spark.dynamicAllocation.maxExecutors](configuration-properties.md#spark.dynamicAllocation.maxExecutors)

* [spark.dynamicAllocation.executorIdleTimeout](configuration-properties.md#spark.dynamicAllocation.executorIdleTimeout) must be greater than `0`

* [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) must be enabled.

* The number of tasks per core, i.e. [spark.executor.cores](../executor/Executor.md#spark.executor.cores) divided by [spark.task.cpus](configuration-properties.md#spark.task.cpus), is not zero.

## Performance Metrics

`ExecutorAllocationManager` uses [ExecutorAllocationManagerSource](ExecutorAllocationManagerSource.md) for performance metrics.

## <span id="executorMonitor"> ExecutorMonitor

`ExecutorAllocationManager` creates an [ExecutorMonitor](ExecutorMonitor.md) when [created](#creating-instance).

`ExecutorMonitor` is [added to the management queue](../scheduler/LiveListenerBus.md#addToManagementQueue) (of [LiveListenerBus](#listenerBus)) when `ExecutorAllocationManager` is [started](#start).

`ExecutorMonitor` is [attached](../core/ContextCleaner.md#attachListener) (to the [ContextCleaner](#cleaner)) when `ExecutorAllocationManager` is [started](#start).

`ExecutorMonitor` is requested to [reset](ExecutorMonitor.md#reset) when `ExecutorAllocationManager` is requested to [reset](#reset).

`ExecutorMonitor` is used for the performance metrics:

* [numberExecutorsPendingToRemove](#numberExecutorsPendingToRemove) (based on [pendingRemovalCount](ExecutorMonitor.md#pendingRemovalCount))
* [numberAllExecutors](#numberAllExecutors) (based on [executorCount](ExecutorMonitor.md#executorCount))

`ExecutorMonitor` is used for the following:

* [timedOutExecutors](ExecutorMonitor.md#timedOutExecutors) when `ExecutorAllocationManager` is requested to [schedule](#schedule)
* [executorCount](ExecutorMonitor.md#executorCount) when `ExecutorAllocationManager` is requested to [addExecutors](#addExecutors)
* [executorCount](ExecutorMonitor.md#executorCount), [pendingRemovalCount](ExecutorMonitor.md#pendingRemovalCount) and [executorsKilled](ExecutorMonitor.md#executorsKilled) when `ExecutorAllocationManager` is requested to [removeExecutors](#removeExecutors)

## <span id="listener"> ExecutorAllocationListener

`ExecutorAllocationManager` creates an [ExecutorAllocationListener](ExecutorAllocationListener.md) when [created](#creating-instance) to intercept Spark events that impact the allocation policy.

`ExecutorAllocationListener` is [added to the management queue](../scheduler/LiveListenerBus.md#addToManagementQueue) (of [LiveListenerBus](#listenerBus)) when `ExecutorAllocationManager` is [started](#start).

`ExecutorAllocationListener` is used to calculate the [maximum number of executors needed](#maxNumExecutorsNeeded).

## <span id="executorAllocationRatio"><span id="spark.dynamicAllocation.executorAllocationRatio"> spark.dynamicAllocation.executorAllocationRatio

`ExecutorAllocationManager` uses [spark.dynamicAllocation.executorAllocationRatio](configuration-properties.md#spark.dynamicAllocation.executorAllocationRatio) configuration property for [maxNumExecutorsNeeded](#maxNumExecutorsNeeded).

## <span id="tasksPerExecutorForFullParallelism"> tasksPerExecutorForFullParallelism

`ExecutorAllocationManager` uses [spark.executor.cores](../configuration-properties.md#spark.executor.cores) and [spark.task.cpus](../configuration-properties.md#spark.task.cpus) configuration properties for the number of tasks that can be submitted to an executor for full parallelism.

Used when:

* [maxNumExecutorsNeeded](#maxNumExecutorsNeeded)

## <span id="maxNumExecutorsNeeded"> Maximum Number of Executors Needed

```scala
maxNumExecutorsNeeded(): Int
```

`maxNumExecutorsNeeded` requests the [ExecutorAllocationListener](#listener) for the number of [pending](ExecutorAllocationListener.md#totalPendingTasks) and [running](ExecutorAllocationListener.md#totalRunningTasks) tasks.

`maxNumExecutorsNeeded` is the smallest integer value that is greater than or equal to the multiplication of the total number of pending and running tasks by [executorAllocationRatio](#executorAllocationRatio) divided by [tasksPerExecutorForFullParallelism](#tasksPerExecutorForFullParallelism).

`maxNumExecutorsNeeded` is used for:

* [updateAndSyncNumExecutorsTarget](#updateAndSyncNumExecutorsTarget)
* [numberMaxNeededExecutors](#numberMaxNeededExecutors) performance metric

## <span id="client"><span id="ExecutorAllocationClient"> ExecutorAllocationClient

`ExecutorAllocationManager` is given an [ExecutorAllocationClient](ExecutorAllocationClient.md) when [created](#creating-instance).

## <span id="start"> Starting ExecutorAllocationManager

```scala
start(): Unit
```

`start` requests the [LiveListenerBus](#listenerBus) to [add to the management queue](../scheduler/LiveListenerBus.md#addToManagementQueue):

* [ExecutorAllocationListener](#listener)
* [ExecutorMonitor](#executorMonitor)

`start` requests the [ContextCleaner](#cleaner) (if defined) to [attach](../core/ContextCleaner.md#attachListener) the [ExecutorMonitor](#executorMonitor).

creates a `scheduleTask` (a Java [Runnable]({{ java.api }}/java.base/java/lang/Runnable.html)) for [schedule](#schedule) when started.

`start` requests the [ScheduledExecutorService](#executor) to schedule the `scheduleTask` every `100` ms.

!!! note
    The schedule delay of `100` is not configurable.

`start` requests the [ExecutorAllocationClient](#client) to [request the total executors](ExecutorAllocationClient.md#requestTotalExecutors) with the following:

* [numExecutorsTarget](#numExecutorsTarget)
* [localityAwareTasks](#localityAwareTasks)
* [hostToLocalTaskCount](#hostToLocalTaskCount)

`start` is used when `SparkContext` is [created](../SparkContext-creating-instance-internals.md#ExecutorAllocationManager).

### <span id="schedule"> Scheduling Executors

```scala
schedule(): Unit
```

`schedule` requests the [ExecutorMonitor](#executorMonitor) for [timedOutExecutors](ExecutorMonitor.md#timedOutExecutors).

If there are executors to be removed, `schedule` turns the [initializing](#initializing) internal flag off.

`schedule` [updateAndSyncNumExecutorsTarget](#updateAndSyncNumExecutorsTarget) with the current time.

In the end, `schedule` [removes the executors](#removeExecutors) to be removed if there are any.

### <span id="updateAndSyncNumExecutorsTarget"> updateAndSyncNumExecutorsTarget

```scala
updateAndSyncNumExecutorsTarget(
  now: Long): Int
```

`updateAndSyncNumExecutorsTarget` [maxNumExecutorsNeeded](#maxNumExecutorsNeeded).

`updateAndSyncNumExecutorsTarget`...FIXME

## <span id="stop"> Stopping ExecutorAllocationManager

```scala
stop(): Unit
```

`stop` shuts down <<spark-dynamic-executor-allocation, spark-dynamic-executor-allocation allocation executor>>.

!!! note
    `stop` waits 10 seconds for the termination to be complete.

`stop` is used when `SparkContext` is requested to [stop](../SparkContext.md#stop)

## <span id="spark-dynamic-executor-allocation"><span id="executor"> spark-dynamic-executor-allocation Allocation Executor

`spark-dynamic-executor-allocation` allocation executor is a...FIXME

## <span id="executorAllocationManagerSource"> ExecutorAllocationManagerSource

[ExecutorAllocationManagerSource](ExecutorAllocationManagerSource.md)

## <span id="removeExecutors"> Removing Executors

```scala
removeExecutors(
  executors: Seq[(String, Int)]): Seq[String]
```

`removeExecutors`...FIXME

`removeExecutors` is used when:

* `ExecutorAllocationManager` is requested to [schedule executors](#schedule)

## Logging

Enable `ALL` logging level for `org.apache.spark.ExecutorAllocationManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.ExecutorAllocationManager=ALL
```

Refer to [Logging](../spark-logging.md).
