# KubernetesClientApplication

`KubernetesClientApplication` is a [SparkApplication](../SparkApplication.md) for [Kubernetes resource manager](index.md).

## Creating Instance

`KubernetesClientApplication` takes no arguments to be created.

`KubernetesClientApplication` is created when:

* `SparkSubmit` is requested to [runMain](../tools/SparkSubmit.md#runMain) (for [kubernetes in cluster deploy mode](../tools/SparkSubmit.md#KubernetesClientApplication))

## <span id="start"> Starting

```scala
start(
  args: Array[String],
  conf: SparkConf): Unit
```

`start` is part of the [SparkApplication](../SparkApplication.md#start) abstraction.

`start`...FIXME

### <span id="run"> run

```scala
run(
  clientArguments: ClientArguments,
  sparkConf: SparkConf): Unit
```

`run`...FIXME
