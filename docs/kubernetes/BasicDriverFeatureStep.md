# BasicDriverFeatureStep

`BasicDriverFeatureStep` is...FIXME

## <span id="configurePod"> Configuring Pod for Driver

```scala
configurePod(
  pod: SparkPod): SparkPod
```

`configurePod` is part of the [KubernetesFeatureConfigStep](KubernetesFeatureConfigStep.md#configurePod) abstraction.

`configurePod`...FIXME

## <span id="driverContainerImage"> Driver Container Image Name

`BasicDriverFeatureStep` uses [spark.kubernetes.driver.container.image](configuration-properties.md#spark.kubernetes.driver.container.image) for the name of the container image for drivers.

The name must be defined or `BasicDriverFeatureStep` throws an `SparkException`:

```text
Must specify the driver container image
```

`driverContainerImage` is used when requested for [configurePod](#configurePod).
