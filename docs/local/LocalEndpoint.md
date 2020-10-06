== [[LocalEndpoint]] LocalEndpoint -- RPC Endpoint for LocalSchedulerBackend

`LocalEndpoint` is the <<../index.md#ThreadSafeRpcEndpoint, ThreadSafeRpcEndpoint>> for <<executorBackend, LocalSchedulerBackend>> and is registered under the *LocalSchedulerBackendEndpoint* name.

`LocalEndpoint` is <<creating-instance, created>> exclusively when `LocalSchedulerBackend` is requested to <<spark-LocalSchedulerBackend.md#start, start>>.

Put simply, `LocalEndpoint` is the communication channel between <<scheduler, TaskSchedulerImpl>> and <<executorBackend, LocalSchedulerBackend>>. `LocalEndpoint` is a (thread-safe) rpc:RpcEndpoint.md[RpcEndpoint] that hosts an <<executor, executor>> (with `driver` ID and `localhost` hostname) for Spark local mode.

[[messages]]
.LocalEndpoint's RPC Messages
[cols="1,3",options="header",width="100%"]
|===
| Message
| Description

| <<KillTask, KillTask>>
| Requests the <<executor, executor>> to executor:Executor.md#killTask[kill a given task]

| <<ReviveOffers, ReviveOffers>>
| Calls <<reviveOffers, reviveOffers>>

| <<StatusUpdate, StatusUpdate>>
|

| <<StopExecutor, StopExecutor>>
| Requests the <<executor, executor>> to executor:Executor.md#stop[stop]

|===

