# CoarseGrainedSchedulerBackend

`CoarseGrainedSchedulerBackend` is a base [SchedulerBackend](SchedulerBackend.md) for [coarse-grained schedulers](#implementations).

`CoarseGrainedSchedulerBackend` is an [ExecutorAllocationClient](../dynamic-allocation/ExecutorAllocationClient.md).

`CoarseGrainedSchedulerBackend` is responsible for requesting resources from a cluster manager for executors that it in turn uses to [launch tasks](DriverEndpoint.md#launchTasks) (on [CoarseGrainedExecutorBackend](../executor/CoarseGrainedExecutorBackend.md)).

`CoarseGrainedSchedulerBackend` holds executors for the duration of the Spark job rather than relinquishing executors whenever a task is done and asking the scheduler to launch a new executor for each new task.

`CoarseGrainedSchedulerBackend` registers [CoarseGrainedScheduler RPC Endpoint](#CoarseGrainedScheduler) that executors use for RPC communication.

!!! note
    **Active executors** are executors that are not [pending to be removed](#executorsPendingToRemove) or [lost](DriverEndpoint.md#executorsPendingLossReason).

## Implementations

* `KubernetesClusterSchedulerBackend` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesClusterSchedulerBackend))
* MesosCoarseGrainedSchedulerBackend
* [StandaloneSchedulerBackend](../spark-standalone/StandaloneSchedulerBackend.md)
* YarnSchedulerBackend

## Creating Instance

`CoarseGrainedSchedulerBackend` takes the following to be created:

* <span id="scheduler"> [TaskSchedulerImpl](TaskSchedulerImpl.md)
* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)

### <span id="createDriverEndpoint"> Creating DriverEndpoint

```scala
createDriverEndpoint(
  properties: Seq[(String, String)]): DriverEndpoint
```

`createDriverEndpoint` creates a [DriverEndpoint](DriverEndpoint.md).

!!! note
    The purpose of `createDriverEndpoint` is to let [CoarseGrainedSchedulerBackends](#implementations) to provide custom implementations (e.g. `KubernetesClusterSchedulerBackend`).

`createDriverEndpoint` is used when `CoarseGrainedSchedulerBackend` is [created](#creating-instance) (and initializes the [driverEndpoint](#driverEndpoint) internal reference).

## <span id="decommissionExecutors"> decommissionExecutors

```scala
decommissionExecutors(
  executorsAndDecomInfo: Array[(String, ExecutorDecommissionInfo)],
  adjustTargetNumExecutors: Boolean,
  triggeredByExecutor: Boolean): Seq[String]
```

`decommissionExecutors` is part of the [ExecutorAllocationClient](../dynamic-allocation/ExecutorAllocationClient.md#decommissionExecutors) abstraction.

`decommissionExecutors`...FIXME

## <span id="totalRegisteredExecutors"> totalRegisteredExecutors Registry

```scala
totalRegisteredExecutors: AtomicInteger
```

`totalRegisteredExecutors` is an internal registry of the number of registered executors (a Java [AtomicInteger]({{ java.api }}/java.base/java/util/concurrent/atomic/AtomicInteger.html)).

`totalRegisteredExecutors` starts from `0`.

`totalRegisteredExecutors` is incremented when:

* `DriverEndpoint` is requested to [handle a RegisterExecutor message](DriverEndpoint.md#RegisterExecutor)

`totalRegisteredExecutors` is decremented when:

* `DriverEndpoint` is requested to [remove an executor](DriverEndpoint.md#removeExecutor)

## <span id="isReady"> isReady

```scala
isReady(): Boolean
```

`isReady` is part of the [SchedulerBackend](SchedulerBackend.md#isReady) abstraction.

`isReady`...FIXME

### <span id="sufficientResourcesRegistered"> Sufficient Resources Registered

```scala
sufficientResourcesRegistered(): Boolean
```

`sufficientResourcesRegistered` is `true` (and is supposed to be overriden by [custom CoarseGrainedSchedulerBackends](#implementations)).

### <span id="minRegisteredRatio"><span id="_minRegisteredRatio"> Minimum Resources Available Ratio

```scala
minRegisteredRatio: Double
```

`minRegisteredRatio` is a ratio of the minimum resources available to the total expected resources for the `CoarseGrainedSchedulerBackend` to be ready for scheduling tasks (for execution).

`minRegisteredRatio` uses [spark.scheduler.minRegisteredResourcesRatio](../configuration-properties.md#spark.scheduler.minRegisteredResourcesRatio) configuration property if defined or defaults to `0.0`.

`minRegisteredRatio` can be between `0.0` and `1.0` (inclusive).

`minRegisteredRatio` is used when:

* `CoarseGrainedSchedulerBackend` is requested to [isReady](#isReady)
* `StandaloneSchedulerBackend` is requested to `sufficientResourcesRegistered`
* `KubernetesClusterSchedulerBackend` is requested to `sufficientResourcesRegistered`
* `MesosCoarseGrainedSchedulerBackend` is requested to `sufficientResourcesRegistered`
* `YarnSchedulerBackend` is requested to `sufficientResourcesRegistered`

## <span id="driverEndpoint"> DriverEndpoint

```scala
driverEndpoint: RpcEndpointRef
```

`CoarseGrainedSchedulerBackend` creates a [DriverEndpoint](DriverEndpoint.md) when [created](#creating-instance).

The `DriverEndpoint` is used to communicate with the driver (by sending RPC messages).

## <span id="executorDataMap"> Available Executors Registry

```scala
executorDataMap: HashMap[String, ExecutorData]
```

`CoarseGrainedSchedulerBackend` tracks available executors using `executorDataMap` registry (of [ExecutorData](ExecutorData.md)s by executor id).

A new entry is added when `DriverEndpoint` is requested to handle [RegisterExecutor](DriverEndpoint.md#RegisterExecutor) message.

An entry is removed when `DriverEndpoint` is requested to handle [RemoveExecutor](DriverEndpoint.md#RemoveExecutor) message or [a remote host (with one or many executors) disconnects](DriverEndpoint.md#onDisconnected).

## <span id="reviveThread"> Revive Messages Scheduler Service

```scala
reviveThread: ScheduledExecutorService
```

`CoarseGrainedSchedulerBackend` creates a Java [ScheduledExecutorService]({{ java.api }}/java.base/java/util/concurrent/ScheduledExecutorService.html) when [created](#creating-instance).

The `ScheduledExecutorService` is used by `DriverEndpoint` RPC Endpoint to [post ReviveOffers messages regularly](DriverEndpoint.md#onStart).

## <span id="maxRpcMessageSize"><span id="spark.rpc.message.maxSize"> Maximum Size of RPC Message

`maxRpcMessageSize` is the value of [spark.rpc.message.maxSize](../configuration-properties.md#spark.rpc.message.maxSize) configuration property.

## <span id="makeOffers"> Making Fake Resource Offers on Executors

```scala
makeOffers(): Unit
makeOffers(
  executorId: String): Unit
```

`makeOffers` takes the active executors (out of the <<executorDataMap, executorDataMap>> internal registry) and creates `WorkerOffer` resource offers for each (one per executor with the executor's id, host and free cores).

CAUTION: Only free cores are considered in making offers. Memory is not! Why?!

It then requests TaskSchedulerImpl.md#resourceOffers[`TaskSchedulerImpl` to process the resource offers] to create a collection of [TaskDescription](TaskDescription.md) collections that it in turn uses to [launch tasks](DriverEndpoint.md#launchTasks).

## <span id="getExecutorIds"> Getting Executor Ids

When called, `getExecutorIds` simply returns executor ids from the internal <<executorDataMap, executorDataMap>> registry.

NOTE: It is called when SparkContext.md#getExecutorIds[SparkContext calculates executor ids].

## <span id="requestExecutors"> Requesting Executors

```scala
requestExecutors(
  numAdditionalExecutors: Int): Boolean
```

`requestExecutors` is a "decorator" method that ultimately calls a cluster-specific [doRequestTotalExecutors](#doRequestTotalExecutors) method and returns whether the request was acknowledged or not (it is assumed `false` by default).

`requestExecutors` method is part of the [ExecutorAllocationClient](../dynamic-allocation/ExecutorAllocationClient.md#requestExecutors) abstraction.

When called, you should see the following INFO message followed by DEBUG message in the logs:

```text
Requesting [numAdditionalExecutors] additional executor(s) from the cluster manager
Number of pending executors is now [numPendingExecutors]
```

<<numPendingExecutors, numPendingExecutors>> is increased by the input `numAdditionalExecutors`.

`requestExecutors` [requests executors from a cluster manager](#doRequestTotalExecutors) (that reflects the current computation needs). The "new executor total" is a sum of the internal <<numExistingExecutors, numExistingExecutors>> and <<numPendingExecutors, numPendingExecutors>> decreased by the <<executorsPendingToRemove, number of executors pending to be removed>>.

If `numAdditionalExecutors` is negative, a `IllegalArgumentException` is thrown:

```text
Attempted to request a negative number of additional executor(s) [numAdditionalExecutors] from the cluster manager. Please specify a positive number!
```

NOTE: It is a final method that no other scheduler backends could customize further.

NOTE: The method is a synchronized block that makes multiple concurrent requests be handled in a serial fashion, i.e. one by one.

## <span id="requestTotalExecutors"> Requesting Exact Number of Executors

```scala
requestTotalExecutors(
  numExecutors: Int,
  localityAwareTasks: Int,
  hostToLocalTaskCount: Map[String, Int]): Boolean
```

`requestTotalExecutors` is a "decorator" method that ultimately calls a cluster-specific [doRequestTotalExecutors](#doRequestTotalExecutors) method and returns whether the request was acknowledged or not (it is assumed `false` by default).

`requestTotalExecutors` is part of the [ExecutorAllocationClient](../dynamic-allocation/ExecutorAllocationClient.md#requestTotalExecutors) abstraction.

It sets the internal <<localityAwareTasks, localityAwareTasks>> and <<hostToLocalTaskCount, hostToLocalTaskCount>> registries. It then calculates the exact number of executors which is the input `numExecutors` and the <<executorsPendingToRemove, executors pending removal>> decreased by the number of <<numExistingExecutors, already-assigned executors>>.

If `numExecutors` is negative, a `IllegalArgumentException` is thrown:

```text
Attempted to request a negative number of executor(s) [numExecutors] from the cluster manager. Please specify a positive number!
```

NOTE: It is a final method that no other scheduler backends could customize further.

NOTE: The method is a synchronized block that makes multiple concurrent requests be handled in a serial fashion, i.e. one by one.

## <span id="defaultParallelism"> Finding Default Level of Parallelism

```scala
defaultParallelism(): Int
```

`defaultParallelism` is part of the [SchedulerBackend](SchedulerBackend.md#defaultParallelism) abstraction.

`defaultParallelism` is [spark.default.parallelism](../configuration-properties.md#spark.default.parallelism) configuration property if defined.

Otherwise, `defaultParallelism` is the maximum of [totalCoreCount](#totalCoreCount) or `2`.

## <span id="killTask"> Killing Task

```scala
killTask(
  taskId: Long,
  executorId: String,
  interruptThread: Boolean): Unit
```

`killTask` is part of the [SchedulerBackend](SchedulerBackend.md#killTask) abstraction.

`killTask` simply sends a [KillTask](DriverEndpoint.md#KillTask) message to <<driverEndpoint, driverEndpoint>>.

## <span id="stopExecutors"> Stopping All Executors

`stopExecutors` sends a blocking <<StopExecutors, StopExecutors>> message to <<driverEndpoint, driverEndpoint>> (if already initialized).

NOTE: It is called exclusively while `CoarseGrainedSchedulerBackend` is <<stop, being stopped>>.

You should see the following INFO message in the logs:

```text
Shutting down all executors
```

## <span id="reset"> Reset State

`reset` resets the internal state:

1. Sets <<numPendingExecutors, numPendingExecutors>> to 0
2. Clears `executorsPendingToRemove`
3. Sends a blocking <<RemoveExecutor, RemoveExecutor>> message to <<driverEndpoint, driverEndpoint>> for every executor (in the internal `executorDataMap`) to inform it about `SlaveLost` with the message:
+
```
Stale executor after cluster manager re-registered.
```

`reset` is a method that is defined in `CoarseGrainedSchedulerBackend`, but used and overriden exclusively by yarn/spark-yarn-yarnschedulerbackend.md[YarnSchedulerBackend].

## <span id="removeExecutor"> Remove Executor

```scala
removeExecutor(executorId: String, reason: ExecutorLossReason)
```

`removeExecutor` sends a blocking <<RemoveExecutor, RemoveExecutor>> message to <<driverEndpoint, driverEndpoint>>.

NOTE: It is called by subclasses spark-standalone.md#SparkDeploySchedulerBackend[SparkDeploySchedulerBackend], spark-mesos/spark-mesos.md#CoarseMesosSchedulerBackend[CoarseMesosSchedulerBackend], and yarn/spark-yarn-yarnschedulerbackend.md[YarnSchedulerBackend].

## <span id="CoarseGrainedScheduler"> CoarseGrainedScheduler RPC Endpoint

When <<start, CoarseGrainedSchedulerBackend starts>>, it registers *CoarseGrainedScheduler* RPC endpoint to be the driver's communication endpoint.

`driverEndpoint` is a [DriverEndpoint](DriverEndpoint.md).

!!! note
    `CoarseGrainedSchedulerBackend` is created while [SparkContext is being created](../SparkContext.md#createTaskScheduler) that in turn lives inside a [Spark driver](../driver.md). That explains the name `driverEndpoint` (at least partially).

It is called *standalone scheduler's driver endpoint* internally.

It tracks:

It uses `driver-revive-thread` daemon single-thread thread pool for ...FIXME

CAUTION: FIXME A potential issue with `driverEndpoint.asInstanceOf[NettyRpcEndpointRef].toURI` - doubles `spark://` prefix.

## <span id="start"> Starting CoarseGrainedSchedulerBackend

```scala
start(): Unit
```

`start` is part of the [SchedulerBackend](SchedulerBackend.md#start) abstraction.

`start` takes all ``spark.``-prefixed properties and registers the <<driverEndpoint, `CoarseGrainedScheduler` RPC endpoint>> (backed by [DriverEndpoint ThreadSafeRpcEndpoint](DriverEndpoint.md)).

![CoarseGrainedScheduler Endpoint](../images/CoarseGrainedScheduler-rpc-endpoint.png)

NOTE: `start` uses <<scheduler, TaskSchedulerImpl>> to access the current SparkContext.md[SparkContext] and in turn SparkConf.md[SparkConf].

NOTE: `start` uses <<rpcEnv, RpcEnv>> that was given when <<creating-instance, `CoarseGrainedSchedulerBackend` was created>>.

## <span id="isReady"> Checking If Sufficient Compute Resources Available Or Waiting Time PassedMethod

```scala
isReady(): Boolean
```

`isReady` is part of the [SchedulerBackend](SchedulerBackend.md#isReady) abstraction.

`isReady` allows to delay task launching until <<sufficientResourcesRegistered, sufficient resources are available>> or <<spark.scheduler.maxRegisteredResourcesWaitingTime, spark.scheduler.maxRegisteredResourcesWaitingTime>> passes.

Internally, `isReady` <<sufficientResourcesRegistered, checks whether there are sufficient resources available>>.

NOTE: <<sufficientResourcesRegistered, sufficientResourcesRegistered>> by default responds that sufficient resources are available.

If the <<sufficientResourcesRegistered, resources are available>>, you should see the following INFO message in the logs and `isReady` is positive.

```text
SchedulerBackend is ready for scheduling beginning after reached minRegisteredResourcesRatio: [minRegisteredRatio]
```

If there are no sufficient resources available yet (the above requirement does not hold), `isReady` checks whether the time since <<createTime, startup>> passed <<spark.scheduler.maxRegisteredResourcesWaitingTime, spark.scheduler.maxRegisteredResourcesWaitingTime>> to give a way to launch tasks (even when <<minRegisteredRatio, minRegisteredRatio>> not being reached yet).

You should see the following INFO message in the logs and `isReady` is positive.

```text
SchedulerBackend is ready for scheduling beginning after waiting maxRegisteredResourcesWaitingTime: [maxRegisteredWaitingTimeMs](ms)
```

Otherwise, when <<sufficientResourcesRegistered, no sufficient resources are available>> and <<spark.scheduler.maxRegisteredResourcesWaitingTime, spark.scheduler.maxRegisteredResourcesWaitingTime>> has not elapsed, `isReady` is negative.

## <span id="reviveOffers"> Reviving Resource Offers

```scala
reviveOffers(): Unit
```

`reviveOffers` is part of the [SchedulerBackend](SchedulerBackend.md#reviveOffers) abstraction.

`reviveOffers` simply sends a [ReviveOffers](DriverEndpoint.md#ReviveOffers) message to [CoarseGrainedSchedulerBackend RPC endpoint](#driverEndpoint).

![CoarseGrainedExecutorBackend Revives Offers](../images/CoarseGrainedExecutorBackend-reviveOffers.png)

## <span id="stop"> Stopping SchedulerBackend

```scala
stop(): Unit
```

`stop` is part of the [SchedulerBackend](SchedulerBackend.md#stop) abstraction.

`stop` <<stopExecutors, stops all executors>> and <<driverEndpoint, `CoarseGrainedScheduler` RPC endpoint>> (by sending a blocking [StopDriver](DriverEndpoint.md#StopDriver) message).

In case of any `Exception`, `stop` reports a `SparkException` with the message:

```text
Error stopping standalone scheduler's driver endpoint
```

## <span id="createDriverEndpointRef"> createDriverEndpointRef

```scala
createDriverEndpointRef(
  properties: ArrayBuffer[(String, String)]): RpcEndpointRef
```

`createDriverEndpointRef` <<createDriverEndpoint, creates DriverEndpoint>> and rpc:index.md#setupEndpoint[registers it] as *CoarseGrainedScheduler*.

`createDriverEndpointRef` is used when `CoarseGrainedSchedulerBackend` is requested to <<start, start>>.

## <span id="isExecutorActive"> Checking Whether Executor is Active

```scala
isExecutorActive(
  id: String): Boolean
```

`isExecutorActive` is part of the [ExecutorAllocationClient](../dynamic-allocation/ExecutorAllocationClient.md#isExecutorActive) abstraction.

`isExecutorActive`...FIXME

## <span id="doRequestTotalExecutors"> Requesting Executors from Cluster Manager

```scala
doRequestTotalExecutors(
  requestedTotal: Int): Future[Boolean]
```

`doRequestTotalExecutors` returns a completed `Future` with `false` value.

`doRequestTotalExecutors` is used when:

* `CoarseGrainedSchedulerBackend` is requested to [requestExecutors](#requestExecutors), [requestTotalExecutors](#requestTotalExecutors) and [killExecutors](#killExecutors)

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.cluster.CoarseGrainedSchedulerBackend` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.cluster.CoarseGrainedSchedulerBackend=ALL
```

Refer to [Logging](../spark-logging.md).

## Internal Properties

[cols="1,1,2",options="header",width="100%"]
|===
| Name
| Initial Value
| Description

| [[currentExecutorIdCounter]] `currentExecutorIdCounter`
|
| The last (highest) identifier of all <<RegisterExecutor, allocated executors>>.

Used exclusively in yarn/spark-yarn-cluster-YarnSchedulerEndpoint.md#RetrieveLastAllocatedExecutorId[`YarnSchedulerEndpoint` to respond to `RetrieveLastAllocatedExecutorId` message].

| [[createTime]] `createTime`
| Current time
| The time <<creating-instance, `CoarseGrainedSchedulerBackend` was created>>.

| [[defaultAskTimeout]] `defaultAskTimeout`
| rpc:index.md#spark.rpc.askTimeout[spark.rpc.askTimeout] or rpc:index.md#spark.network.timeout[spark.network.timeout] or `120s`
| Default timeout for blocking RPC messages (_aka_ ask messages).

| [[driverEndpoint]] `driverEndpoint`
| (uninitialized)
a| rpc:RpcEndpointRef.md[RPC endpoint reference] to `CoarseGrainedScheduler` RPC endpoint (with [DriverEndpoint](DriverEndpoint.md) as the message handler).

Initialized when `CoarseGrainedSchedulerBackend` <<start, starts>>.

Used when `CoarseGrainedSchedulerBackend` executes the following (asynchronously, i.e. on a separate thread):

* <<killExecutorsOnHost, killExecutorsOnHost>>
* <<killTask, killTask>>
* <<removeExecutor, removeExecutor>>
* <<reviveOffers, reviveOffers>>
* <<stop, stop>>
* <<stopExecutors, stopExecutors>>

| [[executorsPendingToRemove]] `executorsPendingToRemove`
| empty
| Executors marked as removed but the confirmation from a cluster manager has not arrived yet.

| [[hostToLocalTaskCount]] `hostToLocalTaskCount`
| empty
| Registry of hostnames and possible number of task running on them.

| [[localityAwareTasks]] `localityAwareTasks`
| `0`
| Number of pending tasks...FIXME

| [[maxRegisteredWaitingTimeMs]] `maxRegisteredWaitingTimeMs`
| <<spark.scheduler.maxRegisteredResourcesWaitingTime, spark.scheduler.maxRegisteredResourcesWaitingTime>>
|

| [[numPendingExecutors]] `numPendingExecutors`
| `0`
|

| [[totalCoreCount]] `totalCoreCount`
| `0`
| Total number of CPU cores, i.e. the sum of all the cores on all executors.
|===
