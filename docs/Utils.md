# Utils Utility

## <span id="getConfiguredLocalDirs"> Local Directories for Storing Files

```scala
getConfiguredLocalDirs(
  conf: SparkConf): Array[String]
```

`getConfiguredLocalDirs` returns the local directories where Spark can write files to.

Internally, `getConfiguredLocalDirs` uses the given [SparkConf](SparkConf.md) to know if [External Shuffle Service](external-shuffle-service/ExternalShuffleService.md) is enabled (based on [spark.shuffle.service.enabled](external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property).

`getConfiguredLocalDirs` checks if [Spark runs on YARN](#isRunningInYarnContainer) and if so, returns [LOCAL_DIRS](#getYarnLocalDirs)-controlled local directories.

In non-YARN mode (or for the driver in yarn-client mode), `getConfiguredLocalDirs` checks the following environment variables (in the order) and returns the value of the first met:

1. `SPARK_EXECUTOR_DIRS` environment variable
1. `SPARK_LOCAL_DIRS` environment variable
1. `MESOS_DIRECTORY` environment variable (only when External Shuffle Service is not used)

In the end, when no earlier environment variables were found, `getConfiguredLocalDirs` uses the following properties (in the order):

1. [spark.local.dir](configuration-properties.md#spark.local.dir) configuration property
1. `java.io.tmpdir` System property

`getConfiguredLocalDirs` is used when:

* `DiskBlockManager` is requested to [createLocalDirs](storage/DiskBlockManager.md#createLocalDirs)
* `Utils` utility is used to [get a local directory](#getLocalDir) and [getOrCreateLocalRootDirsImpl](#getOrCreateLocalRootDirsImpl)

## <span id="LOCAL_SCHEME"> Local URI Scheme

`Utils` defines a `local` URI scheme for files that are locally available on worker nodes in the cluster.

The `local` URL scheme is used when:

* `Utils` is used to [isLocalUri](#isLocalUri)
* `Client` (Spark on YARN) is used

## <span id="isLocalUri"> isLocalUri

```scala
isLocalUri(
  uri: String): Boolean
```

`isLocalUri` is `true` when the URI is a `local:` URI (the given `uri` starts with [local:](#LOCAL_SCHEME) scheme).

`isLocalUri` is used when:

* FIXME

## <span id="getCurrentUserName"> getCurrentUserName

```scala
getCurrentUserName(): String
```

`getCurrentUserName` computes the user name who has started the SparkContext.md[SparkContext] instance.

NOTE: It is later available as SparkContext.md#sparkUser[SparkContext.sparkUser].

Internally, it reads SparkContext.md#SPARK_USER[SPARK_USER] environment variable and, if not set, reverts to Hadoop Security API's `UserGroupInformation.getCurrentUser().getShortUserName()`.

NOTE: It is another place where Spark relies on Hadoop API for its operation.

## <span id="localHostName"> localHostName

```scala
localHostName(): String
```

`localHostName` computes the local host name.

It starts by checking `SPARK_LOCAL_HOSTNAME` environment variable for the value. If it is not defined, it uses `SPARK_LOCAL_IP` to find the name (using `InetAddress.getByName`). If it is not defined either, it calls `InetAddress.getLocalHost` for the name.

NOTE: `Utils.localHostName` is executed while SparkContext.md#creating-instance[`SparkContext` is created] and also to compute the default value of spark-driver.md#spark_driver_host[spark.driver.host Spark property].

## <span id="getUserJars"> getUserJars

```scala
getUserJars(
  conf: SparkConf): Seq[String]
```

`getUserJars` is the [spark.jars](configuration-properties.md#spark.jars) configuration property with non-empty entries.

`getUserJars` is used when:

* `SparkContext` is [created](SparkContext-creating-instance-internals.md#_jars)

## <span id="extractHostPortFromSparkUrl"> extractHostPortFromSparkUrl

```scala
extractHostPortFromSparkUrl(
  sparkUrl: String): (String, Int)
```

`extractHostPortFromSparkUrl` creates a Java [URI]({{ java.api }}/java.base/java/net/URI.html) with the input `sparkUrl` and takes the host and port parts.

`extractHostPortFromSparkUrl` asserts that the input `sparkURL` uses **spark** scheme.

`extractHostPortFromSparkUrl` throws a `SparkException` for unparseable spark URLs:

```text
Invalid master URL: [sparkUrl]
```

`extractHostPortFromSparkUrl` is used when:

* `StandaloneSubmitRequestServlet` is requested to `buildDriverDescription`
* `RpcAddress` is requested to [extract an RpcAddress from a Spark master URL](rpc/RpcAddress.md#fromSparkURL)

## <span id="isDynamicAllocationEnabled"> isDynamicAllocationEnabled

```scala
isDynamicAllocationEnabled(
  conf: SparkConf): Boolean
```

`isDynamicAllocationEnabled` is `true` when the following hold:

1. [spark.dynamicAllocation.enabled](dynamic-allocation/configuration-properties.md#spark.dynamicAllocation.enabled) configuration property is `true`
1. [spark.master](configuration-properties.md#spark.master) is non-`local`

`isDynamicAllocationEnabled` is used when:

* `SparkContext` is created (to [start an ExecutorAllocationManager](SparkContext-creating-instance-internals.md#ExecutorAllocationManager))
* `DAGScheduler` is requested to [checkBarrierStageWithDynamicAllocation](scheduler/DAGScheduler.md#checkBarrierStageWithDynamicAllocation)
* `SchedulerBackendUtils` is requested to [getInitialTargetExecutorNumber](scheduler/SchedulerBackendUtils.md#getInitialTargetExecutorNumber)
* `StandaloneSchedulerBackend` (Spark Standalone) is requested to `start`
* `ExecutorPodsAllocator` (Spark on Kubernetes) is requested to `onNewSnapshots`
* `ApplicationMaster` (Spark on YARN) is created

## <span id="checkAndGetK8sMasterUrl"> checkAndGetK8sMasterUrl

```scala
checkAndGetK8sMasterUrl(
  rawMasterURL: String): String
```

`checkAndGetK8sMasterUrl`...FIXME

`checkAndGetK8sMasterUrl` is used when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](tools/SparkSubmit.md#prepareSubmitEnvironment) (for Kubernetes cluster manager)

## <span id="getLocalDir"> getLocalDir

```scala
getLocalDir(
  conf: SparkConf): String
```

`getLocalDir`...FIXME

`getLocalDir` is used when:

* `Utils` is requested to <<fetchFile, fetchFile>>

* `SparkEnv` is core:SparkEnv.md#create[created] (on the driver)

* spark-shell.md[spark-shell] is launched

* Spark on YARN's `Client` is requested to spark-yarn-client.md#prepareLocalResources[prepareLocalResources] and spark-yarn-client.md#createConfArchive[create ++__spark_conf__.zip++ archive with configuration files and Spark configuration]

* PySpark's  `PythonBroadcast` is requested to `readObject`

* PySpark's  `EvalPythonExec` is requested to `doExecute`

## <span id="fetchFile"> Fetching File

```scala
fetchFile(
  url: String,
  targetDir: File,
  conf: SparkConf,
  securityMgr: SecurityManager,
  hadoopConf: Configuration,
  timestamp: Long,
  useCache: Boolean): File
```

`fetchFile`...FIXME

`fetchFile` is used when:

* `SparkContext` is requested to SparkContext.md#addFile[addFile]

* `Executor` is requested to executor:Executor.md#updateDependencies[updateDependencies]

* Spark Standalone's `DriverRunner` is requested to `downloadUserJar`

## <span id="getOrCreateLocalRootDirs"> getOrCreateLocalRootDirs

```scala
getOrCreateLocalRootDirs(
  conf: SparkConf): Array[String]
```

`getOrCreateLocalRootDirs`...FIXME

`getOrCreateLocalRootDirs` is used when:

* `Utils` is requested to <<getLocalDir, getLocalDir>>

* `Worker` is requested to spark-standalone-worker.md#receive[handle a LaunchExecutor message]

### <span id="getOrCreateLocalRootDirsImpl"> getOrCreateLocalRootDirsImpl

```scala
getOrCreateLocalRootDirsImpl(
  conf: SparkConf): Array[String]
```

`getOrCreateLocalRootDirsImpl`...FIXME

`getOrCreateLocalRootDirsImpl` is used when `Utils` is requested to [getOrCreateLocalRootDirs](#getOrCreateLocalRootDirs)
