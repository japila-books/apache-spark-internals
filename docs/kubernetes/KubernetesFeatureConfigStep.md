# KubernetesFeatureConfigStep

`KubernetesFeatureConfigStep` is an [abstraction](#contract) of [Kubernetes pod features](#implementations) for drivers and executors.

## Contract

### <span id="configurePod"> Configuring Pod

```scala
configurePod(
  pod: SparkPod): SparkPod
```

Used when:

* `KubernetesDriverBuilder` is requested to [buildFromFeatures](KubernetesDriverBuilder.md#buildFromFeatures)
* `KubernetesExecutorBuilder` is requested to [buildFromFeatures](KubernetesExecutorBuilder.md#buildFromFeatures)

### <span id="getAdditionalKubernetesResources"> Additional Kubernetes Resources

```scala
getAdditionalKubernetesResources(): Seq[HasMetadata]
```

Additional Kubernetes resources

Default: `empty`

Used when:

* `KubernetesDriverBuilder` is requested to [buildFromFeatures](KubernetesDriverBuilder.md#buildFromFeatures)

### <span id="getAdditionalPodSystemProperties"> Additional System Properties

```scala
getAdditionalPodSystemProperties(): Map[String, String]
```

System properties to set on the JVM

Default: `empty`

Used when:

* `KubernetesDriverBuilder` is requested to [buildFromFeatures](KubernetesDriverBuilder.md#buildFromFeatures)

## Implementations

* [BasicDriverFeatureStep](BasicDriverFeatureStep.md)
* [BasicExecutorFeatureStep](BasicExecutorFeatureStep.md)
* [DriverCommandFeatureStep](DriverCommandFeatureStep.md)
* DriverKubernetesCredentialsFeatureStep
* DriverServiceFeatureStep
* EnvSecretsFeatureStep
* ExecutorKubernetesCredentialsFeatureStep
* HadoopConfDriverFeatureStep
* KerberosConfDriverFeatureStep
* LocalDirsFeatureStep
* MountSecretsFeatureStep
* MountVolumesFeatureStep
* [PodTemplateConfigMapStep](PodTemplateConfigMapStep.md)
