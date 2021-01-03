# KubernetesClientApplication

`KubernetesClientApplication` is a [SparkApplication](../tools/SparkApplication.md) in [Spark on Kubernetes](index.md) in [cluster](../tools/SparkSubmit.md#KubernetesClientApplication) deploy mode.

## Creating Instance

`KubernetesClientApplication` takes no arguments to be created.

`KubernetesClientApplication` is created when:

* `SparkSubmit` is requested to [launch a Spark application](../tools/SparkSubmit.md#runMain) (for [kubernetes in cluster deploy mode](../tools/SparkSubmit.md#KubernetesClientApplication))

## <span id="start"> Starting Spark Application

```scala
start(
  args: Array[String],
  conf: SparkConf): Unit
```

`start` is part of the [SparkApplication](../tools/SparkApplication.md#start) abstraction.

`start` [parses](ClientArguments.md#fromCommandLineArgs) the command-line arguments (`args`) and [runs](#run).

### <span id="run"> run

```scala
run(
  clientArguments: ClientArguments,
  sparkConf: SparkConf): Unit
```

`run` generates a custom Spark Application ID of the format:

```text
spark-[randomUUID-without-dashes]
```

`run` [creates a KubernetesDriverConf](KubernetesConf.md#createDriverConf) (with the given [ClientArguments](ClientArguments.md), [SparkConf](../SparkConf.md) and the custom Spark Application ID).

`run` removes the **k8s://** prefix from the [spark.master](../configuration-properties.md#spark.master) (which has already been validated by [SparkSubmit](../tools/SparkSubmit.md) itself).

`run` creates a [LoggingPodStatusWatcherImpl](LoggingPodStatusWatcherImpl.md) (with the `KubernetesDriverConf`).

`run` [creates a KubernetesClient](SparkKubernetesClientFactory.md#createKubernetesClient) (with the master URL, the [namespace](KubernetesConf.md#namespace), and others).

In the end, `run` creates a [Client](Client.md) (with the [KubernetesDriverConf](KubernetesDriverConf.md), a new [KubernetesDriverBuilder](KubernetesDriverBuilder.md), the `KubernetesClient`, and the [LoggingPodStatusWatcherImpl](LoggingPodStatusWatcherImpl.md)) and requests it to [run](Client.md#run).
