# LocalSchedulerBackend

`LocalSchedulerBackend` is a [SchedulerBackend](../scheduler/SchedulerBackend.md) and an [ExecutorBackend](../executor/ExecutorBackend.md) for [Spark local](index.md) deployment.

Master URL | Total CPU Cores
-----------|----------------
 `local` | 1
 `local[n]` | `n`
 `local[*]` | The number of available CPU cores on the local machine
 `local[n, m]` | `n` CPU cores and `m` task retries
 `local[*, m]` | The number of available CPU cores on the local machine and `m` task retries

![Task status updates flow in local mode](../images/LocalSchedulerBackend-LocalEndpoint-Executor-task-status-updates.png)

## Creating Instance

`LocalSchedulerBackend` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="scheduler"> [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md)
* <span id="totalCores"> Total number of CPU cores

`LocalSchedulerBackend` is created when:

* `SparkContext` is requested to [create a Spark Scheduler](../SparkContext.md#createTaskScheduler) (for `local` master URL)
* `KubernetesClusterManager` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesClusterManager)) is requested for a `SchedulerBackend`

## Maximum Number of Concurrent Tasks { #maxNumConcurrentTasks }

??? note "SchedulerBackend"

    ```scala
    maxNumConcurrentTasks(
      rp: ResourceProfile): Int
    ```

    `maxNumConcurrentTasks` is part of the [SchedulerBackend](../scheduler/SchedulerBackend.md#maxNumConcurrentTasks) abstraction.

`maxNumConcurrentTasks` [calculates the number of CPU cores per task](../stage-level-scheduling/ResourceProfile.md#getTaskCpusOrDefaultForProfile) for the given [ResourceProfile](../stage-level-scheduling/ResourceProfile.md) (and this [SparkConf](#conf)).

In the end, `maxNumConcurrentTasks` is the [total CPU cores](#totalCores) available divided by the number of CPU cores per task.

## Logging

Enable `ALL` logging level for `org.apache.spark.scheduler.local.LocalSchedulerBackend` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.LocalSchedulerBackend.name = org.apache.spark.scheduler.local.LocalSchedulerBackend
logger.LocalSchedulerBackend.level = all
```

Refer to [Logging](../spark-logging.md).

<!---
## Review Me

While being <<creating-instance, created>>, LocalSchedulerBackend requests the <<launcherBackend, LauncherBackend>> to <<../spark-LauncherBackend.md#connect, connect>>.

When an executor sends task status updates (using `ExecutorBackend.statusUpdate`), they are passed along as <<messages, StatusUpdate>> to <<spark-LocalEndpoint.md#, LocalEndpoint>>.

[[appId]]
[[applicationId]]
When requested for the <<../SchedulerBackend.md#applicationId, applicationId>>, LocalSchedulerBackend uses *local-[currentTimeMillis]*.

[[maxNumConcurrentTasks]]
When requested for the <<../SchedulerBackend.md#maxNumConcurrentTasks, maxNumConcurrentTasks>>, LocalSchedulerBackend simply divides the <<totalCores, total number of CPU cores>> by scheduler:TaskSchedulerImpl.md#CPUS_PER_TASK[spark.task.cpus] configuration (default: `1`).

[[defaultParallelism]]
When requested for the <<../SchedulerBackend.md#defaultParallelism, defaultParallelism>>, LocalSchedulerBackend uses <<../configuration-properties.md#spark.default.parallelism, spark.default.parallelism>> configuration (if defined) or the <<totalCores, total number of CPU cores>>.

[[userClassPath]]
When <<creating-instance, created>>, LocalSchedulerBackend <<getUserClasspath, uses>> the <<../configuration-properties.md#spark.executor.extraClassPath, spark.executor.extraClassPath>> configuration property (in the given <<conf, SparkConf>>) for the *user-defined class path for executors* that is used exclusively when LocalSchedulerBackend is requested to <<start, start>> (and creates a <<spark-LocalEndpoint.md#, LocalEndpoint>> that in turn uses it to create the one <<spark-LocalEndpoint.md#executor, Executor>>).

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

== [[getUserClasspath]] User-Defined Class Path for Executors -- `getUserClasspath` Method

[source, scala]
----
getUserClasspath(conf: SparkConf): Seq[URL]
----

`getUserClasspath` simply requests the given `SparkConf` for the <<../configuration-properties.md#spark.executor.extraClassPath, spark.executor.extraClassPath>> configuration property and converts the entries (separated by the system-dependent path separator) to URLs.

NOTE: `getUserClasspath` is used exclusively when LocalSchedulerBackend is <<userClassPath, created>>.
-->
