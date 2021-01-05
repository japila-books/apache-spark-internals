# DriverEndpoint

`DriverEndpoint` is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) that is a [message handler](#messages) for [CoarseGrainedSchedulerBackend](CoarseGrainedSchedulerBackend.md) to communicate with [CoarseGrainedExecutorBackend](../executor/CoarseGrainedExecutorBackend.md).

![CoarseGrainedSchedulerBackend uses DriverEndpoint for communication with CoarseGrainedExecutorBackend](../images/CoarseGrainedSchedulerBackend-DriverEndpoint-CoarseGrainedExecutorBackend.png)

`DriverEndpoint` uses [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap) internal registry of all the [executors that registered with the driver](executor:CoarseGrainedExecutorBackend.md#onStart). An executor sends a [RegisterExecutor](#RegisterExecutor) message to inform that it wants to register.

![Executor registration (RegisterExecutor RPC message flow)](../images/CoarseGrainedSchedulerBackend-RegisterExecutor-event.png)

## Creating Instance

`DriverEndpoint` takes no arguments to be created.

`DriverEndpoint` is created when `CoarseGrainedSchedulerBackend` is requested for [one](CoarseGrainedSchedulerBackend.md#createDriverEndpoint).

## <span id="logUrlHandler"> ExecutorLogUrlHandler

```scala
logUrlHandler: ExecutorLogUrlHandler
```

`DriverEndpoint` creates an [ExecutorLogUrlHandler](../executor/ExecutorLogUrlHandler.md) (based on [spark.ui.custom.executor.log.url](../webui/configuration-properties.md#CUSTOM_EXECUTOR_LOG_URL) configuration property) when [created](#creating-instance).

`DriverEndpoint` uses the `ExecutorLogUrlHandler` to create an [ExecutorData](ExecutorData.md) when requested to handle a [RegisterExecutor](#RegisterExecutor) message.

## <span id="onStart"> Starting DriverEndpoint

```scala
onStart(): Unit
```

`onStart` is part of the [RpcEndpoint](../rpc/RpcEndpoint.md#onStart) abstraction.

`onStart` requests the [Revive Messages Scheduler Service](CoarseGrainedSchedulerBackend.md#reviveThread) to schedule a periodic action that sends [ReviveOffers](#ReviveOffers) messages every **revive interval** (based on [spark.scheduler.revive.interval](../configuration-properties.md#spark.scheduler.revive.interval) configuration property).

## Messages

### <span id="KillExecutorsOnHost"> KillExecutorsOnHost

`CoarseGrainedSchedulerBackend` is requested to [kill all executors on a node](CoarseGrainedSchedulerBackend.md#killExecutorsOnHost)

### <span id="KillTask"> KillTask

`CoarseGrainedSchedulerBackend` is requested to [kill a task](CoarseGrainedSchedulerBackend.md#killTask).

```scala
KillTask(
  taskId: Long,
  executor: String,
  interruptThread: Boolean)
```

`KillTask` is sent when `CoarseGrainedSchedulerBackend` [kills a task](CoarseGrainedSchedulerBackend.md#killTask).

When `KillTask` is received, `DriverEndpoint` finds `executor` (in [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap) registry).

If found, `DriverEndpoint` [passes the message on to the executor](../executor/CoarseGrainedExecutorBackend.md#KillTask) (using its registered RPC endpoint for `CoarseGrainedExecutorBackend`).

Otherwise, you should see the following WARN in the logs:

```text
Attempted to kill task [taskId] for unknown executor [executor].
```

### <span id="LaunchedExecutor"> LaunchedExecutor

### <span id="RegisterExecutor"> RegisterExecutor

`CoarseGrainedExecutorBackend` [registers with the driver](../executor/CoarseGrainedExecutorBackend.md#onStart)

```scala
RegisterExecutor(
  executorId: String,
  executorRef: RpcEndpointRef,
  hostname: String,
  cores: Int,
  logUrls: Map[String, String])
```

`RegisterExecutor` is sent when `CoarseGrainedExecutorBackend` RPC Endpoint is requested to [start](../executor/CoarseGrainedExecutorBackend.md#onStart).

![Executor registration (RegisterExecutor RPC message flow)](../images/CoarseGrainedSchedulerBackend-RegisterExecutor-event.png)

When received, `DriverEndpoint` makes sure that no other [executors were registered](CoarseGrainedSchedulerBackend.md#executorDataMap) under the input `executorId` and that the input `hostname` is not [blacklisted](TaskSchedulerImpl.md#nodeBlacklist).

If the requirements hold, you should see the following INFO message in the logs:

```text
Registered executor [executorRef] ([address]) with ID [executorId]
```

`DriverEndpoint` does the bookkeeping:

* Registers `executorId` (in [addressToExecutorId](#addressToExecutorId))
* Adds `cores` (in [totalCoreCount](CoarseGrainedSchedulerBackend.md#totalCoreCount))
* Increments [totalRegisteredExecutors](CoarseGrainedSchedulerBackend.md#totalRegisteredExecutors)
* Creates and registers `ExecutorData` for `executorId` (in [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap))
* Updates [currentExecutorIdCounter](CoarseGrainedSchedulerBackend.md#currentExecutorIdCounter) if the input `executorId` is greater than the current value.

If [numPendingExecutors](CoarseGrainedSchedulerBackend.md#numPendingExecutors) is greater than `0`, you should see the following DEBUG message in the logs and DriverEndpoint decrements `numPendingExecutors`.

```text
Decremented number of pending executors ([numPendingExecutors] left)
```

`DriverEndpoint` sends [RegisteredExecutor](../executor/CoarseGrainedExecutorBackend.md#RegisteredExecutor) message back (that is to confirm that the executor was registered successfully).

`DriverEndpoint` replies `true` (to acknowledge the message).

`DriverEndpoint` then announces the new executor by posting [SparkListenerExecutorAdded](../SparkListener.md#SparkListenerExecutorAdded) to [LiveListenerBus](LiveListenerBus.md).

In the end, `DriverEndpoint` [makes executor resource offers (for launching tasks)](#makeOffers).

If however there was already another executor registered under the input `executorId`, `DriverEndpoint` sends [RegisterExecutorFailed](../executor/CoarseGrainedExecutorBackend.md#RegisterExecutorFailed) message back with the reason:

```text
Duplicate executor ID: [executorId]
```

If however the input `hostname` is [blacklisted](TaskSchedulerImpl.md#nodeBlacklist), you should see the following INFO message in the logs:

```text
Rejecting [executorId] as it has been blacklisted.
```

`DriverEndpoint` sends [RegisterExecutorFailed](../executor/CoarseGrainedExecutorBackend.md#RegisterExecutorFailed) message back with the reason:

```text
Executor is blacklisted: [executorId]
```

### <span id="RemoveExecutor"> RemoveExecutor

### <span id="RemoveWorker"> RemoveWorker

### <span id="RetrieveSparkAppConfig"> RetrieveSparkAppConfig

```scala
RetrieveSparkAppConfig(
  resourceProfileId: Int)
```

Posted when:

* `CoarseGrainedExecutorBackend` standalone application is [started](../executor/CoarseGrainedExecutorBackend.md#run)

When [received](#receiveAndReply), `DriverEndpoint` replies with a `SparkAppConfig` message with the following:

1. `spark`-prefixed configuration properties
1. IO Encryption Key
1. Delegation tokens
1. [Default profile](../stage-level-scheduling/ResourceProfile.md#getOrCreateDefaultProfile)

### <span id="ReviveOffers"> ReviveOffers

Posted when:

* Periodically (every [spark.scheduler.revive.interval](../configuration-properties.md#spark.scheduler.revive.interval)) right after `DriverEndpoint` is requested to [start](#onStart)
* `CoarseGrainedSchedulerBackend` is requested to [revive resource offers](CoarseGrainedSchedulerBackend.md#reviveOffers)

When [received](#receive), `DriverEndpoint` [makes executor resource offers](#makeOffers).

### <span id="StatusUpdate"> StatusUpdate

`CoarseGrainedExecutorBackend` [sends task status updates to the driver](../executor/CoarseGrainedExecutorBackend.md#statusUpdate)

```scala
StatusUpdate(
  executorId: String,
  taskId: Long,
  state: TaskState,
  data: SerializableBuffer)
```

`StatusUpdate` is sent when `CoarseGrainedExecutorBackend` [sends task status updates to the driver](../executor/CoarseGrainedExecutorBackend.md#statusUpdate).

When `StatusUpdate` is received, DriverEndpoint requests the [TaskSchedulerImpl](CoarseGrainedSchedulerBackend.md#scheduler) to [handle the task status update](TaskSchedulerImpl.md#statusUpdate).

If the [task has finished](Task.md#TaskState), `DriverEndpoint` updates the number of cores available for work on the corresponding executor (registered in [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap)).

DriverEndpoint [makes an executor resource offer on the single executor](#makeOffers).

When `DriverEndpoint` found no executor (in [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap)), you should see the following WARN message in the logs:

```text
Ignored task status update ([taskId] state [state]) from unknown executor with ID [executorId]
```

### <span id="StopDriver"> StopDriver

### <span id="StopExecutors"> StopExecutors

`StopExecutors` message is receive-reply and blocking. When received, the following INFO message appears in the logs:

```text
Asking each executor to shut down
```

It then sends a [StopExecutor](../executor/CoarseGrainedExecutorBackend.md#StopExecutor) message to every registered executor (from `executorDataMap`).

### <span id="UpdateDelegationTokens"> UpdateDelegationTokens

## <span id="makeOffers"> Making Executor Resource Offers (for Launching Tasks)

```scala
makeOffers(): Unit
```

`makeOffers` creates `WorkerOffer`s for all [active executors](CoarseGrainedSchedulerBackend.md#isExecutorActive).

`makeOffers` requests [TaskSchedulerImpl](CoarseGrainedSchedulerBackend.md#scheduler) to [generate tasks for the available worker offers](TaskSchedulerImpl.md#resourceOffers).

When there are tasks to be launched (from `TaskSchedulerImpl`) `makeOffers` [does so](#launchTasks).

`makeOffers` is used when `DriverEndpoint` handles [ReviveOffers](#ReviveOffers) or [RegisterExecutor](#RegisterExecutor) messages.

## <span id="makeOffers-executorId"> Making Executor Resource Offer on Single Executor (for Launching Tasks)

```scala
makeOffers(
  executorId: String): Unit
```

`makeOffers` makes sure that the [input `executorId` is alive](#executorIsAlive).

NOTE: `makeOffers` does nothing when the input `executorId` is registered as pending to be removed or got lost.

`makeOffers` finds the executor data (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] registry) and creates a scheduler:TaskSchedulerImpl.md#WorkerOffer[WorkerOffer].

NOTE: `WorkerOffer` represents a resource offer with CPU cores available on an executor.

`makeOffers` then scheduler:TaskSchedulerImpl.md#resourceOffers[requests `TaskSchedulerImpl` to generate tasks for the `WorkerOffer`] followed by [launching the tasks](#launchTasks) (on the executor).

`makeOffers` is used when `CoarseGrainedSchedulerBackend` RPC endpoint (DriverEndpoint) handles a [StatusUpdate](#StatusUpdate) message.

## <span id="launchTasks"> Launching Tasks

```scala
launchTasks(
  tasks: Seq[Seq[TaskDescription]]): Unit
```

!!! note
    The input `tasks` collection contains one or more [TaskDescription](TaskDescription.md)s per executor (and the "task partitioning" per executor is of no use in `launchTasks` so it simply flattens the input data structure).

For every [TaskDescription](TaskDescription.md) (in the given `tasks` collection), `launchTasks` [encodes it](TaskDescription.md#encode) and makes sure that the encoded task size is below the [allowed message size](CoarseGrainedSchedulerBackend.md#maxRpcMessageSize).

`launchTasks` looks up the `ExecutorData` of the executor that has been assigned to execute the task (in [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap) internal registry) and decreases the executor's free cores (based on [spark.task.cpus](../configuration-properties.md#spark.task.cpus) configuration property).

!!! note
    Scheduling in Spark relies on cores only (not memory), i.e. the number of tasks Spark can run on an executor is limited by the number of cores available only. When submitting a Spark application for execution both executor resources -- memory and cores -- can however be specified explicitly. It is the job of a cluster manager to monitor the memory and take action when its use exceeds what was assigned.

`launchTasks` prints out the following DEBUG message to the logs:

```text
Launching task [taskId] on executor id: [executorId] hostname: [executorHost].
```

In the end, `launchTasks` sends the (serialized) task to the executor (by sending a [LaunchTask](../executor/CoarseGrainedExecutorBackend.md#LaunchTask) message to the executor's RPC endpoint with the serialized task insize `SerializableBuffer`).

!!! note
    This is the moment in a task's lifecycle when the driver sends the serialized task to an assigned executor.

`launchTasks` is used when `CoarseGrainedSchedulerBackend` is requested to make resource offers on [single](#makeOffers-executorId) or [all](#makeOffers) executors.

### <span id="launchTasks-exceeds-max-allowed"> Task Exceeds Allowed Size

In case the size of a serialized `TaskDescription` equals or exceeds the [maximum allowed RPC message size](CoarseGrainedSchedulerBackend.md#maxRpcMessageSize), `launchTasks` looks up the [TaskSetManager](TaskSetManager.md) for the `TaskDescription` (in [taskIdToTaskSetManager](TaskSchedulerImpl.md#taskIdToTaskSetManager) registry) and [aborts it](TaskSetManager.md#abort) with the following message:

```text
Serialized task [id]:[index] was [limit] bytes, which exceeds max allowed: spark.rpc.message.maxSize ([maxRpcMessageSize] bytes). Consider increasing spark.rpc.message.maxSize or using broadcast variables for large values.
```

## <span id="removeExecutor"> Removing Executor

```scala
removeExecutor(
  executorId: String,
  reason: ExecutorLossReason): Unit
```

When `removeExecutor` is executed, you should see the following DEBUG message in the logs:

```text
Asked to remove executor [executorId] with reason [reason]
```

`removeExecutor` then tries to find the `executorId` executor (in [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap) internal registry).

If the `executorId` executor was found, `removeExecutor` removes the executor from the following registries:

* [addressToExecutorId](#addressToExecutorId)
* [executorDataMap](CoarseGrainedSchedulerBackend.md#executorDataMap)
* <<executorsPendingLossReason, executorsPendingLossReason>>
* [executorsPendingToRemove](CoarseGrainedSchedulerBackend.md#executorsPendingToRemove)

`removeExecutor` decrements:

* [totalCoreCount](CoarseGrainedSchedulerBackend.md#totalCoreCount) by the executor's `totalCores`
* [totalRegisteredExecutors](CoarseGrainedSchedulerBackend.md#totalRegisteredExecutors)

In the end, `removeExecutor` notifies `TaskSchedulerImpl` that an [executor was lost](TaskSchedulerImpl.md#executorLost).

`removeExecutor` posts [SparkListenerExecutorRemoved](../SparkListener.md#SparkListenerExecutorRemoved) to [LiveListenerBus](LiveListenerBus.md) (with the `executorId` executor).

If however the `executorId` executor could not be found, `removeExecutor` [requests `BlockManagerMaster` to remove the executor asynchronously](../storage/BlockManagerMaster.md#removeExecutorAsync).

!!! note
    `removeExecutor` uses `SparkEnv` [to access the current `BlockManager`](../SparkEnv.md#blockManager) and then [BlockManagerMaster](../storage/BlockManager.md#master).

You should see the following INFO message in the logs:

```text
Asked to remove non-existent executor [executorId]
```

`removeExecutor` is used when `DriverEndpoint` handles [RemoveExecutor](#RemoveExecutor) message and [gets disassociated with a remote RPC endpoint of an executor](#onDisconnected).

## <span id="removeWorker"> Removing Worker

```scala
removeWorker(
  workerId: String,
  host: String,
  message: String): Unit
```

`removeWorker` prints out the following DEBUG message to the logs:

```text
Asked to remove worker [workerId] with reason [message]
```

In the end, `removeWorker` simply requests the [TaskSchedulerImpl](CoarseGrainedSchedulerBackend.md#scheduler) to [workerRemoved](TaskSchedulerImpl.md#workerRemoved).

`removeWorker` is used when `DriverEndpoint` is requested to handle a [RemoveWorker](#RemoveWorker) event.

## <span id="receive"> Processing One-Way Messages

```scala
receive: PartialFunction[Any, Unit]
```

`receive` is part of the [RpcEndpoint](../rpc/RpcEndpoint.md#receive) abstraction.

`receive`...FIXME

## <span id="receiveAndReply"> Processing Two-Way Messages

```scala
receiveAndReply(
  context: RpcCallContext): PartialFunction[Any, Unit]
```

`receiveAndReply` is part of the [RpcEndpoint](../rpc/RpcEndpoint.md#receiveAndReply) abstraction.

`receiveAndReply`...FIXME

## <span id="onDisconnected"> onDisconnected Callback

`onDisconnected` removes the worker from the internal [addressToExecutorId](#addressToExecutorId) registry (that effectively removes the worker from a cluster).

`onDisconnected` [removes the executor](#removeExecutor) with the reason being `SlaveLost` and message:

```text
Remote RPC client disassociated. Likely due to containers exceeding thresholds, or network issues. Check driver logs for WARN messages.
```

## <span id="addressToExecutorId"> Executors by RpcAddress Registry

```scala
addressToExecutorId: Map[RpcAddress, String]
```

Executor addresses (host and port) for executors.

Set when an executor connects to register itself.

## <span id="disableExecutor"> Disabling Executor

```scala
disableExecutor(
  executorId: String): Boolean
```

`disableExecutor` [checks whether the executor is active](#isExecutorActive):

* If so, `disableExecutor` adds the executor to the [executorsPendingLossReason](CoarseGrainedSchedulerBackend.md#executorsPendingLossReason) registry
* Otherwise, `disableExecutor` checks whether added to [executorsPendingToRemove](CoarseGrainedSchedulerBackend.md#executorsPendingToRemove) registry

`disableExecutor` determines whether the executor should really be disabled (as active or registered in [executorsPendingToRemove](CoarseGrainedSchedulerBackend.md#executorsPendingToRemove) registry).

If the executor should be disabled, `disableExecutor` prints out the following INFO message to the logs and notifies the [TaskSchedulerImpl](CoarseGrainedSchedulerBackend.md#scheduler) that the [executor is lost](TaskSchedulerImpl.md#executorLost).

```text
Disabling executor [executorId].
```

`disableExecutor` returns the indication whether the executor should have been disabled or not.

`disableExecutor` is used when:

* `KubernetesDriverEndpoint` is requested to handle `onDisconnected` event
* `YarnDriverEndpoint` is requested to handle `onDisconnected` event

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.cluster.CoarseGrainedSchedulerBackend.DriverEndpoint` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.scheduler.cluster.CoarseGrainedSchedulerBackend.DriverEndpoint=ALL
```

Refer to [Logging](../spark-logging.md).