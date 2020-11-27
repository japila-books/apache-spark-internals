# DriverEndpoint &mdash; CoarseGrainedSchedulerBackend RPC Endpoint

DriverEndpoint is a rpc:RpcEndpoint.md#ThreadSafeRpcEndpoint[ThreadSafeRpcEndpoint] that acts as a <<messages, message handler>> for scheduler:CoarseGrainedSchedulerBackend.md[CoarseGrainedSchedulerBackend] to communicate with executor:CoarseGrainedExecutorBackend.md[].

![CoarseGrainedSchedulerBackend uses DriverEndpoint for communication with CoarseGrainedExecutorBackend](../images/CoarseGrainedSchedulerBackend-DriverEndpoint-CoarseGrainedExecutorBackend.png)

DriverEndpoint <<creating-instance, is created>> when `CoarseGrainedSchedulerBackend` scheduler:CoarseGrainedSchedulerBackend.md#starts[starts].

DriverEndpoint uses scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] internal registry of all the executor:CoarseGrainedExecutorBackend.md#onStart[executors that registered with the driver]. An executor sends a <<RegisterExecutor, RegisterExecutor>> message to inform that it wants to register.

![Executor registration (RegisterExecutor RPC message flow)](../images/CoarseGrainedSchedulerBackend-RegisterExecutor-event.png)

