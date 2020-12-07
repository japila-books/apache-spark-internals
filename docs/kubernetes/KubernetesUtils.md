# KubernetesUtils

## <span id="loadPodFromTemplate"> Loading Pod from Template File

```scala
loadPodFromTemplate(
  kubernetesClient: KubernetesClient,
  templateFile: File,
  containerName: Option[String]): SparkPod
```

`loadPodFromTemplate` requests the given `KubernetesClient` to load a pod for the input template file.

`loadPodFromTemplate` [selectSparkContainer](#selectSparkContainer) (with the pod and the input container name).

In case of an `Exception`, `loadPodFromTemplate` prints out the following ERROR message to the logs:

```text
Encountered exception while attempting to load initial pod spec from file
```

`loadPodFromTemplate` (re)throws a `SparkException`:

```text
Could not load pod from template file.
```

`loadPodFromTemplate` is used when:

* `KubernetesClusterManager` is requested to [createSchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)
* `KubernetesDriverBuilder` is requested to [buildFromFeatures](KubernetesDriverBuilder.md#buildFromFeatures)
* `KubernetesExecutorBuilder` is requested to [buildFromFeatures](KubernetesExecutorBuilder.md#buildFromFeatures)
