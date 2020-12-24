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

## <span id="executors"> executors

```scala
executors: ConcurrentHashMap[String, Tracker]
```

`ExecutorMonitor` uses a Java [ConcurrentHashMap]({{ java.api }}/java.base/java/util/concurrent/ConcurrentHashMap.html) for an internal registry of available executors.

`executors` is cleared when [reset](#reset).

`executors` is used when...FIXME

## <span id="shuffleTrackingEnabled"> shuffleTrackingEnabled

`ExecutorMonitor`...FIXME

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

## <span id="onTaskStart"> onTaskStart

```scala
onTaskStart(
  event: SparkListenerTaskStart): Unit
```

`onTaskStart` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onTaskStart) abstraction.

`onTaskStart`...FIXME

## <span id="reset"> reset

```scala
reset(): Unit
```

`reset`...FIXME

`reset` is used when:

* FIXME

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

* FIXME

## <span id="pendingRemovalCount"> pendingRemovalCount

```scala
pendingRemovalCount: Int
```

`pendingRemovalCount`...FIXME

`pendingRemovalCount` is used when:

* FIXME

## <span id="executorsKilled"> executorsKilled

```scala
executorsKilled(
  ids: Seq[String]): Unit
```

`executorsKilled`...FIXME

`executorsKilled` is used when:

* FIXME

## <span id="ensureExecutorIsTracked"> ensureExecutorIsTracked

```scala
ensureExecutorIsTracked(
  id: String,
  resourceProfileId: Int): Tracker
```

`ensureExecutorIsTracked`...FIXME

`ensureExecutorIsTracked` is used when:

* [onTaskStart](#onTaskStart)
* [onExecutorAdded](#onExecutorAdded)
* [onBlockUpdated](#onBlockUpdated)
