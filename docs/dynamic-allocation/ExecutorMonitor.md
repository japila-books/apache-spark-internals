# ExecutorMonitor

`ExecutorMonitor` is a [SparkListener](../SparkListener.md) and a [CleanerListener](../core/CleanerListener.md).

## Creating Instance

`ExecutorMonitor` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="client"> [ExecutorAllocationClient](ExecutorAllocationClient.md)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)
* <span id="clock"> `Clock`

`ExecutorMonitor` is created when:

* `ExecutorAllocationManager` is [created](ExecutorAllocationManager.md#executorMonitor)

## <span id="shuffleIds"> shuffleIds Registry

```scala
shuffleIds: Set[Int]
```

`ExecutorMonitor` uses a mutable `HashSet` to track shuffle IDs...FIXME

`shuffleIds` is initialized only when [shuffleTrackingEnabled](#shuffleTrackingEnabled) is enabled.

`shuffleIds` is used by `Tracker` internal class for the following:

* `updateTimeout`, `addShuffle`, `removeShuffle` and `updateActiveShuffles`

## <span id="executors"> Executors Registry

```scala
executors: ConcurrentHashMap[String, Tracker]
```

`ExecutorMonitor` uses a Java [ConcurrentHashMap]({{ java.api }}/java.base/java/util/concurrent/ConcurrentHashMap.html) to track available executors.

An executor is added when (via [ensureExecutorIsTracked](#ensureExecutorIsTracked)):

* [onBlockUpdated](#onBlockUpdated)
* [onExecutorAdded](#onExecutorAdded)
* [onTaskStart](#onTaskStart)

An executor is removed when [onExecutorRemoved](#onExecutorRemoved).

All executors are removed when [reset](#reset).

`executors` is used when:

* [onOtherEvent](#onOtherEvent) ([cleanupShuffle](#cleanupShuffle))
* [executorCount](#executorCount)
* [executorsKilled](#executorsKilled)
* [onUnpersistRDD](#onUnpersistRDD)
* [onTaskEnd](#onTaskEnd)
* [onJobStart](#onJobStart)
* [onJobEnd](#onJobEnd)
* [pendingRemovalCount](#pendingRemovalCount)
* [timedOutExecutors](#timedOutExecutors)

## <span id="fetchFromShuffleSvcEnabled"> fetchFromShuffleSvcEnabled Flag

```scala
fetchFromShuffleSvcEnabled: Boolean
```

`ExecutorMonitor` initializes `fetchFromShuffleSvcEnabled` internal flag based on the values of [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) and [spark.shuffle.service.fetch.rdd.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.fetch.rdd.enabled) configuration properties.

`fetchFromShuffleSvcEnabled` is enabled (`true`) when the aforementioned configuration properties are.

`fetchFromShuffleSvcEnabled` is used when:

* [onBlockUpdated](#onBlockUpdated)

## <span id="shuffleTrackingEnabled"> shuffleTrackingEnabled Flag

```scala
shuffleTrackingEnabled: Boolean
```

`ExecutorMonitor` initializes `shuffleTrackingEnabled` internal flag based on the values of [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) and [spark.dynamicAllocation.shuffleTracking.enabled](configuration-properties.md#spark.dynamicAllocation.shuffleTracking.enabled) configuration properties.

`shuffleTrackingEnabled` is enabled (`true`) when the following holds:

1. [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) is disabled
1. [spark.dynamicAllocation.shuffleTracking.enabled](configuration-properties.md#spark.dynamicAllocation.shuffleTracking.enabled) is enabled

When enabled, `shuffleTrackingEnabled` is used to skip execution of the following (making them noops):

* [onJobStart](#onJobStart)
* [onJobEnd](#onJobEnd)

When disabled, `shuffleTrackingEnabled` is used for the following:

* [onTaskEnd](#onTaskEnd)
* [shuffleCleaned](#shuffleCleaned)
* [shuffleIds](#shuffleIds)

## <span id="storageTimeoutNs"> spark.dynamicAllocation.cachedExecutorIdleTimeout

`ExecutorMonitor` reads [spark.dynamicAllocation.cachedExecutorIdleTimeout](configuration-properties.md#spark.dynamicAllocation.cachedExecutorIdleTimeout) configuration property for `Tracker` to [updateTimeout](Tracker.md#updateTimeout).

## <span id="onBlockUpdated"> onBlockUpdated

```scala
onBlockUpdated(
  event: SparkListenerBlockUpdated): Unit
```

`onBlockUpdated` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onBlockUpdated) abstraction.

`onBlockUpdated`...FIXME

## <span id="onExecutorAdded"> onExecutorAdded

```scala
onExecutorAdded(
  event: SparkListenerExecutorAdded): Unit
```

`onExecutorAdded` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onExecutorAdded) abstraction.

`onExecutorAdded`...FIXME

## <span id="onExecutorRemoved"> onExecutorRemoved

```scala
onExecutorRemoved(
  event: SparkListenerExecutorRemoved): Unit
```

`onExecutorRemoved` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onExecutorRemoved) abstraction.

`onExecutorRemoved`...FIXME

## <span id="onJobEnd"> onJobEnd

```scala
onJobEnd(
  event: SparkListenerJobEnd): Unit
```

`onJobEnd` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onJobEnd) abstraction.

`onJobEnd`...FIXME

## <span id="onJobStart"> onJobStart

```scala
onJobStart(
  event: SparkListenerJobStart): Unit
```

`onJobStart` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onJobStart) abstraction.

!!! note
    `onJobStart` does nothing and simply returns when the [shuffleTrackingEnabled](#shuffleTrackingEnabled) flag is turned off (`false`).

`onJobStart` requests the input `SparkListenerJobStart` for the [StageInfo](../SparkListenerEvent.md#SparkListenerJobStart-stageInfos)s and converts...FIXME

## <span id="onOtherEvent"> onOtherEvent

```scala
onOtherEvent(
  event: SparkListenerEvent): Unit
```

`onOtherEvent` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onOtherEvent) abstraction.

`onOtherEvent`...FIXME

### <span id="cleanupShuffle"> cleanupShuffle

```scala
cleanupShuffle(
  id: Int): Unit
```

`cleanupShuffle`...FIXME

`cleanupShuffle` is used when [onOtherEvent](#onOtherEvent)

## <span id="onTaskEnd"> onTaskEnd

```scala
onTaskEnd(
  event: SparkListenerTaskEnd): Unit
```

`onTaskEnd` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onTaskEnd) abstraction.

`onTaskEnd`...FIXME

## <span id="onTaskStart"> onTaskStart

```scala
onTaskStart(
  event: SparkListenerTaskStart): Unit
```

`onTaskStart` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onTaskStart) abstraction.

`onTaskStart`...FIXME

## <span id="onUnpersistRDD"> onUnpersistRDD

```scala
onUnpersistRDD(
  event: SparkListenerUnpersistRDD): Unit
```

`onUnpersistRDD` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onUnpersistRDD) abstraction.

`onUnpersistRDD`...FIXME

## <span id="reset"> reset

```scala
reset(): Unit
```

`reset`...FIXME

`reset` is used when:

* FIXME

## <span id="shuffleCleaned"> shuffleCleaned

```scala
shuffleCleaned(
  shuffleId: Int): Unit
```

`shuffleCleaned` is part of the [CleanerListener](../core/CleanerListener.md#shuffleCleaned) abstraction.

`shuffleCleaned`...FIXME

## <span id="timedOutExecutors"> timedOutExecutors

```scala
timedOutExecutors(): Seq[String]
timedOutExecutors(
  when: Long): Seq[String]
```

`timedOutExecutors`...FIXME

`timedOutExecutors` is used when:

* `ExecutorAllocationManager` is requested to [schedule](ExecutorAllocationManager.md#schedule)

## <span id="executorCount"> executorCount

```scala
executorCount: Int
```

`executorCount`...FIXME

`executorCount` is used when:

* `ExecutorAllocationManager` is requested to [addExecutors](ExecutorAllocationManager.md#addExecutors) and [removeExecutors](ExecutorAllocationManager.md#removeExecutors)
* `ExecutorAllocationManagerSource` is requested for [numberAllExecutors](ExecutorAllocationManagerSource.md#numberAllExecutors) performance metric

## <span id="pendingRemovalCount"> pendingRemovalCount

```scala
pendingRemovalCount: Int
```

`pendingRemovalCount`...FIXME

`pendingRemovalCount` is used when:

* `ExecutorAllocationManager` is requested to [removeExecutors](ExecutorAllocationManager.md#removeExecutors)
* `ExecutorAllocationManagerSource` is requested for [numberExecutorsPendingToRemove](ExecutorAllocationManagerSource.md#numberExecutorsPendingToRemove) performance metric

## <span id="executorsKilled"> executorsKilled

```scala
executorsKilled(
  ids: Seq[String]): Unit
```

`executorsKilled`...FIXME

`executorsKilled` is used when:

* `ExecutorAllocationManager` is requested to [removeExecutors](ExecutorAllocationManager.md#removeExecutors)

## <span id="ensureExecutorIsTracked"> ensureExecutorIsTracked

```scala
ensureExecutorIsTracked(
  id: String,
  resourceProfileId: Int): Tracker
```

`ensureExecutorIsTracked`...FIXME

`ensureExecutorIsTracked` is used when:

* [onBlockUpdated](#onBlockUpdated)
* [onExecutorAdded](#onExecutorAdded)
* [onTaskStart](#onTaskStart)

## <span id="getResourceProfileId"> getResourceProfileId

```scala
getResourceProfileId(
  executorId: String): Int
```

`getResourceProfileId`...FIXME

`getResourceProfileId` is used for testing only.
