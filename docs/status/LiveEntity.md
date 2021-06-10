# LiveEntity

`LiveEntity` is an [abstraction](#contract) of [entities](#implementations) of a running (_live_) Spark application.

## Contract

### <span id="doUpdate"> doUpdate

```scala
doUpdate(): Any
```

Updated view of this entity's data

Used when:

* `LiveEntity` is requested to [write out to the store](#write)

## Implementations

* LiveExecutionData (Spark SQL)
* LiveExecutionData (Spark Thrift Server)
* LiveExecutor
* LiveExecutorStageSummary
* LiveJob
* LiveRDD
* LiveResourceProfile
* LiveSessionData
* LiveStage
* LiveTask
* SchedulerPool

## <span id="write"> Writing Out to Store

```scala
write(
  store: ElementTrackingStore,
  now: Long,
  checkTriggers: Boolean = false): Unit
```

`write`...FIXME

`write` is used when:

* `AppStatusListener` is requested to [update](AppStatusListener.md#update)
* `HiveThriftServer2Listener` (Spark Thrift Server) is requested to `updateStoreWithTriggerEnabled` and `updateLiveStore`
* `SQLAppStatusListener` (Spark SQL) is requested to `update`
