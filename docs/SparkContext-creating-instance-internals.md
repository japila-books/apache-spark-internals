# Inside Creating SparkContext

This document describes what happens when you SparkContext.md#creating-instance[create a new SparkContext].

```text
import org.apache.spark.{SparkConf, SparkContext}

// 1. Create Spark configuration
val conf = new SparkConf()
  .setAppName("SparkMe Application")
  .setMaster("local[*]")  // local mode

// 2. Create Spark context
val sc = new SparkContext(conf)
```

NOTE: The example uses Spark in local/spark-local.md[local mode], but the initialization with spark-cluster.md[the other cluster modes] would follow similar steps.

Creating `SparkContext` instance starts by setting the internal `allowMultipleContexts` field with the value of SparkContext.md#spark.driver.allowMultipleContexts[spark.driver.allowMultipleContexts] and marking this `SparkContext` instance as partially constructed. It makes sure that no other thread is creating a `SparkContext` instance in this JVM. It does so by synchronizing on `SPARK_CONTEXT_CONSTRUCTOR_LOCK` and using the internal atomic reference `activeContext` (that eventually has a fully-created `SparkContext` instance).

[NOTE]
====
The entire code of `SparkContext` that creates a fully-working `SparkContext` instance is between two statements:

[source, scala]
----
SparkContext.markPartiallyConstructed(this, allowMultipleContexts)

// the SparkContext code goes here

SparkContext.setActiveContext(this, allowMultipleContexts)
----
====

SparkContext.md#startTime[startTime] is set to the current time in milliseconds.

<<stopped, stopped>> internal flag is set to `false`.

The very first information printed out is the version of Spark as an INFO message:

```
INFO SparkContext: Running Spark version 2.0.0-SNAPSHOT
```

TIP: You can use SparkContext.md#version[version] method to learn about the current Spark version or `org.apache.spark.SPARK_VERSION` value.

A scheduler:LiveListenerBus.md#creating-instance[LiveListenerBus instance is created] (as `listenerBus`).

[[sparkUser]]
The SparkContext.md#sparkUser[current user name] is computed.

CAUTION: FIXME Where is `sparkUser` used?

It saves the input `SparkConf` (as `_conf`).

CAUTION: FIXME Review `_conf.validateSettings()`

It ensures that the first mandatory setting - `spark.master` is defined. `SparkException` is thrown if not.

```
A master URL must be set in your configuration
```

It ensures that the other mandatory setting - `spark.app.name` is defined. `SparkException` is thrown if not.

```
An application name must be set in your configuration
```

For yarn/spark-yarn-cluster-yarnclusterschedulerbackend.md[Spark on YARN in cluster deploy mode], it checks existence of `spark.yarn.app.id`. `SparkException` is thrown if it does not exist.

```
Detected yarn cluster mode, but isn't running on a cluster. Deployment to YARN is not supported directly by SparkContext. Please use spark-submit.
```

CAUTION: FIXME How to "trigger" the exception? What are the steps?

When `spark.logConf` is enabled SparkConf.md[SparkConf.toDebugString] is called.

NOTE: `SparkConf.toDebugString` is called very early in the initialization process and other settings configured afterwards are not included. Use `sc.getConf.toDebugString` once SparkContext is initialized.

The driver's host and port are set if missing. spark-driver.md#spark_driver_host[spark.driver.host] becomes the value of <<localHostName, Utils.localHostName>> (or an exception is thrown) while spark-driver.md#spark_driver_port[spark.driver.port] is set to `0`.

NOTE: spark-driver.md#spark_driver_host[spark.driver.host] and spark-driver.md#spark_driver_port[spark.driver.port] are expected to be set on the driver. It is later asserted by core:SparkEnv.md#createDriverEnv[SparkEnv].

executor:Executor.md#spark.executor.id[spark.executor.id] setting is set to `driver`.

TIP: Use `sc.getConf.get("spark.executor.id")` to know where the code is executed -- core:SparkEnv.md[driver or executors].

It sets the jars and files based on `spark.jars` and `spark.files`, respectively. These are files that are required for proper task execution on executors.

If spark-history-server:EventLoggingListener.md[event logging] is enabled, i.e. EventLoggingListener.md#spark_eventLog_enabled[spark.eventLog.enabled] flag is `true`, the internal field `_eventLogDir` is set to the value of EventLoggingListener.md#spark_eventLog_dir[spark.eventLog.dir] setting or the default value `/tmp/spark-events`.

