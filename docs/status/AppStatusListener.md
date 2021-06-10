# AppStatusListener

`AppStatusListener` is a [SparkListener](../SparkListener.md) that writes application state information to a [data store](#kvstore).

## Event Handlers

Event Handler | LiveEntities
--------------|-----------
 [onJobStart](../SparkListenerInterface.md#onJobStart) | <ul><li>`LiveJob`<li>`LiveStage`<li>`RDDOperationGraph`</ul>
 [onStageSubmitted](../SparkListenerInterface.md#onStageSubmitted) |

## Creating Instance

`AppStatusListener` takes the following to be created:

* [ElementTrackingStore](#kvstore)
* <span id="conf"> [SparkConf](../SparkConf.md)
* [live](#live) flag
* <span id="appStatusSource"> [AppStatusSource](AppStatusSource.md) (default: `None`)
* <span id="lastUpdateTime"> Last Update Time (default: `None`)

`AppStatusListener` is created when:

* `AppStatusStore` is requested for a [in-memory store for a running Spark application](AppStatusStore.md#createLiveStore) (with the [live](#live) flag enabled)
* `FsHistoryProvider` is requested to [rebuildAppStore](../history-server/FsHistoryProvider.md#rebuildAppStore) (with the [live](#live) flag disabled)

## <span id="kvstore"> ElementTrackingStore

`AppStatusListener` is given an [ElementTrackingStore](ElementTrackingStore.md) when [created](#creating-instance).

`AppStatusListener` [registers triggers](ElementTrackingStore.md#addTrigger) to clean up state in the store:

* [cleanupExecutors](#cleanupExecutors)
* [cleanupJobs](#cleanupJobs)
* [cleanupStages](#cleanupStages)

`ElementTrackingStore` is used to [write](ElementTrackingStore.md#write) and...FIXME

## <span id="live"> live Flag

`AppStatusListener` is given a `live` flag when [created](#creating-instance).

`live` flag indicates whether `AppStatusListener` is created for the following:

* `true` when created for a active (_live_) Spark application (for [AppStatusStore](AppStatusStore.md))
* `false` when created for [Spark History Server](../history-server/index.md) (for [FsHistoryProvider](../history-server/FsHistoryProvider.md))

## <span id="liveUpdate"> Updating ElementTrackingStore for Active Spark Application

```scala
liveUpdate(
  entity: LiveEntity,
  now: Long): Unit
```

`liveUpdate` [update the ElementTrackingStore](#update) when the [live](#live) flag is enabled.

## <span id="update"> Updating ElementTrackingStore

```scala
update(
  entity: LiveEntity,
  now: Long,
  last: Boolean = false): Unit
```

`update` requests the given [LiveEntity](LiveEntity.md) to [write](LiveEntity.md#write) (with the [ElementTrackingStore](#kvstore) and `checkTriggers` flag being the given `last` flag).

## <span id="getOrCreateExecutor"> getOrCreateExecutor

```scala
getOrCreateExecutor(
  executorId: String,
  addTime: Long): LiveExecutor
```

`getOrCreateExecutor`...FIXME

`getOrCreateExecutor` is used when:

* `AppStatusListener` is requested to [onExecutorAdded](#onExecutorAdded) and [onBlockManagerAdded](#onBlockManagerAdded)

## <span id="getOrCreateStage"> getOrCreateStage

```scala
getOrCreateStage(
  info: StageInfo): LiveStage
```

`getOrCreateStage`...FIXME

`getOrCreateStage` is used when:

* `AppStatusListener` is requested to [onJobStart](#onJobStart) and [onStageSubmitted](#onStageSubmitted)
