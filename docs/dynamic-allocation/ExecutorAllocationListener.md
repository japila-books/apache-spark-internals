# ExecutorAllocationListener

`ExecutorAllocationListener` is a SparkListener.md[] that intercepts events about stages, tasks, and executors, i.e. onStageSubmitted, onStageCompleted, onTaskStart, onTaskEnd, onExecutorAdded, and onExecutorRemoved. Using the events [ExecutorAllocationManager](ExecutorAllocationManager.md) can manage the pool of dynamically managed executors.

!!! note "Internal Class"
    `ExecutorAllocationListener` is an internal class of [ExecutorAllocationManager](ExecutorAllocationManager.md) with full access to internal registries.
