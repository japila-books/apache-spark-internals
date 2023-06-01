# Spark Configuration Properties

## spark.dynamicAllocation

### <span id="spark.dynamicAllocation.cachedExecutorIdleTimeout"><span id="DYN_ALLOCATION_CACHED_EXECUTOR_IDLE_TIMEOUT"> cachedExecutorIdleTimeout

**spark.dynamicAllocation.cachedExecutorIdleTimeout**

How long (in seconds) to keep blocks cached

Default: The largest value representable as an Int

Must be >= `0`

Used when:

* `ExecutorMonitor` is [created](ExecutorMonitor.md#storageTimeoutNs)
* `RDD` is requested to [localCheckpoint](../rdd/RDD.md#localCheckpoint) (simply to print out a WARN message)

### <span id="spark.dynamicAllocation.enabled"><span id="DYN_ALLOCATION_ENABLED"> enabled

**spark.dynamicAllocation.enabled**

Enables [Dynamic Allocation of Executors](index.md)

Default: `false`

Used when:

* `BarrierJobAllocationFailed` is requested for [ERROR_MESSAGE_RUN_BARRIER_WITH_DYN_ALLOCATION](../barrier-execution-mode/BarrierJobAllocationFailed.md#ERROR_MESSAGE_RUN_BARRIER_WITH_DYN_ALLOCATION) (for reporting purposes)
* `RDD` is requested to [localCheckpoint](../rdd/RDD.md#localCheckpoint) (for reporting purposes)
* `SparkSubmitArguments` is requested to [loadEnvironmentArguments](../tools/spark-submit/SparkSubmitArguments.md#loadEnvironmentArguments) (for [validation](../tools/spark-submit/SparkSubmitArguments.md#validateSubmitArguments) purposes)
* `Utils` is requested to [isDynamicAllocationEnabled](../Utils.md#isDynamicAllocationEnabled)

### <span id="spark.dynamicAllocation.executorAllocationRatio"><span id="DYN_ALLOCATION_EXECUTOR_ALLOCATION_RATIO"> executorAllocationRatio

**spark.dynamicAllocation.executorAllocationRatio**

Default: `1.0`

Must be between `0` (exclusive) and `1.0` (inclusive)

Used when:

* `ExecutorAllocationManager` is [created](ExecutorAllocationManager.md#executorAllocationRatio)

### <span id="spark.dynamicAllocation.executorIdleTimeout"><span id="DYN_ALLOCATION_EXECUTOR_IDLE_TIMEOUT"> executorIdleTimeout

**spark.dynamicAllocation.executorIdleTimeout**

Default: `60`

### <span id="spark.dynamicAllocation.initialExecutors"><span id="DYN_ALLOCATION_INITIAL_EXECUTORS"> initialExecutors

**spark.dynamicAllocation.initialExecutors**

Default: [spark.dynamicAllocation.minExecutors](#DYN_ALLOCATION_MIN_EXECUTORS)

### <span id="spark.dynamicAllocation.maxExecutors"><span id="DYN_ALLOCATION_MAX_EXECUTORS"> maxExecutors

**spark.dynamicAllocation.maxExecutors**

Default: `Int.MaxValue`

### <span id="spark.dynamicAllocation.minExecutors"><span id="DYN_ALLOCATION_MIN_EXECUTORS"> minExecutors

**spark.dynamicAllocation.minExecutors**

Default: `0`

### <span id="spark.dynamicAllocation.schedulerBacklogTimeout"><span id="DYN_ALLOCATION_SCHEDULER_BACKLOG_TIMEOUT"> schedulerBacklogTimeout

**spark.dynamicAllocation.schedulerBacklogTimeout**

(in seconds)

Default: `1`

### <span id="spark.dynamicAllocation.shuffleTracking.enabled"><span id="DYN_ALLOCATION_SHUFFLE_TRACKING_ENABLED"> shuffleTracking.enabled

**spark.dynamicAllocation.shuffleTracking.enabled**

Default: `false`

Used when:

* `ExecutorMonitor` is [created](ExecutorMonitor.md#shuffleTrackingEnabled)

### <span id="spark.dynamicAllocation.shuffleTracking.timeout"><span id="DYN_ALLOCATION_SHUFFLE_TRACKING_TIMEOUT"> shuffleTracking.timeout

**spark.dynamicAllocation.shuffleTracking.timeout**

(in millis)

Default: The largest value representable as an Int

### <span id="spark.dynamicAllocation.sustainedSchedulerBacklogTimeout"><span id="DYN_ALLOCATION_SUSTAINED_SCHEDULER_BACKLOG_TIMEOUT"> sustainedSchedulerBacklogTimeout

**spark.dynamicAllocation.sustainedSchedulerBacklogTimeout**

Default: [spark.dynamicAllocation.schedulerBacklogTimeout](#DYN_ALLOCATION_SCHEDULER_BACKLOG_TIMEOUT)
