# ExecutorPodsSnapshotsStore

`ExecutorPodsSnapshotsStore` is an [abstraction](#contract) of [pod stores](#implementations).

## Contract

### <span id="addSubscriber"> addSubscriber

```scala
addSubscriber(
  processBatchIntervalMillis: Long)(
  onNewSnapshots: Seq[ExecutorPodsSnapshot] => Unit): Unit
```

Used when:

* `ExecutorPodsAllocator` is requested to [start](ExecutorPodsAllocator.md#start)
* `ExecutorPodsLifecycleManager` is requested to [start](ExecutorPodsLifecycleManager.md#start)

### <span id="notifySubscribers"> notifySubscribers

```scala
notifySubscribers(): Unit
```

Used when:

* `ExecutorPodsAllocator` is requested to [setTotalExpectedExecutors](ExecutorPodsAllocator.md#setTotalExpectedExecutors)

### <span id="replaceSnapshot"> replaceSnapshot

```scala
replaceSnapshot(
  newSnapshot: Seq[Pod]): Unit
```

Used when:

* `PollRunnable` is requested to [start](PollRunnable.md#run)

### <span id="stop"> stop

```scala
stop(): Unit
```

Used when:

* `KubernetesClusterSchedulerBackend` is requested to [stop](KubernetesClusterSchedulerBackend.md#stop)

### <span id="updatePod"> updatePod

```scala
updatePod(
  updatedPod: Pod): Unit
```

Used when:

* `ExecutorPodsWatcher` is requested to [eventReceived](ExecutorPodsWatcher.md#eventReceived)

## Implementations

* [ExecutorPodsSnapshotsStoreImpl](ExecutorPodsSnapshotsStoreImpl.md)
