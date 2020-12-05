# ExecutorPodsSnapshotsStoreImpl

`ExecutorPodsSnapshotsStoreImpl` is an [ExecutorPodsSnapshotsStore](ExecutorPodsSnapshotsStore.md).

## Creating Instance

`ExecutorPodsSnapshotsStoreImpl` takes the following to be created:

* <span id="subscribersExecutor"> Java's [ScheduledExecutorService]({{ java.api }}/java.base/java/util/concurrent/ScheduledExecutorService.html)

`ExecutorPodsSnapshotsStoreImpl` is created when:

* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)
