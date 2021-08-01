# SparkListenerEvent

`SparkListenerEvent` is an [abstraction](#contract) of [scheduling events](#implementations).

## Dispatching SparkListenerEvents

[SparkListenerBus](SparkListenerBus.md) in general (and [AsyncEventQueue](AsyncEventQueue.md) in particular) are event buses used to dispatch `SparkListenerEvent`s to registered [SparkListener](SparkListenerInterface.md)s.

[LiveListenerBus](scheduler/LiveListenerBus.md) is an event bus to dispatch `SparkListenerEvent`s to registered [SparkListener](SparkListenerInterface.md)s.

## Spark History Server

Once logged, Spark History Server uses `JsonProtocol` utility to [sparkEventFromJson](history-server/JsonProtocol.md#sparkEventFromJson).

## Contract

### <span id="logEvent"> logEvent

```scala
logEvent: Boolean
```

`logEvent` controls whether [EventLoggingListener](history-server/EventLoggingListener.md) should save the event to an event log.

Default: `true`

`logEvent` is used when:

* `EventLoggingListener` is requested to [handle "other" events](history-server/EventLoggingListener.md#onOtherEvent)

## Implementations

### <span id="SparkListenerApplicationEnd"> SparkListenerApplicationEnd

### <span id="SparkListenerApplicationStart"> SparkListenerApplicationStart

### <span id="SparkListenerBlockManagerAdded"> SparkListenerBlockManagerAdded

### <span id="SparkListenerBlockManagerRemoved"> SparkListenerBlockManagerRemoved

### <span id="SparkListenerBlockUpdated"> SparkListenerBlockUpdated

### <span id="SparkListenerEnvironmentUpdate"> SparkListenerEnvironmentUpdate

### <span id="SparkListenerExecutorAdded"> SparkListenerExecutorAdded

### <span id="SparkListenerExecutorBlacklisted"> SparkListenerExecutorBlacklisted

### <span id="SparkListenerExecutorBlacklistedForStage"> SparkListenerExecutorBlacklistedForStage

### <span id="SparkListenerExecutorMetricsUpdate"> SparkListenerExecutorMetricsUpdate

### <span id="SparkListenerExecutorRemoved"> SparkListenerExecutorRemoved

### <span id="SparkListenerExecutorUnblacklisted"> SparkListenerExecutorUnblacklisted

### <span id="SparkListenerJobEnd"> SparkListenerJobEnd

### <span id="SparkListenerJobStart"> SparkListenerJobStart

### <span id="SparkListenerLogStart"> SparkListenerLogStart

### <span id="SparkListenerNodeBlacklisted"> SparkListenerNodeBlacklisted

### <span id="SparkListenerNodeBlacklistedForStage"> SparkListenerNodeBlacklistedForStage

### <span id="SparkListenerNodeUnblacklisted"> SparkListenerNodeUnblacklisted

### <span id="SparkListenerSpeculativeTaskSubmitted"> SparkListenerSpeculativeTaskSubmitted

### <span id="SparkListenerStageCompleted"> SparkListenerStageCompleted

### <span id="SparkListenerStageExecutorMetrics"> SparkListenerStageExecutorMetrics

### <span id="SparkListenerStageSubmitted"> SparkListenerStageSubmitted

### <span id="SparkListenerTaskEnd"> SparkListenerTaskEnd

[SparkListenerTaskEnd](SparkListenerTaskEnd.md)

### <span id="SparkListenerTaskGettingResult"> SparkListenerTaskGettingResult

### <span id="SparkListenerTaskStart"> SparkListenerTaskStart

### <span id="SparkListenerUnpersistRDD"> SparkListenerUnpersistRDD
