== [[Utils]] Utils Helper Object

`Utils` is a Scala object that...FIXME

=== [[getLocalDir]] `getLocalDir` Method

[source, scala]
----
getLocalDir(conf: SparkConf): String
----

`getLocalDir`...FIXME

[NOTE]
====
`getLocalDir` is used when:

* `Utils` is requested to <<fetchFile, fetchFile>>

* `SparkEnv` is core:SparkEnv.md#create[created] (on the driver)

* spark-shell.md[spark-shell] is launched

* Spark on YARN's `Client` is requested to spark-yarn-client.md#prepareLocalResources[prepareLocalResources] and spark-yarn-client.md#createConfArchive[create ++__spark_conf__.zip++ archive with configuration files and Spark configuration]

* PySpark's  `PythonBroadcast` is requested to `readObject`

* PySpark's  `EvalPythonExec` is requested to `doExecute`
====

=== [[fetchFile]] `fetchFile` Method

[source, scala]
----
fetchFile(
  url: String,
  targetDir: File,
  conf: SparkConf,
  securityMgr: SecurityManager,
  hadoopConf: Configuration,
  timestamp: Long,
  useCache: Boolean): File
----

`fetchFile`...FIXME

[NOTE]
====
`fetchFile` is used when:

* `SparkContext` is requested to SparkContext.md#addFile[addFile]

* `Executor` is requested to executor:Executor.md#updateDependencies[updateDependencies]

* Spark Standalone's `DriverRunner` is requested to `downloadUserJar`
====

=== [[getOrCreateLocalRootDirsImpl]] `getOrCreateLocalRootDirsImpl` Internal Method

[source, scala]
----
getOrCreateLocalRootDirsImpl(conf: SparkConf): Array[String]
----

`getOrCreateLocalRootDirsImpl`...FIXME

NOTE: `getOrCreateLocalRootDirsImpl` is used exclusively when `Utils` is requested to <<getOrCreateLocalRootDirs, getOrCreateLocalRootDirs>>

=== [[getOrCreateLocalRootDirs]] `getOrCreateLocalRootDirs` Internal Method

[source, scala]
----
getOrCreateLocalRootDirs(conf: SparkConf): Array[String]
----

`getOrCreateLocalRootDirs`...FIXME

[NOTE]
====
`getOrCreateLocalRootDirs` is used when:

* `Utils` is requested to <<getLocalDir, getLocalDir>>

* `Worker` is requested to spark-standalone-worker.md#receive[handle a LaunchExecutor message]
====
