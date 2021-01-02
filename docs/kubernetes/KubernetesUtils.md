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

## <span id="uploadAndTransformFileUris"> uploadAndTransformFileUris

```scala
uploadAndTransformFileUris(
  fileUris: Iterable[String],
  conf: Option[SparkConf] = None): Iterable[String]
```

`uploadAndTransformFileUris`...FIXME

`uploadAndTransformFileUris` is used when:

* `BasicDriverFeatureStep` is requested to [getAdditionalPodSystemProperties](BasicDriverFeatureStep.md#getAdditionalPodSystemProperties)

### <span id="uploadFileUri"> uploadFileUri

```scala
uploadFileUri(
  uri: String,
  conf: Option[SparkConf] = None): String
```

`uploadFileUri`...FIXME

## <span id="renameMainAppResource"> renameMainAppResource

```scala
renameMainAppResource(
  resource: String,
  conf: SparkConf): String
```

`renameMainAppResource` is converted to [spark-internal](../tools/SparkLauncher.md#NO_RESOURCE) internal name when the given `resource` [is local and resolvable](#isLocalAndResolvable). Otherwise, `renameMainAppResource` returns the given resource as-is.

`renameMainAppResource` is used when:

* `DriverCommandFeatureStep` is requested for a [base container for drivers](DriverCommandFeatureStep.md#baseDriverContainer) (for a `JavaMainAppResource` application)

## <span id="isLocalAndResolvable"> isLocalAndResolvable

```scala
isLocalAndResolvable(
  resource: String): Boolean
```

`isLocalAndResolvable` is `true` when the given `resource` is not [internal](../tools/SparkSubmit.md#isInternal) and a [local dependency](#isLocalDependency) (after converting to a well-formed URI)

`isLocalAndResolvable` is used when:

* `KubernetesUtils` is requested to [renameMainAppResource](#renameMainAppResource)
* `BasicDriverFeatureStep` is requested to [getAdditionalPodSystemProperties](BasicDriverFeatureStep.md#getAdditionalPodSystemProperties)

### <span id="isLocalDependency"> isLocalDependency

```scala
isLocalDependency(
  uri: URI): Boolean
```

An input `URI` is a **local dependency** when the scheme is `null` (undefined) or `file`.
