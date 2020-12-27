# Tracker

`Tracker` is a private internal class of [ExecutorMonitor](ExecutorMonitor.md).

## Creating Instance

`Tracker` takes the following to be created:

* <span id="resourceProfileId"> resourceProfileId

`Tracker` is created when:

* `ExecutorMonitor` is requested to [ensureExecutorIsTracked](ExecutorMonitor.md#ensureExecutorIsTracked)

## <span id="cachedBlocks"> cachedBlocks Internal Registry

```scala
cachedBlocks: Map[Int, BitSet]
```

`Tracker` uses `cachedBlocks` internal registry for cached blocks (RDD IDs and partition IDs stored in an executor).

`cachedBlocks` is used when:

* `ExecutorMonitor` is requested to [onBlockUpdated](ExecutorMonitor.md#onBlockUpdated), [onUnpersistRDD](ExecutorMonitor.md#onUnpersistRDD)
* `Tracker` is requested to [updateTimeout](#updateTimeout)

## <span id="removeShuffle"> removeShuffle

```scala
removeShuffle(
  id: Int): Unit
```

`removeShuffle`...FIXME

`removeShuffle` is used when:

* `ExecutorMonitor` is requested to [cleanupShuffle](ExecutorMonitor.md#cleanupShuffle)

## <span id="updateActiveShuffles"> updateActiveShuffles

```scala
updateActiveShuffles(
  ids: Iterable[Int]): Unit
```

`updateActiveShuffles`...FIXME

`updateActiveShuffles` is used when:

* `ExecutorMonitor` is requested to [onJobStart](ExecutorMonitor.md#onJobStart) and [onJobEnd](ExecutorMonitor.md#onJobEnd)

## <span id="updateRunningTasks"> updateRunningTasks

```scala
updateRunningTasks(
  delta: Int): Unit
```

`updateRunningTasks`...FIXME

`updateRunningTasks` is used when:

* `ExecutorMonitor` is requested to [onTaskStart](ExecutorMonitor.md#onTaskStart), [onTaskEnd](ExecutorMonitor.md#onTaskEnd) and [onExecutorAdded](ExecutorMonitor.md#onExecutorAdded)

## <span id="updateTimeout"> updateTimeout

```scala
updateTimeout(): Unit
```

`updateTimeout`...FIXME

`updateTimeout` is used when:

* `ExecutorMonitor` is requested to [onBlockUpdated](ExecutorMonitor.md#onBlockUpdated) and [onUnpersistRDD](ExecutorMonitor.md#onUnpersistRDD)
* `Tracker` is requested to [updateRunningTasks](#updateRunningTasks), [removeShuffle](#removeShuffle), [updateActiveShuffles](#updateActiveShuffles)
