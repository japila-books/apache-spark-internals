# KubernetesVolumeUtils

## <span id="parseVolumesWithPrefix"> parseVolumesWithPrefix

```scala
parseVolumesWithPrefix(
  sparkConf: SparkConf,
  prefix: String): Seq[KubernetesVolumeSpec]
```

`parseVolumesWithPrefix`...FIXME

`parseVolumesWithPrefix` is used when:

* `KubernetesDriverConf` is requested for [volumes](KubernetesDriverConf.md#volumes)
* `KubernetesExecutorConf` is requested for [volumes](KubernetesExecutorConf.md#volumes)
* `KubernetesConf` utility is used to [create a KubernetesDriverConf](KubernetesConf.md#createDriverConf)
