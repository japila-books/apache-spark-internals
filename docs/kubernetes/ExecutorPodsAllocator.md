# ExecutorPodsAllocator

`ExecutorPodsAllocator` is used to create a [KubernetesClusterSchedulerBackend](KubernetesClusterSchedulerBackend.md#podAllocator).

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

## <span id="setTotalExpectedExecutors"> setTotalExpectedExecutors

```scala
setTotalExpectedExecutors(
  total: Int): Unit
```

`setTotalExpectedExecutors` sets [totalExpectedExecutors](#totalExpectedExecutors) internal registry to the input `total`.

With no [hasPendingPods](#hasPendingPods), `setTotalExpectedExecutors` requests the [ExecutorPodsSnapshotsStore](#snapshotsStore) to [notifySubscribers](ExecutorPodsSnapshotsStore.md#notifySubscribers).

`setTotalExpectedExecutors` is used when:

* `KubernetesClusterSchedulerBackend` is requested to [start](KubernetesClusterSchedulerBackend.md#start) and [doRequestTotalExecutors](KubernetesClusterSchedulerBackend.md#doRequestTotalExecutors)

## Registries

### <span id="totalExpectedExecutors"> Total Expected Executors

```scala
totalExpectedExecutors: AtomicInteger
```

`ExecutorPodsAllocator` uses a Java [AtomicInteger]({{ java.api }}/java.base/java/util/concurrent/atomic/AtomicInteger.html) to track the total expected number of executors.

Starts from `0` and is set to a fixed number of the total expected executors in [setTotalExpectedExecutors](#setTotalExpectedExecutors)

Used in [onNewSnapshots](#onNewSnapshots)

### <span id="hasPendingPods"> hasPendingPods Flag

```scala
hasPendingPods: AtomicBoolean
```

`ExecutorPodsAllocator` uses a Java [AtomicBoolean]({{ java.api }}/java.base/java/util/concurrent/atomic/AtomicBoolean.html) as a flag to avoid notifying subscribers.

Starts as `false` and is updated every [onNewSnapshots](#onNewSnapshots)

Used in [setTotalExpectedExecutors](#setTotalExpectedExecutors) (only when `false`)

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.cluster.k8s.ExecutorPodsAllocator=ALL
```

Refer to [Logging](../spark-logging.md).