DriverEndpoint uses a <<reviveThread, single thread executor>> called *driver-revive-thread* to <<makeOffers, make executor resource offers (for launching tasks)>> (by emitting <<ReviveOffers, ReviveOffers>> message every scheduler:CoarseGrainedSchedulerBackend.md#spark.scheduler.revive.interval[spark.scheduler.revive.interval]).

[[messages]]
.CoarseGrainedClusterMessages and Their Handlers (in alphabetical order)
[width="100%",cols="1,1,2",options="header"]
|===
| CoarseGrainedClusterMessage
| Event Handler
| When emitted?

| [[KillExecutorsOnHost]] KillExecutorsOnHost
| <<KillExecutorsOnHost-handler, KillExecutorsOnHost handler>>
| `CoarseGrainedSchedulerBackend` is requested to scheduler:CoarseGrainedSchedulerBackend.md#killExecutorsOnHost[kill all executors on a node].

| [[KillTask]] KillTask
| <<KillTask-handler, KillTask handler>>
| `CoarseGrainedSchedulerBackend` is requested to scheduler:CoarseGrainedSchedulerBackend.md#killTask[kill a task].

| [[ReviveOffers]] ReviveOffers
| <<makeOffers, makeOffers>>
a|

* Periodically (every scheduler:CoarseGrainedSchedulerBackend.md#spark.scheduler.revive.interval[spark.scheduler.revive.interval]) soon after DriverEndpoint <<onStart, starts accepting messages>>.
* `CoarseGrainedSchedulerBackend` is requested to scheduler:CoarseGrainedSchedulerBackend.md#reviveOffers[revive resource offers].

| [[RegisterExecutor]] RegisterExecutor
| <<RegisterExecutor-handler, RegisterExecutor handler>>
| `CoarseGrainedExecutorBackend` executor:CoarseGrainedExecutorBackend.md#onStart[registers with the driver].

| [[StatusUpdate]] StatusUpdate
| <<StatusUpdate-handler, StatusUpdate handler>>
| `CoarseGrainedExecutorBackend` executor:CoarseGrainedExecutorBackend.md#statusUpdate[sends task status updates to the driver].
|===

[[internal-properties]]
.DriverEndpoint's Internal Properties
[cols="1,1,2",options="header",width="100%"]
|===
| Name
| Initial Value
| Description

| [[addressToExecutorId]] `addressToExecutorId`
|
| Executor addresses (host and port) for executors.

Set when an executor connects to register itself. See <<RegisterExecutor, RegisterExecutor>> RPC message.

| [[executorsPendingLossReason]] `executorsPendingLossReason`
|
|

| [[reviveThread]] `reviveThread`
|
|
|===

== [[disableExecutor]] `disableExecutor` Internal Method

CAUTION: FIXME

== [[KillExecutorsOnHost-handler]] KillExecutorsOnHost Handler

CAUTION: FIXME

== [[executorIsAlive]] `executorIsAlive` Internal Method

CAUTION: FIXME

== [[onStop]] `onStop` Callback

CAUTION: FIXME

== [[onDisconnected]] `onDisconnected` Callback

When called, `onDisconnected` removes the worker from the internal <<addressToExecutorId, addressToExecutorId registry>> (that effectively removes the worker from a cluster).

While removing, it calls <<removeExecutor, removeExecutor>> with the reason being `SlaveLost` and message:

[options="wrap"]
----
Remote RPC client disassociated. Likely due to containers exceeding thresholds, or network issues. Check driver logs for WARN messages.
----

NOTE: `onDisconnected` is called when a remote host is lost.

== [[RemoveExecutor]] RemoveExecutor

== [[RetrieveSparkProps]] RetrieveSparkProps

== [[StopDriver]] StopDriver

`StopDriver` message stops the RPC endpoint.

== [[StopExecutors]] StopExecutors

`StopExecutors` message is receive-reply and blocking. When received, the following INFO message appears in the logs:

```
INFO Asking each executor to shut down
```

It then sends a executor:CoarseGrainedExecutorBackend.md#StopExecutor[StopExecutor] message to every registered executor (from `executorDataMap`).

== [[onStart]] Scheduling Sending ReviveOffers Periodically -- `onStart` Callback

[source, scala]
----
onStart(): Unit
----

NOTE: `onStart` is part of rpc:RpcEndpoint.md#onStart[RpcEndpoint contract] that is executed before a RPC endpoint starts accepting messages.

`onStart` schedules a periodic action to send <<ReviveOffers, ReviveOffers>> immediately every scheduler:CoarseGrainedSchedulerBackend.md#spark.scheduler.revive.interval[spark.scheduler.revive.interval].

NOTE: scheduler:CoarseGrainedSchedulerBackend.md#spark.scheduler.revive.interval[spark.scheduler.revive.interval] defaults to `1s`.

== [[makeOffers]] Making Executor Resource Offers (for Launching Tasks) -- `makeOffers` Internal Method

[source, scala]
----
makeOffers(): Unit
----

`makeOffers` first creates `WorkerOffers` for all <<executorIsAlive, active executors>> (registered in the internal scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] cache).

NOTE: `WorkerOffer` represents a resource offer with CPU cores available on an executor.

`makeOffers` then scheduler:TaskSchedulerImpl.md#resourceOffers[requests `TaskSchedulerImpl` to generate tasks for the available `WorkerOffers`] followed by <<launchTasks, launching the tasks on respective executors>>.

NOTE: `makeOffers` uses scheduler:CoarseGrainedSchedulerBackend.md#scheduler[TaskSchedulerImpl] that was given when scheduler:CoarseGrainedSchedulerBackend.md#creating-instance[`CoarseGrainedSchedulerBackend` was created].

NOTE: Tasks are described using spark-scheduler-TaskDescription.md[TaskDescription] that holds...FIXME

NOTE: `makeOffers` is used when `CoarseGrainedSchedulerBackend` RPC endpoint (DriverEndpoint) handles <<ReviveOffers, ReviveOffers>> or <<RegisterExecutor, RegisterExecutor>> messages.

== [[makeOffers-executorId]] Making Executor Resource Offer on Single Executor (for Launching Tasks) -- `makeOffers` Internal Method

[source, scala]
----
makeOffers(executorId: String): Unit
----

`makeOffers` makes sure that the <<executorIsAlive, input `executorId` is alive>>.

NOTE: `makeOffers` does nothing when the input `executorId` is registered as pending to be removed or got lost.

`makeOffers` finds the executor data (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] registry) and creates a scheduler:TaskSchedulerImpl.md#WorkerOffer[WorkerOffer].

NOTE: `WorkerOffer` represents a resource offer with CPU cores available on an executor.

`makeOffers` then scheduler:TaskSchedulerImpl.md#resourceOffers[requests `TaskSchedulerImpl` to generate tasks for the `WorkerOffer`] followed by <<launchTasks, launching the tasks>> (on the executor).

NOTE: `makeOffers` is used when `CoarseGrainedSchedulerBackend` RPC endpoint (DriverEndpoint) handles <<StatusUpdate, StatusUpdate>> messages.

== [[launchTasks]] Launching Tasks on Executors -- `launchTasks` Internal Method

[source, scala]
----
launchTasks(tasks: Seq[Seq[TaskDescription]]): Unit
----

