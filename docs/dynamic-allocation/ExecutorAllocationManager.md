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

`ExecutorAllocationManager` is created when [SparkContext](../SparkContext.md) is created.

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

## <span id="client"><span id="ExecutorAllocationClient"> ExecutorAllocationClient

`ExecutorAllocationManager` is given an [ExecutorAllocationClient](ExecutorAllocationClient.md) when [created](#creating-instance).

## <span id="start"> Starting ExecutorAllocationManager

```scala
start(): Unit
```

`start` registers [ExecutorAllocationListener](ExecutorAllocationListener.md) (with [LiveListenerBus](../scheduler/LiveListenerBus.md)) to monitor scheduler events and make decisions when to add and remove executors. It then immediately starts <<spark-dynamic-executor-allocation, spark-dynamic-executor-allocation allocation executor>> that is responsible for the <<schedule, scheduling>> every `100` milliseconds.

NOTE: `100` milliseconds for the period between successive <<schedule, scheduling>> is fixed, i.e. not configurable.

It [requests executors](ExecutorAllocationClient.md#requestTotalExecutors) using the input [ExecutorAllocationClient](ExecutorAllocationClient.md). It requests [spark.dynamicAllocation.initialExecutors](index.md#spark.dynamicAllocation.initialExecutors).

`start` is used when [SparkContext](../SparkContext.md) is created.

### <span id="schedule"> Scheduling Executors

```scala
schedule(): Unit
```

`schedule` calls <<updateAndSyncNumExecutorsTarget, updateAndSyncNumExecutorsTarget>> to...FIXME

It then go over <<removeTimes, removeTimes>> to remove expired executors, i.e. executors for which expiration time has elapsed.

### <span id="updateAndSyncNumExecutorsTarget"> updateAndSyncNumExecutorsTarget

```scala
updateAndSyncNumExecutorsTarget(
  now: Long): Int
```

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

## Logging

Enable `ALL` logging level for `org.apache.spark.ExecutorAllocationManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.ExecutorAllocationManager=ALL
```

Refer to [Logging](../spark-logging.md).
