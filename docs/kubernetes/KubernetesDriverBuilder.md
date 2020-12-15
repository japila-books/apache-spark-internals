# KubernetesDriverBuilder

`KubernetesDriverBuilder` is used to [build a specification of a driver pod](#buildFromFeatures).

## Creating Instance

`KubernetesDriverBuilder` takes no arguments to be created.

`KubernetesDriverBuilder` is created when:

* `KubernetesClientApplication` is requested to [run](KubernetesClientApplication.md#run)

## <span id="KubernetesDriverSpec"> KubernetesDriverSpec

`KubernetesDriverSpec` is the following:

* <span id="pod"> `SparkPod`
* <span id="driverKubernetesResources"> Driver Resources
* <span id="systemProperties"> System Properties

## <span id="buildFromFeatures"> Building KubernetesDriverSpec from Features

```scala
buildFromFeatures(
  conf: KubernetesDriverConf,
  client: KubernetesClient): KubernetesDriverSpec
```

`buildFromFeatures` creates an initial driver pod specification.

With [spark.kubernetes.driver.podTemplateFile](configuration-properties.md#spark.kubernetes.driver.podTemplateFile) configuration property defined, `buildFromFeatures` [loads it](KubernetesUtils.md#loadPodFromTemplate) (with the given `KubernetesClient` and the container name based on [spark.kubernetes.driver.podTemplateContainerName](configuration-properties.md#spark.kubernetes.driver.podTemplateContainerName) configuration property) or defaults to an empty pod specification.

`buildFromFeatures` builds a [KubernetesDriverSpec](#KubernetesDriverSpec) (with the initial driver pod specification).

In the end, `buildFromFeatures` configures the driver pod specification using the following feature steps:

* [BasicDriverFeatureStep](BasicDriverFeatureStep.md)
* DriverKubernetesCredentialsFeatureStep
* DriverServiceFeatureStep
* MountSecretsFeatureStep
* EnvSecretsFeatureStep
* MountVolumesFeatureStep
* [DriverCommandFeatureStep](DriverCommandFeatureStep.md)
* HadoopConfDriverFeatureStep
* KerberosConfDriverFeatureStep
* [PodTemplateConfigMapStep](PodTemplateConfigMapStep.md)
* LocalDirsFeatureStep

`buildFromFeatures`...FIXME

`buildFromFeatures` is used when:

* `Client` is requested to [run](Client.md#run)
