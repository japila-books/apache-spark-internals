# PollRunnable

`PollRunnable` is a Java [Runnable]({{ java.api }}/java.base/java/lang/Runnable.html) that [ExecutorPodsPollingSnapshotSource](ExecutorPodsPollingSnapshotSource.md) uses to [run](#run) regularly for current snapshots of the executor pods of the [application](#applicationId).

!!! note "Internal Class"
    `PollRunnable` is an internal class of [ExecutorPodsPollingSnapshotSource](ExecutorPodsPollingSnapshotSource.md) with full access to internal registries.

## Creating Instance

`PollRunnable` takes the following to be created:

* <span id="applicationId"> Application Id

`PollRunnable` is created when:

* `ExecutorPodsPollingSnapshotSource` is requested to [start](ExecutorPodsPollingSnapshotSource.md#start)

## <span id="run"> Starting Thread

```scala
run(): Unit
```

`run` prints out the following DEBUG message to the logs:

```text
Resynchronizing full executor pod state from Kubernetes.
```

`run` requests the [KubernetesClient](ExecutorPodsPollingSnapshotSource.md#kubernetesClient) for Spark executor pods that are pods with the following labels and values:

* `spark-app-selector` as the [application Id](#applicationId)
* `spark-role` as `executor`

In the end, `run` requests the [ExecutorPodsSnapshotsStore](ExecutorPodsPollingSnapshotSource.md#snapshotsStore) to [replace the snapshot](ExecutorPodsSnapshotsStore.md#replaceSnapshot).

## Logging

`PollRunnable` uses [org.apache.spark.scheduler.cluster.k8s.ExecutorPodsPollingSnapshotSource](ExecutorPodsPollingSnapshotSource.md#logging) logger for logging.
