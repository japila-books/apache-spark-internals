# ExecutorPodsAllocator

`ExecutorPodsAllocator` is...FIXME

## Creating Instance

`ExecutorPodsAllocator` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="secMgr"> `SecurityManager`
* <span id="executorBuilder"> [KubernetesExecutorBuilder](KubernetesExecutorBuilder.md)
* <span id="kubernetesClient"> `KubernetesClient`
* <span id="snapshotsStore"> [ExecutorPodsSnapshotsStore](ExecutorPodsSnapshotsStore.md)
* <span id="clock"> `Clock`

`ExecutorPodsAllocator` is created when:

* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)

## <span id="podAllocationDelay"> spark.kubernetes.allocation.batch.delay

`ExecutorPodsAllocator` uses [spark.kubernetes.allocation.batch.delay](configuration-properties.md#spark.kubernetes.allocation.batch.delay) configuration property for the following:

* [podCreationTimeout](#podCreationTimeout)
* [Registering a subscriber](#start)

## <span id="start"> Starting

```scala
start(
  applicationId: String): Unit
```

`start` requests the [ExecutorPodsSnapshotsStore](#snapshotsStore) to [add a new subscriber](ExecutorPodsSnapshotsStore.md#addSubscriber) (with [podAllocationDelay](#podAllocationDelay)) to [intercept new snapshots](#onNewSnapshots).

`start` is used when:

* `KubernetesClusterSchedulerBackend` is requested to [start](KubernetesClusterSchedulerBackend.md#start)

### <span id="onNewSnapshots"> onNewSnapshots

```scala
onNewSnapshots(
  applicationId: String,
  snapshots: Seq[ExecutorPodsSnapshot]): Unit
```

`onNewSnapshots`...FIXME

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator=ALL
```

Refer to [Logging](../spark-logging.md).
