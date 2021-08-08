# Executor

Executor is a process that is used for executing scheduler:Task.md[tasks].

Executor _typically_ runs for the entire lifetime of a Spark application which is called *static allocation of executors* (but you could also opt in for [dynamic allocation](../dynamic-allocation/index.md)).

Executors are managed by executor:ExecutorBackend.md[executor backends].

Executors <<startDriverHeartbeater, reports heartbeat and partial metrics for active tasks>> to the <<heartbeatReceiverRef, HeartbeatReceiver RPC Endpoint>> on the driver.

![HeartbeatReceiver's Heartbeat Message Handler](../images/executor/HeartbeatReceiver-Heartbeat.png)

Executors provide in-memory storage for RDDs that are cached in Spark applications (via storage:BlockManager.md[]).

When started, an executor first registers itself with the driver that establishes a communication channel directly to the driver to accept tasks for execution.

![Launching tasks on executor using TaskRunners]()../images/executor/executor-taskrunner-executorbackend.png)

*Executor offers* are described by executor id and the host on which an executor runs (see <<resource-offers, Resource Offers>> in this document).

Executors can run multiple tasks over its lifetime, both in parallel and sequentially. They track executor:TaskRunner.md[running tasks] (by their task ids in <<runningTasks, runningTasks>> internal registry). Consult <<launchTask, Launching Tasks>> section.

Executors use a <<threadPool, Executor task launch worker thread pool>> for <<launchTask, launching tasks>>.

Executors send <<metrics, metrics>> (and heartbeats) using the <<heartbeater, internal heartbeater - Heartbeat Sender Thread>>.

It is recommended to have as many executors as data nodes and as many cores as you can get from the cluster.

Executors are described by their *id*, *hostname*, *environment* (as `SparkEnv`), and *classpath* (and, less importantly, and more for internal optimization, whether they run in spark-local:index.md[local] or spark-cluster.md[cluster] mode).

## Creating Instance

`Executor` takes the following to be created:

