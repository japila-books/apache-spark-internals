---
tags:
  - DeveloperApi
---

# ExecutorMetrics

`ExecutorMetrics` is a collection of executor metrics.

## Creating Instance

`ExecutorMetrics` takes the following to be created:

* <span id="metrics"> Metrics

`ExecutorMetrics` is created when:

* `SparkContext` is requested to [reportHeartBeat](../SparkContext.md#reportHeartBeat)
* `DAGScheduler` is requested to [post a SparkListenerTaskEnd event](../scheduler/DAGScheduler.md#postTaskEnd)
* `ExecutorMetricsPoller` is requested to [getExecutorUpdates](ExecutorMetricsPoller.md#getExecutorUpdates)
* `ExecutorMetricsJsonDeserializer` is requested to `deserialize`
* `JsonProtocol` is requested to [executorMetricsFromJson](../history-server/JsonProtocol.md#executorMetricsFromJson)

## <span id="getCurrentMetrics"> Current Metric Values

```scala
getCurrentMetrics(
  memoryManager: MemoryManager): Array[Long]
```

`getCurrentMetrics` gives [metric values](ExecutorMetricType.md#getMetricValues) for every [metric getter](ExecutorMetricType.md#metricGetters).

Given that one metric getter (type) can report multiple metrics, the length of the result collection is the [number of metrics](ExecutorMetricType.md#numMetrics) (and at least the number of metric getters). The order matters and is exactly as [metricGetters](ExecutorMetricType.md#metricGetters).

`getCurrentMetrics` is used when:

* `SparkContext` is requested to [reportHeartBeat](../SparkContext.md#reportHeartBeat)
* `ExecutorMetricsPoller` is requested to [poll](ExecutorMetricsPoller.md#poll)
