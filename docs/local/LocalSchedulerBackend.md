= LocalSchedulerBackend

LocalSchedulerBackend is a <<../SchedulerBackend.md#, SchedulerBackend>> and an executor:ExecutorBackend.md[] for the <<spark-local.md#, Spark local>>.

LocalSchedulerBackend is <<creating-instance, created>> when `SparkContext` is requested to SparkContext.md#createTaskScheduler[create the SchedulerBackend with the TaskScheduler] for the following master URLs:

* *local* (with exactly <<totalCores, 1 CPU core>>)

* *local[n]* (with exactly <<totalCores, n CPU cores>>)

* *++local[*]++* (with the <<totalCores, total number of CPU cores>> that is the number of available CPU cores on the local machine)

* *local[n, m]* (with exactly <<totalCores, n CPU cores>>)

* *++local[*, m]++* (with the <<totalCores, total number of CPU cores>> that is the number of available CPU cores on the local machine)

While being <<creating-instance, created>>, LocalSchedulerBackend requests the <<launcherBackend, LauncherBackend>> to <<../spark-LauncherBackend.md#connect, connect>>.

When an executor sends task status updates (using `ExecutorBackend.statusUpdate`), they are passed along as <<messages, StatusUpdate>> to <<spark-LocalEndpoint.md#, LocalEndpoint>>.

.Task status updates flow in local mode
image::LocalSchedulerBackend-LocalEndpoint-Executor-task-status-updates.png[align="center"]

[[appId]]
[[applicationId]]
When requested for the <<../SchedulerBackend.md#applicationId, applicationId>>, LocalSchedulerBackend uses *local-[currentTimeMillis]*.

[[maxNumConcurrentTasks]]
When requested for the <<../SchedulerBackend.md#maxNumConcurrentTasks, maxNumConcurrentTasks>>, LocalSchedulerBackend simply divides the <<totalCores, total number of CPU cores>> by scheduler:TaskSchedulerImpl.md#CPUS_PER_TASK[spark.task.cpus] configuration (default: `1`).

[[defaultParallelism]]
When requested for the <<../SchedulerBackend.md#defaultParallelism, defaultParallelism>>, LocalSchedulerBackend uses <<../configuration-properties.md#spark.default.parallelism, spark.default.parallelism>> configuration (if defined) or the <<totalCores, total number of CPU cores>>.

[[userClassPath]]
When <<creating-instance, created>>, LocalSchedulerBackend <<getUserClasspath, uses>> the <<../configuration-properties.md#spark.executor.extraClassPath, spark.executor.extraClassPath>> configuration property (in the given <<conf, SparkConf>>) for the *user-defined class path for executors* that is used exclusively when LocalSchedulerBackend is requested to <<start, start>> (and creates a <<spark-LocalEndpoint.md#, LocalEndpoint>> that in turn uses it to create the one <<spark-LocalEndpoint.md#executor, Executor>>).

[[creating-instance]]
LocalSchedulerBackend takes the following to be created:

* [[conf]] <<../SparkConf.md#, SparkConf>>
* [[scheduler]] scheduler:TaskSchedulerImpl.md[TaskSchedulerImpl]
* [[totalCores]] Total number of CPU cores (aka _totalCores_)

[[internal-registries]]
.LocalSchedulerBackend's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1m,3",options="header",width="100%"]
|===
| Name
| Description

