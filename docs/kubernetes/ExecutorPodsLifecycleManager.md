# ExecutorPodsLifecycleManager

`ExecutorPodsLifecycleManager` is...FIXME

## Creating Instance

`ExecutorPodsLifecycleManager` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="kubernetesClient"> `KubernetesClient`
* <span id="snapshotsStore"> [ExecutorPodsSnapshotsStore](ExecutorPodsSnapshotsStore.md)
* <span id="removedExecutorsCache"> Guava `Cache`

`ExecutorPodsLifecycleManager` is created when `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend).

## <span id="start"> Starting

```scala
start(
  schedulerBackend: KubernetesClusterSchedulerBackend): Unit
```

`start` requests the [ExecutorPodsSnapshotsStore](#snapshotsStore) to [add a subscriber](ExecutorPodsSnapshotsStore.md#addSubscriber) to [intercept state changes in executor pods](#onNewSnapshots).

`start` is used when...FIXME

### <span id="onNewSnapshots"> Handling State Changes in Executor Pods

```scala
onNewSnapshots(
  schedulerBackend: KubernetesClusterSchedulerBackend,
  snapshots: Seq[ExecutorPodsSnapshot]): Unit
```

`onNewSnapshots`...FIXME