`launchTasks` flattens (and hence "destroys" the structure of) the input `tasks` collection and takes one task at a time. Tasks are described using spark-scheduler-TaskDescription.md[TaskDescription].

NOTE: The input `tasks` collection contains one or more spark-scheduler-TaskDescription.md[TaskDescriptions] per executor (and the "task partitioning" per executor is of no use in `launchTasks` so it simply flattens the input data structure).

`launchTasks` spark-scheduler-TaskDescription.md#encode[encodes the `TaskDescription`] and makes sure that the encoded task's size is below the scheduler:CoarseGrainedSchedulerBackend.md#maxRpcMessageSize[maximum RPC message size].

NOTE: The scheduler:CoarseGrainedSchedulerBackend.md#maxRpcMessageSize[maximum RPC message size] is calculated when `CoarseGrainedSchedulerBackend` scheduler:CoarseGrainedSchedulerBackend.md#creating-instance[is created] and corresponds to scheduler:CoarseGrainedSchedulerBackend.md#spark.rpc.message.maxSize[spark.rpc.message.maxSize] Spark property (with maximum of `2047` MB).

If the size of the encoded task is acceptable, `launchTasks` finds the `ExecutorData` of the executor that has been assigned to execute the task (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] internal registry) and decreases the executor's configuration-properties.md#spark.task.cpus[available number of cores].

NOTE: `ExecutorData` tracks the number of free cores of an executor (as `freeCores`).

NOTE: The default task scheduler in Spark -- scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl] -- uses configuration-properties.md#spark.task.cpus[spark.task.cpus] Spark property to control the number of tasks that can be scheduled per executor.

You should see the following DEBUG message in the logs:

```
DEBUG DriverEndpoint: Launching task [taskId] on executor id: [executorId] hostname: [executorHost].
```

In the end, `launchTasks` sends the (serialized) task to associated executor to launch the task (by sending a executor:CoarseGrainedExecutorBackend.md#LaunchTask[LaunchTask] message to the executor's RPC endpoint with the serialized task insize `SerializableBuffer`).

NOTE: `ExecutorData` tracks the rpc:RpcEndpointRef.md[RpcEndpointRef] of executors to send serialized tasks to (as `executorEndpoint`).

IMPORTANT: This is the moment in a task's lifecycle when the driver sends the serialized task to an assigned executor.

In case the size of a serialized `TaskDescription` equals or exceeds the scheduler:CoarseGrainedSchedulerBackend.md#maxRpcMessageSize[maximum RPC message size], `launchTasks` finds the scheduler:TaskSetManager.md[TaskSetManager] (associated with the `TaskDescription`) and scheduler:TaskSetManager.md#abort[aborts it] with the following message:

[options="wrap"]
----
Serialized task [id]:[index] was [limit] bytes, which exceeds max allowed: spark.rpc.message.maxSize ([maxRpcMessageSize] bytes). Consider increasing spark.rpc.message.maxSize or using broadcast variables for large values.
----

NOTE: `launchTasks` uses the scheduler:TaskSchedulerImpl.md#taskIdToTaskSetManager[registry of active `TaskSetManagers` per task id] from <<scheduler, TaskSchedulerImpl>> that was given when <<creating-instance, `CoarseGrainedSchedulerBackend` was created>>.

NOTE: Scheduling in Spark relies on cores only (not memory), i.e. the number of tasks Spark can run on an executor is limited by the number of cores available only. When submitting a Spark application for execution both executor resources -- memory and cores -- can however be specified explicitly. It is the job of a cluster manager to monitor the memory and take action when its use exceeds what was assigned.

NOTE: `launchTasks` is used when `CoarseGrainedSchedulerBackend` is requested to make resource offers on <<makeOffers-executorId, single>> or <<makeOffers, all>> executors.

== [[creating-instance]] Creating DriverEndpoint Instance

DriverEndpoint takes the following when created:

* [[rpcEnv]] rpc:index.md[RpcEnv]
* [[sparkProperties]] Collection of Spark properties and their values

DriverEndpoint initializes the <<internal-registries, internal registries and counters>>.

== [[RegisterExecutor-handler]] RegisterExecutor Handler

[source, scala]
----
RegisterExecutor(
  executorId: String,
  executorRef: RpcEndpointRef,
  hostname: String,
  cores: Int,
  logUrls: Map[String, String])
extends CoarseGrainedClusterMessage
----

NOTE: `RegisterExecutor` is sent when executor:CoarseGrainedExecutorBackend.md#onStart[`CoarseGrainedExecutorBackend` (RPC Endpoint) is started].

.Executor registration (RegisterExecutor RPC message flow)
image::CoarseGrainedSchedulerBackend-RegisterExecutor-event.png[align="center"]

When received, DriverEndpoint makes sure that no other scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executors were registered] under the input `executorId` and that the input `hostname` is not scheduler:TaskSchedulerImpl.md#nodeBlacklist[blacklisted].

