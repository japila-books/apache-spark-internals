# Spark Configuration Properties

## <span id="spark.dynamicAllocation.cachedExecutorIdleTimeout"><span id="DYN_ALLOCATION_CACHED_EXECUTOR_IDLE_TIMEOUT"> spark.dynamicAllocation.cachedExecutorIdleTimeout

How long (in seconds) to keep blocks cached

Default: The largest value representable as an Int

Must be >= `0`

Used when:

* `ExecutorMonitor` is [created](ExecutorMonitor.md#storageTimeoutNs)
* `RDD` is requested to [localCheckpoint](../rdd/RDD.md#localCheckpoint) (simply to print out a WARN message)

## <span id="spark.dynamicAllocation.enabled"><span id="DYN_ALLOCATION_ENABLED"> spark.dynamicAllocation.enabled

Default: `false`

Used when:

* `Utils` utility is requested to [isDynamicAllocationEnabled](../Utils.md#isDynamicAllocationEnabled)
* `SparkSubmitArguments` is requested to [loadEnvironmentArguments](../tools/SparkSubmitArguments.md#loadEnvironmentArguments) (and [validates numExecutors argument](../tools/SparkSubmitArguments.md#validateSubmitArguments))
* `RDD` is requested to [localCheckpoint](../rdd/RDD.md#localCheckpoint)
* `DAGScheduler` is requested to [checkBarrierStageWithDynamicAllocation](../scheduler/DAGScheduler.md#checkBarrierStageWithDynamicAllocation)

## <span id="spark.dynamicAllocation.executorAllocationRatio"><span id="DYN_ALLOCATION_EXECUTOR_ALLOCATION_RATIO"> spark.dynamicAllocation.executorAllocationRatio

Default: `1.0`

Must be between `0` (exclusive) and `1.0` (inclusive)

Used when:

* `ExecutorAllocationManager` is [created](ExecutorAllocationManager.md#executorAllocationRatio)

## <span id="spark.dynamicAllocation.executorIdleTimeout"><span id="DYN_ALLOCATION_EXECUTOR_IDLE_TIMEOUT"> spark.dynamicAllocation.executorIdleTimeout

Default: `60`

## <span id="spark.dynamicAllocation.initialExecutors"><span id="DYN_ALLOCATION_INITIAL_EXECUTORS"> spark.dynamicAllocation.initialExecutors

Default: [spark.dynamicAllocation.minExecutors](#DYN_ALLOCATION_MIN_EXECUTORS)

## <span id="spark.dynamicAllocation.maxExecutors"><span id="DYN_ALLOCATION_MAX_EXECUTORS"> spark.dynamicAllocation.maxExecutors

Default: The largest value representable as an Int

## <span id="spark.dynamicAllocation.minExecutors"><span id="DYN_ALLOCATION_MIN_EXECUTORS"> spark.dynamicAllocation.minExecutors

Default: `0`

## <span id="spark.dynamicAllocation.schedulerBacklogTimeout"><span id="DYN_ALLOCATION_SCHEDULER_BACKLOG_TIMEOUT"> spark.dynamicAllocation.schedulerBacklogTimeout

(in seconds)

Default: `1`

## <span id="spark.dynamicAllocation.shuffleTracking.enabled"><span id="DYN_ALLOCATION_SHUFFLE_TRACKING_ENABLED"> spark.dynamicAllocation.shuffleTracking.enabled

Default: `false`

Used when:

* `ExecutorMonitor` is [created](ExecutorMonitor.md#shuffleTrackingEnabled)

## <span id="spark.dynamicAllocation.shuffleTracking.timeout"><span id="DYN_ALLOCATION_SHUFFLE_TRACKING_TIMEOUT"> spark.dynamicAllocation.shuffleTracking.timeout

(in millis)

Default: The largest value representable as an Int

## <span id="spark.dynamicAllocation.sustainedSchedulerBacklogTimeout"><span id="DYN_ALLOCATION_SUSTAINED_SCHEDULER_BACKLOG_TIMEOUT"> spark.dynamicAllocation.sustainedSchedulerBacklogTimeout

Default: [spark.dynamicAllocation.schedulerBacklogTimeout](#DYN_ALLOCATION_SCHEDULER_BACKLOG_TIMEOUT)
