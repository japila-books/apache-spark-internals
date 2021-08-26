# Inside Creating SparkContext

This document describes the internals of what happens when a new `SparkContext` is [created](SparkContext.md#creating-instance).

```text
import org.apache.spark.{SparkConf, SparkContext}

// 1. Create Spark configuration
val conf = new SparkConf()
  .setAppName("SparkMe Application")
  .setMaster("local[*]")

// 2. Create Spark context
val sc = new SparkContext(conf)
```

## <span id="creationSite"> creationSite

```scala
creationSite: CallSite
```

`SparkContext` determines **call site**.

## <span id="assertOnDriver"> assertOnDriver

`SparkContext`...FIXME

## <span id="markPartiallyConstructed"> markPartiallyConstructed

`SparkContext`...FIXME

## <span id="startTime"> startTime

```scala
startTime: Long
```

`SparkContext` records the current time (in ms).

## <span id="stopped"> stopped

```scala
stopped: AtomicBoolean
```

`SparkContext` initializes `stopped` flag to `false`.

## <span id="spark-version"> Printing Out Spark Version

`SparkContext` prints out the following INFO message to the logs:

```text
Running Spark version [SPARK_VERSION]
```

## <span id="sparkUser"> sparkUser

```scala
sparkUser: String
```

`SparkContext` determines **Spark user**.

## <span id="_conf"> SparkConf

```scala
_conf: SparkConf
```

`SparkContext` clones the [SparkConf](#config) and requests it to [validateSettings](SparkConf.md#validateSettings).

## <span id="spark.master"> Enforcing Mandatory Configuration Properties

`SparkContext` asserts that [spark.master](configuration-properties.md#spark.master) and [spark.app.name](configuration-properties.md#spark.app.name) are defined (in the [SparkConf](#config)).

```text
A master URL must be set in your configuration
```

```text
An application name must be set in your configuration
```

## <span id="_driverLogger"> DriverLogger

```scala
_driverLogger: Option[DriverLogger]
```

`SparkContext` creates a `DriverLogger`.

## <span id="ResourceInformation"> ResourceInformation

```scala
_resources: Map[String, ResourceInformation]
```

`SparkContext` uses [spark.driver.resourcesFile](configuration-properties.md#spark.driver.resourcesFile) configuration property to discovery driver resources and prints out the following INFO message to the logs:

```text
==============================================================
Resources for [componentName]:
[resources]
==============================================================
```

## Submitted Application

`SparkContext` prints out the following INFO message to the logs (with the value of [spark.app.name](configuration-properties.md#spark.app.name) configuration property):

```text
Submitted application: [appName]
```

## Spark on YARN and spark.yarn.app.id

For Spark on YARN in cluster deploy mode], `SparkContext` checks whether `spark.yarn.app.id` configuration property is defined. `SparkException` is thrown if it does not exist.

```text
Detected yarn cluster mode, but isn't running on a cluster. Deployment to YARN is not supported directly by SparkContext. Please use spark-submit.
```

## Displaying Spark Configuration

With [spark.logConf](configuration-properties.md#spark.logConf) configuration property enabled, `SparkContext` prints out the following INFO message to the logs:

```text
Spark configuration:
[conf.toDebugString]
```

!!! note
    `SparkConf.toDebugString` is used very early in the initialization process and other settings configured afterwards are not included. Use `SparkContext.getConf.toDebugString` once `SparkContext` is initialized.

## Setting Configuration Properties

* [spark.driver.host](configuration-properties.md#spark.driver.host) to the current value of the property (to override the default)
* [spark.driver.port](configuration-properties.md#spark.driver.port) to `0` unless defined already
* [spark.executor.id](configuration-properties.md#spark.executor.id) to `driver`

## <span id="_jars"> User-Defined Jar Files

```scala
_jars: Seq[String]
```

`SparkContext` sets the `_jars` to [spark.jars](configuration-properties.md#spark.jars) configuration property.

## <span id="_files"> User-Defined Files

```scala
_files: Seq[String]
```

`SparkContext` sets the `_files` to [spark.files](configuration-properties.md#spark.files) configuration property.

## <span id="_eventLogDir"><span id="spark.eventLog.dir"> spark.eventLog.dir

```scala
_eventLogDir: Option[URI]
```

If spark-history-server:EventLoggingListener.md[event logging] is enabled, i.e. EventLoggingListener.md#spark_eventLog_enabled[spark.eventLog.enabled] flag is `true`, the internal field `_eventLogDir` is set to the value of EventLoggingListener.md#spark_eventLog_dir[spark.eventLog.dir] setting or the default value `/tmp/spark-events`.

## <span id="_eventLogCodec"><span id="spark.eventLog.compress"> spark.eventLog.compress

```scala
_eventLogCodec: Option[String]
```

Also, if spark-history-server:EventLoggingListener.md#spark_eventLog_compress[spark.eventLog.compress] is enabled (it is not by default), the short name of the io:CompressionCodec.md[CompressionCodec] is assigned to `_eventLogCodec`. The config key is [spark.io.compression.codec](broadcast-variables/BroadcastManager.md#spark_io_compression_codec) (default: `lz4`).

## <span id="_listenerBus"> Creating LiveListenerBus

```scala
_listenerBus: LiveListenerBus
```

`SparkContext` creates a [LiveListenerBus](scheduler/LiveListenerBus.md).

## <span id="_statusStore"><span id="appStatusSource"> Creating AppStatusStore (and AppStatusSource)

```scala
_statusStore: AppStatusStore
```

`SparkContext` [creates an in-memory store](status/AppStatusStore.md#createLiveStore) (with an optional [AppStatusSource](status/AppStatusSource.md#createSource) if [enabled](metrics/configuration-properties.md#spark.metrics.appStatusSource.enabled)) and requests the [LiveListenerBus](#listenerBus) to register the [AppStatusListener](status/AppStatusStore.md#listener) with the [status queue](scheduler/LiveListenerBus.md#addToStatusQueue).

The `AppStatusStore` is available using the [statusStore](SparkContext.md#statusStore) property of the `SparkContext`.

## <span id="_env"> Creating SparkEnv

```scala
_env: SparkEnv
```

`SparkContext` creates a [SparkEnv](#createSparkEnv) and requests `SparkEnv` to [use the instance as the default SparkEnv](SparkEnv.md#set).

## <span id="spark.repl.class.uri"><span id="spark.repl.class.outputDir"> spark.repl.class.uri

With [spark.repl.class.outputDir](configuration-properties.md#spark.repl.class.outputDir) configuration property defined, `SparkContext` sets [spark.repl.class.uri](configuration-properties.md#spark.repl.class.uri) configuration property to be...FIXME

## <span id="_statusTracker"> Creating SparkStatusTracker

```scala
_statusTracker: SparkStatusTracker
```

`SparkContext` creates a [SparkStatusTracker](SparkStatusTracker.md) (with itself and the [AppStatusStore](#_statusStore)).

## <span id="_progressBar"> Creating ConsoleProgressBar

```scala
_progressBar: Option[ConsoleProgressBar]
```

`SparkContext` creates a [ConsoleProgressBar](ConsoleProgressBar.md) only when [spark.ui.showConsoleProgress](configuration-properties.md#spark.ui.showConsoleProgress) configuration property is enabled.

## <span id="_ui"><span id="ui"> Creating SparkUI

```scala
_ui: Option[SparkUI]
```

`SparkContext` creates a [SparkUI](webui/SparkUI.md#create) only when [spark.ui.enabled](webui/configuration-properties.md#spark.ui.enabled) configuration property is enabled.

`SparkContext` requests the `SparkUI` to [bind](webui/SparkUI.md#bind).

## <span id="_hadoopConfiguration"> Hadoop Configuration

```scala
_hadoopConfiguration: Configuration
```

`SparkContext` creates a new Hadoop `Configuration`.

## <span id="jars"> Adding User-Defined Jar Files

If there are jars given through the `SparkContext` constructor, they are added using `addJar`.

## <span id="files"><span id="addFile"> Adding User-Defined Files

`SparkContext` [adds the files](SparkContext.md#addFile) in [spark.files](configuration-properties.md#spark.files) configuration property.

## <span id="_executorMemory"> _executorMemory

```scala
_executorMemory: Int
```

`SparkContext` determines the amount of memory to allocate to each executor. It is the value of executor:Executor.md#spark.executor.memory[spark.executor.memory] setting, or SparkContext.md#environment-variables[SPARK_EXECUTOR_MEMORY] environment variable (or currently-deprecated `SPARK_MEM`), or defaults to `1024`.

`_executorMemory` is later available as `sc.executorMemory` and used for LOCAL_CLUSTER_REGEX, spark-standalone.md#SparkDeploySchedulerBackend[Spark Standalone's SparkDeploySchedulerBackend], to set `executorEnvs("SPARK_EXECUTOR_MEMORY")`, MesosSchedulerBackend, CoarseMesosSchedulerBackend.

## <span id="SPARK_PREPEND_CLASSES"> SPARK_PREPEND_CLASSES Environment Variable

The value of `SPARK_PREPEND_CLASSES` environment variable is included in `executorEnvs`.

## For Mesos SchedulerBackend Only

The Mesos scheduler backend's configuration is included in `executorEnvs`, i.e. SparkContext.md#environment-variables[SPARK_EXECUTOR_MEMORY], `_conf.getExecutorEnv`, and `SPARK_USER`.

## <span id="_shuffleDriverComponents"> ShuffleDriverComponents

```scala
_shuffleDriverComponents: ShuffleDriverComponents
```

`SparkContext`...FIXME

## <span id="_heartbeatReceiver"> Registering HeartbeatReceiver

`SparkContext` registers [HeartbeatReceiver RPC endpoint](HeartbeatReceiver.md).

## <span id="_plugins"><span id="PluginContainer"> PluginContainer

```scala
_plugins: Option[PluginContainer]
```

`SparkContext` creates a [PluginContainer](plugins/PluginContainer.md) (with itself and the [_resources](#_resources)).

## Creating SchedulerBackend and TaskScheduler

`SparkContext` object is requested to SparkContext.md#createTaskScheduler[create the SchedulerBackend with the TaskScheduler] (for the given master URL) and the result becomes the internal `_schedulerBackend` and `_taskScheduler`.

scheduler:DAGScheduler.md#creating-instance[DAGScheduler is created] (as `_dagScheduler`).

## <span id="TaskSchedulerIsSet"> Sending Blocking TaskSchedulerIsSet

`SparkContext` sends a blocking [`TaskSchedulerIsSet` message to HeartbeatReceiver RPC endpoint](HeartbeatReceiver.md#TaskSchedulerIsSet) (to inform that the `TaskScheduler` is now available).

## <span id="_heartbeater"> Heartbeater

```scala
_heartbeater: Heartbeater
```

`SparkContext` creates a `Heartbeater` and starts it.

## <span id="taskScheduler-start"> Starting TaskScheduler

`SparkContext` requests the [TaskScheduler](#_taskScheduler) to [start](scheduler/TaskScheduler.md#start).

## <span id="_applicationId"><span id="_applicationAttemptId"> Setting Spark Application's and Execution Attempt's IDs

`SparkContext` sets the internal fields -- `_applicationId` and `_applicationAttemptId` -- (using `applicationId` and `applicationAttemptId` methods from the scheduler:TaskScheduler.md#contract[TaskScheduler Contract]).

NOTE: `SparkContext` requests `TaskScheduler` for the scheduler:TaskScheduler.md#applicationId[unique identifier of a Spark application] (that is currently only implemented by scheduler:TaskSchedulerImpl.md#applicationId[TaskSchedulerImpl] that uses `SchedulerBackend` to scheduler:SchedulerBackend.md#applicationId[request the identifier]).

NOTE: The unique identifier of a Spark application is used to initialize spark-webui-SparkUI.md#setAppId[SparkUI] and storage:BlockManager.md#initialize[BlockManager].

NOTE: `_applicationAttemptId` is used when `SparkContext` is requested for the SparkContext.md#applicationAttemptId[unique identifier of execution attempt of a Spark application] and when `EventLoggingListener` spark-history-server:EventLoggingListener.md#creating-instance[is created].

## <span id="spark.app.id"> Setting spark.app.id Spark Property in SparkConf

`SparkContext` sets SparkConf.md#spark.app.id[spark.app.id] property to be the <<_applicationId, unique identifier of a Spark application>> and, if enabled, spark-webui-SparkUI.md#setAppId[passes it on to `SparkUI`].

## <span id="spark.ui.proxyBase"> spark.ui.proxyBase

## Initializing SparkUI

`SparkContext` requests the [SparkUI](#_ui) (if defined) to [setAppId](webui/SparkUI.md#setAppId) with the [_applicationId](#_applicationId).

## Initializing BlockManager

The storage:BlockManager.md#initialize[BlockManager (for the driver) is initialized] (with `_applicationId`).

## Starting MetricsSystem

`SparkContext` requests the `MetricsSystem` to [start](metrics/MetricsSystem.md#start).

NOTE: `SparkContext` starts `MetricsSystem` after <<spark.app.id, setting spark.app.id Spark property>> as `MetricsSystem` uses it to [build unique identifiers fo metrics sources](metrics/MetricsSystem.md#buildRegistryName).

## Attaching JSON Servlet Handler

`SparkContext` requests the `MetricsSystem` for a [JSON servlet handler](metrics/MetricsSystem.md#getServletHandlers) and requests the <<_ui, SparkUI>> to spark-webui-WebUI.md#attachHandler[attach it].

## <span id="_eventLogger"> Starting EventLoggingListener (with Event Log Enabled)

```scala
_eventLogger: Option[EventLoggingListener]
```

With [spark.eventLog.enabled](history-server/configuration-properties.md#spark.eventLog.enabled) configuration property enabled, `SparkContext` creates an [EventLoggingListener](history-server/EventLoggingListener.md) and requests it to [start](history-server/EventLoggingListener.md#start).

`SparkContext` requests the [LiveListenerBus](#listenerBus) to [add](scheduler/LiveListenerBus.md#addToEventLogQueue) the `EventLoggingListener` to `eventLog` event queue.

With `spark.eventLog.enabled` disabled, `_eventLogger` is `None` (undefined).

## <span id="_cleaner"><span id="ContextCleaner"> ContextCleaner

```scala
_cleaner: Option[ContextCleaner]
```

With [spark.cleaner.referenceTracking](configuration-properties.md#spark.cleaner.referenceTracking) configuration property enabled, `SparkContext` creates a [ContextCleaner](core/ContextCleaner.md) (with itself and the [_shuffleDriverComponents](#_shuffleDriverComponents)).

`SparkContext` requests the `ContextCleaner` to [start](core/ContextCleaner.md#start)

## <span id="ExecutorAllocationManager"><span id="_executorAllocationManager"> ExecutorAllocationManager

```scala
_executorAllocationManager: Option[ExecutorAllocationManager]
```

`SparkContext` initializes `_executorAllocationManager` internal registry.

`SparkContext` creates an [ExecutorAllocationManager](dynamic-allocation/ExecutorAllocationManager.md) when:

* [Dynamic Allocation of Executors](dynamic-allocation/index.md) is enabled (based on [spark.dynamicAllocation.enabled](Utils.md#isDynamicAllocationEnabled) configuration property and the master URL)

* [SchedulerBackend](SparkContext.md#schedulerBackend) is an [ExecutorAllocationClient](dynamic-allocation/ExecutorAllocationClient.md)

The `ExecutorAllocationManager` is requested to [start](dynamic-allocation/ExecutorAllocationManager.md#start).

## Registering User-Defined SparkListeners

`SparkContext` [registers user-defined listeners and starts `SparkListenerEvent` event delivery to the listeners](#setupAndStartListenerBus).

## <span id="postEnvironmentUpdate"> postEnvironmentUpdate

`postEnvironmentUpdate` is called that posts SparkListener.md#SparkListenerEnvironmentUpdate[SparkListenerEnvironmentUpdate] message on scheduler:LiveListenerBus.md[] with information about Task Scheduler's scheduling mode, added jar and file paths, and other environmental details.

## <span id="postApplicationStart"> postApplicationStart

SparkListener.md#SparkListenerApplicationStart[SparkListenerApplicationStart] message is posted to scheduler:LiveListenerBus.md[] (using the internal `postApplicationStart` method).

## <span id="postStartHook"> postStartHook

`TaskScheduler` scheduler:TaskScheduler.md#postStartHook[is notified that `SparkContext` is almost fully initialized].

NOTE: scheduler:TaskScheduler.md#postStartHook[TaskScheduler.postStartHook] does nothing by default, but custom implementations offer more advanced features, i.e. `TaskSchedulerImpl` scheduler:TaskSchedulerImpl.md#postStartHook[blocks the current thread until `SchedulerBackend` is ready]. There is also `YarnClusterScheduler` for Spark on YARN in `cluster` deploy mode.

## Registering Metrics Sources

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

## <span id="nextShuffleId"><span id="nextRddId"> Initializing nextShuffleId and nextRddId Internal Counters

`nextShuffleId` and `nextRddId` start with `0`.

CAUTION: FIXME Where are `nextShuffleId` and `nextRddId` used?

A new instance of Spark context is created and ready for operation.

## <span id="getClusterManager"> Loading External Cluster Manager for URL (getClusterManager method)

```scala
getClusterManager(
  url: String): Option[ExternalClusterManager]
```

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

!!! tip
    Set `INFO` logging level for `org.apache.spark.SparkContext` logger to see the extra listeners being registered.

    ```text
    Registered listener pl.japila.spark.CustomSparkListener
    ```
