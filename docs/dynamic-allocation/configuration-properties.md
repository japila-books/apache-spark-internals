# Spark Configuration Properties

## <span id="spark.dynamicAllocation.enabled"><span id="DYN_ALLOCATION_ENABLED"> spark.dynamicAllocation.enabled

Default: `false`

## <span id="spark.dynamicAllocation.minExecutors"><span id="DYN_ALLOCATION_MIN_EXECUTORS"> spark.dynamicAllocation.minExecutors

Default: `0`

## <span id="spark.dynamicAllocation.initialExecutors"><span id="DYN_ALLOCATION_INITIAL_EXECUTORS"> spark.dynamicAllocation.initialExecutors

Default: [spark.dynamicAllocation.minExecutors](#DYN_ALLOCATION_MIN_EXECUTORS)

## <span id="spark.dynamicAllocation.maxExecutors"><span id="DYN_ALLOCATION_MAX_EXECUTORS"> spark.dynamicAllocation.maxExecutors

Default: The largest value representable as an Int

## <span id="spark.dynamicAllocation.executorAllocationRatio"><span id="DYN_ALLOCATION_EXECUTOR_ALLOCATION_RATIO"> spark.dynamicAllocation.executorAllocationRatio

Default: `1.0`

## <span id="spark.dynamicAllocation.cachedExecutorIdleTimeout"><span id="DYN_ALLOCATION_CACHED_EXECUTOR_IDLE_TIMEOUT"> spark.dynamicAllocation.cachedExecutorIdleTimeout

(in seconds)

Default: The largest value representable as an Int

## <span id="spark.dynamicAllocation.executorIdleTimeout"><span id="DYN_ALLOCATION_EXECUTOR_IDLE_TIMEOUT"> spark.dynamicAllocation.executorIdleTimeout

(in seconds)

Default: `60`

## <span id="spark.dynamicAllocation.shuffleTracking.enabled"><span id="DYN_ALLOCATION_SHUFFLE_TRACKING_ENABLED"> spark.dynamicAllocation.shuffleTracking.enabled

Default: `false`

## <span id="spark.dynamicAllocation.shuffleTracking.timeout"><span id="DYN_ALLOCATION_SHUFFLE_TRACKING_TIMEOUT"> spark.dynamicAllocation.shuffleTracking.timeout

(in millis)

Default: The largest value representable as an Int

## <span id="spark.dynamicAllocation.schedulerBacklogTimeout"><span id="DYN_ALLOCATION_SCHEDULER_BACKLOG_TIMEOUT"> spark.dynamicAllocation.schedulerBacklogTimeout

(in seconds)

Default: `1`

## <span id="spark.dynamicAllocation.sustainedSchedulerBacklogTimeout"><span id="DYN_ALLOCATION_SUSTAINED_SCHEDULER_BACKLOG_TIMEOUT"> spark.dynamicAllocation.sustainedSchedulerBacklogTimeout

Default: [spark.dynamicAllocation.schedulerBacklogTimeout](#DYN_ALLOCATION_SCHEDULER_BACKLOG_TIMEOUT)