When a `LocalEndpoint` starts up (as part of Spark local's initialization) it prints out the following INFO messages to the logs:

```
INFO Executor: Starting executor ID driver on host localhost
INFO Executor: Using REPL class URI: http://192.168.1.4:56131
```

[[executor]]
`LocalEndpoint` creates a single executor:Executor.md[] with the following properties:

* [[localExecutorId]] *driver* ID for the executor:Executor.md#executorId[executor ID]

* [[localExecutorHostname]] *localhost* for the executor:Executor.md#executorHostname[hostname]

* <<userClassPath, User-defined CLASSPATH>> for the executor:Executor.md#userClassPath[user-defined CLASSPATH]

* executor:Executor.md#isLocal[isLocal] flag enabled

The <<executor, executor>> is then used when `LocalEndpoint` is requested to handle <<KillTask, KillTask>> and <<StopExecutor, StopExecutor>> RPC messages, and <<reviveOffers, reviveOffers>>.

[[internal-registries]]
.LocalEndpoint's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1m,3",options="header",width="100%"]
|===
| Name
| Description

| freeCores
a| [[freeCores]] The number of CPU cores that are free to use (to schedule tasks)

Default: Initial <<totalCores, number of CPU cores>> (aka _totalCores_)

Increments when `LocalEndpoint` is requested to handle <<StatusUpdate, StatusUpdate>> RPC message with a finished state

Decrements when `LocalEndpoint` is requested to <<reviveOffers, reviveOffers>> and there were tasks to execute

NOTE: A single task to execute costs scheduler:TaskSchedulerImpl.md#CPUS_PER_TASK[spark.task.cpus] configuration (default: `1`).

Used when `LocalEndpoint` is requested to <<reviveOffers, reviveOffers>>

|===

[[logging]]
[TIP]
====
Enable `INFO` logging level for `org.apache.spark.scheduler.local.LocalEndpoint` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.scheduler.local.LocalEndpoint=INFO
```

Refer to <<../spark-logging.md#, Logging>>.
====

=== [[creating-instance]] Creating LocalEndpoint Instance

`LocalEndpoint` takes the following to be created:

* [[rpcEnv]] <<../index.md#, RpcEnv>>
* [[userClassPath]] User-defined class path (`Seq[URL]`) that is the <<spark-LocalSchedulerBackend.md#userClassPath, spark.executor.extraClassPath>> configuration property and is used exclusively to create the <<executor, Executor>>
* [[scheduler]] scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl]
* [[executorBackend]] <<spark-LocalSchedulerBackend.md#, LocalSchedulerBackend>>
* [[totalCores]] Number of CPU cores (aka _totalCores_)

`LocalEndpoint` initializes the <<internal-registries, internal registries and counters>>.

=== [[receive]] Processing Receive-Only RPC Messages -- `receive` Method

[source, scala]
----
receive: PartialFunction[Any, Unit]
----

NOTE: `receive` is part of the rpc:RpcEndpoint.md#receive[RpcEndpoint] abstraction.

`receive` handles (_processes_) <<ReviveOffers, ReviveOffers>>, <<StatusUpdate, StatusUpdate>>, and <<KillTask, KillTask>> RPC messages.

==== [[ReviveOffers]] `ReviveOffers` RPC Message

[source, scala]
----
ReviveOffers()
----

When <<receive, received>>, `LocalEndpoint` <<reviveOffers, reviveOffers>>.

NOTE: `ReviveOffers` RPC message is sent out exclusively when `LocalSchedulerBackend` is requested to <<spark-LocalSchedulerBackend.md#reviveOffers, reviveOffers>>.

==== [[StatusUpdate]] `StatusUpdate` RPC Message

[source, scala]
----
StatusUpdate(
  taskId: Long,
  state: TaskState,
  serializedData: ByteBuffer)
----

When <<receive, received>>, `LocalEndpoint` requests the <<scheduler, TaskSchedulerImpl>> to scheduler:TaskSchedulerImpl.md#statusUpdate[handle a task status update] (given the `taskId`, the task state and the data).

If the given scheduler:Task.md#TaskState[TaskState] is a *finished state* (one of `FINISHED`, `FAILED`, `KILLED`, `LOST` states), `LocalEndpoint` adds scheduler:TaskSchedulerImpl.md#CPUS_PER_TASK[spark.task.cpus] configuration (default: `1`) to the <<freeCores, freeCores>> registry followed by <<reviveOffers, reviveOffers>>.

NOTE: `StatusUpdate` RPC message is sent out exclusively when `LocalSchedulerBackend` is requested to <<spark-LocalSchedulerBackend.md#statusUpdate, statusUpdate>>.

==== [[KillTask]] `KillTask` RPC Message

[source, scala]
----
KillTask(
  taskId: Long,
  interruptThread: Boolean,
  reason: String)
----

When <<receive, received>>, `LocalEndpoint` requests the single <<executor, Executor>> to executor:Executor.md#killTask[kill a task] (given the `taskId`, the `interruptThread` flag and the reason).

NOTE: `KillTask` RPC message is sent out exclusively when `LocalSchedulerBackend` is requested to <<spark-LocalSchedulerBackend.md#killTask, kill a task>>.

=== [[reviveOffers]] Reviving Offers -- `reviveOffers` Method

[source, scala]
----
reviveOffers(): Unit
----

`reviveOffers`...FIXME

NOTE: `reviveOffers` is used when `LocalEndpoint` is requested to <<receive, handle RPC messages>> (namely <<ReviveOffers, ReviveOffers>> and <<StatusUpdate, StatusUpdate>>).

=== [[receiveAndReply]] Processing Receive-Reply RPC Messages -- `receiveAndReply` Method

[source, scala]
----
receiveAndReply(context: RpcCallContext): PartialFunction[Any, Unit]
----

NOTE: `receiveAndReply` is part of the rpc:RpcEndpoint.md#receiveAndReply[RpcEndpoint] abstraction.

`receiveAndReply` handles (_processes_) <<StopExecutor, StopExecutor>> RPC message exclusively.

==== [[StopExecutor]] `StopExecutor` RPC Message

[source, scala]
----
StopExecutor()
----

When <<receiveAndReply, received>>, `LocalEndpoint` requests the single <<executor, Executor>> to executor:Executor.md#stop[stop] and requests the given `RpcCallContext` to `reply` with `true` (as the response).

NOTE: `StopExecutor` RPC message is sent out exclusively when `LocalSchedulerBackend` is requested to <<spark-LocalSchedulerBackend.md#stop, stop>>.
