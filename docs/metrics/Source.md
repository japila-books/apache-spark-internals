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
* ApplicationMasterSource
* ApplicationSource
* [AppStatusSource](../status/AppStatusSource.md)
* [BlockManagerSource](../storage/BlockManagerSource.md)
* CacheMetrics
* CodegenMetrics
* [DAGSchedulerSource](../scheduler/DAGSchedulerSource.md)
* [ExecutorAllocationManagerSource](../dynamic-allocation/ExecutorAllocationManagerSource.md)
* ExecutorMetricsSource
* [ExecutorSource](../executor/ExecutorSource.md)
* ExternalShuffleServiceSource
* HiveCatalogMetrics
* JVMCPUSource
* [JvmSource](JvmSource.md)
* LiveListenerBusMetrics
* MasterSource
* PluginMetricsSource
* [ShuffleMetricsSource](../storage/ShuffleMetricsSource.md)
* WorkerSource
