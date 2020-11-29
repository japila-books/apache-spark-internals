# AppStatusListener

`AppStatusListener` is a [SparkListener](SparkListener.md).

## Creating Instance

`AppStatusListener` takes the following to be created:

* <span id="kvstore"> [ElementTrackingStore](core/ElementTrackingStore.md)
* <span id="conf"> [SparkConf](SparkConf.md)
* [live](#live) flag
* <span id="appStatusSource"> `AppStatusSource` (default: `None`)
* <span id="lastUpdateTime"> Last Update Time (default: `None`)

`AppStatusListener` is created when:

* `AppStatusStore` is requested to [createLiveStore](core/AppStatusStore.md#createLiveStore) (with the [live](#live) flag enabled)
* `FsHistoryProvider` is requested to [rebuildAppStore](history-server/FsHistoryProvider.md#rebuildAppStore) (with the [live](#live) flag disabled)

## <span id="live"> live Flag

`AppStatusListener` is given a `live` flag when [created](#creating-instance).

`live` flag indicates whether `AppStatusListener` is created for the following:

* `true` when created for a active (_live_) Spark application (for [AppStatusStore](core/AppStatusStore.md))
* `false` when created for [Spark History Server](history-server/index.md) (for [FsHistoryProvider](history-server/FsHistoryProvider.md))

## <span id="onJobStart"> onJobStart

```scala
onJobStart(
  event: SparkListenerJobStart): Unit
```

`onJobStart`...FIXME

`onJobStart` is part of the [SparkListener](SparkListener.md#onJobStart) abstraction.

## <span id="onStageSubmitted"> onStageSubmitted

```scala
onStageSubmitted(
  event: SparkListenerStageSubmitted): Unit
```

`onStageSubmitted` is part of the [SparkListener](SparkListener.md#onStageSubmitted) abstraction.

`onStageSubmitted` [getOrCreateStage](#getOrCreateStage) for the [StageInfo](scheduler/StageInfo.md) (from the given `SparkListenerStageSubmitted` event).

`onStageSubmitted`...FIXME

In the end, `onStageSubmitted` [liveUpdate](#liveUpdate) with the stage and `now` timestamp.

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

`update` requests the given [LiveEntity](webui/LiveEntity.md) to [write](webui/LiveEntity.md#write) (with the [ElementTrackingStore](#kvstore) and `checkTriggers` flag being the given `last` flag).

## <span id="getOrCreateStage"> getOrCreateStage

```scala
getOrCreateStage(
  info: StageInfo): LiveStage
```

`getOrCreateStage`...FIXME

`getOrCreateStage` is used when `AppStatusListener` is requested to [onJobStart](#onJobStart) and [onStageSubmitted](#onStageSubmitted).
