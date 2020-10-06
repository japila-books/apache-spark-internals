# ExecutorAllocationManagerSource -- Metric Source for Dynamic Allocation

`ExecutorAllocationManagerSource` is a spark-metrics-MetricsSystem.md[metric source] for ROOT:spark-dynamic-allocation.md[] with name `ExecutorAllocationManager` and the following gauges:

* `executors/numberExecutorsToAdd` which exposes spark-ExecutorAllocationManager.md#numExecutorsToAdd[numExecutorsToAdd].
* `executors/numberExecutorsPendingToRemove` which corresponds to the number of elements in spark-ExecutorAllocationManager.md#executorsPendingToRemove[executorsPendingToRemove].
* `executors/numberAllExecutors` which corresponds to the number of elements in spark-ExecutorAllocationManager.md#executorIds[executorIds].
* `executors/numberTargetExecutors` which is spark-ExecutorAllocationManager.md#numExecutorsTarget[numExecutorsTarget].
* `executors/numberMaxNeededExecutors` which simply calls spark-ExecutorAllocationManager.md#maxNumExecutorsNeeded[maxNumExecutorsNeeded].

NOTE: Spark uses http://metrics.dropwizard.io/[Metrics] Java library to expose internal state of its services to measure.
