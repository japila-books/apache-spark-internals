# SparkContext

`SparkContext` is the entry point to all of the components of Apache Spark (execution engine) and so the heart of a Spark application. In fact, you can consider an application a Spark application only when it uses a SparkContext (directly or indirectly).

![Spark context acts as the master of your Spark application](images/diagrams/sparkcontext-services.png)

!!! important
    There should be one active `SparkContext` per JVM and Spark developers should use [SparkContext.getOrCreate](#getOrCreate) utility for sharing it (e.g. across threads).

## Creating Instance

`SparkContext` takes the following to be created:

* <span id="config"> [SparkConf](SparkConf.md)

`SparkContext` is created (directly or indirectly using [getOrCreate](#getOrCreate) utility).

While being created, `SparkContext` [sets up core services](SparkContext-creating-instance-internals.md) and establishes a connection to a [Spark execution environment](spark-deployment-environments.md).

## <span id="localProperties"><span id="getLocalProperties"><span id="setLocalProperties"><span id="setLocalProperty"> Local Properties

```scala
localProperties: InheritableThreadLocal[Properties]
```

`SparkContext` uses an `InheritableThreadLocal` ([Java]({{ java.api }}/java.base/java/lang/InheritableThreadLocal.html)) of key-value pairs of thread-local properties to pass extra information from a parent thread (on the driver) to child threads.

`localProperties` is meant to be used by developers using [SparkContext.setLocalProperty](#setLocalProperty) and [SparkContext.getLocalProperty](#getLocalProperty).

Local Properties are available using [TaskContext.getLocalProperty](scheduler/TaskContext.md#getLocalProperty).

Local Properties are available to [SparkListener](SparkListener.md)s using the following events:

* [SparkListenerJobStart](SparkListenerEvent.md#SparkListenerJobStart)
* [SparkListenerStageSubmitted](SparkListenerEvent.md#SparkListenerStageSubmitted)

`localProperties` are passed down when `SparkContext` is requested for the following:

* [Running Job](#runJob) (that in turn makes the local properties available to the [DAGScheduler](#dagScheduler) to [run a job](scheduler/DAGScheduler.md#runJob))
* [Running Approximate Job](#runApproximateJob)
* [Submitting Job](#submitJob)
* [Submitting MapStage](#submitMapStage)

`DAGScheduler` passes down local properties when scheduling:

* [ShuffleMapTask](scheduler/ShuffleMapTask.md#localProperties)s
* [ResultTask](scheduler/ResultTask.md#localProperties)s
* [TaskSet](scheduler/TaskSet.md#properties)s

Spark (Core) defines the following local properties.

Name | Default Value | Setter
-----|---------------|-------------
 <span id="LONG_FORM"> `callSite.long` |
 <span id="SHORT_FORM"><span id="setCallSite"> `callSite.short` | | `SparkContext.setCallSite`
 <span id="SPARK_JOB_DESCRIPTION"><span id="setJobDescription"> `spark.job.description` | [callSite.short](#SHORT_FORM) | `SparkContext.setJobDescription` <br> (`SparkContext.setJobGroup`)
 <span id="SPARK_JOB_INTERRUPT_ON_CANCEL"> `spark.job.interruptOnCancel` | | `SparkContext.setJobGroup`
 <span id="SPARK_JOB_GROUP_ID"><span id="setJobGroup"> `spark.jobGroup.id` | | `SparkContext.setJobGroup`
 <span id="SPARK_SCHEDULER_POOL"> `spark.scheduler.pool` | |

## Services

* <span id="statusStore"><span id="AppStatusStore"><span id="_statusStore"> [AppStatusStore](status/AppStatusStore.md)

* <span id="executorAllocationManager"><span id="_executorAllocationManager"><span id="ExecutorAllocationManager"> [ExecutorAllocationManager](dynamic-allocation/ExecutorAllocationManager.md) (optional)

* <span id="schedulerBackend"> [SchedulerBackend](scheduler/SchedulerBackend.md)

* _others_

## <span id="shuffleDriverComponents"><span id="_shuffleDriverComponents"> ShuffleDriverComponents

`SparkContext` creates a [ShuffleDriverComponents](shuffle/ShuffleDriverComponents.md) when [created](#creating-instance).

`SparkContext` [loads the ShuffleDataIO](shuffle/ShuffleDataIOUtils.md#loadShuffleDataIO) that is in turn requested for the [ShuffleDriverComponents](shuffle/ShuffleDataIO.md#driver). `SparkContext` requests the `ShuffleDriverComponents` to [initialize](shuffle/ShuffleDriverComponents.md#initializeApplication).

The `ShuffleDriverComponents` is used when:

* `ShuffleDependency` is [created](rdd/ShuffleDependency.md)
* `SparkContext` creates the [ContextCleaner](#cleaner) (if enabled)

`SparkContext` requests the `ShuffleDriverComponents` to [clean up](shuffle/ShuffleDriverComponents.md#cleanupApplication) when [stopping](#stop).

## Static Files

### <span id="addFile"> addFile

```scala
addFile(
  path: String,
  recursive: Boolean): Unit
// recursive = false
addFile(
  path: String): Unit
```

Firstly, `addFile` validate the schema of given `path`. For a no-schema path, `addFile` converts it to a canonical form. For a local schema path, `addFile` prints out the following WARN message to the logs and exits.

```text
File with 'local' scheme is not supported to add to file server, since it is already available on every node.
```
And for other schema path, `addFile` creates a Hadoop Path from the given path.

`addFile` Will validate the URL if the path is an HTTP, HTTPS or FTP URI.

`addFile` Will throw `SparkException` with below message if path is local directories but not in local mode.

```text
addFile does not support local directories when not running local mode.
```

`addFile` Will throw `SparkException` with below message if path is directories but not turn on `recursive` flag.

```text
Added file $hadoopPath is a directory and recursive is not turned on.
```

In the end, `addFile` adds the file to the [addedFiles](#addedFiles) internal registry (with the current timestamp):

* For new files, `addFile` prints out the following INFO message to the logs, [fetches the file](Utils.md#fetchFile) (to the root directory and without using the cache) and [postEnvironmentUpdate](#postEnvironmentUpdate).

    ```text
    Added file [path] at [key] with timestamp [timestamp]
    ```

* For files that were already added, `addFile` prints out the following WARN message to the logs:

    ```text
    The path [path] has been added already. Overwriting of added paths is not supported in the current version.
    ```

`addFile` is used when:

* `SparkContext` is [created](SparkContext-creating-instance-internals.md#addFile)

### <span id="listFiles"> listFiles

```scala
listFiles(): Seq[String]
```

`listFiles` is the [files added](#addedFiles).

### <span id="addedFiles"> addedFiles Internal Registry

```scala
addedFiles: Map[String, Long]
```

`addedFiles` is a collection of static files by the timestamp the were [added](#addFile) at.

`addedFiles` is used when:

* `SparkContext` is requested to [postEnvironmentUpdate](#postEnvironmentUpdate) and [listFiles](#listFiles)
* `TaskSetManager` is [created](scheduler/TaskSetManager.md#addedFiles) (and [resourceOffer](scheduler/TaskSetManager.md#resourceOffer))

### <span id="files"><span id="_files"> files

```scala
files: Seq[String]
```

`files` is a collection of file paths defined by [spark.files](configuration-properties.md#spark.files) configuration property.

## <span id="postEnvironmentUpdate"> Posting SparkListenerEnvironmentUpdate Event

```scala
postEnvironmentUpdate(): Unit
```

`postEnvironmentUpdate`...FIXME

`postEnvironmentUpdate` is used when:

* `SparkContext` is requested to [addFile](#addFile) and [addJar](#addJar)

## <span id="getOrCreate"> getOrCreate Utility

```scala
getOrCreate(): SparkContext
getOrCreate(
  config: SparkConf): SparkContext
```

`getOrCreate`...FIXME

## <span id="_plugins"><span id="PluginContainer"> PluginContainer

`SparkContext` creates a [PluginContainer](plugins/PluginContainer.md) when [created](#creating-instance).

`PluginContainer` is created (for the driver where `SparkContext` lives) using [PluginContainer.apply](plugins/PluginContainer.md#apply) utility.

`PluginContainer` is then requested to [registerMetrics](plugins/PluginContainer.md#registerMetrics) with the [applicationId](#applicationId).

`PluginContainer` is requested to [shutdown](plugins/PluginContainer.md#shutdown) when `SparkContext` is requested to [stop](#stop).

## <span id="createTaskScheduler"> Creating SchedulerBackend and TaskScheduler

```scala
createTaskScheduler(
  sc: SparkContext,
  master: String,
  deployMode: String): (SchedulerBackend, TaskScheduler)
```

`createTaskScheduler` creates a [SchedulerBackend](scheduler/SchedulerBackend.md) and a [TaskScheduler](scheduler/TaskScheduler.md) for the given master URL and deployment mode.

![SparkContext creates Task Scheduler and Scheduler Backend](images/diagrams/sparkcontext-createtaskscheduler.png)

Internally, `createTaskScheduler` branches off per the given master URL ([master URL](spark-deployment-environments.md#master-urls)) to select the requested implementations.

`createTaskScheduler` accepts the following master URLs:

* `local` - local mode with 1 thread only
* `local[n]` or `local[*]` - local mode with `n` threads
* `local[n, m]` or `local[*, m]` -- local mode with `n` threads and `m` number of failures
* `spark://hostname:port` for Spark Standalone
* `local-cluster[n, m, z]` -- local cluster with `n` workers, `m` cores per worker, and `z` memory per worker
* Other URLs are simply handed over to [getClusterManager](#getClusterManager) to load an external cluster manager if available

`createTaskScheduler` is used when `SparkContext` is [created](#creating-instance).

## <span id="getClusterManager"> Loading ExternalClusterManager

```scala
getClusterManager(
  url: String): Option[ExternalClusterManager]
```

`getClusterManager` uses Java's [ServiceLoader]({{ java.api }}/java.base/java/util/ServiceLoader.html) to find and load an [ExternalClusterManager](scheduler/ExternalClusterManager.md) that [supports](scheduler/ExternalClusterManager.md#canCreate) the given master URL.

!!! note "ExternalClusterManager Service Discovery"
    For [ServiceLoader]({{ java.api }}/java.base/java/util/ServiceLoader.html) to find [ExternalClusterManager](scheduler/ExternalClusterManager.md)s, they have to be registered using the following file:
    
    ```text
    META-INF/services/org.apache.spark.scheduler.ExternalClusterManager
    ```

`getClusterManager` throws a `SparkException` when multiple cluster managers were found:

```text
Multiple external cluster managers registered for the url [url]: [serviceLoaders]
```

`getClusterManager` is used when `SparkContext` is requested for a [SchedulerBackend and TaskScheduler](#createTaskScheduler).

## <span id="runJob"> Running Job Synchronously

```scala
runJob[T, U: ClassTag](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U): Array[U]
runJob[T, U: ClassTag](
  rdd: RDD[T],
  processPartition: (TaskContext, Iterator[T]) => U,
  resultHandler: (Int, U) => Unit): Unit
runJob[T, U: ClassTag](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int]): Array[U]
runJob[T, U: ClassTag](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int],
  resultHandler: (Int, U) => Unit): Unit
runJob[T, U: ClassTag](
  rdd: RDD[T],
  func: Iterator[T] => U): Array[U]
runJob[T, U: ClassTag](
  rdd: RDD[T],
  processPartition: Iterator[T] => U,
  resultHandler: (Int, U) => Unit): Unit
runJob[T, U: ClassTag](
  rdd: RDD[T],
  func: Iterator[T] => U,
  partitions: Seq[Int]): Array[U]
```

![Executing action](images/spark-runjob.png)

`runJob` finds the [call site](#getCallSite) and [cleans up](#clean) the given `func` function.

`runJob` prints out the following INFO message to the logs:

```text
Starting job: [callSite]
```

With [spark.logLineage](configuration-properties.md#spark.logLineage) enabled, `runJob` requests the given `RDD` for the [recursive dependencies](rdd/RDD.md#toDebugString) and prints out the following INFO message to the logs:

```text
RDD's recursive dependencies:
[toDebugString]
```

`runJob` requests the [DAGScheduler](#dagScheduler) to [run a job](scheduler/DAGScheduler.md#runJob).

`runJob` requests the [ConsoleProgressBar](#progressBar) to [finishAll](ConsoleProgressBar.md#finishAll) if defined.

In the end, `runJob` requests the given `RDD` to [doCheckpoint](rdd/RDD.md#doCheckpoint).

`runJob` throws an `IllegalStateException` when `SparkContext` is [stopped](#stopped):

```text
SparkContext has been shutdown
```

### <span id="runJob-demo"> Demo

`runJob` is essentially executing a `func` function on all or a subset of partitions of an RDD and returning the result as an array (with elements being the results per partition).

```scala
sc.setLocalProperty("callSite.short", "runJob Demo")

val partitionsNumber = 4
val rdd = sc.parallelize(
  Seq("hello world", "nice to see you"),
  numSlices = partitionsNumber)

import org.apache.spark.TaskContext
val func = (t: TaskContext, ss: Iterator[String]) => 1
val result = sc.runJob(rdd, func)
assert(result.length == partitionsNumber)

sc.clearCallSite()
```

## <span id="getCallSite"> Call Site

```scala
getCallSite(): CallSite
```

`getCallSite`...FIXME

`getCallSite` is used when:

* `SparkContext` is requested to [broadcast](#broadcast), [runJob](#runJob), [runApproximateJob](#runApproximateJob), [submitJob](#submitJob) and [submitMapStage](#submitMapStage)
* `AsyncRDDActions` is requested to [takeAsync](rdd/AsyncRDDActions.md#takeAsync)
* `RDD` is [created](rdd/RDD.md#creationSite)

## <span id="clean"> Closure Cleaning

```scala
clean(
  f: F,
  checkSerializable: Boolean = true): F
```

`clean` cleans up the given `f` closure (using `ClosureCleaner.clean` utility).

!!! tip
    Enable `DEBUG` logging level for `org.apache.spark.util.ClosureCleaner` logger to see what happens inside the class.

    Add the following line to `conf/log4j.properties`:

    ```
    log4j.logger.org.apache.spark.util.ClosureCleaner=DEBUG
    ```

    Refer to [Logging](spark-logging.md).

With `DEBUG` logging level you should see the following messages in the logs:

```text
+++ Cleaning closure [func] ([func.getClass.getName]) +++
 + declared fields: [declaredFields.size]
     [field]
 ...
+++ closure [func] ([func.getClass.getName]) is now cleaned +++
```

## Logging

Enable `ALL` logging level for `org.apache.spark.SparkContext` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.SparkContext=ALL
```

Refer to [Logging](spark-logging.md).

## To Be Reviewed

SparkContext offers the following functions:

* Getting current status of a Spark application
** <<env, SparkEnv>>
** <<getConf, SparkConf>>
** <<master, deployment environment (as master URL)>>
** <<appName, application name>>
** <<applicationAttemptId, unique identifier of execution attempt>>
** <<deployMode, deploy mode>>
** <<defaultParallelism, default level of parallelism>> that specifies the number of spark-rdd-partitions.md[partitions] in RDDs when they are created without specifying the number explicitly by a user.
** <<sparkUser, Spark user>>
** <<startTime, the time (in milliseconds) when SparkContext was created>>
** <<uiWebUrl, URL of web UI>>
** <<version, Spark version>>
** <<getExecutorStorageStatus, Storage status>>

* Setting Configuration
** <<master-url, master URL>>
** [Local Properties](#localProperties)
** <<setJobGroup, Setting Local Properties to Group Spark Jobs>>
** <<setting-default-log-level, Default Logging Level>>

* Creating Distributed Entities
** <<creating-rdds, RDDs>>
** <<creating-accumulators, Accumulators>>
** <<broadcast, Broadcast variables>>

* Accessing services, e.g. <<statusStore, AppStatusStore>>, <<taskScheduler, TaskScheduler>>, scheduler:LiveListenerBus.md[], storage:BlockManager.md[BlockManager], scheduler:SchedulerBackend.md[SchedulerBackends], shuffle:ShuffleManager.md[ShuffleManager] and the <<cleaner, optional ContextCleaner>>.

* <<runJob, Running jobs synchronously>>
* <<submitJob, Submitting jobs asynchronously>>
* <<cancelJob, Cancelling a job>>
* <<cancelStage, Cancelling a stage>>
* <<custom-schedulers, Assigning custom Scheduler Backend, TaskScheduler and DAGScheduler>>
* <<closure-cleaning, Closure cleaning>>
* <<getPersistentRDDs, Accessing persistent RDDs>>
* <<unpersist, Unpersisting RDDs, i.e. marking RDDs as non-persistent>>
* <<addSparkListener, Registering SparkListener>>
* <<dynamic-allocation, Programmable Dynamic Allocation>>

TIP: Read the scaladoc of  http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.SparkContext[org.apache.spark.SparkContext].

### <span id="unpersistRDD"> Removing RDD Blocks from BlockManagerMaster

```scala
unpersistRDD(
  rddId: Int,
  blocking: Boolean = true): Unit
```

`unpersistRDD` requests `BlockManagerMaster` to storage:BlockManagerMaster.md#removeRdd[remove the blocks for the RDD] (given `rddId`).

NOTE: `unpersistRDD` uses `SparkEnv` core:SparkEnv.md#blockManager[to access the current `BlockManager`] that is in turn used to storage:BlockManager.md#master[access the current `BlockManagerMaster`].

`unpersistRDD` removes `rddId` from <<persistentRdds, persistentRdds>> registry.

In the end, `unpersistRDD` posts a SparkListener.md#SparkListenerUnpersistRDD[SparkListenerUnpersistRDD] (with `rddId`) to <<listenerBus, LiveListenerBus Event Bus>>.

[NOTE]
====
`unpersistRDD` is used when:

* `ContextCleaner` does core:ContextCleaner.md#doCleanupRDD[doCleanupRDD]
* SparkContext <<unpersist, unpersists an RDD>> (i.e. marks an RDD as non-persistent)
====

== [[applicationId]] Unique Identifier of Spark Application -- `applicationId` Method

CAUTION: FIXME

== [[postApplicationStart]] `postApplicationStart` Internal Method

[source, scala]
----
postApplicationStart(): Unit
----

`postApplicationStart`...FIXME

`postApplicationStart` is used exclusively when `SparkContext` is created.

== [[postApplicationEnd]] `postApplicationEnd` Method

CAUTION: FIXME

== [[clearActiveContext]] `clearActiveContext` Method

CAUTION: FIXME

== [[getPersistentRDDs]] Accessing persistent RDDs -- `getPersistentRDDs` Method

[source, scala]
----
getPersistentRDDs: Map[Int, RDD[_]]
----

`getPersistentRDDs` returns the collection of RDDs that have marked themselves as persistent via spark-rdd-caching.md#cache[cache].

Internally, `getPersistentRDDs` returns <<persistentRdds, persistentRdds>> internal registry.

== [[cancelJob]] Cancelling Job -- `cancelJob` Method

[source, scala]
----
cancelJob(jobId: Int)
----

`cancelJob` requests `DAGScheduler` scheduler:DAGScheduler.md#cancelJob[to cancel a Spark job].

== [[cancelStage]] Cancelling Stage -- `cancelStage` Methods

[source, scala]
----
cancelStage(stageId: Int): Unit
cancelStage(stageId: Int, reason: String): Unit
----

`cancelStage` simply requests `DAGScheduler` scheduler:DAGScheduler.md#cancelJob[to cancel a Spark stage] (with an optional `reason`).

NOTE: `cancelStage` is used when `StagesTab` spark-webui-StagesTab.md#handleKillRequest[handles a kill request] (from a user in web UI).

## <span id="dynamic-allocation"> Programmable Dynamic Allocation

SparkContext offers the following methods as the developer API for [Dynamic Allocation of Executors](dynamic-allocation/index.md):

* <<requestExecutors, requestExecutors>>
* <<killExecutors, killExecutors>>
* <<requestTotalExecutors, requestTotalExecutors>>
* (private!) <<getExecutorIds, getExecutorIds>>

=== [[requestExecutors]] Requesting New Executors -- `requestExecutors` Method

[source, scala]
----
requestExecutors(numAdditionalExecutors: Int): Boolean
----

`requestExecutors` requests `numAdditionalExecutors` executors from scheduler:CoarseGrainedSchedulerBackend.md[CoarseGrainedSchedulerBackend].

=== [[killExecutors]] Requesting to Kill Executors -- `killExecutors` Method

[source, scala]
----
killExecutors(executorIds: Seq[String]): Boolean
----

CAUTION: FIXME

=== [[requestTotalExecutors]] Requesting Total Executors -- `requestTotalExecutors` Method

[source, scala]
----
requestTotalExecutors(
  numExecutors: Int,
  localityAwareTasks: Int,
  hostToLocalTaskCount: Map[String, Int]): Boolean
----

`requestTotalExecutors` is a `private[spark]` method that scheduler:CoarseGrainedSchedulerBackend.md#requestTotalExecutors[requests the exact number of executors from a coarse-grained scheduler backend].

NOTE: It works for scheduler:CoarseGrainedSchedulerBackend.md[coarse-grained scheduler backends] only.

When called for other scheduler backends you should see the following WARN message in the logs:

```text
Requesting executors is only supported in coarse-grained mode
```

## <span id="getExecutorIds"> Executor IDs

`getExecutorIds` is a `private[spark]` method that is part of [ExecutorAllocationClient contract](dynamic-allocation/ExecutorAllocationClient.md). It simply [passes the call on to the current coarse-grained scheduler backend, i.e. calls `getExecutorIds`](scheduler:CoarseGrainedSchedulerBackend.md#getExecutorIds).

!!! important
    It works for [coarse-grained scheduler backends](scheduler:CoarseGrainedSchedulerBackend.md) only.

When called for other scheduler backends you should see the following WARN message in the logs:

```text
Requesting executors is only supported in coarse-grained mode
```

CAUTION: FIXME Why does SparkContext implement the method for coarse-grained scheduler backends? Why doesn't SparkContext throw an exception when the method is called? Nobody seems to be using it (!)

=== [[getOrCreate]] Getting Existing or Creating New SparkContext -- `getOrCreate` Methods

[source, scala]
----
getOrCreate(): SparkContext
getOrCreate(conf: SparkConf): SparkContext
----

`getOrCreate` methods allow you to get the existing SparkContext or create a new one.

[source, scala]
----
import org.apache.spark.SparkContext
val sc = SparkContext.getOrCreate()

// Using an explicit SparkConf object
import org.apache.spark.SparkConf
val conf = new SparkConf()
  .setMaster("local[*]")
  .setAppName("SparkMe App")
val sc = SparkContext.getOrCreate(conf)
----

The no-param `getOrCreate` method requires that the two mandatory Spark settings - <<master, master>> and <<appName, application name>> - are specified using spark-submit.md[spark-submit].

=== [[constructors]] Constructors

[source, scala]
----
SparkContext()
SparkContext(conf: SparkConf)
SparkContext(master: String, appName: String, conf: SparkConf)
SparkContext(
  master: String,
  appName: String,
  sparkHome: String = null,
  jars: Seq[String] = Nil,
  environment: Map[String, String] = Map())
----

You can create a SparkContext instance using the four constructors.

[source, scala]
----
import org.apache.spark.SparkConf
val conf = new SparkConf()
  .setMaster("local[*]")
  .setAppName("SparkMe App")

import org.apache.spark.SparkContext
val sc = new SparkContext(conf)
----

When a Spark context starts up you should see the following INFO in the logs (amongst the other messages that come from the Spark services):

```
Running Spark version 2.0.0-SNAPSHOT
```

NOTE: Only one SparkContext may be running in a single JVM (check out https://issues.apache.org/jira/browse/SPARK-2243[SPARK-2243 Support multiple SparkContexts in the same JVM]). Sharing access to a SparkContext in the JVM is the solution to share data within Spark (without relying on other means of data sharing using external data stores).

== [[env]] Accessing Current SparkEnv -- `env` Method

CAUTION: FIXME

== [[getConf]] Getting Current SparkConf -- `getConf` Method

[source, scala]
----
getConf: SparkConf
----

`getConf` returns the current SparkConf.md[SparkConf].

NOTE: Changing the `SparkConf` object does not change the current configuration (as the method returns a copy).

== [[master]][[master-url]] Deployment Environment -- `master` Method

[source, scala]
----
master: String
----

`master` method returns the current value of configuration-properties.md#spark.master[spark.master] which is the spark-deployment-environments.md[deployment environment] in use.

== [[appName]] Application Name -- `appName` Method

[source, scala]
----
appName: String
----

`appName` gives the value of the mandatory SparkConf.md#spark.app.name[spark.app.name] setting.

NOTE: `appName` is used when spark-standalone.md#SparkDeploySchedulerBackend[`SparkDeploySchedulerBackend` starts], spark-webui-SparkUI.md#createLiveUI[`SparkUI` creates a web UI], when `postApplicationStart` is executed, and for Mesos and checkpointing in Spark Streaming.

== [[applicationAttemptId]] Unique Identifier of Execution Attempt -- `applicationAttemptId` Method

[source, scala]
----
applicationAttemptId: Option[String]
----

`applicationAttemptId` gives the  unique identifier of the execution attempt of a Spark application.

[NOTE]
====
`applicationAttemptId` is used when:

* scheduler:ShuffleMapTask.md#creating-instance[ShuffleMapTask] and scheduler:ResultTask.md#creating-instance[ResultTask] are created

* SparkContext <<postApplicationStart, announces that a Spark application has started>>
====

== [[getExecutorStorageStatus]] Storage Status (of All BlockManagers) -- `getExecutorStorageStatus` Method

[source, scala]
----
getExecutorStorageStatus: Array[StorageStatus]
----

`getExecutorStorageStatus` storage:BlockManagerMaster.md#getStorageStatus[requests `BlockManagerMaster` for storage status] (of all storage:BlockManager.md[BlockManagers]).

NOTE: `getExecutorStorageStatus` is a developer API.

`getExecutorStorageStatus` is used when:

* `SparkContext` is requested for [storage status of cached RDDs](#getRDDStorageInfo)

* `SparkStatusTracker` is requested for [known executors](SparkStatusTracker.md#getExecutorInfos)

== [[deployMode]] Deploy Mode -- `deployMode` Method

[source,scala]
----
deployMode: String
----

`deployMode` returns the current value of spark-deploy-mode.md[spark.submit.deployMode] setting or `client` if not set.

== [[getSchedulingMode]] Scheduling Mode -- `getSchedulingMode` Method

[source, scala]
----
getSchedulingMode: SchedulingMode.SchedulingMode
----

`getSchedulingMode` returns the current spark-scheduler-SchedulingMode.md[Scheduling Mode].

== [[getPoolForName]] Schedulable (Pool) by Name -- `getPoolForName` Method

[source, scala]
----
getPoolForName(pool: String): Option[Schedulable]
----

`getPoolForName` returns a spark-scheduler-Schedulable.md[Schedulable] by the `pool` name, if one exists.

NOTE: `getPoolForName` is part of the Developer's API and may change in the future.

Internally, it requests the scheduler:TaskScheduler.md#rootPool[TaskScheduler for the root pool] and spark-scheduler-Pool.md#schedulableNameToSchedulable[looks up the `Schedulable` by the `pool` name].

It is exclusively used to spark-webui-PoolPage.md[show pool details in web UI (for a stage)].

== [[getAllPools]] All Schedulable Pools -- `getAllPools` Method

[source, scala]
----
getAllPools: Seq[Schedulable]
----

`getAllPools` collects the spark-scheduler-Pool.md[Pools] in scheduler:TaskScheduler.md#contract[TaskScheduler.rootPool].

NOTE: `TaskScheduler.rootPool` is part of the scheduler:TaskScheduler.md#contract[TaskScheduler Contract].

NOTE: `getAllPools` is part of the Developer's API.

CAUTION: FIXME Where is the method used?

NOTE: `getAllPools` is used to calculate pool names for spark-webui-AllStagesPage.md#pool-names[Stages tab in web UI] with FAIR scheduling mode used.

== [[defaultParallelism]] Default Level of Parallelism

[source, scala]
----
defaultParallelism: Int
----

`defaultParallelism` requests <<taskScheduler, TaskScheduler>> for the scheduler:TaskScheduler.md#defaultParallelism[default level of parallelism].

NOTE: *Default level of parallelism* specifies the number of spark-rdd-partitions.md[partitions] in RDDs when created without specifying them explicitly by a user.

[NOTE]
====
`defaultParallelism` is used in <<parallelize, SparkContext.parallelize>>, `SparkContext.range` and <<makeRDD, SparkContext.makeRDD>> (as well as Spark Streaming's `DStream.countByValue` and `DStream.countByValueAndWindow` et al.).

`defaultParallelism` is also used to instantiate rdd:HashPartitioner.md[HashPartitioner] and for the minimum number of partitions in rdd:HadoopRDD.md[HadoopRDDs].
====

== [[taskScheduler]] Current Spark Scheduler (aka TaskScheduler) -- `taskScheduler` Property

[source, scala]
----
taskScheduler: TaskScheduler
taskScheduler_=(ts: TaskScheduler): Unit
----

`taskScheduler` manages (i.e. reads or writes) <<_taskScheduler, _taskScheduler>> internal property.

== [[version]] Getting Spark Version -- `version` Property

[source, scala]
----
version: String
----

`version` returns the Spark version this SparkContext uses.

== [[makeRDD]] `makeRDD` Method

CAUTION: FIXME

== [[submitJob]] Submitting Jobs Asynchronously -- `submitJob` Method

[source, scala]
----
submitJob[T, U, R](
  rdd: RDD[T],
  processPartition: Iterator[T] => U,
  partitions: Seq[Int],
  resultHandler: (Int, U) => Unit,
  resultFunc: => R): SimpleFutureAction[R]
----

`submitJob` submits a job in an asynchronous, non-blocking way to scheduler:DAGScheduler.md#submitJob[DAGScheduler].

It cleans the `processPartition` input function argument and returns an instance of spark-rdd-actions.md#FutureAction[SimpleFutureAction] that holds the [JobWaiter](scheduler/JobWaiter.md) instance.

CAUTION: FIXME What are `resultFunc`?

It is used in:

* spark-rdd-actions.md#AsyncRDDActions[AsyncRDDActions] methods
* spark-streaming/spark-streaming.md[Spark Streaming] for spark-streaming/spark-streaming-receivertracker.md#ReceiverTrackerEndpoint-startReceiver[ReceiverTrackerEndpoint.startReceiver]

== [[spark-configuration]] Spark Configuration

CAUTION: FIXME

== [[sparkcontext-and-rdd]] SparkContext and RDDs

You use a Spark context to create RDDs (see <<creating-rdds, Creating RDD>>).

When an RDD is created, it belongs to and is completely owned by the Spark context it originated from. RDDs can't by design be shared between SparkContexts.

.A Spark context creates a living space for RDDs.
image::diagrams/sparkcontext-rdds.png)

== [[creating-rdds]][[parallelize]] Creating RDD -- `parallelize` Method

SparkContext allows you to create many different RDDs from input sources like:

* Scala's collections, i.e. `sc.parallelize(0 to 100)`
* local or remote filesystems, i.e. `sc.textFile("README.md")`
* Any Hadoop `InputSource` using `sc.newAPIHadoopFile`

Read rdd:index.md#creating-rdds[Creating RDDs] in rdd:index.md[RDD - Resilient Distributed Dataset].

== [[unpersist]] Unpersisting RDD (Marking RDD as Non-Persistent) -- `unpersist` Method

CAUTION: FIXME

`unpersist` removes an RDD from the master's storage:BlockManager.md[Block Manager] (calls `removeRdd(rddId: Int, blocking: Boolean)`) and the internal <<persistentRdds, persistentRdds>> mapping.

It finally posts SparkListener.md#SparkListenerUnpersistRDD[SparkListenerUnpersistRDD] message to `listenerBus`.

== [[setCheckpointDir]] Setting Checkpoint Directory -- `setCheckpointDir` Method

[source, scala]
----
setCheckpointDir(directory: String)
----

`setCheckpointDir` method is used to set up the checkpoint directory...FIXME

CAUTION: FIXME

== [[register]] Registering Accumulator -- `register` Methods

[source, scala]
----
register(acc: AccumulatorV2[_, _]): Unit
register(acc: AccumulatorV2[_, _], name: String): Unit
----

`register` registers the `acc` [accumulator](accumulators/index.md). You can optionally give an accumulator a `name`.

TIP: You can create built-in accumulators for longs, doubles, and collection types using <<creating-accumulators, specialized methods>>.

Internally, `register` [registers `acc` accumulator](accumulators/index.md#register) (with the current SparkContext).

== [[creating-accumulators]][[longAccumulator]][[doubleAccumulator]][[collectionAccumulator]] Creating Built-In Accumulators

[source, scala]
----
longAccumulator: LongAccumulator
longAccumulator(name: String): LongAccumulator
doubleAccumulator: DoubleAccumulator
doubleAccumulator(name: String): DoubleAccumulator
collectionAccumulator[T]: CollectionAccumulator[T]
collectionAccumulator[T](name: String): CollectionAccumulator[T]
----

You can use `longAccumulator`, `doubleAccumulator` or `collectionAccumulator` to create and register [accumulators](accumulators/index.md) for simple and collection values.

`longAccumulator` returns [LongAccumulator](accumulators/index.md#LongAccumulator) with the zero value `0`.

`doubleAccumulator` returns [DoubleAccumulator](accumulators/index.md#DoubleAccumulator) with the zero value `0.0`.

`collectionAccumulator` returns [CollectionAccumulator](accumulators/index.md#CollectionAccumulator) with the zero value `java.util.List[T]`.

```text
scala> val acc = sc.longAccumulator
acc: org.apache.spark.util.LongAccumulator = LongAccumulator(id: 0, name: None, value: 0)

scala> val counter = sc.longAccumulator("counter")
counter: org.apache.spark.util.LongAccumulator = LongAccumulator(id: 1, name: Some(counter), value: 0)

scala> counter.value
res0: Long = 0

scala> sc.parallelize(0 to 9).foreach(n => counter.add(n))

scala> counter.value
res3: Long = 45
```

The `name` input parameter allows you to give a name to an accumulator and have it displayed in spark-webui-StagePage.md#accumulators[Spark UI] (under Stages tab for a given stage).

![Accumulators in the Spark UI](images/webui/spark-webui-accumulators.png)

!!! tip
    You can register custom accumulators using [register](#register) methods.

== [[broadcast]] Creating Broadcast Variable -- broadcast Method

[source, scala]
----
broadcast[T](
  value: T): Broadcast[T]
----

broadcast method creates a Broadcast.md[]. It is a shared memory with `value` (as broadcast blocks) on the driver and later on all Spark executors.

[source,plaintext]
----
val sc: SparkContext = ???
scala> val hello = sc.broadcast("hello")
hello: org.apache.spark.broadcast.Broadcast[String] = Broadcast(0)
----

Spark transfers the value to Spark executors _once_, and tasks can share it without incurring repetitive network transmissions when the broadcast variable is used multiple times.

![Broadcasting a value to executors](images/sparkcontext-broadcast-executors.png)

Internally, broadcast requests `BroadcastManager` for a [new broadcast variable](broadcast-variables/BroadcastManager.md#newBroadcast).

NOTE: The current `BroadcastManager` is available using core:SparkEnv.md#broadcastManager[`SparkEnv.broadcastManager`] attribute and is always [BroadcastManager](broadcast-variables/BroadcastManager.md) (with few internal configuration changes to reflect where it runs, i.e. inside the driver or executors).

You should see the following INFO message in the logs:

```text
Created broadcast [id] from [callSite]
```

If `ContextCleaner` is defined, the core:ContextCleaner.md#[new broadcast variable is registered for cleanup].

[NOTE]
====
Spark does not support broadcasting RDDs.

```
scala> sc.broadcast(sc.range(0, 10))
java.lang.IllegalArgumentException: requirement failed: Can not directly broadcast RDDs; instead, call collect() and broadcast the result.
  at scala.Predef$.require(Predef.scala:224)
  at org.apache.spark.SparkContext.broadcast(SparkContext.scala:1392)
  ... 48 elided
```
====

Once created, the broadcast variable (and other blocks) are displayed per executor and the driver in web UI.

![Broadcast Variables In web UI's Executors Tab](images/spark-broadcast-webui-executors-rdd-blocks.png)

== [[jars]] Distribute JARs to workers

The jar you specify with `SparkContext.addJar` will be copied to all the worker nodes.

The configuration setting `spark.jars` is a comma-separated list of jar paths to be included in all tasks executed from this SparkContext. A path can either be a local file, a file in HDFS (or other Hadoop-supported filesystems), an HTTP, HTTPS or FTP URI, or `local:/path` for a file on every worker node.

```
scala> sc.addJar("build.sbt")
15/11/11 21:54:54 Added JAR build.sbt at http://192.168.1.4:49427/jars/build.sbt with timestamp 1447275294457
```

CAUTION: FIXME Why is HttpFileServer used for addJar?

=== SparkContext as Application-Wide Counter

SparkContext keeps track of:

[[nextShuffleId]]
* shuffle ids using `nextShuffleId` internal counter for scheduler:ShuffleMapStage.md[registering shuffle dependencies] to shuffle:ShuffleManager.md[Shuffle Service].

== [[stop]][[stopping]] Stopping SparkContext -- `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` stops the SparkContext.

Internally, `stop` enables `stopped` internal flag. If already stopped, you should see the following INFO message in the logs:

```
SparkContext already stopped.
```

`stop` then does the following:

1. Removes `_shutdownHookRef` from `ShutdownHookManager`
2. <<postApplicationEnd, Posts a `SparkListenerApplicationEnd`>> (to <<listenerBus, LiveListenerBus Event Bus>>)
3. spark-webui-SparkUI.md#stop[Stops web UI]
4. [Requests `MetricSystem` to report metrics](metrics/MetricsSystem.md#report) (from all registered sinks)
5. core:ContextCleaner.md#stop[Stops `ContextCleaner`]
6. [Requests `ExecutorAllocationManager` to stop](dynamic-allocation/ExecutorAllocationManager.md#stop)
7. If `LiveListenerBus` was started, scheduler:LiveListenerBus.md#stop[requests `LiveListenerBus` to stop]
8. Requests spark-history-server:EventLoggingListener.md#stop[`EventLoggingListener` to stop]
9. Requests scheduler:DAGScheduler.md#stop[`DAGScheduler` to stop]
10. Requests rpc:index.md#stop[RpcEnv to stop `HeartbeatReceiver` endpoint]
11. Requests [`ConsoleProgressBar` to stop](ConsoleProgressBar.md#stop)
12. Clears the reference to `TaskScheduler`, i.e. `_taskScheduler` is `null`
13. Requests core:SparkEnv.md#stop[`SparkEnv` to stop] and clears `SparkEnv`
14. Clears yarn/spark-yarn-client.md#SPARK_YARN_MODE[`SPARK_YARN_MODE` flag]
15. <<clearActiveContext, Clears an active SparkContext>>

Ultimately, you should see the following INFO message in the logs:

```
Successfully stopped SparkContext
```

## <span id="addSparkListener"> Registering SparkListener

```scala
addSparkListener(
  listener: SparkListenerInterface): Unit
```

`addSparkListener` registers a custom [SparkListenerInterface](SparkListenerInterface.md).

!!! note
    Custom listeners can also be registered declaratively using [spark.extraListeners](configuration-properties.md#spark.extraListeners) configuration property.

== [[custom-schedulers]] Custom SchedulerBackend, TaskScheduler and DAGScheduler

By default, SparkContext uses (`private[spark]` class) `org.apache.spark.scheduler.DAGScheduler`, but you can develop your own custom DAGScheduler implementation, and use (`private[spark]`) `SparkContext.dagScheduler_=(ds: DAGScheduler)` method to assign yours.

It is also applicable to `SchedulerBackend` and `TaskScheduler` using `schedulerBackend_=(sb: SchedulerBackend)` and `taskScheduler_=(ts: TaskScheduler)` methods, respectively.

CAUTION: FIXME Make it an advanced exercise.

== [[events]] Events

When a Spark context starts, it triggers SparkListener.md#SparkListenerEnvironmentUpdate[SparkListenerEnvironmentUpdate] and SparkListener.md#SparkListenerApplicationStart[SparkListenerApplicationStart] messages.

Refer to the section <<creating-instance, SparkContext's initialization>>.

== [[setLogLevel]][[setting-default-log-level]] Setting Default Logging Level -- `setLogLevel` Method

[source, scala]
----
setLogLevel(logLevel: String)
----

`setLogLevel` allows you to set the root logging level in a Spark application, e.g. spark-shell.md[Spark shell].

Internally, `setLogLevel` calls ++http://logging.apache.org/log4j/2.x/log4j-api/apidocs/org/apache/logging/log4j/Level.html#toLevel(java.lang.String)++[org.apache.log4j.Level.toLevel(logLevel)] that it then uses to set using ++http://logging.apache.org/log4j/2.x/log4j-api/apidocs/org/apache/logging/log4j/LogManager.html#getRootLogger()++[org.apache.log4j.LogManager.getRootLogger().setLevel(level)].

[TIP]
====
You can directly set the logging level using ++http://logging.apache.org/log4j/2.x/log4j-api/apidocs/org/apache/logging/log4j/LogManager.html#getLogger()++[org.apache.log4j.LogManager.getLogger()].

[source, scala]
----
LogManager.getLogger("org").setLevel(Level.OFF)
----

====

== [[hadoopConfiguration]] Hadoop Configuration

While a <<creating-instance, SparkContext is being created>>, so is a Hadoop configuration (as an instance of https://hadoop.apache.org/docs/current/api/org/apache/hadoop/conf/Configuration.html[org.apache.hadoop.conf.Configuration] that is available as `_hadoopConfiguration`).

NOTE: spark-SparkHadoopUtil.md#newConfiguration[SparkHadoopUtil.get.newConfiguration] is used.

If a SparkConf is provided it is used to build the configuration as described. Otherwise, the default `Configuration` object is returned.

If `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are both available, the following settings are set for the Hadoop configuration:

* `fs.s3.awsAccessKeyId`, `fs.s3n.awsAccessKeyId`, `fs.s3a.access.key` are set to the value of `AWS_ACCESS_KEY_ID`
* `fs.s3.awsSecretAccessKey`, `fs.s3n.awsSecretAccessKey`, and `fs.s3a.secret.key` are set to the value of `AWS_SECRET_ACCESS_KEY`

Every `spark.hadoop.` setting becomes a setting of the configuration with the prefix `spark.hadoop.` removed for the key.

The value of `spark.buffer.size` (default: `65536`) is used as the value of `io.file.buffer.size`.

== [[listenerBus]] `listenerBus` -- `LiveListenerBus` Event Bus

`listenerBus` is a scheduler:LiveListenerBus.md[] object that acts as a mechanism to announce events to other services on the spark-driver.md[driver].

`LiveListenerBus` is created and started when `SparkContext` is created and, since it is a single-JVM event bus, is exclusively used on the driver.

== [[startTime]] Time when SparkContext was Created -- `startTime` Property

[source, scala]
----
startTime: Long
----

`startTime` is the time in milliseconds when <<creating-instance, SparkContext was created>>.

[source, scala]
----
scala> sc.startTime
res0: Long = 1464425605653
----

== [[submitMapStage]] Submitting `ShuffleDependency` for Execution -- `submitMapStage` Internal Method

[source, scala]
----
submitMapStage[K, V, C](
  dependency: ShuffleDependency[K, V, C]): SimpleFutureAction[MapOutputStatistics]
----

`submitMapStage` scheduler:DAGScheduler.md#submitMapStage[submits the input `ShuffleDependency` to `DAGScheduler` for execution] and returns a `SimpleFutureAction`.

Internally, `submitMapStage` <<getCallSite, calculates the call site>> first and submits it with `localProperties`.

NOTE: Interestingly, `submitMapStage` is used exclusively when Spark SQL's spark-sql-SparkPlan-ShuffleExchange.md[ShuffleExchange] physical operator is executed.

NOTE: `submitMapStage` _seems_ related to scheduler:DAGScheduler.md#adaptive-query-planning[Adaptive Query Planning / Adaptive Scheduling].

== [[cancelJobGroup]] Cancelling Job Group -- `cancelJobGroup` Method

[source, scala]
----
cancelJobGroup(groupId: String)
----

`cancelJobGroup` requests `DAGScheduler` scheduler:DAGScheduler.md#cancelJobGroup[to cancel a group of active Spark jobs].

NOTE: `cancelJobGroup` is used exclusively when `SparkExecuteStatementOperation` does `cancel`.

== [[cancelAllJobs]] Cancelling All Running and Scheduled Jobs -- `cancelAllJobs` Method

CAUTION: FIXME

NOTE: `cancelAllJobs` is used when spark-shell.md[spark-shell] is terminated (e.g. using Ctrl+C, so it can in turn terminate all active Spark jobs) or `SparkSQLCLIDriver` is terminated.

== [[cleaner]] ContextCleaner

[source, scala]
----
cleaner: Option[ContextCleaner]
----

SparkContext may have a core:ContextCleaner.md[ContextCleaner] defined.

`ContextCleaner` is created when `SparkContext` is created with configuration-properties.md#spark.cleaner.referenceTracking[spark.cleaner.referenceTracking] configuration property enabled.

== [[getPreferredLocs]] Finding Preferred Locations (Placement Preferences) for RDD Partition

[source, scala]
----
getPreferredLocs(
  rdd: RDD[_],
  partition: Int): Seq[TaskLocation]
----

getPreferredLocs simply scheduler:DAGScheduler.md#getPreferredLocs[requests `DAGScheduler` for the preferred locations for `partition`].

NOTE: Preferred locations of a partition of a RDD are also called *placement preferences* or *locality preferences*.

getPreferredLocs is used in CoalescedRDDPartition, DefaultPartitionCoalescer and PartitionerAwareUnionRDD.

== [[persistRDD]] Registering RDD in persistentRdds Internal Registry -- `persistRDD` Internal Method

[source, scala]
----
persistRDD(rdd: RDD[_]): Unit
----

`persistRDD` registers `rdd` in <<persistentRdds, persistentRdds>> internal registry.

NOTE: `persistRDD` is used exclusively when `RDD` is rdd:index.md#persist-internal[persisted or locally checkpointed].

== [[getRDDStorageInfo]] Getting Storage Status of Cached RDDs (as RDDInfos) -- `getRDDStorageInfo` Methods

[source, scala]
----
getRDDStorageInfo: Array[RDDInfo] // <1>
getRDDStorageInfo(filter: RDD[_] => Boolean): Array[RDDInfo]  // <2>
----
<1> Part of Spark's Developer API that uses <2> filtering no RDDs

`getRDDStorageInfo` takes all the RDDs (from <<persistentRdds, persistentRdds>> registry) that match `filter` and creates a collection of storage:RDDInfo.md[RDDInfo] instances.

`getRDDStorageInfo`...FIXME

In the end, `getRDDStorageInfo` gives only the RDD that are cached (i.e. the sum of memory and disk sizes as well as the number of partitions cached are greater than `0`).

NOTE: `getRDDStorageInfo` is used when `RDD` spark-rdd-lineage.md#toDebugString[is requested for RDD lineage graph].

== [[statusStore]] Accessing AppStatusStore

[source, scala]
----
statusStore: AppStatusStore
----

statusStore gives the current core:AppStatusStore.md[].

statusStore is used when:

* SparkContext is requested to <<getRDDStorageInfo, getRDDStorageInfo>>

* `ConsoleProgressBar` is requested to [refresh](ConsoleProgressBar.md#refresh)

* SharedState (Spark SQL) is requested for a SQLAppStatusStore

== [[uiWebUrl]] Requesting URL of web UI -- `uiWebUrl` Method

[source, scala]
----
uiWebUrl: Option[String]
----

`uiWebUrl` requests the `SparkUI` for [webUrl](webui/WebUI.md#webUrl).

== [[maxNumConcurrentTasks]] `maxNumConcurrentTasks` Method

[source, scala]
----
maxNumConcurrentTasks(): Int
----

`maxNumConcurrentTasks` simply requests the <<schedulerBackend, SchedulerBackend>> for the scheduler:SchedulerBackend.md#maxNumConcurrentTasks[maximum number of tasks that can be launched concurrently].

NOTE: `maxNumConcurrentTasks` is used exclusively when `DAGScheduler` is requested to scheduler:DAGScheduler.md#checkBarrierStageWithNumSlots[checkBarrierStageWithNumSlots].

== [[environment-variables]] Environment Variables

.Environment Variables
[cols="1,1,2",options="header",width="100%"]
|===
| Environment Variable
| Default Value
| Description

| [[SPARK_EXECUTOR_MEMORY]] `SPARK_EXECUTOR_MEMORY`
| `1024`
| Amount of memory to allocate for a Spark executor in  MB.

See executor:Executor.md#memory[Executor Memory].

| [[SPARK_USER]] `SPARK_USER`
|
| The user who is running SparkContext. Available later as <<sparkUser, sparkUser>>.
|===

== [[addJar-internals]] `addJar` Method

[source, scala]
----
addJar(path: String): Unit
----

`addJar`...FIXME

NOTE: `addJar` is used when...FIXME

== [[runApproximateJob]] Running Approximate Job

[source, scala]
----
runApproximateJob[T, U, R](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  evaluator: ApproximateEvaluator[U, R],
  timeout: Long): PartialResult[R]
----

runApproximateJob...FIXME

runApproximateJob is used when:

* DoubleRDDFunctions is requested to meanApprox and sumApprox

* RDD is requested to countApprox and countByValueApprox

== [[killTaskAttempt]] Killing Task

[source, scala]
----
killTaskAttempt(
  taskId: Long,
  interruptThread: Boolean = true,
  reason: String = "killed via SparkContext.killTaskAttempt"): Boolean
----

killTaskAttempt requests the <<dagScheduler, DAGScheduler>> to scheduler:DAGScheduler.md#killTaskAttempt[kill a task].

== [[checkpointFile]] checkpointFile Internal Method

[source, scala]
----
checkpointFile[T: ClassTag](
  path: String): RDD[T]
----

checkpointFile...FIXME

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.SparkContext` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.SparkContext=ALL
----

Refer to spark-logging.md[Logging].

== [[internal-properties]] Internal Properties

=== [[checkpointDir]] Checkpoint Directory

[source,scala]
----
checkpointDir: Option[String] = None
----

checkpointDir is...FIXME

=== [[persistentRdds]] persistentRdds Lookup Table

Lookup table of persistent/cached RDDs per their ids.

Used when SparkContext is requested to:

* <<persistRDD, persistRDD>>
* <<getRDDStorageInfo, getRDDStorageInfo>>
* <<getPersistentRDDs, getPersistentRDDs>>
* <<unpersistRDD, unpersistRDD>>

## <span id="createSparkEnv"> Creating SparkEnv for Driver

```scala
createSparkEnv(
  conf: SparkConf,
  isLocal: Boolean,
  listenerBus: LiveListenerBus): SparkEnv
```

`createSparkEnv` uses the `SparkEnv` utility to [create a SparkEnv for the driver](SparkEnv.md#createDriverEnv) (with the arguments and [numDriverCores](#numDriverCores)).

### <span id="numDriverCores"> numDriverCores

```scala
numDriverCores(
  master: String,
  conf: SparkConf): Int
```

`numDriverCores`...FIXME
