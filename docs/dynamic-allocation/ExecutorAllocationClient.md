# ExecutorAllocationClient

`ExecutorAllocationClient` is an [abstraction](#contract) of [schedulers](#implementations) that can communicate with a cluster manager to request or kill executors.

## Contract

### <span id="getExecutorIds"> Active Executor IDs

```scala
getExecutorIds(): Seq[String]
```

Used when:

* `SparkContext` is requested for [active executors](../SparkContext.md#getExecutorIds)

### <span id="isExecutorActive"> isExecutorActive

```scala
isExecutorActive(
  id: String): Boolean
```

Whether a given executor (by ID) is active (and can be used to execute tasks)

Used when:

* FIXME

### <span id="killExecutors"> Killing Executors

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

### <span id="killExecutorsOnHost"> Killing Executors on Host

```scala
killExecutorsOnHost(
  host: String): Boolean
```

Used when:

* `BlacklistTracker` is requested to [kill executors on a blacklisted node](../scheduler/BlacklistTracker.md#killExecutorsOnBlacklistedNode)

### <span id="requestExecutors"> Requesting Additional Executors

```scala
requestExecutors(
  numAdditionalExecutors: Int): Boolean
```

Requests additional executors from a cluster manager and returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when:

* `SparkContext` is requested for [additional executors](../SparkContext.md#requestExecutors)

### <span id="requestTotalExecutors"> Updating Total Executors

```scala
requestTotalExecutors(
  resourceProfileIdToNumExecutors: Map[Int, Int],
  numLocalityAwareTasksPerResourceProfileId: Map[Int, Int],
  hostToLocalTaskCount: Map[Int, Map[String, Int]]): Boolean
```

Updates a cluster manager with the exact number of executors desired. Returns whether the request has been acknowledged by the cluster manager (`true`) or not (`false`).

Used when:

* `SparkContext` is requested to [update the number of total executors](../SparkContext.md#requestTotalExecutors)

* `ExecutorAllocationManager` is requested to [start](ExecutorAllocationManager.md#start), [updateAndSyncNumExecutorsTarget](ExecutorAllocationManager.md#updateAndSyncNumExecutorsTarget), [addExecutors](ExecutorAllocationManager.md#addExecutors), [removeExecutors](ExecutorAllocationManager.md#removeExecutors)

## Implementations

* [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md)
* `KubernetesClusterSchedulerBackend` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesClusterSchedulerBackend))
* MesosCoarseGrainedSchedulerBackend
* [StandaloneSchedulerBackend](../spark-standalone/StandaloneSchedulerBackend.md)
* YarnSchedulerBackend

## <span id="killExecutor"> Killing Single Executor

```scala
killExecutor(
  executorId: String): Boolean
```

`killExecutor` [kill the given executor](#killExecutors).

`killExecutor` is used when:

* `ExecutorAllocationManager` [removes an executor](ExecutorAllocationManager.md#removeExecutor).
* `SparkContext` [is requested to kill executors](../SparkContext.md#killExecutors).

## <span id="decommissionExecutors"> Decommissioning Executors

```scala
decommissionExecutors(
  executorsAndDecomInfo: Array[(String, ExecutorDecommissionInfo)],
  adjustTargetNumExecutors: Boolean,
  triggeredByExecutor: Boolean): Seq[String]
```

`decommissionExecutors` [kills](#killExecutors) the given executors.

`decommissionExecutors` is used when:

* `ExecutorAllocationClient` is requested to [decommission a single executor](#decommissionExecutor)
* `ExecutorAllocationManager` is requested to [remove executors](ExecutorAllocationManager.md#removeExecutors)
* `StandaloneSchedulerBackend` is requested to [executorDecommissioned](../spark-standalone/StandaloneSchedulerBackend.md#executorDecommissioned)

## <span id="decommissionExecutor"> Decommissioning Single Executor

```scala
decommissionExecutor(
  executorId: String,
  decommissionInfo: ExecutorDecommissionInfo,
  adjustTargetNumExecutors: Boolean,
  triggeredByExecutor: Boolean = false): Boolean
```

`decommissionExecutor`...FIXME

`decommissionExecutor` is used when:

* `DriverEndpoint` is requested to [handle a ExecutorDecommissioning message](../scheduler/DriverEndpoint.md#ExecutorDecommissioning)
