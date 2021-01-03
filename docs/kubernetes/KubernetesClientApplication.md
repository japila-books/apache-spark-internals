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

`run`...FIXME
