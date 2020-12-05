# ExecutorAllocationClient

`ExecutorAllocationClient` is an abstraction of [schedulers](#implementations) that can communicate with a cluster manager to request or kill executors.

## Implementations

* [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md)
* [KubernetesClusterSchedulerBackend](../kubernetes/KubernetesClusterSchedulerBackend.md)
* MesosCoarseGrainedSchedulerBackend
* StandaloneSchedulerBackend
* YarnSchedulerBackend

## <span id="getExecutorIds"> Active Executors

```scala
getExecutorIds(): Seq[String]
```

Used when:

* `SparkContext` is requested for [active executors](../SparkContext.md#getExecutorIds)

## <span id="isExecutorActive"> Whether Executor is Active

```scala
isExecutorActive(
  id: String): Boolean
```

Returns whether a given executor is active (and can be used to execute tasks)

## <span id="killExecutors"> Killing Executors

```scala
killExecutors(
  executorIds: Seq[String],
  adjustTargetNumExecutors: Boolean,
  countFailures: Boolean,
  force: Boolean = false): Seq[String]
```

Requests a cluster manager to kill given executors and returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when:

* `ExecutorAllocationClient` is requested to [kill an executor](#killExecutor)
* `ExecutorAllocationManager` is requested to [removeExecutors](ExecutorAllocationManager.md#removeExecutors)
* `SparkContext` is requested to [kill executors](../SparkContext.md#killExecutors) and [killAndReplaceExecutor](../SparkContext.md#killAndReplaceExecutor)
* `BlacklistTracker` is requested to [kill an executor](../scheduler/BlacklistTracker.md#killExecutor)
* `DriverEndpoint` is requested to [handle a KillExecutorsOnHost message](../scheduler/DriverEndpoint.md#KillExecutorsOnHost)

## <span id="killExecutorsOnHost"> Killing Executors on Host

```scala
killExecutorsOnHost(
  host: String): Boolean
```

Used when:

* `BlacklistTracker` is requested to [kill executors on a blacklisted node](../scheduler/BlacklistTracker.md#killExecutorsOnBlacklistedNode)

## <span id="requestExecutors"> Requesting Additional Executors

```scala
requestExecutors(
  numAdditionalExecutors: Int): Boolean
```

Requests additional executors from a cluster manager and returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when:

* `SparkContext` is requested for [additional executors](../SparkContext.md#requestExecutors)

## <span id="requestTotalExecutors"> Updating Total Executors

```scala
requestTotalExecutors(
  numExecutors: Int,
  localityAwareTasks: Int,
  hostToLocalTaskCount: Map[String, Int]): Boolean
```

Updates a cluster manager with the exact number of executors desired. Returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when:

* `SparkContext` is requested to [update the number of total executors](../SparkContext.md#requestTotalExecutors)

* `ExecutorAllocationManager` is requested to [start](ExecutorAllocationManager.md#start), [updateAndSyncNumExecutorsTarget](ExecutorAllocationManager.md#updateAndSyncNumExecutorsTarget), [addExecutors](ExecutorAllocationManager.md#addExecutors), [removeExecutors](ExecutorAllocationManager.md#removeExecutors)

## <span id="killExecutor"> Killing Executor

```scala
killExecutor(
  executorId: String): Boolean
```

`killExecutor` [kill the given executor](#killExecutors).

`killExecutor` is used when:

* `ExecutorAllocationManager` [removes an executor](ExecutorAllocationManager.md#removeExecutor).
* `SparkContext` [is requested to kill executors](../SparkContext.md#killExecutors).