* <span id="executorId"> Executor ID
* <span id="executorHostname"> Host name
* <span id="env"> [SparkEnv](../SparkEnv.md)
* [User-defined jars](#userClassPath) (default: `empty`)
* [isLocal flag](#isLocal) (default: `false`)
* <span id="uncaughtExceptionHandler"> Java's UncaughtExceptionHandler (default: `SparkUncaughtExceptionHandler`)
* <span id="resources"> Resources (`Map[String, ResourceInformation]`)

`Executor` is created when:

* `CoarseGrainedExecutorBackend` is requested to [handle a RegisteredExecutor message](CoarseGrainedExecutorBackend.md#RegisteredExecutor) (after having registered with the driver)

* `LocalEndpoint` is [created](../local/LocalEndpoint.md#executor)

### When Created

When created, `Executor` prints out the following INFO messages to the logs:

```text
Starting executor ID [executorId] on host [executorHostname]
```

(only for [non-local](#isLocal) modes) `Executor` sets `SparkUncaughtExceptionHandler` as the default handler invoked when a thread abruptly terminates due to an uncaught exception.

(only for [non-local](#isLocal) modes) `Executor` requests the [BlockManager](../SparkEnv.md#blockManager) to [initialize](../storage/BlockManager.md#initialize) (with the [Spark application id](../SparkConf.md#getAppId) of the [SparkConf](../SparkEnv.md#conf)).

<span id="creating-instance-BlockManager-shuffleMetricsSource">

(only for [non-local](#isLocal) modes) `Executor` requests the [MetricsSystem](../SparkEnv.md#metricsSystem) to [register](../metrics/MetricsSystem.md#registerSource) the [ExecutorSource](#executorSource) and [shuffleMetricsSource](../storage/BlockManager.md#shuffleMetricsSource) of the [BlockManager](../SparkEnv.md#blockManager).

`Executor` uses `SparkEnv` to access the [MetricsSystem](../SparkEnv.md#metricsSystem) and [BlockManager](../SparkEnv.md#blockManager).

`Executor` [creates a task class loader](#createClassLoader) (optionally with [REPL support](#addReplClassLoaderIfNeeded)) and requests the system `Serializer` to [use as the default classloader](../serializer/Serializer.md#setDefaultClassLoader) (for deserializing tasks).

`Executor` [starts sending heartbeats with the metrics of active tasks](#startDriverHeartbeater).

## <span id="updateDependencies"> Fetching File and Jar Dependencies

```scala
updateDependencies(
  newFiles: Map[String, Long],
  newJars: Map[String, Long]): Unit
```

`updateDependencies` fetches missing or outdated extra files (in the given `newFiles`). For every name-timestamp pair that...FIXME..., `updateDependencies` prints out the following INFO message to the logs:

```text
Fetching [name] with timestamp [timestamp]
```

`updateDependencies` fetches missing or outdated extra jars (in the given `newJars`). For every name-timestamp pair that...FIXME..., `updateDependencies` prints out the following INFO message to the logs:

```text
Fetching [name] with timestamp [timestamp]
```

`updateDependencies` [fetches the file](../Utils.md#fetchFile) to the [SparkFiles root directory](../SparkFiles.md#getRootDirectory).

`updateDependencies`...FIXME

`updateDependencies` is used when:

* `TaskRunner` is requested to [start](TaskRunner.md#run) (and run a task)

## <span id="maxResultSize"> spark.driver.maxResultSize

`Executor` uses the [spark.driver.maxResultSize](../configuration-properties.md#spark.driver.maxResultSize) for `TaskRunner` when requested to [run a task](TaskRunner.md#run) (and [decide on a serialized task result](TaskRunner.md#run-serializedResult)).

## <span id="maxDirectResultSize"> Maximum Size of Direct Results

`Executor` uses the minimum of [spark.task.maxDirectResultSize](../configuration-properties.md#spark.task.maxDirectResultSize) and [spark.rpc.message.maxSize](../rpc/RpcUtils.md#maxMessageSizeBytes) when `TaskRunner` is requested to [run a task](TaskRunner.md#run) (and [decide on the type of a serialized task result](TaskRunner.md#run-serializedResult)).

## Logging

Enable `ALL` logging level for `org.apache.spark.executor.Executor` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.executor.Executor=ALL
```

Refer to [Logging](../spark-logging.md).

## Review Me

== [[isLocal]] isLocal Flag

Executor is given a isLocal flag when created. This is how the executor knows whether it runs in local or cluster mode. It is disabled by default.

The flag is turned on for spark-local:index.md[Spark local] (via spark-local:spark-LocalEndpoint.md[LocalEndpoint]).

== [[userClassPath]] User-Defined Jars

Executor is given user-defined jars when created. There are no jars defined by default.

The jars are specified using configuration-properties.md#spark.executor.extraClassPath[spark.executor.extraClassPath] configuration property (via executor:CoarseGrainedExecutorBackend.md#main[--user-class-path] command-line option of CoarseGrainedExecutorBackend).

## <span id="runningTasks"> Running Tasks Registry

```scala
runningTasks: Map[Long, TaskRunner]
```

`Executor` tracks [TaskRunners](executor:TaskRunner.md) by task IDs.

## <span id="heartbeatReceiverRef"> HeartbeatReceiver RPC Endpoint Reference

[RPC endpoint reference](../rpc/RpcEndpointRef.md) to [HeartbeatReceiver](../HeartbeatReceiver.md) on the [driver](../driver.md).

Set when Executor <<creating-instance, is created>>.

Used exclusively when Executor <<reportHeartBeat, reports heartbeats and partial metrics for active tasks to the driver>> (that happens every <<spark.executor.heartbeatInterval, spark.executor.heartbeatInterval>> interval).

== [[launchTask]] Launching Task

[source, scala]
----
launchTask(
  context: ExecutorBackend,
  taskDescription: TaskDescription): Unit
----

launchTask simply creates a executor:TaskRunner.md[] (with the given executor:ExecutorBackend.md[] and the [TaskDescription](../scheduler/TaskDescription.md)) and adds it to the <<runningTasks, runningTasks>> internal registry.

In the end, launchTask requests the <<threadPool, "Executor task launch worker" thread pool>> to execute the TaskRunner (sometime in the future).

.Launching tasks on executor using TaskRunners
image::executor-taskrunner-executorbackend.png[align="center"]

launchTask is used when:

* CoarseGrainedExecutorBackend is requested to executor:CoarseGrainedExecutorBackend.md#LaunchTask[handle a LaunchTask message]

* LocalEndpoint RPC endpoint (of spark-local:spark-LocalSchedulerBackend.md#[LocalSchedulerBackend]) is requested to spark-local:spark-LocalEndpoint.md#reviveOffers[reviveOffers]

* MesosExecutorBackend is requested to spark-on-mesos:spark-executor-backends-MesosExecutorBackend.md#launchTask[launchTask]

== [[heartbeater]] Heartbeat Sender Thread

heartbeater is a daemon {java-javadoc-url}/java/util/concurrent/ScheduledThreadPoolExecutor.html[ScheduledThreadPoolExecutor] with a single thread.

The name of the thread pool is *driver-heartbeater*.

== [[coarse-grained-executor]] Coarse-Grained Executors

*Coarse-grained executors* are executors that use executor:CoarseGrainedExecutorBackend.md[] for task scheduling.

== [[resource-offers]] Resource Offers

Read scheduler:TaskSchedulerImpl.md#resourceOffers[resourceOffers] in TaskSchedulerImpl and scheduler:TaskSetManager.md#resourceOffers[resourceOffer] in TaskSetManager.

== [[threadPool]] Executor task launch worker Thread Pool

Executor uses threadPool daemon cached thread pool with the name *Executor task launch worker-[ID]* (with `ID` being the task id) for <<launchTask, launching tasks>>.

threadPool is created when <<creating-instance, Executor is created>> and shut down when <<stop, it stops>>.

== [[memory]] Executor Memory

You can control the amount of memory per executor using configuration-properties.md#spark.executor.memory[spark.executor.memory] configuration property. It sets the available memory equally for all executors per application.

The amount of memory per executor is looked up when SparkContext.md#creating-instance[SparkContext is created].

You can change the assigned memory per executor per node in spark-standalone:index.md[standalone cluster] using SparkContext.md#environment-variables[SPARK_EXECUTOR_MEMORY] environment variable.

You can find the value displayed as *Memory per Node* in spark-standalone:Master.md[web UI for standalone Master] (as depicted in the figure below).

.Memory per Node in Spark Standalone's web UI
image::spark-standalone-webui-memory-per-node.png[align="center"]

The above figure shows the result of running tools:spark-shell.md[Spark shell] with the amount of memory per executor defined explicitly (on command line), i.e.

```
./bin/spark-shell --master spark://localhost:7077 -c spark.executor.memory=2g
```

## Metrics

Every executor registers its own executor:ExecutorSource.md[] to [report metrics](../metrics/MetricsSystem.md#report).

== [[stop]] Stopping Executor

[source, scala]
----
stop(): Unit
----

stop requests core:SparkEnv.md#metricsSystem[MetricsSystem] for a [report](../metrics/MetricsSystem.md#report).

stop shuts <<heartbeater, driver-heartbeater thread>> down (and waits at most 10 seconds).

stop shuts <<threadPool, Executor task launch worker thread pool>> down.

(only when <<isLocal, not local>>) stop core:SparkEnv.md#stop[requests `SparkEnv` to stop].

stop is used when executor:CoarseGrainedExecutorBackend.md#Shutdown[CoarseGrainedExecutorBackend] and spark-local:spark-LocalEndpoint.md#StopExecutor[LocalEndpoint] are requested to stop their managed executors.

== [[computeTotalGcTime]] computeTotalGcTime Method

[source, scala]
----
computeTotalGcTime(): Long
----

computeTotalGcTime...FIXME

computeTotalGcTime is used when:

* TaskRunner is requested to executor:TaskRunner.md#collectAccumulatorsAndResetStatusOnFailure[collectAccumulatorsAndResetStatusOnFailure] and executor:TaskRunner.md#run[run]

* Executor is requested to <<reportHeartBeat, heartbeat with partial metrics for active tasks to the driver>>

== [[createClassLoader]] createClassLoader Method

[source, scala]
----
createClassLoader(): MutableURLClassLoader
----

createClassLoader...FIXME

createClassLoader is used when...FIXME

== [[addReplClassLoaderIfNeeded]] addReplClassLoaderIfNeeded Method

[source, scala]
----
addReplClassLoaderIfNeeded(
  parent: ClassLoader): ClassLoader
----

addReplClassLoaderIfNeeded...FIXME

addReplClassLoaderIfNeeded is used when...FIXME

== [[reportHeartBeat]] Heartbeating With Partial Metrics For Active Tasks To Driver

[source, scala]
----
reportHeartBeat(): Unit
----

reportHeartBeat collects executor:TaskRunner.md[TaskRunners] for <<runningTasks, currently running tasks>> (aka _active tasks_) with their executor:TaskRunner.md#task[tasks] deserialized (i.e. either ready for execution or already started).

executor:TaskRunner.md[] has TaskRunner.md#task[task] deserialized when it executor:TaskRunner.md#run[runs the task].

For every running task, reportHeartBeat takes its scheduler:Task.md#metrics[TaskMetrics] and:

* Requests executor:TaskMetrics.md#mergeShuffleReadMetrics[ShuffleRead metrics to be merged]
* executor:TaskMetrics.md#setJvmGCTime[Sets jvmGCTime metrics]

reportHeartBeat then records the latest values of executor:TaskMetrics.md#accumulators[internal and external accumulators] for every task.

NOTE: Internal accumulators are a task's metrics while external accumulators are a Spark application's accumulators that a user has created.

reportHeartBeat sends a blocking [Heartbeat](../HeartbeatReceiver.md#Heartbeat) message to <<heartbeatReceiverRef, `HeartbeatReceiver` endpoint>> (running on the driver). reportHeartBeat uses the value of configuration-properties.md#spark.executor.heartbeatInterval[spark.executor.heartbeatInterval] configuration property for the RPC timeout.

NOTE: A `Heartbeat` message contains the executor identifier, the accumulator updates, and the identifier of the storage:BlockManager.md[].

If the response (from <<heartbeatReceiverRef, `HeartbeatReceiver` endpoint>>) is to re-register the `BlockManager`, you should see the following INFO message in the logs and reportHeartBeat requests the BlockManager to storage:BlockManager.md#reregister[re-register] (which will register the blocks the `BlockManager` manages with the driver).

[source,plaintext]
----
Told to re-register on heartbeat
----

HeartbeatResponse requests the BlockManager to re-register when either scheduler:TaskScheduler.md#executorHeartbeatReceived[TaskScheduler] or [HeartbeatReceiver](../HeartbeatReceiver.md#Heartbeat) know nothing about the executor.

When posting the `Heartbeat` was successful, reportHeartBeat resets <<heartbeatFailures, heartbeatFailures>> internal counter.

In case of a non-fatal exception, you should see the following WARN message in the logs (followed by the stack trace).

```
Issue communicating with driver in heartbeater
```

Every failure reportHeartBeat increments <<heartbeatFailures, heartbeat failures>> up to configuration-properties.md#spark.executor.heartbeat.maxFailures[spark.executor.heartbeat.maxFailures] configuration property. When the heartbeat failures reaches the maximum, you should see the following ERROR message in the logs and the executor terminates with the error code: `56`.

```
Exit as unable to send heartbeats to driver more than [HEARTBEAT_MAX_FAILURES] times
```

reportHeartBeat is used when Executor is requested to <<startDriverHeartbeater, schedule reporting heartbeat and partial metrics for active tasks to the driver>> (that happens every configuration-properties.md#spark.executor.heartbeatInterval[spark.executor.heartbeatInterval]).

== [[startDriverHeartbeater]][[heartbeats-and-active-task-metrics]] Sending Heartbeats and Active Tasks Metrics

Executors keep sending <<metrics, metrics for active tasks>> to the driver every <<spark.executor.heartbeatInterval, spark.executor.heartbeatInterval>> (defaults to `10s` with some random initial delay so the heartbeats from different executors do not pile up on the driver).

.Executors use HeartbeatReceiver endpoint to report task metrics
image::executor-heartbeatReceiver-endpoint.png[align="center"]

An executor sends heartbeats using the <<heartbeater, internal heartbeater -- Heartbeat Sender Thread>>.

.HeartbeatReceiver's Heartbeat Message Handler
image::HeartbeatReceiver-Heartbeat.png[align="center"]

For each scheduler:Task.md[task] in executor:TaskRunner.md[] (in <<runningTasks, runningTasks>> internal registry), the task's metrics are computed (i.e. `mergeShuffleReadMetrics` and `setJvmGCTime`) that become part of the heartbeat (with accumulators).

NOTE: Executors track the executor:TaskRunner.md[] that run scheduler:Task.md[tasks]. A executor:TaskRunner.md#run[task might not be assigned to a TaskRunner yet] when the executor sends a heartbeat.

A blocking [Heartbeat](../HeartbeatReceiver.md#Heartbeat) message that holds the executor id, all accumulator updates (per task id), and storage:BlockManagerId.md[] is sent to [HeartbeatReceiver RPC endpoint](../HeartbeatReceiver.md) (with <<spark.executor.heartbeatInterval, spark.executor.heartbeatInterval>> timeout).

If the response [requests to reregister BlockManager](../HeartbeatReceiver.md#Heartbeat), you should see the following INFO message in the logs:

```text
Told to re-register on heartbeat
```

BlockManager is requested to storage:BlockManager.md#reregister[reregister].

The internal <<heartbeatFailures, heartbeatFailures>> counter is reset (i.e. becomes `0`).

If there are any issues with communicating with the driver, you should see the following WARN message in the logs:

[source,plaintext]
----
Issue communicating with driver in heartbeater
----

The internal <<heartbeatFailures, heartbeatFailures>> is incremented and checked to be less than the <<spark.executor.heartbeat.maxFailures, acceptable number of failures>> (i.e. `spark.executor.heartbeat.maxFailures` Spark property). If the number is greater, the following ERROR is printed out to the logs:

```
Exit as unable to send heartbeats to driver more than [HEARTBEAT_MAX_FAILURES] times
```

The executor exits (using `System.exit` and exit code 56).

== [[internal-properties]] Internal Properties

=== [[executorSource]] ExecutorSource

executor:ExecutorSource.md[]

=== [[heartbeatFailures]] heartbeatFailures
