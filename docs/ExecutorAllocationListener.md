== ExecutorAllocationListener

CAUTION: FIXME

`ExecutorAllocationListener` is a xref:ROOT:SparkListener.adoc[] that intercepts events about stages, tasks, and executors, i.e. onStageSubmitted, onStageCompleted, onTaskStart, onTaskEnd, onExecutorAdded, and onExecutorRemoved. Using the events link:spark-ExecutorAllocationManager.adoc[ExecutorAllocationManager] can manage the pool of dynamically managed executors.

NOTE: `ExecutorAllocationListener` is an internal class of link:spark-ExecutorAllocationManager.adoc[ExecutorAllocationManager] with full access to link:spark-ExecutorAllocationManager.adoc#internal-registries[its internal registries].
