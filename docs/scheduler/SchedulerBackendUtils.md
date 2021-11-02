# SchedulerBackendUtils Utility

## <span id="DEFAULT_NUMBER_EXECUTORS"> Default Number of Executors

`SchedulerBackendUtils` defaults to `2` as the default number of executors.

## <span id="getInitialTargetExecutorNumber"> getInitialTargetExecutorNumber

```scala
getInitialTargetExecutorNumber(
  conf: SparkConf,
  numExecutors: Int = DEFAULT_NUMBER_EXECUTORS): Int
```

`getInitialTargetExecutorNumber` branches off based on [whether Dynamic Allocation of Executors is enabled or not](../Utils.md#isDynamicAllocationEnabled).

With no [Dynamic Allocation of Executors](../dynamic-allocation/index.md), `getInitialTargetExecutorNumber` uses the [spark.executor.instances](../configuration-properties.md#spark.executor.instances) configuration property (if defined) or uses the given `numExecutors` (and the [DEFAULT_NUMBER_EXECUTORS](#DEFAULT_NUMBER_EXECUTORS)).

With [Dynamic Allocation of Executors](../dynamic-allocation/index.md) enabled, `getInitialTargetExecutorNumber` [getDynamicAllocationInitialExecutors](../Utils.md#getDynamicAllocationInitialExecutors) and makes sure that the value is between the following configuration properties:

* [spark.dynamicAllocation.minExecutors](../dynamic-allocation/configuration-properties.md#spark.dynamicAllocation.minExecutors)
* [spark.dynamicAllocation.maxExecutors](../dynamic-allocation/configuration-properties.md#spark.dynamicAllocation.maxExecutors)

`getInitialTargetExecutorNumber` is used when:

* `KubernetesClusterSchedulerBackend` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesClusterSchedulerBackend#initialExecutors)) is created
* Spark on YARN's `YarnAllocator`, `YarnClientSchedulerBackend` and `YarnClusterSchedulerBackend` are used
