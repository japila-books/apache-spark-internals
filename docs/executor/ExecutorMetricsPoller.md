# ExecutorMetricsPoller

## Creating Instance

`ExecutorMetricsPoller` takes the following to be created:

* <span id="memoryManager"> [MemoryManager](../memory/MemoryManager.md)
* <span id="pollingInterval"> [spark.executor.metrics.pollingInterval](../configuration-properties.md#spark.executor.metrics.pollingInterval)
* <span id="executorMetricsSource"> [ExecutorMetricsSource](ExecutorMetricsSource.md)

`ExecutorMetricsPoller` is created when:

* `Executor` is [created](Executor.md#metricsPoller)

## <span id="poller"> executor-metrics-poller

`ExecutorMetricsPoller` creates a `ScheduledExecutorService` ([Java]({{ java.api }}/java.base/java/util/concurrent/ScheduledExecutorService.html)) when [created](#creating-instance) with the [spark.executor.metrics.pollingInterval](#pollingInterval) greater than `0`.

The `ScheduledExecutorService` manages 1 daemon thread with `executor-metrics-poller` name prefix.

The `ScheduledExecutorService` is requested to [poll](#poll) at every [pollingInterval](#pollingInterval) when `ExecutorMetricsPoller` is requested to [start](#start) until [stop](#stop).

## <span id="poll"> poll

```scala
poll(): Unit
```

`poll`...FIXME

`poll` is used when:

* `Executor` is requested to [reportHeartBeat](Executor.md#reportHeartBeat)
* `ExecutorMetricsPoller` is requested to [start](#start)
