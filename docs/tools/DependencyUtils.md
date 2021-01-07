# DependencyUtils Utilities

## <span id="resolveGlobPaths"> resolveGlobPaths

```scala
resolveGlobPaths(
  paths: String,
  hadoopConf: Configuration): String
```

`resolveGlobPaths`...FIXME

`resolveGlobPaths` is used when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](SparkSubmit.md#prepareSubmitEnvironment)
* `DependencyUtils` is used to [resolveAndDownloadJars](#resolveAndDownloadJars)

## <span id="downloadFile"> downloadFile

```scala
downloadFile(
  path: String,
  targetDir: File,
  sparkConf: SparkConf,
  hadoopConf: Configuration,
  secMgr: SecurityManager): String
```

`downloadFile` resolves the path to a well-formed URI and branches off based on the scheme:

* For `file` and `local` schemes, `downloadFile` returns the input `path`
* For other schemes, `downloadFile`...FIXME

`downloadFile` is used when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](SparkSubmit.md#prepareSubmitEnvironment)
* `DependencyUtils` is used to [downloadFileList](#downloadFileList)

## <span id="downloadFileList"> downloadFileList

```scala
downloadFileList(
  fileList: String,
  targetDir: File,
  sparkConf: SparkConf,
  hadoopConf: Configuration,
  secMgr: SecurityManager): String
```

`downloadFileList`...FIXME

`downloadFileList` is used when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](SparkSubmit.md#prepareSubmitEnvironment)
* `DependencyUtils` is used to [resolveAndDownloadJars](#resolveAndDownloadJars)

## <span id="resolveMavenDependencies"> resolveMavenDependencies

```scala
resolveMavenDependencies(
  packagesExclusions: String,
  packages: String,
  repositories: String,
  ivyRepoPath: String,
  ivySettingsPath: Option[String]): String
```

`resolveMavenDependencies`...FIXME

`resolveMavenDependencies` is used when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](SparkSubmit.md#prepareSubmitEnvironment) (for all resource managers but [Spark Standalone](../spark-standalone/index.md) and Apache Mesos)

## <span id="addJarToClasspath"> Adding Local Jars to ClassLoader

```scala
addJarToClasspath(
  localJar: String,
  loader: MutableURLClassLoader): Unit
```

`addJarToClasspath` adds `file` and `local` jars (as `localJar`) to the `loader` classloader.

`addJarToClasspath` resolves the URI of `localJar`. If the URI is `file` or `local` and the file denoted by `localJar` exists, `localJar` is added to `loader`. Otherwise, the following warning is printed out to the logs:

```text
Warning: Local jar /path/to/fake.jar does not exist, skipping.
```

For all other URIs, the following warning is printed out to the logs:

```text
Warning: Skip remote jar hdfs://fake.jar.
```

!!! note
    `addJarToClasspath` assumes `file` URI when `localJar` has no URI specified, e.g. `/path/to/local.jar`.

## <span id="resolveAndDownloadJars"> resolveAndDownloadJars

```scala
resolveAndDownloadJars(
  jars: String,
  userJar: String,
  sparkConf: SparkConf,
  hadoopConf: Configuration,
  secMgr: SecurityManager): String
```

`resolveAndDownloadJars`...FIXME

`resolveAndDownloadJars` is used when:

* `DriverWrapper` is requested to `setupDependencies` (Spark Standalone cluster mode)