[[_eventLogCodec]]
Also, if spark-history-server:EventLoggingListener.md#spark_eventLog_compress[spark.eventLog.compress] is enabled (it is not by default), the short name of the io:CompressionCodec.md[CompressionCodec] is assigned to `_eventLogCodec`. The config key is core:BroadcastManager.md#spark_io_compression_codec[spark.io.compression.codec] (default: `lz4`).

TIP: Read about compression codecs in core:BroadcastManager.md#compression[Compression].

=== [[_listenerBus]] Creating LiveListenerBus

`SparkContext` creates a scheduler:LiveListenerBus.md#creating-instance[LiveListenerBus].

## <span id="_statusStore"> Creating AppStatusStore

`SparkContext` requests `AppStatusStore` to create a core:AppStatusStore.md#createLiveStore[live store] (i.e. the `AppStatusStore` for a live Spark application) and requests <<listenerBus, LiveListenerBus>> to add the core:AppStatusStore.md#listener[AppStatusListener] to the scheduler:LiveListenerBus.md#addToStatusQueue[status queue].

NOTE: The current `AppStatusStore` is available as SparkContext.md#statusStore[statusStore] property of the `SparkContext`.

=== [[_env]] Creating SparkEnv

`SparkContext` creates a <<createSparkEnv, SparkEnv>> and requests `SparkEnv` to core:SparkEnv.md#set[use the instance as the default SparkEnv].

CAUTION: FIXME Describe the following steps.

`MetadataCleaner` is created.

CAUTION: FIXME What's MetadataCleaner?

=== [[_statusTracker]] Creating SparkStatusTracker

`SparkContext` creates a spark-sparkcontext-SparkStatusTracker.md#creating-instance[SparkStatusTracker] (with itself and the <<_statusStore, AppStatusStore>>).

=== [[_progressBar]] Creating ConsoleProgressBar