| localEndpoint
a| [[localEndpoint]] rpc:RpcEndpointRef.md[RpcEndpointRef] to *LocalSchedulerBackendEndpoint* RPC endpoint (that is <<spark-LocalEndpoint.md#, LocalEndpoint>> which LocalSchedulerBackend registers when <<start, started>>)

Used when LocalSchedulerBackend is requested for the following:

* <<reviveOffers, reviveOffers>> (and sends a <<spark-LocalEndpoint.md#ReviveOffers, ReviveOffers>> one-way asynchronous message)

* <<killTask, killTask>> (and sends a <<spark-LocalEndpoint.md#KillTask, KillTask>> one-way asynchronous message)

* <<statusUpdate, statusUpdate>> (and sends a <<spark-LocalEndpoint.md#StatusUpdate, StatusUpdate>> one-way asynchronous message)

* <<stop, stop>> (and sends a <<spark-LocalEndpoint.md#StopExecutor, StopExecutor>> asynchronous message)

| launcherBackend
a| [[launcherBackend]] <<../spark-LauncherBackend.md#, LauncherBackend>>

Used when LocalSchedulerBackend is <<creating-instance, created>>, <<start, started>> and <<stop, stopped>>

| listenerBus
a| [[listenerBus]] scheduler:LiveListenerBus.md[] that is used exclusively when LocalSchedulerBackend is requested to <<start, start>>

|===

[[logging]]
[TIP]
====
Enable `INFO` logging level for `org.apache.spark.scheduler.local.LocalSchedulerBackend` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.scheduler.local.LocalSchedulerBackend=INFO
```

Refer to <<../spark-logging.md#, Logging>>.
====

== [[start]] Starting Scheduling Backend -- `start` Method

[source, scala]
----
start(): Unit
----

NOTE: `start` is part of the <<../SchedulerBackend.md#start, SchedulerBackend Contract>> to start the scheduling backend.

`start` requests the `SparkEnv` object for the current core:SparkEnv.md#rpcEnv[RpcEnv].

`start` then creates a <<spark-LocalEndpoint.md#, LocalEndpoint>> and requests the `RpcEnv` to rpc:RpcEnv.md#setupEndpoint[register it] as *LocalSchedulerBackendEndpoint* RPC endpoint.

`start` requests the <<listenerBus, LiveListenerBus>> to scheduler:LiveListenerBus.md#post[post] a SparkListener.md#SparkListenerExecutorAdded[SparkListenerExecutorAdded] event.

In the end, `start` requests the <<launcherBackend, LauncherBackend>> to <<../spark-LauncherBackend.md#setAppId, setAppId>> as the <<appId, appId>> and <<../spark-LauncherBackend.md#setState, setState>> as `RUNNING`.

== [[reviveOffers]] `reviveOffers` Method

[source, scala]
----
reviveOffers(): Unit
----

NOTE: `reviveOffers` is part of the <<../SchedulerBackend.md#reviveOffers, SchedulerBackend Contract>> to...FIXME.

`reviveOffers`...FIXME

== [[killTask]] `killTask` Method

[source, scala]
----
killTask(
  taskId: Long,
  executorId: String,
  interruptThread: Boolean,
  reason: String): Unit
----

NOTE: `killTask` is part of the <<../SchedulerBackend.md#killTask, SchedulerBackend Contract>> to kill a task.

`killTask`...FIXME

== [[statusUpdate]] `statusUpdate` Method

[source, scala]
----
statusUpdate(
  taskId: Long,
  state: TaskState,
  data: ByteBuffer): Unit
----

NOTE: `statusUpdate` is part of the executor:ExecutorBackend.md#statusUpdate[ExecutorBackend] abstraction.

`statusUpdate`...FIXME

== [[stop]] Stopping Scheduling Backend -- `stop` Method

[source, scala]
----
stop(): Unit
----

NOTE: `stop` is part of the <<../SchedulerBackend.md#stop, SchedulerBackend Contract>> to stop a scheduling backend.

`stop`...FIXME

== [[getUserClasspath]] User-Defined Class Path for Executors -- `getUserClasspath` Method

[source, scala]
----
getUserClasspath(conf: SparkConf): Seq[URL]
----

`getUserClasspath` simply requests the given `SparkConf` for the <<../configuration-properties.md#spark.executor.extraClassPath, spark.executor.extraClassPath>> configuration property and converts the entries (separated by the system-dependent path separator) to URLs.

NOTE: `getUserClasspath` is used exclusively when LocalSchedulerBackend is <<userClassPath, created>>.
