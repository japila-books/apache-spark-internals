# KubernetesClusterManager

<span id="canCreate">
`KubernetesClusterManager` is an [ExternalClusterManager](../scheduler/ExternalClusterManager.md) for **k8s** master URLs.

## <span id="createTaskScheduler"> Creating TaskScheduler

```scala
createTaskScheduler(
  sc: SparkContext,
  masterURL: String): TaskScheduler
```

`createTaskScheduler` creates a [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md).

`createTaskScheduler` is part of the [ExternalClusterManager](../scheduler/ExternalClusterManager.md#createTaskScheduler) abstraction.

## <span id="createSchedulerBackend"> Creating SchedulerBackend

```scala
createSchedulerBackend(
  sc: SparkContext,
  masterURL: String,
  scheduler: TaskScheduler): SchedulerBackend
```

`createSchedulerBackend` creates a [KubernetesClusterSchedulerBackend](KubernetesClusterSchedulerBackend.md).

!!! note
    `createSchedulerBackend` assumes that the given [TaskScheduler](../scheduler/TaskScheduler.md) is [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md).

`createSchedulerBackend` uses [spark.kubernetes.submitInDriver](configuration-properties.md#spark.kubernetes.submitInDriver) configuration property to determine whether executing in `cluster` deploy mode.

`createSchedulerBackend`...FIXME

`createSchedulerBackend` is part of the [ExternalClusterManager](../scheduler/ExternalClusterManager.md#createSchedulerBackend) abstraction.

## <span id="initialize"> Initializing Scheduling Components

```scala
initialize(
  scheduler: TaskScheduler,
  backend: SchedulerBackend): Unit
```

`initialize` requests the given [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md) to [initialize](#initialize) with the given [SchedulerBackend](../scheduler/SchedulerBackend.md).

`initialize` is part of the [ExternalClusterManager](../scheduler/ExternalClusterManager.md#initialize) abstraction.
