# SparkSubmit

`SparkSubmit` is the [entry point](#main) to [spark-submit](spark-submit.md) shell script.

## <span id="clusterManager"> Cluster Managers

`SparkSubmit` has a built-in support for some cluster managers (that are selected based on the [master](SparkSubmitArguments.md#master) argument).

Nickname | master URL
---------|------------
<span id="YARN"> YARN | `yarn`
<span id="STANDALONE"> STANDALONE | `spark`-prefix
<span id="MESOS"> MESOS | `mesos`-prefix
<span id="LOCAL"> LOCAL | `k8s://`-prefix
<span id="KUBERNETES"> KUBERNETES | `local`-prefix

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

### <span id="submit"> submit

```scala
submit(
  args: SparkSubmitArguments,
  uninitLog: Boolean): Unit
```

`submit`...FIXME

### <span id="runMain"> Running Main Class

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

`runMain`...FIXME

<span id="runMain-mainClass" />
`runMain` loads the main class (`childMainClass`).

`runMain` creates an instance of a [SparkApplication](../SparkApplication.md) (if the main class is a subtype of) or creates a [JavaMainApplication](../JavaMainApplication.md) (with the main class).

`runMain` requests the `SparkApplication` to [start](../SparkApplication.md#start) (with the `childArgs` and `sparkConf`).

### <span id="prepareSubmitEnvironment"> prepareSubmitEnvironment

```scala
prepareSubmitEnvironment(
  args: SparkSubmitArguments,
  conf: Option[HadoopConfiguration] = None): (Seq[String], Seq[String], SparkConf, String)
```

`prepareSubmitEnvironment` creates a 4-element tuple:

1. `childArgs` for arguments
1. `childClasspath` for Classpath elements
1. `sysProps` for [Spark properties](../spark-properties.md)
1. [childMainClass](#childMainClass)

!!! tip
    Use `--verbose` command-line option to have the elements of the tuple printed out to the standard output.

`prepareSubmitEnvironment`...FIXME

`prepareSubmitEnvironment` determines the cluster manager based on [master](#clusterManager) argument.

For [KUBERNETES](#KUBERNETES), `prepareSubmitEnvironment` [checkAndGetK8sMasterUrl](../Utils.md#checkAndGetK8sMasterUrl).

`prepareSubmitEnvironment`...FIXME

`prepareSubmitEnvironment` is used when...FIXME

### <span id="childMainClass"> childMainClass

`childMainClass` is the last fourth argument in the result tuple of [prepareSubmitEnvironment](#prepareSubmitEnvironment).

```scala
// (childArgs, childClasspath, sparkConf, childMainClass)
(Seq[String], Seq[String], SparkConf, String)
```

`childMainClass` can be as follows:

Deploy Mode | Master URL | childMainClass
---------|----------|---------
 `client` | | [mainClass](SparkSubmitArguments.md#mainClass)
 `cluster` | [KUBERNETES](#KUBERNETES) | [KubernetesClientApplication](#KUBERNETES_CLUSTER_SUBMIT_CLASS)
 `cluster` | [MESOS](#MESOS) | [RestSubmissionClientApp](#REST_CLUSTER_SUBMIT_CLASS) (for [REST submission API](SparkSubmitArguments.md#useRest))
 `cluster` | [STANDALONE](#STANDALONE) | [RestSubmissionClientApp](#REST_CLUSTER_SUBMIT_CLASS) (for [REST submission API](SparkSubmitArguments.md#useRest))
 `cluster` | [STANDALONE](#STANDALONE) | [ClientApp](#STANDALONE_CLUSTER_SUBMIT_CLASS)
 `cluster` | [YARN](#YARN) | [YarnClusterApplication](#YARN_CLUSTER_SUBMIT_CLASS)

## <span id="KUBERNETES_CLUSTER_SUBMIT_CLASS"> KubernetesClientApplication

`SparkSubmit` hardcodes the fully-qualified class name of the [KubernetesClientApplication](../kubernetes/KubernetesClientApplication.md).

`SparkSubmit` uses it when requested to [prepareSubmitEnvironment](#prepareSubmitEnvironment) (for [KUBERNETES](#KUBERNETES) in `cluster` deploy mode).

## <span id="REST_CLUSTER_SUBMIT_CLASS"> RestSubmissionClientApp

`SparkSubmit` hardcodes...FIXME

## <span id="STANDALONE_CLUSTER_SUBMIT_CLASS"> ClientApp

`SparkSubmit` hardcodes...FIXME

## <span id="YARN_CLUSTER_SUBMIT_CLASS"> YarnClusterApplication

`SparkSubmit` hardcodes...FIXME
