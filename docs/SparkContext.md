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

## <span id="getClusterManager"> Finding ExternalClusterManager for Master URL

```scala
getClusterManager(
  url: String): Option[ExternalClusterManager]
```

`getClusterManager`...FIXME

`getClusterManager` is used when `SparkContext` is requested for a [SchedulerBackend and TaskScheduler](#createTaskScheduler).

## Old Information

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
** spark-sparkcontext-local-properties.md[Local Properties -- Creating Logical Job Groups]
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

== [[addFile]] addFile Method

[source, scala]
----
addFile(
  path: String): Unit // <1>
addFile(
  path: String,
  recursive: Boolean): Unit
----
<1> `recursive` flag is off

`addFile` adds the `path` file to be downloaded...FIXME

== [[unpersistRDD]] Removing RDD Blocks from BlockManagerMaster -- `unpersistRDD` Internal Method

[source, scala]
----
unpersistRDD(rddId: Int, blocking: Boolean = true): Unit
----

`unpersistRDD` requests `BlockManagerMaster` to storage:BlockManagerMaster.md#removeRdd[remove the blocks for the RDD] (given `rddId`).

NOTE: `unpersistRDD` uses `SparkEnv` core:SparkEnv.md#blockManager[to access the current `BlockManager`] that is in turn used to storage:BlockManager.md#master[access the current `BlockManagerMaster`].

`unpersistRDD` removes `rddId` from <<persistentRdds, persistentRdds>> registry.

In the end, `unpersistRDD` posts a ROOT:SparkListener.md#SparkListenerUnpersistRDD[SparkListenerUnpersistRDD] (with `rddId`) to <<listenerBus, LiveListenerBus Event Bus>>.

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

== [[dynamic-allocation]] Programmable Dynamic Allocation

SparkContext offers the following methods as the developer API for ROOT:spark-dynamic-allocation.md[]:

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

```
WARN Requesting executors is only supported in coarse-grained mode
```

=== [[getExecutorIds]] Getting Executor Ids -- `getExecutorIds` Method

`getExecutorIds` is a `private[spark]` method that is part of spark-service-ExecutorAllocationClient.md[ExecutorAllocationClient contract]. It simply scheduler:CoarseGrainedSchedulerBackend.md#getExecutorIds[passes the call on to the current coarse-grained scheduler backend, i.e. calls `getExecutorIds`].

NOTE: It works for scheduler:CoarseGrainedSchedulerBackend.md[coarse-grained scheduler backends] only.

When called for other scheduler backends you should see the following WARN message in the logs:

```
WARN Requesting executors is only supported in coarse-grained mode
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
INFO SparkContext: Running Spark version 2.0.0-SNAPSHOT
```

NOTE: Only one SparkContext may be running in a single JVM (check out https://issues.apache.org/jira/browse/SPARK-2243[SPARK-2243 Support multiple SparkContexts in the same JVM]). Sharing access to a SparkContext in the JVM is the solution to share data within Spark (without relying on other means of data sharing using external data stores).

== [[env]] Accessing Current SparkEnv -- `env` Method

CAUTION: FIXME

== [[getConf]] Getting Current SparkConf -- `getConf` Method

[source, scala]
----
getConf: SparkConf
----

`getConf` returns the current ROOT:SparkConf.md[SparkConf].

NOTE: Changing the `SparkConf` object does not change the current configuration (as the method returns a copy).

== [[master]][[master-url]] Deployment Environment -- `master` Method

[source, scala]
----
master: String
----

`master` method returns the current value of ROOT:configuration-properties.md#spark.master[spark.master] which is the spark-deployment-environments.md[deployment environment] in use.

== [[appName]] Application Name -- `appName` Method

[source, scala]
----
appName: String
----

`appName` gives the value of the mandatory ROOT:SparkConf.md#spark.app.name[spark.app.name] setting.

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

[NOTE]
====
`getExecutorStorageStatus` is used when:

* SparkContext <<getRDDStorageInfo, is requested for storage status of cached RDDs>>

* `SparkStatusTracker` spark-sparkcontext-SparkStatusTracker.md#getExecutorInfos[is requested for information about all known executors]
====

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

`defaultParallelism` is also used to instantiate rdd:HashPartitioner.md[HashPartitioner] and for the minimum number of partitions in rdd:spark-rdd-HadoopRDD.md[HadoopRDDs].
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

It cleans the `processPartition` input function argument and returns an instance of spark-rdd-actions.md#FutureAction[SimpleFutureAction] that holds the scheduler:spark-scheduler-JobWaiter.md[JobWaiter] instance.

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
image::diagrams/sparkcontext-rdds.png[align="center"]

== [[creating-rdds]][[parallelize]] Creating RDD -- `parallelize` Method

SparkContext allows you to create many different RDDs from input sources like:

* Scala's collections, i.e. `sc.parallelize(0 to 100)`
* local or remote filesystems, i.e. `sc.textFile("README.md")`
* Any Hadoop `InputSource` using `sc.newAPIHadoopFile`

Read rdd:index.md#creating-rdds[Creating RDDs] in rdd:index.md[RDD - Resilient Distributed Dataset].

== [[unpersist]] Unpersisting RDD (Marking RDD as Non-Persistent) -- `unpersist` Method

CAUTION: FIXME

`unpersist` removes an RDD from the master's storage:BlockManager.md[Block Manager] (calls `removeRdd(rddId: Int, blocking: Boolean)`) and the internal <<persistentRdds, persistentRdds>> mapping.

It finally posts ROOT:SparkListener.md#SparkListenerUnpersistRDD[SparkListenerUnpersistRDD] message to `listenerBus`.

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

`register` registers the `acc` spark-accumulators.md[accumulator]. You can optionally give an accumulator a `name`.

TIP: You can create built-in accumulators for longs, doubles, and collection types using <<creating-accumulators, specialized methods>>.

Internally, `register` spark-accumulators.md#register[registers `acc` accumulator] (with the current SparkContext).

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

You can use `longAccumulator`, `doubleAccumulator` or `collectionAccumulator` to create and register spark-accumulators.md[accumulators] for simple and collection values.

`longAccumulator` returns spark-accumulators.md#LongAccumulator[LongAccumulator] with the zero value `0`.

`doubleAccumulator` returns spark-accumulators.md#DoubleAccumulator[DoubleAccumulator] with the zero value `0.0`.

`collectionAccumulator` returns spark-accumulators.md#CollectionAccumulator[CollectionAccumulator] with the zero value `java.util.List[T]`.

[source, scala]
----
scala> val acc = sc.longAccumulator
acc: org.apache.spark.util.LongAccumulator = LongAccumulator(id: 0, name: None, value: 0)

scala> val counter = sc.longAccumulator("counter")
counter: org.apache.spark.util.LongAccumulator = LongAccumulator(id: 1, name: Some(counter), value: 0)

scala> counter.value
res0: Long = 0

scala> sc.parallelize(0 to 9).foreach(n => counter.add(n))

scala> counter.value
res3: Long = 45
----

The `name` input parameter allows you to give a name to an accumulator and have it displayed in spark-webui-StagePage.md#accumulators[Spark UI] (under Stages tab for a given stage).

.Accumulators in the Spark UI
image::spark-webui-accumulators.png[align="center"]

TIP: You can register custom accumulators using <<register, register>> methods.

== [[broadcast]] Creating Broadcast Variable -- broadcast Method

[source, scala]
----
broadcast[T](
  value: T): Broadcast[T]
----

broadcast method creates a ROOT:Broadcast.md[]. It is a shared memory with `value` (as broadcast blocks) on the driver and later on all Spark executors.

[source,plaintext]
----
val sc: SparkContext = ???
scala> val hello = sc.broadcast("hello")
hello: org.apache.spark.broadcast.Broadcast[String] = Broadcast(0)
----

Spark transfers the value to Spark executors _once_, and tasks can share it without incurring repetitive network transmissions when the broadcast variable is used multiple times.

.Broadcasting a value to executors
image::sparkcontext-broadcast-executors.png[align="center"]

Internally, broadcast requests BroadcastManager for a core:BroadcastManager.md#newBroadcast[new broadcast variable].

NOTE: The current `BroadcastManager` is available using core:SparkEnv.md#broadcastManager[`SparkEnv.broadcastManager`] attribute and is always core:BroadcastManager.md[BroadcastManager] (with few internal configuration changes to reflect where it runs, i.e. inside the driver or executors).

You should see the following INFO message in the logs:

```
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

Once created, the broadcast variable (and other blocks) are displayed per executor and the driver in web UI (under spark-webui-executors.md[Executors tab]).

.Broadcast Variables In web UI's Executors Tab
image::spark-broadcast-webui-executors-rdd-blocks.png[align="center"]

== [[jars]] Distribute JARs to workers

The jar you specify with `SparkContext.addJar` will be copied to all the worker nodes.

The configuration setting `spark.jars` is a comma-separated list of jar paths to be included in all tasks executed from this SparkContext. A path can either be a local file, a file in HDFS (or other Hadoop-supported filesystems), an HTTP, HTTPS or FTP URI, or `local:/path` for a file on every worker node.

```
scala> sc.addJar("build.sbt")
15/11/11 21:54:54 INFO SparkContext: Added JAR build.sbt at http://192.168.1.4:49427/jars/build.sbt with timestamp 1447275294457
```

CAUTION: FIXME Why is HttpFileServer used for addJar?

=== SparkContext as Application-Wide Counter

SparkContext keeps track of:

[[nextShuffleId]]
* shuffle ids using `nextShuffleId` internal counter for scheduler:ShuffleMapStage.md[registering shuffle dependencies] to shuffle:ShuffleManager.md[Shuffle Service].

== [[runJob]] Running Job Synchronously

rdd:index.md#actions[RDD actions] run spark-scheduler-ActiveJob.md[jobs] using one of `runJob` methods.

[source, scala]
----
runJob[T, U](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int],
  resultHandler: (Int, U) => Unit): Unit
runJob[T, U](
  rdd: RDD[T],
  func: (TaskContext, Iterator[T]) => U,
  partitions: Seq[Int]): Array[U]
runJob[T, U](
  rdd: RDD[T],
  func: Iterator[T] => U,
  partitions: Seq[Int]): Array[U]
runJob[T, U](rdd: RDD[T], func: (TaskContext, Iterator[T]) => U): Array[U]
runJob[T, U](rdd: RDD[T], func: Iterator[T] => U): Array[U]
runJob[T, U](
  rdd: RDD[T],
  processPartition: (TaskContext, Iterator[T]) => U,
  resultHandler: (Int, U) => Unit)
runJob[T, U: ClassTag](
  rdd: RDD[T],
  processPartition: Iterator[T] => U,
  resultHandler: (Int, U) => Unit)
----

`runJob` executes a function on one or many partitions of a RDD (in a SparkContext space) to produce a collection of values per partition.

NOTE: `runJob` can only work when a SparkContext is _not_ <<stop, stopped>>.

Internally, `runJob` first makes sure that the SparkContext is not <<stop, stopped>>. If it is, you should see the following `IllegalStateException` exception in the logs:

```
java.lang.IllegalStateException: SparkContext has been shutdown
  at org.apache.spark.SparkContext.runJob(SparkContext.scala:1893)
  at org.apache.spark.SparkContext.runJob(SparkContext.scala:1914)
  at org.apache.spark.SparkContext.runJob(SparkContext.scala:1934)
  ... 48 elided
```

`runJob` then <<getCallSite, calculates the call site>> and <<clean, cleans a `func` closure>>.

You should see the following INFO message in the logs:

```
INFO SparkContext: Starting job: [callSite]
```

With spark-rdd-lineage.md#spark_logLineage[spark.logLineage] enabled (which is not by default), you should see the following INFO message with spark-rdd-lineage.md#toDebugString[toDebugString] (executed on `rdd`):

```
INFO SparkContext: RDD's recursive dependencies:
[toDebugString]
```

`runJob` requests  scheduler:DAGScheduler.md#runJob[`DAGScheduler` to run a job].

TIP: `runJob` just prepares input parameters for scheduler:DAGScheduler.md#runJob[`DAGScheduler` to run a job].

After `DAGScheduler` is done and the job has finished, `runJob` spark-sparkcontext-ConsoleProgressBar.md#finishAll[stops `ConsoleProgressBar`] and ROOT:rdd-checkpointing.md#doCheckpoint[performs RDD checkpointing of `rdd`].

TIP: For some actions, e.g. `first()` and `lookup()`, there is no need to compute all the partitions of the RDD in a job. And Spark knows it.

[source,scala]
----
// RDD to work with
val lines = sc.parallelize(Seq("hello world", "nice to see you"))

import org.apache.spark.TaskContext
scala> sc.runJob(lines, (t: TaskContext, i: Iterator[String]) => 1) // <1>
res0: Array[Int] = Array(1, 1)  // <2>
----
<1> Run a job using `runJob` on `lines` RDD with a function that returns 1 for every partition (of `lines` RDD).
<2> What can you say about the number of partitions of the `lines` RDD? Is your result `res0` different than mine? Why?

TIP: Read spark-TaskContext.md[TaskContext].

Running a job is essentially executing a `func` function on all or a subset of partitions in an `rdd` RDD and returning the result as an array (with elements being the results per partition).

.Executing action
image::spark-runjob.png[align="center"]

== [[stop]][[stopping]] Stopping SparkContext -- `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` stops the SparkContext.

Internally, `stop` enables `stopped` internal flag. If already stopped, you should see the following INFO message in the logs:

```
INFO SparkContext: SparkContext already stopped.
```

`stop` then does the following:

1. Removes `_shutdownHookRef` from `ShutdownHookManager`
2. <<postApplicationEnd, Posts a `SparkListenerApplicationEnd`>> (to <<listenerBus, LiveListenerBus Event Bus>>)
3. spark-webui-SparkUI.md#stop[Stops web UI]
4. spark-metrics-MetricsSystem.md#report[Requests `MetricSystem` to report metrics] (from all registered sinks)
5. core:ContextCleaner.md#stop[Stops `ContextCleaner`]
6. spark-ExecutorAllocationManager.md#stop[Requests `ExecutorAllocationManager` to stop]
7. If `LiveListenerBus` was started, scheduler:LiveListenerBus.md#stop[requests `LiveListenerBus` to stop]
8. Requests spark-history-server:EventLoggingListener.md#stop[`EventLoggingListener` to stop]
9. Requests scheduler:DAGScheduler.md#stop[`DAGScheduler` to stop]
10. Requests rpc:index.md#stop[RpcEnv to stop `HeartbeatReceiver` endpoint]
11. Requests spark-sparkcontext-ConsoleProgressBar.md#stop[`ConsoleProgressBar` to stop]
12. Clears the reference to `TaskScheduler`, i.e. `_taskScheduler` is `null`
13. Requests core:SparkEnv.md#stop[`SparkEnv` to stop] and clears `SparkEnv`
14. Clears yarn/spark-yarn-client.md#SPARK_YARN_MODE[`SPARK_YARN_MODE` flag]
15. <<clearActiveContext, Clears an active SparkContext>>

Ultimately, you should see the following INFO message in the logs:

```
INFO SparkContext: Successfully stopped SparkContext
```

== [[addSparkListener]] Registering SparkListener -- `addSparkListener` Method

[source, scala]
----
addSparkListener(listener: SparkListenerInterface): Unit
----

You can register a custom ROOT:SparkListener.md#SparkListenerInterface[SparkListenerInterface] using `addSparkListener` method

NOTE: You can also register custom listeners using ROOT:configuration-properties.md#spark.extraListeners[spark.extraListeners] configuration property.

== [[custom-schedulers]] Custom SchedulerBackend, TaskScheduler and DAGScheduler

By default, SparkContext uses (`private[spark]` class) `org.apache.spark.scheduler.DAGScheduler`, but you can develop your own custom DAGScheduler implementation, and use (`private[spark]`) `SparkContext.dagScheduler_=(ds: DAGScheduler)` method to assign yours.

It is also applicable to `SchedulerBackend` and `TaskScheduler` using `schedulerBackend_=(sb: SchedulerBackend)` and `taskScheduler_=(ts: TaskScheduler)` methods, respectively.

CAUTION: FIXME Make it an advanced exercise.

== [[events]] Events

When a Spark context starts, it triggers ROOT:SparkListener.md#SparkListenerEnvironmentUpdate[SparkListenerEnvironmentUpdate] and ROOT:SparkListener.md#SparkListenerApplicationStart[SparkListenerApplicationStart] messages.

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

== [[clean]][[closure-cleaning]] Closure Cleaning -- `clean` Method

[source, scala]
----
clean(f: F, checkSerializable: Boolean = true): F
----

Every time an action is called, Spark cleans up the closure, i.e. the body of the action, before it is serialized and sent over the wire to executors.

SparkContext comes with `clean(f: F, checkSerializable: Boolean = true)` method that does this. It in turn calls `ClosureCleaner.clean` method.

Not only does `ClosureCleaner.clean` method clean the closure, but also does it transitively, i.e. referenced closures are cleaned transitively.

A closure is considered serializable as long as it does not explicitly reference unserializable objects. It does so by traversing the hierarchy of enclosing closures and null out any references that are not actually used by the starting closure.

[TIP]
====
Enable `DEBUG` logging level for `org.apache.spark.util.ClosureCleaner` logger to see what happens inside the class.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.util.ClosureCleaner=DEBUG
```

Refer to spark-logging.md[Logging].
====

With `DEBUG` logging level you should see the following messages in the logs:

```
+++ Cleaning closure [func] ([func.getClass.getName]) +++
 + declared fields: [declaredFields.size]
     [field]
 ...
+++ closure [func] ([func.getClass.getName]) is now cleaned +++
```

Serialization is verified using a new instance of `Serializer` (as core:SparkEnv.md#closureSerializer[closure Serializer]). Refer to spark-serialization.md[Serialization].

CAUTION: FIXME an example, please.

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

== [[getCallSite]] Calculating Call Site -- `getCallSite` Method

CAUTION: FIXME

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

== [[setJobGroup]] Setting Local Properties to Group Spark Jobs -- `setJobGroup` Method

[source, scala]
----
setJobGroup(
  groupId: String,
  description: String,
  interruptOnCancel: Boolean = false): Unit
----

`setJobGroup` spark-sparkcontext-local-properties.md#setLocalProperty[sets local properties]:

* `spark.jobGroup.id` as `groupId`
* `spark.job.description` as `description`
* `spark.job.interruptOnCancel` as `interruptOnCancel`

[NOTE]
====
`setJobGroup` is used when:

* Spark Thrift Server's `SparkExecuteStatementOperation` runs a query
* Structured Streaming's `StreamExecution` runs batches
====

== [[cleaner]] ContextCleaner

[source, scala]
----
cleaner: Option[ContextCleaner]
----

SparkContext may have a core:ContextCleaner.md[ContextCleaner] defined.

`ContextCleaner` is created when `SparkContext` is created with ROOT:configuration-properties.md#spark.cleaner.referenceTracking[spark.cleaner.referenceTracking] configuration property enabled.

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

`getRDDStorageInfo` then spark-webui-StorageListener.md#StorageUtils.updateRddInfo[updates the RDDInfos] with the <<getExecutorStorageStatus, current status of all BlockManagers>> (in a Spark application).

In the end, `getRDDStorageInfo` gives only the RDD that are cached (i.e. the sum of memory and disk sizes as well as the number of partitions cached are greater than `0`).

NOTE: `getRDDStorageInfo` is used when `RDD` spark-rdd-lineage.md#toDebugString[is requested for RDD lineage graph].

== [[settings]] Settings

=== [[spark.driver.allowMultipleContexts]] spark.driver.allowMultipleContexts

Quoting the scaladoc of  http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.SparkContext[org.apache.spark.SparkContext]:

> Only one SparkContext may be active per JVM. You must `stop()` the active SparkContext before creating a new one.

You can however control the behaviour using `spark.driver.allowMultipleContexts` flag.

It is disabled, i.e. `false`, by default.

If enabled (i.e. `true`), Spark prints the following WARN message to the logs:

```
WARN Multiple running SparkContexts detected in the same JVM!
```

If disabled (default), it will throw an `SparkException` exception:

```
Only one SparkContext may be running in this JVM (see SPARK-2243). To ignore this error, set spark.driver.allowMultipleContexts = true. The currently running SparkContext was created at:
[ctx.creationSite.longForm]
```

When creating an instance of SparkContext, Spark marks the current thread as having it being created (very early in the instantiation process).

CAUTION: It's not guaranteed that Spark will work properly with two or more SparkContexts. Consider the feature a work in progress.

== [[statusStore]] Accessing AppStatusStore

[source, scala]
----
statusStore: AppStatusStore
----

statusStore gives the current core:AppStatusStore.md[].

statusStore is used when:

* SparkContext is requested to <<getRDDStorageInfo, getRDDStorageInfo>>

* ConsoleProgressBar is requested to ROOT:spark-sparkcontext-ConsoleProgressBar.md#refresh[refresh]

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

== [[postEnvironmentUpdate]] Posting SparkListenerEnvironmentUpdate Event

[source, scala]
----
postEnvironmentUpdate(): Unit
----

`postEnvironmentUpdate`...FIXME

`postEnvironmentUpdate` is used when [SparkContext](SparkContext.md) is created, and requested to <<addFile, addFile>> and <<addJar, addJar>>.

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

Refer to ROOT:spark-logging.md[Logging].

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

=== [[stopped]] stopped Flag

Flag that says whether...FIXME (`true`) or not (`false`)

=== [[_taskScheduler]] TaskScheduler

scheduler:TaskScheduler.md[TaskScheduler]