# KubernetesClusterSchedulerBackend

`KubernetesClusterSchedulerBackend` is a [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md) for [Kubernetes](index.md).

## Creating Instance

`KubernetesClusterSchedulerBackend` takes the following to be created:

* <span id="scheduler"> [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md)
* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="kubernetesClient"> `KubernetesClient`
* <span id="executorService"> Java's [ScheduledExecutorService]({{ java.api }}/java.base/java/util/concurrent/ScheduledExecutorService.html)
* <span id="snapshotsStore"> [ExecutorPodsSnapshotsStore](ExecutorPodsSnapshotsStore.md)
* [ExecutorPodsAllocator](#podAllocator)
* <span id="lifecycleEventHandler"> [ExecutorPodsLifecycleManager](ExecutorPodsLifecycleManager.md)
* <span id="watchEvents"> [ExecutorPodsWatchSnapshotSource](ExecutorPodsWatchSnapshotSource.md)
* <span id="pollEvents"> [ExecutorPodsPollingSnapshotSource](ExecutorPodsPollingSnapshotSource.md)

`KubernetesClusterSchedulerBackend` is created when:

* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)

## <span id="podAllocator"><span id="ExecutorPodsAllocator"> ExecutorPodsAllocator

`KubernetesClusterSchedulerBackend` is given an [ExecutorPodsAllocator](ExecutorPodsAllocator.md) to be [created](#creating-instance).

When [started](#start), `KubernetesClusterSchedulerBackend` requests the `ExecutorPodsAllocator` to [setTotalExpectedExecutors](ExecutorPodsAllocator.md#setTotalExpectedExecutors) to the [number of initial executors](#initialExecutors) and [starts it](ExecutorPodsAllocator.md#start) with [application Id](#applicationId).

When requested for the [expected number of executors](#doRequestTotalExecutors), `KubernetesClusterSchedulerBackend` requests the `ExecutorPodsAllocator` to [setTotalExpectedExecutors](ExecutorPodsAllocator.md#setTotalExpectedExecutors) to the given total number of executors.

When requested to [isBlacklisted](#isBlacklisted), `KubernetesClusterSchedulerBackend` requests the `ExecutorPodsAllocator` to [isDeleted](ExecutorPodsAllocator.md#isDeleted) with a given executor.

## <span id="applicationId"> Application Id

```scala
applicationId(): String
```

`applicationId` is part of the [SchedulerBackend](../scheduler/SchedulerBackend.md#applicationId) abstraction.

`applicationId` is the value of [spark.app.id](../configuration-properties.md#spark.app.id) configuration property if defined or the default [applicationId](../scheduler/SchedulerBackend.md#applicationId).

## <span id="sufficientResourcesRegistered"> Sufficient Resources Registered

```scala
sufficientResourcesRegistered(): Boolean
```

`sufficientResourcesRegistered` is part of the [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md#sufficientResourcesRegistered) abstraction.

`sufficientResourcesRegistered` holds (is `true`) when the [totalRegisteredExecutors](../scheduler/CoarseGrainedSchedulerBackend.md#totalRegisteredExecutors) is at least the [ratio](#minRegisteredRatio) of the [initial executors](#initialExecutors).

## <span id="initialExecutors"> Initial Executors

```scala
initialExecutors: Int
```

`KubernetesClusterSchedulerBackend` [calculates the initial target number of executors](../scheduler/SchedulerBackendUtils.md#getInitialTargetExecutorNumber) when [created](#creating-instance).

`initialExecutors` is used when `KubernetesClusterSchedulerBackend` is requested to [start](#start) and [whether or not sufficient resources registered](#sufficientResourcesRegistered).

## <span id="minRegisteredRatio"> Minimum Resources Available Ratio

```scala
minRegisteredRatio: Double
```

`minRegisteredRatio` is part of the [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md#minRegisteredRatio) abstraction.

`minRegisteredRatio` is `0.8` unless [spark.scheduler.minRegisteredResourcesRatio](../configuration-properties.md#spark.scheduler.minRegisteredResourcesRatio) is defined.

## <span id="start"> Starting SchedulerBackend

```scala
start(): Unit
```

`start` is part of the [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md#start) abstraction.

`start` [creates a delegation token manager](../scheduler/CoarseGrainedSchedulerBackend.md#start).

`start` requests the [ExecutorPodsAllocator](#podAllocator) to [setTotalExpectedExecutors](ExecutorPodsAllocator.md#setTotalExpectedExecutors) to [initialExecutors](#initialExecutors).

`start` requests the [ExecutorPodsLifecycleManager](#lifecycleEventHandler) to [start](ExecutorPodsLifecycleManager.md#start) (with this `KubernetesClusterSchedulerBackend`).

`start` requests the [ExecutorPodsAllocator](#podAllocator) to [start](ExecutorPodsAllocator.md#start) (with the [applicationId](#applicationId))

`start` requests the [ExecutorPodsWatchSnapshotSource](#watchEvents) to [start](ExecutorPodsWatchSnapshotSource.md#start) (with the [applicationId](#applicationId))

`start` requests the [ExecutorPodsPollingSnapshotSource](#pollEvents) to [start](ExecutorPodsPollingSnapshotSource.md#start) (with the [applicationId](#applicationId))

## <span id="createDriverEndpoint"> Creating DriverEndpoint

```scala
createDriverEndpoint(): DriverEndpoint
```

`createDriverEndpoint` is part of the [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md#createDriverEndpoint) abstraction.

`createDriverEndpoint` creates a [KubernetesDriverEndpoint](KubernetesDriverEndpoint.md).

## <span id="doRequestTotalExecutors"> Requesting Executors from Cluster Manager

```scala
doRequestTotalExecutors(
  requestedTotal: Int): Future[Boolean]
```

`doRequestTotalExecutors` is part of the [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md#doRequestTotalExecutors) abstraction.

`doRequestTotalExecutors` requests the [ExecutorPodsAllocator](#podAllocator) to [setTotalExpectedExecutors](ExecutorPodsAllocator.md#setTotalExpectedExecutors) to the given `requestedTotal`.

In the end, `doRequestTotalExecutors` returns a completed `Future` with `true` value.
