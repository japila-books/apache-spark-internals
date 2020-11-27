# ExecutorAllocationManagerSource

`ExecutorAllocationManagerSource` is a [metric source](../metrics/MetricsSystem.md) for [Dynamic Allocation of Executors](index.md) with name `ExecutorAllocationManager` and the following gauges:

* `executors/numberExecutorsToAdd` which exposes [numExecutorsToAdd](ExecutorAllocationManager.md#numExecutorsToAdd).
* `executors/numberExecutorsPendingToRemove` which corresponds to the number of elements in [executorsPendingToRemove](ExecutorAllocationManager.md#executorsPendingToRemove).
* `executors/numberAllExecutors` which corresponds to the number of elements in [executorIds](ExecutorAllocationManager.md#executorIds).
* `executors/numberTargetExecutors` which is [numExecutorsTarget](ExecutorAllocationManager.md#numExecutorsTarget).
* `executors/numberMaxNeededExecutors` which simply calls [maxNumExecutorsNeeded](ExecutorAllocationManager.md#maxNumExecutorsNeeded).
