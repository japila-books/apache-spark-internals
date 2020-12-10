# KubernetesConf

## <span id="namespace"> Namespace

```scala
namespace: String
```

`namespace` gives the value of [spark.kubernetes.namespace](configuration-properties.md#spark.kubernetes.namespace) configuration property.

`namespace` is used when:

* `DriverServiceFeatureStep` is requested to [getAdditionalPodSystemProperties](DriverServiceFeatureStep.md#getAdditionalPodSystemProperties)
* `Client` is requested to [run](Client.md#run)
* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)
