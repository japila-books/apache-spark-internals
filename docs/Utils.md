# Utils Utility

## <span id="getConfiguredLocalDirs"> Local Directories for Scratch Space

```scala
getConfiguredLocalDirs(
  conf: SparkConf): Array[String]
```

`getConfiguredLocalDirs` returns the local directories where Spark can write files to.

---

`getConfiguredLocalDirs` uses the given [SparkConf](SparkConf.md) to know if [External Shuffle Service](external-shuffle-service/ExternalShuffleService.md) is enabled or not (based on [spark.shuffle.service.enabled](external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property).

When in a YARN container (`CONTAINER_ID`), `getConfiguredLocalDirs` uses `LOCAL_DIRS` environment variable for YARN-approved local directories.

In non-YARN mode (or for the driver in yarn-client mode), `getConfiguredLocalDirs` checks the following environment variables (in order) and returns the value of the first found:

1. `SPARK_EXECUTOR_DIRS`
1. `SPARK_LOCAL_DIRS`
1. `MESOS_DIRECTORY` (only when External Shuffle Service is not used)

The environment variables are a comma-separated list of local directory paths.

In the end, when no earlier environment variables were found, `getConfiguredLocalDirs` uses [spark.local.dir](configuration-properties.md#spark.local.dir) configuration property (with `java.io.tmpdir` System property as the default value).

---

`getConfiguredLocalDirs` is used when:

* `DiskBlockManager` is requested to [createLocalDirs](storage/DiskBlockManager.md#createLocalDirs) and [createLocalDirsForMergedShuffleBlocks](storage/DiskBlockManager.md#createLocalDirsForMergedShuffleBlocks)
* `Utils` utility is used to [get a single random local root directory](#getLocalDir) and [create a spark directory in every local root directory](#getOrCreateLocalRootDirsImpl)

## <span id="getLocalDir"> Random Local Directory Path

```scala
getLocalDir(
  conf: SparkConf): String
```

`getLocalDir` takes a random directory path out of the [configured local root directories](#getOrCreateLocalRootDirs)

`getLocalDir` throws an `IOException` if no local directory is defined:

```text
Failed to get a temp directory under [[configuredLocalDirs]].
```

`getLocalDir` is used when:

* `SparkEnv` utility is used to [create a base SparkEnv for the driver](SparkEnv.md#create)
* `Utils` utility is used to [fetchFile](#fetchFile)
* `DriverLogger` is [created](DriverLogger.md#localLogFile)
* `RocksDBStateStoreProvider` (Spark Structured Streaming) is requested for a `RocksDB`
* `PythonBroadcast` (PySpark) is requested to `readObject`
* `AggregateInPandasExec` (PySpark) is requested to `doExecute`
* `EvalPythonExec` (PySpark) is requested to `doExecute`
* `WindowInPandasExec` (PySpark) is requested to `doExecute`
* `PythonForeachWriter` (PySpark) is requested for a `UnsafeRowBuffer`
* `Client` (Spark on YARN) is requested to `prepareLocalResources` and `createConfArchive`

## <span id="getOrCreateLocalRootDirs"><span id="localRootDirs"> localRootDirs Registry

`Utils` utility uses `localRootDirs` internal registry so [getOrCreateLocalRootDirsImpl](#getOrCreateLocalRootDirsImpl) is executed just once (when first requested).

`localRootDirs` is available using `getOrCreateLocalRootDirs` method.

```scala
getOrCreateLocalRootDirs(
  conf: SparkConf): Array[String]
```

`getOrCreateLocalRootDirs` is used when:

* `Utils` is used to [getLocalDir](#getLocalDir)
* `Worker` ([Spark Standalone]({{ book.spark_standalone }}/Worker)) is requested to launch an executor

### <span id="getOrCreateLocalRootDirsImpl"> Creating spark Directory in Every Local Root Directory

```scala
getOrCreateLocalRootDirsImpl(
  conf: SparkConf): Array[String]
```

`getOrCreateLocalRootDirsImpl` creates a `spark-[randomUUID]` directory under every [root directory for local storage](#getConfiguredLocalDirs) (and registers a shutdown hook to delete the directories at shutdown).

`getOrCreateLocalRootDirsImpl` prints out the following WARN message to the logs when there is a local root directories as a URI (with a scheme):

```text
The configured local directories are not expected to be URIs;
however, got suspicious values [[uris]].
Please check your configured local directories.
```

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

## <span id="isPushBasedShuffleEnabled"> isPushBasedShuffleEnabled

```scala
isPushBasedShuffleEnabled(
  conf: SparkConf,
  isDriver: Boolean,
  checkSerializer: Boolean = true): Boolean
```

`isPushBasedShuffleEnabled`...FIXME

`isPushBasedShuffleEnabled` is used when:

* `ShuffleDependency` is requested to [canShuffleMergeBeEnabled](rdd/ShuffleDependency.md#canShuffleMergeBeEnabled)
* `MapOutputTrackerMaster` is [created](scheduler/MapOutputTrackerMaster.md#pushBasedShuffleEnabled)
* `MapOutputTrackerWorker` is [created](scheduler/MapOutputTrackerWorker.md#fetchMergeResult)
* `DAGScheduler` is [created](scheduler/DAGScheduler.md#pushBasedShuffleEnabled)
* `ShuffleBlockPusher` utility is used to `BLOCK_PUSHER_POOL`
* `BlockManager` is requested to [initialize](storage/BlockManager.md#initialize) and [registerWithExternalShuffleServer](storage/BlockManager.md#registerWithExternalShuffleServer)
* `BlockManagerMasterEndpoint` is [created](storage/BlockManagerMasterEndpoint.md#pushBasedShuffleEnabled)
* `DiskBlockManager` is requested to [createLocalDirsForMergedShuffleBlocks](storage/DiskBlockManager.md#createLocalDirsForMergedShuffleBlocks)

## Logging

Enable `ALL` logging level for `org.apache.spark.util.Utils` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.util.Utils=ALL
```

Refer to [Logging](spark-logging.md).
