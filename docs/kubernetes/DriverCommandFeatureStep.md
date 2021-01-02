# DriverCommandFeatureStep

`DriverCommandFeatureStep` is a [KubernetesFeatureConfigStep](KubernetesFeatureConfigStep.md).

## Creating Instance

`DriverCommandFeatureStep` takes the following to be created:

* <span id="conf"> [KubernetesDriverConf](KubernetesDriverConf.md)

`DriverCommandFeatureStep` is created when:

* `KubernetesDriverBuilder` is requested to [build a KubernetesDriverSpec from features](KubernetesDriverBuilder.md#buildFromFeatures)

## <span id="configurePod"> configurePod

```scala
configurePod(
  pod: SparkPod): SparkPod
```

`configurePod` is part of the [KubernetesFeatureConfigStep](KubernetesFeatureConfigStep.md#configurePod) abstraction.

`configurePod` branches off based on the [MainAppResource](KubernetesDriverConf.md#mainAppResource) (of the [KubernetesDriverConf](#conf)):

* For `JavaMainAppResource`, `configurePod` [configureForJava](#configureForJava) with the primary resource (if defined) or uses [spark-internal](../tools/SparkLauncher.md#NO_RESOURCE)

* For `PythonMainAppResource`, `configurePod` [configureForPython](#configureForPython) with the primary resource

* For `RMainAppResource`, `configurePod` [configureForR](#configureForR) with the primary resource

## <span id="configureForJava"> configureForJava

```scala
configureForJava(
  pod: SparkPod,
  res: String): SparkPod
```

`configureForJava` builds the [base driver container](#baseDriverContainer) for the given `SparkPod` and the primary resource.

In the end, `configureForJava` creates another `SparkPod` (for the pod of the given `SparkPod`) and the driver container.

`configureForJava` is used when:

* `DriverCommandFeatureStep` is requested to [configurePod](#configurePod) for a `JavaMainAppResource` (based on the [mainAppResource](KubernetesDriverConf.md#mainAppResource) of the [KubernetesDriverConf](#conf))

## <span id="configureForPython"> configureForPython

```scala
configureForPython(
  pod: SparkPod,
  res: String): SparkPod
```

`configureForPython`...FIXME

`configureForPython` is used when:

* FIXME

## <span id="configureForR"> configureForR

```scala
configureForR(
  pod: SparkPod,
  res: String): SparkPod
```

`configureForR`...FIXME

`configureForR` is used when:

* FIXME

## <span id="baseDriverContainer"> baseDriverContainer

```scala
baseDriverContainer(
  pod: SparkPod,
  resource: String): ContainerBuilder
```

`baseDriverContainer` [renames](KubernetesUtils.md#renameMainAppResource) the given primary resource when the [MainAppResource](KubernetesDriverConf.md#mainAppResource) is a `JavaMainAppResource`. Otherwise, `baseDriverContainer` leaves the primary resource as-is.

`baseDriverContainer` creates a `ContainerBuilder` (for the pod of the given `SparkPod`) and adds the following arguments (in that order):

1. `driver`
1. `--properties-file` with `/opt/spark/conf/spark.properties`
1. `--class` with the [mainClass](KubernetesDriverConf.md#mainClass) of the [KubernetesDriverConf](#conf)
1. the primary resource (possibly renamed when a `MainAppResource`)
1. [appArgs](KubernetesDriverConf.md#appArgs) of the [KubernetesDriverConf](#conf)

!!! note
    The arguments are then used by the default `entrypoint.sh` of the official Docker image of Apache Spark (in `resource-managers/kubernetes/docker/src/main/dockerfiles/spark/`).

`baseDriverContainer` is used when:

* `DriverCommandFeatureStep` is requested to [configureForJava](#configureForJava), [configureForPython](#configureForPython), and [configureForR](#configureForR)
