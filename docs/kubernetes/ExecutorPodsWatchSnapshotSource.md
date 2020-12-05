# ExecutorPodsWatchSnapshotSource

`ExecutorPodsWatchSnapshotSource` is...FIXME

## Creating Instance

`ExecutorPodsWatchSnapshotSource` takes the following to be created:

* <span id="snapshotsStore"> [ExecutorPodsSnapshotsStore](ExecutorPodsSnapshotsStore.md)
* <span id="kubernetesClient"> `KubernetesClient`

`ExecutorPodsWatchSnapshotSource` is created when:

* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)

## <span id="start"> Starting

```scala
start(
  applicationId: String): Unit
```

`start` prints out the following DEBUG message to the logs:

```text
Starting watch for pods with labels spark-app-selector=[applicationId], spark-role=executor.
```

`start` requests the [KubernetesClient](#kubernetesClient) to watch pods with the following labels using [ExecutorPodsWatcher](ExecutorPodsWatcher.md):

* `spark-app-selector` with the given `applicationId`
* `spark-role` as `executor`

`start` is used when:

* `KubernetesClusterSchedulerBackend` is requested to [start](KubernetesClusterSchedulerBackend.md#start)

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.cluster.k8s.ExecutorPodsWatchSnapshotSource` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.cluster.k8s.ExecutorPodsWatchSnapshotSource=ALL
```

Refer to [Logging](../spark-logging.md).
