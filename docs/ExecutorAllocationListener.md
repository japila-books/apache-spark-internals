== ExecutorAllocationListener

CAUTION: FIXME

`ExecutorAllocationListener` is a ROOT:SparkListener.md[] that intercepts events about stages, tasks, and executors, i.e. onStageSubmitted, onStageCompleted, onTaskStart, onTaskEnd, onExecutorAdded, and onExecutorRemoved. Using the events spark-ExecutorAllocationManager.md[ExecutorAllocationManager] can manage the pool of dynamically managed executors.

NOTE: `ExecutorAllocationListener` is an internal class of spark-ExecutorAllocationManager.md[ExecutorAllocationManager] with full access to spark-ExecutorAllocationManager.md#internal-registries[its internal registries].
