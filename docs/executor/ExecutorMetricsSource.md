# ExecutorMetricsSource

`ExecutorMetricsSource` is a [metrics source](../metrics/Source.md).

## Creating Instance

`ExecutorMetricsSource` takes no arguments to be created.

`ExecutorMetricsSource` is created when:

* `SparkContext` is [created](../SparkContext.md#ExecutorMetricsSource) (with [spark.metrics.executorMetricsSource.enabled](../metrics/configuration-properties.md#spark.metrics.executorMetricsSource.enabled) enabled)
* `Executor` is [created](../executor/Executor.md#executorMetricsSource) (with [spark.metrics.executorMetricsSource.enabled](../metrics/configuration-properties.md#spark.metrics.executorMetricsSource.enabled) enabled)

## <span id="sourceName"> Source Name

```scala
sourceName: String
```

`sourceName` is **ExecutorMetrics**.

`sourceName` is part of the [Source](../metrics/Source.md#sourceName) abstraction.

## <span id="register"> Registering with MetricsSystem

```scala
register(
  metricsSystem: MetricsSystem): Unit
```

`register` creates `ExecutorMetricGauge`s for every [executor metric](ExecutorMetricType.md#metricGetters).

`register` requests the [MetricRegistry](#metricRegistry) to register every [metric type](ExecutorMetricType.md#metricGetters).

In the end, `register` requests the [MetricRegistry](#metricRegistry) to [register](../metrics/MetricsSystem.md#registerSource) this `ExecutorMetricsSource`.

`register` is used when:

* `SparkContext` is [created](../SparkContext.md#ExecutorMetricsSource)
* `Executor` is [created](../executor/Executor.md#executorMetricsSource) (for non-local mode)

## <span id="metricsSnapshot"> Metrics Snapshot

`ExecutorMetricsSource` defines `metricsSnapshot` internal registry of values of [every metric](ExecutorMetricType.md#metricGetters).

The values are updated in [updateMetricsSnapshot](#updateMetricsSnapshot) and read using `ExecutorMetricGauge`s.

### <span id="updateMetricsSnapshot"> updateMetricsSnapshot

```scala
updateMetricsSnapshot(
  metricsUpdates: Array[Long]): Unit
```

`updateMetricsSnapshot` updates the [metricsSnapshot](#metricsSnapshot) registry with the given `metricsUpdates`.

`updateMetricsSnapshot` is used when:

* `SparkContext` is requested to [reportHeartBeat](../SparkContext.md#reportHeartBeat)
* `ExecutorMetricsPoller` is requested to [poll](../executor/ExecutorMetricsPoller.md#poll)