`SparkContext` creates the optional [ConsoleProgressBar](ConsoleProgressBar.md#creating-instance) when spark-webui-properties.md#spark.ui.showConsoleProgress[spark.ui.showConsoleProgress] property is enabled and the `INFO` logging level for `SparkContext` is disabled.

=== [[_ui]][[ui]] Creating SparkUI

`SparkContext` creates a spark-webui-SparkUI.md#create[SparkUI] when spark-webui-properties.md#spark.ui.enabled[spark.ui.enabled] configuration property is enabled (i.e. `true`) with the following:

* <<_statusStore, AppStatusStore>>

* Name of the Spark application that is exactly the value of SparkConf.md#spark.app.name[spark.app.name] configuration property

* Empty base path

NOTE: spark-webui-properties.md#spark.ui.enabled[spark.ui.enabled] Spark property is assumed enabled when undefined.

CAUTION: FIXME Where's `_ui` used?

A Hadoop configuration is created. See SparkContext.md#hadoopConfiguration[Hadoop Configuration].

[[jars]]
If there are jars given through the SparkContext constructor, they are added using `addJar`.

[[files]]
If there were files specified, they are added using SparkContext.md#addFile[addFile].

At this point in time, the amount of memory to allocate to each executor (as `_executorMemory`) is calculated. It is the value of executor:Executor.md#spark.executor.memory[spark.executor.memory] setting, or SparkContext.md#environment-variables[SPARK_EXECUTOR_MEMORY] environment variable (or currently-deprecated `SPARK_MEM`), or defaults to `1024`.

`_executorMemory` is later available as `sc.executorMemory` and used for LOCAL_CLUSTER_REGEX, spark-standalone.md#SparkDeploySchedulerBackend[Spark Standalone's SparkDeploySchedulerBackend], to set `executorEnvs("SPARK_EXECUTOR_MEMORY")`, MesosSchedulerBackend, CoarseMesosSchedulerBackend.

The value of `SPARK_PREPEND_CLASSES` environment variable is included in `executorEnvs`.

[CAUTION]
====
FIXME

* What's `_executorMemory`?
* What's the unit of the value of `_executorMemory` exactly?
* What are "SPARK_TESTING", "spark.testing"? How do they contribute to `executorEnvs`?
* What's `executorEnvs`?
====

The Mesos scheduler backend's configuration is included in `executorEnvs`, i.e. SparkContext.md#environment-variables[SPARK_EXECUTOR_MEMORY], `_conf.getExecutorEnv`, and `SPARK_USER`.

## <span id="_heartbeatReceiver"> Registering HeartbeatReceiver

`SparkContext` registers [HeartbeatReceiver RPC endpoint](HeartbeatReceiver.md).

`SparkContext` object is requested to SparkContext.md#createTaskScheduler[create the SchedulerBackend with the TaskScheduler] (for the given master URL) and the result becomes the internal `_schedulerBackend` and `_taskScheduler`.

NOTE: The internal `_schedulerBackend` and `_taskScheduler` are used by `schedulerBackend` and `taskScheduler` methods, respectively.

scheduler:DAGScheduler.md#creating-instance[DAGScheduler is created] (as `_dagScheduler`).

## <span id="TaskSchedulerIsSet"> Sending Blocking TaskSchedulerIsSet

`SparkContext` sends a blocking [`TaskSchedulerIsSet` message to HeartbeatReceiver RPC endpoint](HeartbeatReceiver.md#TaskSchedulerIsSet) (to inform that the `TaskScheduler` is now available).

=== [[taskScheduler-start]] Starting TaskScheduler

`SparkContext` scheduler:TaskScheduler.md#start[starts `TaskScheduler`].

=== [[_applicationId]][[_applicationAttemptId]] Setting Spark Application's and Execution Attempt's IDs -- `_applicationId` and `_applicationAttemptId`

`SparkContext` sets the internal fields -- `_applicationId` and `_applicationAttemptId` -- (using `applicationId` and `applicationAttemptId` methods from the scheduler:TaskScheduler.md#contract[TaskScheduler Contract]).

NOTE: `SparkContext` requests `TaskScheduler` for the scheduler:TaskScheduler.md#applicationId[unique identifier of a Spark application] (that is currently only implemented by scheduler:TaskSchedulerImpl.md#applicationId[TaskSchedulerImpl] that uses `SchedulerBackend` to scheduler:SchedulerBackend.md#applicationId[request the identifier]).

NOTE: The unique identifier of a Spark application is used to initialize spark-webui-SparkUI.md#setAppId[SparkUI] and storage:BlockManager.md#initialize[BlockManager].

NOTE: `_applicationAttemptId` is used when `SparkContext` is requested for the SparkContext.md#applicationAttemptId[unique identifier of execution attempt of a Spark application] and when `EventLoggingListener` spark-history-server:EventLoggingListener.md#creating-instance[is created].

=== [[spark.app.id]] Setting spark.app.id Spark Property in SparkConf

`SparkContext` sets SparkConf.md#spark.app.id[spark.app.id] property to be the <<_applicationId, unique identifier of a Spark application>> and, if enabled, spark-webui-SparkUI.md#setAppId[passes it on to `SparkUI`].

=== [[BlockManager-initialization]] Initializing BlockManager

The storage:BlockManager.md#initialize[BlockManager (for the driver) is initialized] (with `_applicationId`).

=== [[MetricsSystem-start]] Starting MetricsSystem

`SparkContext` requests the `MetricsSystem` to [start](metrics/MetricsSystem.md#start).

NOTE: `SparkContext` starts `MetricsSystem` after <<spark.app.id, setting spark.app.id Spark property>> as `MetricsSystem` uses it to [build unique identifiers fo metrics sources](metrics/MetricsSystem.md#buildRegistryName).

## <span id="MetricsSystem-getServletHandlers"> Requesting JSON Servlet Handler

`SparkContext` requests the `MetricsSystem` for a [JSON servlet handler](metrics/MetricsSystem.md#getServletHandlers) and requests the <<_ui, SparkUI>> to spark-webui-WebUI.md#attachHandler[attach it].

## <span id="_eventLogger"> Starting EventLoggingListener (with Event Log Enabled)

```scala
_eventLogger: Option[EventLoggingListener]
```

With [spark.eventLog.enabled](history-server/configuration-properties.md#spark.eventLog.enabled) configuration property enabled, `SparkContext` creates an [EventLoggingListener](history-server/EventLoggingListener.md) and requests it to [start](history-server/EventLoggingListener.md#start).

`SparkContext` requests the [LiveListenerBus](#listenerBus) to [add](scheduler/LiveListenerBus.md#addToEventLogQueue) the `EventLoggingListener` to `eventLog` event queue.

With `spark.eventLog.enabled` disabled, `_eventLogger` is `None` (undefined).

## <span id="ExecutorAllocationManager"> ExecutorAllocationManager

With [Dynamic Allocation of Executors](dynamic-allocation/index.md) enabled, `SparkContext` creates an [ExecutorAllocationManager](dynamic-allocation/ExecutorAllocationManager.md) and requests it to [start](dynamic-allocation/ExecutorAllocationManager.md#start).

## <span id="_cleaner"><span id="ContextCleaner"> ContextCleaner

With [spark.cleaner.referenceTracking](configuration-properties.md#spark.cleaner.referenceTracking) configuration property enabled, `SparkContext` core:ContextCleaner.md#creating-instance[creates `ContextCleaner`] (as `_cleaner`) and core:ContextCleaner.md#start[started] immediately. Otherwise, `_cleaner` is empty.

CAUTION: FIXME It'd be quite useful to have all the properties with their default values in `sc.getConf.toDebugString`, so when a configuration is not included but does change Spark runtime configuration, it should be added to `_conf`.

[[registering_SparkListeners]]
It <<setupAndStartListenerBus, registers user-defined listeners and starts `SparkListenerEvent` event delivery to the listeners>>.

[[postEnvironmentUpdate]]
`postEnvironmentUpdate` is called that posts SparkListener.md#SparkListenerEnvironmentUpdate[SparkListenerEnvironmentUpdate] message on scheduler:LiveListenerBus.md[] with information about Task Scheduler's scheduling mode, added jar and file paths, and other environmental details. They are displayed in web UI's spark-webui-environment.md[Environment tab].

[[postApplicationStart]]
SparkListener.md#SparkListenerApplicationStart[SparkListenerApplicationStart] message is posted to scheduler:LiveListenerBus.md[] (using the internal `postApplicationStart` method).

[[postStartHook]]
`TaskScheduler` scheduler:TaskScheduler.md#postStartHook[is notified that `SparkContext` is almost fully initialized].

NOTE: scheduler:TaskScheduler.md#postStartHook[TaskScheduler.postStartHook] does nothing by default, but custom implementations offer more advanced features, i.e. `TaskSchedulerImpl` scheduler:TaskSchedulerImpl.md#postStartHook[blocks the current thread until `SchedulerBackend` is ready]. There is also `YarnClusterScheduler` for Spark on YARN in `cluster` deploy mode.

## <span id="registerSource"> Registering Metrics Sources

`SparkContext` requests `MetricsSystem` to [register metrics sources](metrics/MetricsSystem.md#registerSource) for the following services:

* [DAGScheduler](scheduler:DAGScheduler.md#metricsSource)
* [BlockManager](storage/BlockManagerSource.md)
* [ExecutorAllocationManager](dynamic-allocation/ExecutorAllocationManager.md#executorAllocationManagerSource)

## <span id="addShutdownHook"> Adding Shutdown Hook

`SparkContext` adds a shutdown hook (using `ShutdownHookManager.addShutdownHook()`).

`SparkContext` prints out the following DEBUG message to the logs:

```text
Adding shutdown hook
```

CAUTION: FIXME ShutdownHookManager.addShutdownHook()

Any non-fatal Exception leads to termination of the Spark context instance.

CAUTION: FIXME What does `NonFatal` represent in Scala?

CAUTION: FIXME Finish me

=== [[nextShuffleId]][[nextRddId]] Initializing nextShuffleId and nextRddId Internal Counters

`nextShuffleId` and `nextRddId` start with `0`.

CAUTION: FIXME Where are `nextShuffleId` and `nextRddId` used?

A new instance of Spark context is created and ready for operation.

=== [[getClusterManager]] Loading External Cluster Manager for URL (getClusterManager method)

[source, scala]
----
getClusterManager(url: String): Option[ExternalClusterManager]
----

`getClusterManager` loads scheduler:ExternalClusterManager.md[] that scheduler:ExternalClusterManager.md#canCreate[can handle the input `url`].

If there are two or more external cluster managers that could handle `url`, a `SparkException` is thrown:

```
Multiple Cluster Managers ([serviceLoaders]) registered for the url [url].
```

NOTE: `getClusterManager` uses Java's ++https://docs.oracle.com/javase/8/docs/api/java/util/ServiceLoader.html#load-java.lang.Class-java.lang.ClassLoader-++[ServiceLoader.load] method.

NOTE: `getClusterManager` is used to find a cluster manager for a master URL when SparkContext.md#createTaskScheduler[creating a `SchedulerBackend` and a `TaskScheduler` for the driver].

## <span id="setupAndStartListenerBus"> setupAndStartListenerBus

```scala
setupAndStartListenerBus(): Unit
```

`setupAndStartListenerBus` is an internal method that reads configuration-properties.md#spark.extraListeners[spark.extraListeners] configuration property from the current SparkConf.md[SparkConf] to create and register [SparkListenerInterface](SparkListenerInterface.md) listeners.

It expects that the class name represents a `SparkListenerInterface` listener with one of the following constructors (in this order):

* a single-argument constructor that accepts SparkConf.md[SparkConf]
* a zero-argument constructor

`setupAndStartListenerBus` scheduler:LiveListenerBus.md#ListenerBus-addListener[registers every listener class].

You should see the following INFO message in the logs:

```
INFO Registered listener [className]
```

It scheduler:LiveListenerBus.md#start[starts LiveListenerBus] and records it in the internal `_listenerBusStarted`.

When no single-`SparkConf` or zero-argument constructor could be found for a class name in configuration-properties.md#spark.extraListeners[spark.extraListeners] configuration property, a `SparkException` is thrown with the message:

```
[className] did not have a zero-argument constructor or a single-argument constructor that accepts SparkConf. Note: if the class is defined inside of another Scala class, then its constructors may accept an implicit parameter that references the enclosing class; in this case, you must define the listener as a top-level class in order to prevent this extra parameter from breaking Spark's ability to find a valid constructor.
```

Any exception while registering a [SparkListenerInterface](SparkListenerInterface.md) listener [stops the SparkContext](SparkContext.md#stop) and a `SparkException` is thrown and the source exception's message.

```text
Exception when registering SparkListener
```

[TIP]
====
Set `INFO` on `org.apache.spark.SparkContext` logger to see the extra listeners being registered.

```
INFO SparkContext: Registered listener pl.japila.spark.CustomSparkListener
```
====

=== [[createSparkEnv]] Creating SparkEnv for Driver -- `createSparkEnv` Method

[source, scala]
----
createSparkEnv(
  conf: SparkConf,
  isLocal: Boolean,
  listenerBus: LiveListenerBus): SparkEnv
----

`createSparkEnv` simply delegates the call to core:SparkEnv.md#createDriverEnv[SparkEnv to create a `SparkEnv` for the driver].

It calculates the number of cores to `1` for `local` master URL, the number of processors available for JVM for `*` or the exact number in the master URL, or `0` for the cluster master URLs.

=== [[getCurrentUserName]] `Utils.getCurrentUserName` Method

[source, scala]
----
getCurrentUserName(): String
----

`getCurrentUserName` computes the user name who has started the SparkContext.md[SparkContext] instance.

NOTE: It is later available as SparkContext.md#sparkUser[SparkContext.sparkUser].

Internally, it reads SparkContext.md#SPARK_USER[SPARK_USER] environment variable and, if not set, reverts to Hadoop Security API's `UserGroupInformation.getCurrentUser().getShortUserName()`.

NOTE: It is another place where Spark relies on Hadoop API for its operation.

=== [[localHostName]] `Utils.localHostName` Method

`localHostName` computes the local host name.

It starts by checking `SPARK_LOCAL_HOSTNAME` environment variable for the value. If it is not defined, it uses `SPARK_LOCAL_IP` to find the name (using `InetAddress.getByName`). If it is not defined either, it calls `InetAddress.getLocalHost` for the name.

NOTE: `Utils.localHostName` is executed while SparkContext.md#creating-instance[`SparkContext` is created] and also to compute the default value of spark-driver.md#spark_driver_host[spark.driver.host Spark property].

CAUTION: FIXME Review the rest.

=== [[stopped]] `stopped` Flag

CAUTION: FIXME Where is this used?
