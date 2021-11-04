# ExecutorMetricType

`ExecutorMetricType`  is an [abstraction](#contract) of [executor metric types](#implementations).

## Contract

### <span id="getMetricValues"> Metric Values

```scala
getMetricValues(
  memoryManager: MemoryManager): Array[Long]
```

Used when:

* `ExecutorMetrics` utility is used for the [current metric values](ExecutorMetrics.md#getCurrentMetrics)

### <span id="names"> Metric Names

```scala
names: Seq[String]
```

Used when:

* `ExecutorMetricType` utility is used for the [metricToOffset](#metricToOffset) and [number of metrics](#numMetrics)

## Implementations

??? note "Sealed Trait"
    `ExecutorMetricType` is a Scala **sealed trait** which means that all of the implementations are in the same compilation unit (a single file).

    Learn more in the [Scala Language Specification]({{ scala.spec }}/05-classes-and-objects.html#sealed).

* `GarbageCollectionMetrics`
* `ProcessTreeMetrics`
* `SingleValueExecutorMetricType`
* `JVMHeapMemory`
* `JVMOffHeapMemory`
* `MBeanExecutorMetricType`
* `DirectPoolMemory`
* `MappedPoolMemory`
* `MemoryManagerExecutorMetricType`
* `OffHeapExecutionMemory`
* `OffHeapStorageMemory`
* `OffHeapUnifiedMemory`
* `OnHeapExecutionMemory`
* `OnHeapStorageMemory`
* `OnHeapUnifiedMemory`

## <span id="metricGetters"> Executor Metric Getters (Ordered ExecutorMetricTypes)

`ExecutorMetricType` defines an ordered collection of [ExecutorMetricType](#implementations)s:

1. `JVMHeapMemory`
1. `JVMOffHeapMemory`
1. `OnHeapExecutionMemory`
1. `OffHeapExecutionMemory`
1. `OnHeapStorageMemory`
1. `OffHeapStorageMemory`
1. `OnHeapUnifiedMemory`
1. `OffHeapUnifiedMemory`
1. `DirectPoolMemory`
1. `MappedPoolMemory`
1. `ProcessTreeMetrics`
1. `GarbageCollectionMetrics`

This ordering allows for passing metric values as arrays (to save space) with indices being a metric of a metric type.

`metricGetters` is used when:

* `ExecutorMetrics` utility is used for the [current metric values](ExecutorMetrics.md#getCurrentMetrics)
* `ExecutorMetricType` utility is used to get the [metricToOffset](#metricToOffset) and the [numMetrics](#numMetrics)
