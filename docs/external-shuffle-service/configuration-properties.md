# Spark Configuration Properties of External Shuffle Service

The following are configuration properties of [External Shuffle Service](index.md).

## <span id="spark.shuffle.service.db.enabled"><span id="SHUFFLE_SERVICE_DB_ENABLED"> spark.shuffle.service.db.enabled

Whether to use db in [ExternalShuffleService](ExternalShuffleService.md). Note that this only affects standalone mode.

Default: `true`

Used when:

* `ExternalShuffleService` is requested for an [ExternalBlockHandler](ExternalShuffleService.md#newShuffleBlockHandler)
* `Worker` (Spark Standalone) is requested to [handle a WorkDirCleanup message](../spark-standalone/Worker.md#WorkDirCleanup)

## <span id="spark.shuffle.service.enabled"><span id="SHUFFLE_SERVICE_ENABLED"> spark.shuffle.service.enabled

Controls whether to use the [External Shuffle Service](ExternalShuffleService.md)

Default: `false`

!!! note
    `LocalSparkCluster` turns this property off explicitly when started.

Used when:

* `BlacklistTracker` is requested to [updateBlacklistForFetchFailure](../scheduler/BlacklistTracker.md#updateBlacklistForFetchFailure)
* `ExecutorMonitor` is created
* `ExecutorAllocationManager` is requested to [validateSettings](../dynamic-allocation/ExecutorAllocationManager.md#validateSettings)
* `SparkEnv` utility is requested to [create a "base" SparkEnv](../SparkEnv.md#create)
* `ExternalShuffleService` is [created](ExternalShuffleService.md#enabled) and [started](ExternalShuffleService.md#main)
* `Worker` (Spark Standalone) is requested to handle a `WorkDirCleanup` message or started
* `ExecutorRunnable` (Spark on YARN) is requested to `startContainer`

## <span id="spark.shuffle.service.fetch.rdd.enabled"><span id="SHUFFLE_SERVICE_FETCH_RDD_ENABLED"> spark.shuffle.service.fetch.rdd.enabled

Enables [ExternalShuffleService](ExternalShuffleService.md) for fetching disk persisted RDD blocks.

When enabled with [Dynamic Resource Allocation](../dynamic-allocation/index.md) executors having only disk persisted blocks are considered idle after [spark.dynamicAllocation.executorIdleTimeout](../dynamic-allocation/configuration-properties.md#spark.dynamicAllocation.executorIdleTimeout) and will be released accordingly.

Default: `false`

Used when:

* `ExternalShuffleBlockResolver` is [created](ExternalShuffleBlockResolver.md#rddFetchEnabled)
* `SparkEnv` utility is requested to [create a "base" SparkEnv](../SparkEnv.md#create)
* `ExecutorMonitor` is [created](../dynamic-allocation/ExecutorMonitor.md#fetchFromShuffleSvcEnabled)

## <span id="spark.shuffle.service.port"><span id="SHUFFLE_SERVICE_PORT"> spark.shuffle.service.port

Port of the [external shuffle service](ExternalShuffleService.md)

Default: `7337`

Used when:

* `ExternalShuffleService` is [created](ExternalShuffleService.md#port)
* `StorageUtils` utility is requested for the [port of an external shuffle service](../storage/StorageUtils.md#externalShuffleServicePort)
