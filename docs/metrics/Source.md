# Source

`Source` is an [abstraction](#contract) of [metrics sources](#implementations).

## Contract

### <span id="metricRegistry"> MetricRegistry

```scala
metricRegistry: MetricRegistry
```

`MetricRegistry` ([Codahale Metrics]({{ codahale.api }}/com/codahale/metrics/MetricRegistry.html))

Used when:

* `MetricsSystem` is requested to [register a metrics source](MetricsSystem.md#registerSource)

### <span id="sourceName"> Source Name

```scala
sourceName: String
```

Used when:

* `MetricsSystem` is requested to [build a metrics source identifier](MetricsSystem.md#buildRegistryName) and [getSourcesByName](MetricsSystem.md#getSourcesByName)

## Implementations

* [AccumulatorSource](../accumulators/AccumulatorSource.md)
* [AppStatusSource](../status/AppStatusSource.md)
* [BlockManagerSource](../storage/BlockManagerSource.md)
* [DAGSchedulerSource](../scheduler/DAGSchedulerSource.md)
* [ExecutorAllocationManagerSource](../dynamic-allocation/ExecutorAllocationManagerSource.md)
* [ExecutorMetricsSource](../executor/ExecutorMetricsSource.md)
* [ExecutorSource](../executor/ExecutorSource.md)
* [JvmSource](JvmSource.md)
* [ShuffleMetricsSource](../storage/ShuffleMetricsSource.md)
* _others_