NOTE: DriverEndpoint uses <<scheduler, TaskSchedulerImpl>> (for the list of blacklisted nodes) that was specified when `CoarseGrainedSchedulerBackend` scheduler:CoarseGrainedSchedulerBackend.md#creating-instance[was created].

If the requirements hold, you should see the following INFO message in the logs:

```
INFO Registered executor [executorRef] ([address]) with ID [executorId]
```

DriverEndpoint does the bookkeeping:

* Registers `executorId` (in <<addressToExecutorId, addressToExecutorId>>)
* Adds `cores` (in scheduler:CoarseGrainedSchedulerBackend.md#totalCoreCount[totalCoreCount])
* Increments scheduler:CoarseGrainedSchedulerBackend.md#totalRegisteredExecutors[totalRegisteredExecutors]
* Creates and registers `ExecutorData` for `executorId` (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap])
* Updates scheduler:CoarseGrainedSchedulerBackend.md#currentExecutorIdCounter[currentExecutorIdCounter] if the input `executorId` is greater than the current value.

If scheduler:CoarseGrainedSchedulerBackend.md#numPendingExecutors[numPendingExecutors] is greater than `0`, you should see the following DEBUG message in the logs and DriverEndpoint decrements `numPendingExecutors`.

```
DEBUG Decremented number of pending executors ([numPendingExecutors] left)
```

DriverEndpoint sends executor:CoarseGrainedExecutorBackend.md#RegisteredExecutor[RegisteredExecutor] message back (that is to confirm that the executor was registered successfully).

NOTE: DriverEndpoint uses the input `executorRef` as the executor's rpc:RpcEndpointRef.md[RpcEndpointRef].

DriverEndpoint replies `true` (to acknowledge the message).

DriverEndpoint then announces the new executor by posting SparkListener.md#SparkListenerExecutorAdded[SparkListenerExecutorAdded] to scheduler:LiveListenerBus.md[] (with the current time, executor id, and `ExecutorData`).

In the end, DriverEndpoint <<makeOffers, makes executor resource offers (for launching tasks)>>.

If however there was already another executor registered under the input `executorId`, DriverEndpoint sends executor:CoarseGrainedExecutorBackend.md#RegisterExecutorFailed[RegisterExecutorFailed] message back with the reason:

```
Duplicate executor ID: [executorId]
```

If however the input `hostname` is scheduler:TaskSchedulerImpl.md#nodeBlacklist[blacklisted], you should see the following INFO message in the logs:

```
INFO Rejecting [executorId] as it has been blacklisted.
```

DriverEndpoint sends executor:CoarseGrainedExecutorBackend.md#RegisterExecutorFailed[RegisterExecutorFailed] message back with the reason:

```
Executor is blacklisted: [executorId]
```

== [[StatusUpdate-handler]] StatusUpdate Handler

[source, scala]
----
StatusUpdate(
  executorId: String,
  taskId: Long,
  state: TaskState,
  data: SerializableBuffer)
extends CoarseGrainedClusterMessage
----

NOTE: `StatusUpdate` is sent when `CoarseGrainedExecutorBackend` executor:CoarseGrainedExecutorBackend.md#statusUpdate[sends task status updates to the driver].

When `StatusUpdate` is received, DriverEndpoint requests the scheduler:CoarseGrainedSchedulerBackend.md#scheduler[TaskSchedulerImpl] to scheduler:TaskSchedulerImpl.md#statusUpdate[handle the task status update].

If the scheduler:Task.md#TaskState[task has finished], DriverEndpoint updates the number of cores available for work on the corresponding executor (registered in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap]).

NOTE: DriverEndpoint uses ``TaskSchedulerImpl``'s configuration-properties.md#spark.task.cpus[spark.task.cpus] as the number of cores that became available after the task has finished.

