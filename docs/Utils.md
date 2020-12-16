# Utils Utility

## <span id="isDynamicAllocationEnabled"> isDynamicAllocationEnabled

```scala
isDynamicAllocationEnabled(
  conf: SparkConf): Boolean
```

`isDynamicAllocationEnabled` is `true` when the following hold:

* [spark.dynamicAllocation.enabled](dynamic-allocation/configuration-properties.md#spark.dynamicAllocation.enabled) configuration property is `true`
* Spark application uses non-`local` master URL

`isDynamicAllocationEnabled` is used when:

* `SparkContext` is created (to [start an ExecutorAllocationManager](SparkContext-creating-instance-internals.md#ExecutorAllocationManager))
* `DAGScheduler` is requested to [checkBarrierStageWithDynamicAllocation](scheduler/DAGScheduler.md#checkBarrierStageWithDynamicAllocation)
* `SchedulerBackendUtils` is requested to [getInitialTargetExecutorNumber](scheduler/SchedulerBackendUtils.md#getInitialTargetExecutorNumber)
* `StandaloneSchedulerBackend` (Spark Standalone) is requested to `start`
* `ExecutorPodsAllocator` (Spark on Kubernetes) is requested to [onNewSnapshots](kubernetes/ExecutorPodsAllocator.md#onNewSnapshots)
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

## <span id="fetchFile"> fetchFile

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
