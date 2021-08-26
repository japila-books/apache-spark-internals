# Driver

A *Spark driver* (_aka_ *an application's driver process*) is a JVM process that hosts SparkContext.md[SparkContext] for a Spark application. It is the master node in a Spark application.

It is the cockpit of jobs and tasks execution (using scheduler:DAGScheduler.md[DAGScheduler] and scheduler:TaskScheduler.md[Task Scheduler]). It hosts spark-webui.md[Web UI] for the environment.

.Driver with the services
image::spark-driver.png[align="center"]

It splits a Spark application into tasks and schedules them to run on executors.

A driver is where the task scheduler lives and spawns tasks across workers.

A driver coordinates workers and overall execution of tasks.

NOTE: spark-shell.md[Spark shell] is a Spark application and the driver. It creates a `SparkContext` that is available as `sc`.

Driver requires the additional services (beside the common ones like shuffle:ShuffleManager.md[], memory:MemoryManager.md[], storage:BlockTransferService.md[], [BroadcastManager](broadcast-variables/BroadcastManager.md):

* Listener Bus
* rpc:index.md[]
* scheduler:MapOutputTrackerMaster.md[] with the name *MapOutputTracker*
* storage:BlockManagerMaster.md[] with the name *BlockManagerMaster*
* [MetricsSystem](metrics/MetricsSystem.md) with the name *driver*
* [OutputCommitCoordinator](OutputCommitCoordinator.md)

CAUTION: FIXME Diagram of RpcEnv for a driver (and later executors). Perhaps it should be in the notes about RpcEnv?

* High-level control flow of work
* Your Spark application runs as long as the Spark driver.
** Once the driver terminates, so does your Spark application.
* Creates `SparkContext`, `RDD`'s, and executes transformations and actions
* Launches scheduler:Task.md[tasks]

=== [[driver-memory]] Driver's Memory

It can be set first using spark-submit.md#command-line-options[spark-submit's `--driver-memory`] command-line option or <<spark_driver_memory, spark.driver.memory>> and falls back to spark-submit.md#environment-variables[SPARK_DRIVER_MEMORY] if not set earlier.

NOTE: It is printed out to the standard error output in spark-submit.md#verbose-mode[spark-submit's verbose mode].

=== [[driver-memory]] Driver's Cores

It can be set first using spark-submit.md#driver-cores[spark-submit's `--driver-cores`] command-line option for spark-deploy-mode.md#cluster[`cluster` deploy mode].

NOTE: In spark-deploy-mode.md#client[`client` deploy mode] the driver's memory corresponds to the memory of the JVM process the Spark application runs on.

NOTE: It is printed out to the standard error output in spark-submit.md#verbose-mode[spark-submit's verbose mode].

=== [[settings]] Settings

.Spark Properties
[cols="1,1,2",options="header",width="100%"]
|===
| Spark Property | Default Value | Description
| [[spark_driver_blockManager_port]] `spark.driver.blockManager.port` | storage:BlockManager.md#spark_blockManager_port[spark.blockManager.port] | Port to use for the storage:BlockManager.md[BlockManager] on the driver.

More precisely, `spark.driver.blockManager.port` is used when core:SparkEnv.md#NettyBlockTransferService[`NettyBlockTransferService` is created] (while `SparkEnv` is created for the driver).

| [[spark_driver_memory]] `spark.driver.memory` | `1g` | The driver's memory size (in MiBs).

Refer to <<driver-memory, Driver's Memory>>.

| [[spark_driver_cores]] `spark.driver.cores` | `1` | The number of CPU cores assigned to the driver in spark-deploy-mode.md#cluster[cluster deploy mode].

NOTE: When yarn/spark-yarn-client.md#creating-instance[Client is created] (for Spark on YARN in cluster mode only), it sets the number of cores for `ApplicationManager` using `spark.driver.cores`.

Refer to <<driver-cores, Driver's Cores>>.

| [[spark_driver_extraLibraryPath]] `spark.driver.extraLibraryPath` | |

| [[spark_driver_extraJavaOptions]] `spark.driver.extraJavaOptions` | | Additional JVM options for the driver.

| [[spark.driver.appUIAddress]] spark.driver.appUIAddress

`spark.driver.appUIAddress` is used exclusively in yarn/README.md[Spark on YARN]. It is set when yarn/spark-yarn-client-yarnclientschedulerbackend.md#start[YarnClientSchedulerBackend starts] to yarn/spark-yarn-applicationmaster.md#runExecutorLauncher[run ExecutorLauncher] (and yarn/spark-yarn-applicationmaster.md#registerAM[register ApplicationMaster] for the Spark application).

| [[spark_driver_libraryPath]] `spark.driver.libraryPath` | |

|===

==== [[spark_driver_extraClassPath]] spark.driver.extraClassPath

`spark.driver.extraClassPath` system property sets the additional classpath entries (e.g. jars and directories) that should be added to the driver's classpath in spark-deploy-mode.md#cluster[`cluster` deploy mode].

[NOTE]
====
For spark-deploy-mode.md#client[`client` deploy mode] you can use a properties file or command line to set `spark.driver.extraClassPath`.

Do not use SparkConf.md[SparkConf] since it is too late for `client` deploy mode given the JVM has already been set up to start a Spark application.

Refer to spark-class.md#buildSparkSubmitCommand[`buildSparkSubmitCommand` Internal Method] for the very low-level details of how it is handled internally.
====

`spark.driver.extraClassPath` uses a OS-specific path separator.

NOTE: Use ``spark-submit``'s spark-submit.md#driver-class-path[`--driver-class-path` command-line option] on command line to override `spark.driver.extraClassPath` from a spark-properties.md#spark-defaults-conf[Spark properties file].