DriverEndpoint <<makeOffers, makes an executor resource offer on the single executor>>.

When DriverEndpoint found no executor (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap]), you should see the following WARN message in the logs:

```
WARN Ignored task status update ([taskId] state [state]) from unknown executor with ID [executorId]
```

== [[KillTask-handler]] KillTask Handler

[source, scala]
----
KillTask(
  taskId: Long,
  executor: String,
  interruptThread: Boolean)
extends CoarseGrainedClusterMessage
----

NOTE: `KillTask` is sent when `CoarseGrainedSchedulerBackend` scheduler:CoarseGrainedSchedulerBackend.md#killTask[kills a task].

When `KillTask` is received, DriverEndpoint finds `executor` (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] registry).

If found, DriverEndpoint executor:CoarseGrainedExecutorBackend.md#KillTask[passes the message on to the executor] (using its registered RPC endpoint for `CoarseGrainedExecutorBackend`).

Otherwise, you should see the following WARN in the logs:

```
WARN Attempted to kill task [taskId] for unknown executor [executor].
```

== [[removeExecutor]] Removing Executor from Internal Registries (and Notifying TaskSchedulerImpl and Posting SparkListenerExecutorRemoved) -- `removeExecutor` Internal Method

[source, scala]
----
removeExecutor(executorId: String, reason: ExecutorLossReason): Unit
----

When `removeExecutor` is executed, you should see the following DEBUG message in the logs:

```
DEBUG Asked to remove executor [executorId] with reason [reason]
```

`removeExecutor` then tries to find the `executorId` executor (in scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap] internal registry).

If the `executorId` executor was found, `removeExecutor` removes the executor from the following registries:

* <<addressToExecutorId, addressToExecutorId>>
* scheduler:CoarseGrainedSchedulerBackend.md#executorDataMap[executorDataMap]
* <<executorsPendingLossReason, executorsPendingLossReason>>
* scheduler:CoarseGrainedSchedulerBackend.md#executorsPendingToRemove[executorsPendingToRemove]

`removeExecutor` decrements:

* scheduler:CoarseGrainedSchedulerBackend.md#totalCoreCount[totalCoreCount] by the executor's `totalCores`
* scheduler:CoarseGrainedSchedulerBackend.md#totalRegisteredExecutors[totalRegisteredExecutors]

In the end, `removeExecutor` notifies `TaskSchedulerImpl` that an scheduler:TaskSchedulerImpl.md#executorLost[executor was lost].

NOTE: `removeExecutor` uses scheduler:CoarseGrainedSchedulerBackend.md#scheduler[TaskSchedulerImpl] that is specified when `CoarseGrainedSchedulerBackend` scheduler:CoarseGrainedSchedulerBackend.md#creating-instance[is created].

`removeExecutor` posts SparkListener.md#SparkListenerExecutorRemoved[SparkListenerExecutorRemoved] to scheduler:LiveListenerBus.md[] (with the `executorId` executor).

If however the `executorId` executor could not be found, `removeExecutor` storage:BlockManagerMaster.md#removeExecutorAsync[requests `BlockManagerMaster` to remove the executor asynchronously].

NOTE: `removeExecutor` uses `SparkEnv` core:SparkEnv.md#blockManager[to access the current `BlockManager`] and then storage:BlockManager.md#master[BlockManagerMaster].

You should see the following INFO message in the logs:

```
INFO Asked to remove non-existent executor [executorId]
```

NOTE: `removeExecutor` is used when DriverEndpoint <<RemoveExecutor, handles `RemoveExecutor` message>> and <<onDisconnected, gets disassociated with a remote RPC endpoint of an executor>>.

== [[removeWorker]] `removeWorker` Internal Method

[source, scala]
----
removeWorker(
  workerId: String,
  host: String,
  message: String): Unit
----

`removeWorker` prints out the following DEBUG message to the logs:

```
Asked to remove worker [workerId] with reason [message]
```

In the end, `removeWorker` simply requests the scheduler:CoarseGrainedSchedulerBackend.md#scheduler[TaskSchedulerImpl] to scheduler:TaskSchedulerImpl.md#workerRemoved[workerRemoved].

NOTE: `removeWorker` is used exclusively when DriverEndpoint is requested to handle a <<RemoveWorker, RemoveWorker>> event.
