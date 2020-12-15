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

`configureForJava`...FIXME

`configureForJava` is used when:

* `DriverCommandFeatureStep` is requested to [configurePod](#configurePod)

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

`baseDriverContainer`...FIXME

`baseDriverContainer` is used when:

* `DriverCommandFeatureStep` is requested to [baseDriverContainer](DriverCommandFeatureStep.md#)
