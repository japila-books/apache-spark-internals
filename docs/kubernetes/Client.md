# Client

`Client` submits a Spark application to [run on Kubernetes](#run) (by creating the driver pod and starting a watcher that monitors and logs the application status).

## Creating Instance

`Client` takes the following to be created:

* <span id="conf"> [KubernetesDriverConf](KubernetesDriverConf.md)
* <span id="builder"> [KubernetesDriverBuilder](KubernetesDriverBuilder.md)
* <span id="kubernetesClient"> Kubernetes' `KubernetesClient`
* <span id="watcher"> [LoggingPodStatusWatcher](LoggingPodStatusWatcher.md)

`Client` is created when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)

## <span id="run"> Running Driver Pod

```scala
run(): Unit
```

`run` requests the [KubernetesDriverBuilder](#builder) to [build a KubernetesDriverSpec from features](KubernetesDriverBuilder.md#buildFromFeatures).

`run` requests the [KubernetesDriverConf](#conf) for the [resourceNamePrefix](KubernetesDriverConf.md#resourceNamePrefix) and uses it for the name of the driver's config map:

```text
[resourceNamePrefix]-driver-conf-map
```

`run` [builds a ConfigMap](#buildConfigMap) (with the name and the system properties of the `KubernetesDriverSpec`).

`run` creates a driver container (based on the `KubernetesDriverSpec`) and adds the following:

* `SPARK_CONF_DIR` env var as `/opt/spark/conf`
* `spark-conf-volume` volume mount as `/opt/spark/conf`

`run` creates a driver pod (based on the `KubernetesDriverSpec`) with the driver container and a new `spark-conf-volume` volume for the `ConfigMap`.

`run` requests the [KubernetesClient](#kubernetesClient) to watch for the driver pod (using the [LoggingPodStatusWatcher](#watcher)) and, when available, attaches the `ConfigMap`.

`run` is used when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)

### <span id="addDriverOwnerReference"> addDriverOwnerReference

```scala
addDriverOwnerReference(
  driverPod: Pod,
  resources: Seq[HasMetadata]): Unit
```

`addDriverOwnerReference`...FIXME

### <span id="buildConfigMap"> buildConfigMap

```scala
buildConfigMap(
  configMapName: String,
  conf: Map[String, String]): ConfigMap
```

`buildConfigMap`...FIXME
