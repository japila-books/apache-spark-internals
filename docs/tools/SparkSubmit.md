# SparkSubmit

`SparkSubmit` is the [entry point](#main) to [spark-submit](spark-submit.md) shell script.

## <span id="shells"><span id="SPARK_SHELL"><span id="SPARKR_SHELL"> Special Primary Resource Names

`SparkSubmit` uses the following special primary resource names to represent Spark shells rather than application jars:

* `spark-shell`
* [pyspark-shell](#PYSPARK_SHELL)
* `sparkr-shell`

### <span id="PYSPARK_SHELL"> pyspark-shell

`SparkSubmit` uses `pyspark-shell` when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](#prepareSubmitEnvironment) for `.py` scripts or `pyspark`, [isShell](#isShell) and [isPython](#isPython)

## <span id="isShell"> isShell

```scala
isShell(
  res: String): Boolean
```

`isShell` is `true` when the given `res` primary resource represents a [Spark shell](#shells).

`isShell` is used when:

* `SparkSubmit` is requested to [prepareSubmitEnvironment](#prepareSubmitEnvironment) and [isUserJar](#isUserJar)
* `SparkSubmitArguments` is requested to [handleUnknown](SparkSubmitArguments.md#handleUnknown) (and determine a primary application resource)

## <span id="actions"> Actions

`SparkSubmit` [executes actions](#doSubmit) (based on the [action](SparkSubmitArguments.md#action) argument).

### <span id="kill"><span id="KILL"> Killing Submission

```scala
kill(
  args: SparkSubmitArguments): Unit
```

`kill`...FIXME

### <span id="printVersion"><span id="PRINT_VERSION"> Displaying Version

```scala
printVersion(): Unit
```

`printVersion`...FIXME

### <span id="requestStatus"><span id="REQUEST_STATUS"> Submission Status

```scala
requestStatus(
  args: SparkSubmitArguments): Unit
```

`requestStatus`...FIXME

### <span id="submit"><span id="SUBMIT"> Submission

```scala
submit(
  args: SparkSubmitArguments,
  uninitLog: Boolean): Unit
```

`submit`...FIXME

#### <span id="runMain"> Running Main Class

```scala
runMain(
  args: SparkSubmitArguments,
  uninitLog: Boolean): Unit
```

`runMain` [prepareSubmitEnvironment](#prepareSubmitEnvironment) with the given [SparkSubmitArguments](SparkSubmitArguments.md) (that gives a 4-element tuple of `childArgs`, `childClasspath`, `sparkConf` and [childMainClass](#childMainClass)).

With [verbose](SparkSubmitArguments.md#verbose) enabled, `runMain` prints out the following INFO messages to the logs:

```text
Main class:
[childMainClass]
Arguments:
[childArgs]
Spark config:
[sparkConf_redacted]
Classpath elements:
[childClasspath]
```

<span id="runMain-getSubmitClassLoader" />
`runMain` creates and sets a context classloader (based on `spark.driver.userClassPathFirst` configuration property) and adds the jars (from `childClasspath`).

<span id="runMain-mainClass" />
`runMain` loads the main class (`childMainClass`).

`runMain` creates a [SparkApplication](SparkApplication.md) (if the main class is a subtype of) or creates a [JavaMainApplication](JavaMainApplication.md) (with the main class).

In the end, `runMain` requests the `SparkApplication` to [start](SparkApplication.md#start) (with the `childArgs` and `sparkConf`).

## <span id="clusterManager"> Cluster Managers

`SparkSubmit` has a built-in support for some cluster managers (that are selected based on the [master](SparkSubmitArguments.md#master) argument).

Nickname | Master URL
---------|------------
<span id="KUBERNETES"> KUBERNETES | `k8s://`-prefix
<span id="LOCAL"> LOCAL | `local`-prefix
<span id="MESOS"> MESOS | `mesos`-prefix
<span id="STANDALONE"> STANDALONE | `spark`-prefix
<span id="YARN"> YARN | `yarn`

## <span id="main"> Launching Standalone Application

```scala
main(
  args: Array[String]): Unit
```

`main`...FIXME

## <span id="doSubmit"> doSubmit

```scala
doSubmit(
  args: Array[String]): Unit
```

`doSubmit`...FIXME

`doSubmit` is used when:

* `InProcessSparkSubmit` standalone application is started
* `SparkSubmit` standalone application is [started](#main)

### <span id="prepareSubmitEnvironment"> prepareSubmitEnvironment

```scala
prepareSubmitEnvironment(
  args: SparkSubmitArguments,
  conf: Option[HadoopConfiguration] = None): (Seq[String], Seq[String], SparkConf, String)
```

`prepareSubmitEnvironment` creates a 4-element tuple made up of the following:

1. `childArgs` for arguments
1. `childClasspath` for Classpath elements
1. `sysProps` for [Spark properties](../spark-properties.md)
1. [childMainClass](#childMainClass)

!!! tip
    Use `--verbose` command-line option to have the elements of the tuple printed out to the standard output.

`prepareSubmitEnvironment`...FIXME

For [isPython](SparkSubmitArguments.md#isPython) in `CLIENT` deploy mode, `prepareSubmitEnvironment` sets the following based on [primaryResource](SparkSubmitArguments.md#primaryResource):

* For [pyspark-shell](#PYSPARK_SHELL) the [mainClass](SparkSubmitArguments.md#mainClass) is `org.apache.spark.api.python.PythonGatewayServer`

* Otherwise, the [mainClass](SparkSubmitArguments.md#mainClass) is `org.apache.spark.deploy.PythonRunner` and the main python file, extra python files and the [childArgs](SparkSubmitArguments.md#childArgs)

`prepareSubmitEnvironment`...FIXME

`prepareSubmitEnvironment` determines the cluster manager based on [master](#clusterManager) argument.

For [KUBERNETES](#KUBERNETES), `prepareSubmitEnvironment` [checkAndGetK8sMasterUrl](../Utils.md#checkAndGetK8sMasterUrl).

`prepareSubmitEnvironment`...FIXME

`prepareSubmitEnvironment` is used when...FIXME

### <span id="childMainClass"> childMainClass

`childMainClass` is the last 4th argument in the result tuple of [prepareSubmitEnvironment](#prepareSubmitEnvironment).

```scala
// (childArgs, childClasspath, sparkConf, childMainClass)
(Seq[String], Seq[String], SparkConf, String)
```

`childMainClass` can be as follows:

Deploy Mode | Master URL | childMainClass
---------|----------|---------
 `client` | any | [mainClass](SparkSubmitArguments.md#mainClass)
<span id="isKubernetesCluster"> `cluster` | [KUBERNETES](#KUBERNETES) | <span id="KUBERNETES_CLUSTER_SUBMIT_CLASS"><span id="KubernetesClientApplication"> `KubernetesClientApplication`
 `cluster` | [MESOS](#MESOS) | [RestSubmissionClientApp](#REST_CLUSTER_SUBMIT_CLASS) (for [REST submission API](SparkSubmitArguments.md#useRest))
 `cluster` | [STANDALONE](#STANDALONE) | <span id="REST_CLUSTER_SUBMIT_CLASS"> `RestSubmissionClientApp` (for [REST submission API](SparkSubmitArguments.md#useRest))
 `cluster` | [STANDALONE](#STANDALONE) | <span id="STANDALONE_CLUSTER_SUBMIT_CLASS"> `ClientApp`
 `cluster` | [YARN](#YARN) | <span id="YARN_CLUSTER_SUBMIT_CLASS"> `YarnClusterApplication`

### <span id="isKubernetesClient"> isKubernetesClient

`prepareSubmitEnvironment` uses `isKubernetesClient` flag to indicate that:

* [Cluster manager](#clusterManager) is [Kubernetes](#KUBERNETES)
* [Deploy mode](#deployMode) is [client](#CLIENT)

### <span id="isKubernetesClusterModeDriver"> isKubernetesClusterModeDriver

`prepareSubmitEnvironment` uses `isKubernetesClusterModeDriver` flag to indicate that:

* [isKubernetesClient](#isKubernetesClient)
* `spark.kubernetes.submitInDriver` configuration property is enabled ([Spark on Kubernetes]({{ book.spark_k8s }}/configuration-properties/#spark.kubernetes.submitInDriver))

### <span id="renameResourcesToLocalFS"> renameResourcesToLocalFS

```scala
renameResourcesToLocalFS(
  resources: String,
  localResources: String): String
```

`renameResourcesToLocalFS`...FIXME

`renameResourcesToLocalFS` is used for [isKubernetesClusterModeDriver](#isKubernetesClusterModeDriver) mode.

### <span id="downloadResource"> downloadResource

```scala
downloadResource(
  resource: String): String
```

`downloadResource`...FIXME

## <span id="isInternal"> Checking Whether Resource is Internal

```scala
isInternal(
  res: String): Boolean
```

`isInternal` is `true` when the given `res` is [spark-internal](SparkLauncher.md#NO_RESOURCE).

`isInternal` is used when:

* `SparkSubmit` is requested to [isUserJar](#isUserJar)
* `SparkSubmitArguments` is requested to [handleUnknown](SparkSubmitArguments.md#handleUnknown)

## <span id="isUserJar"> isUserJar

```scala
isUserJar(
  res: String): Boolean
```

`isUserJar` is `true` when the given `res` is none of the following:

* `isShell`
* [isPython](#isPython)
* [isInternal](#isInternal)
* `isR`

`isUserJar` is used when:

* FIXME

## <span id="isPython"> isPython Utility

```scala
isPython(
  res: String): Boolean
```

`isPython` is `true` when the given `res` primary resource represents a PySpark application:

* `.py` script
* [pyspark-shell](#PYSPARK_SHELL)

`isPython` is used when:

* `SparkSubmit` is requested to [isUserJar](#isUserJar)
* `SparkSubmitArguments` is requested to [handleUnknown](SparkSubmitArguments.md#handleUnknown) (and set `isPython` internal flag)
