# KubernetesDriverConf

`KubernetesDriverConf` is a [KubernetesConf](KubernetesConf.md).

## Creating Instance

`KubernetesDriverConf` takes the following to be created:

* <span id="sparkConf"> [SparkConf](../SparkConf.md)
* <span id="appId"> Application ID
* <span id="mainAppResource"> `MainAppResource`
* <span id="mainClass"> Name of the Main Class
* <span id="appArgs"> Application Arguments

`KubernetesDriverConf` is created when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start) (via [KubernetesConf utility](#createDriverConf))

## <span id="volumes"> volumes

```scala
volumes: Seq[KubernetesVolumeSpec]
```

`volumes` is part of the [KubernetesConf](KubernetesConf.md#volumes) abstraction.

`volumes` [extracts volumes](KubernetesVolumeUtils.md#parseVolumesWithPrefix) for the driver (with the **spark.kubernetes.driver.volumes** prefix) from the [SparkConf](#sparkConf).
