# Configuration Properties of Spark on Kubernetes

## <span id="spark.kubernetes.container.image.pullPolicy"><span id="CONTAINER_IMAGE_PULL_POLICY"> spark.kubernetes.container.image.pullPolicy

Kubernetes image pull policy:

* `Always`
* `Never`
* `IfNotPresent`

Default: `IfNotPresent`

Used when:

* `KubernetesConf` is requested to [imagePullPolicy](KubernetesConf.md#imagePullPolicy)

## <span id="spark.kubernetes.file.upload.path"><span id="KUBERNETES_FILE_UPLOAD_PATH"> spark.kubernetes.file.upload.path

Hadoop DFS-compatible file system path where files from the local file system will be uploded to in `cluster` mode.

Default: (undefined)

Used when:

* `KubernetesUtils` is requested to [uploadFileUri](KubernetesUtils.md#uploadFileUri)

## <span id="spark.kubernetes.report.interval"><span id="REPORT_INTERVAL"> spark.kubernetes.report.interval

Interval between reports of the current app status in cluster mode

Default: `1s`

Used when:

* `LoggingPodStatusWatcherImpl` is requested to [watchOrStop](LoggingPodStatusWatcherImpl.md#watchOrStop)

## <span id="spark.kubernetes.executor.deleteOnTermination"><span id="KUBERNETES_DELETE_EXECUTORS"> spark.kubernetes.executor.deleteOnTermination

When disabled (`false`), executor pods will not be deleted in case of failure or normal termination

Default: `true`

Used when:

* `ExecutorPodsAllocator` is requested to [onNewSnapshots](ExecutorPodsAllocator.md#onNewSnapshots)
* `ExecutorPodsLifecycleManager` is requested to [onFinalNonDeletedState](ExecutorPodsLifecycleManager.md#onFinalNonDeletedState)
* `KubernetesClusterSchedulerBackend` is requested to [stop](KubernetesClusterSchedulerBackend.md#stop)

## <span id="spark.kubernetes.executor.apiPollingInterval"><span id="KUBERNETES_EXECUTOR_API_POLLING_INTERVAL"> spark.kubernetes.executor.apiPollingInterval

Interval (in millis) between polls against the Kubernetes API server to inspect the state of executors.

Default: `30s`

Used when:

* `ExecutorPodsPollingSnapshotSource` is requested to [start](ExecutorPodsPollingSnapshotSource.md#pollingInterval)

## <span id="spark.kubernetes.executor.eventProcessingInterval"><span id="KUBERNETES_EXECUTOR_EVENT_PROCESSING_INTERVAL"> spark.kubernetes.executor.eventProcessingInterval

Interval (in millis) between successive inspection of executor events sent from the Kubernetes API

Default: `1s`

Used when:

* `ExecutorPodsLifecycleManager` is requested to [start and register a new subscriber](ExecutorPodsLifecycleManager.md#eventProcessingInterval)

## <span id="spark.kubernetes.namespace"><span id="KUBERNETES_NAMESPACE"> spark.kubernetes.namespace

[Namespace]({{ k8s.doc }}/concepts/overview/working-with-objects/namespaces/) for running the driver and executor pods

Default: `default`

Used when:

* `KubernetesConf` is requested for [namespace](KubernetesConf.md#namespace)
* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)
* `ExecutorPodsAllocator` is created (and initializes [namespace](ExecutorPodsAllocator.md#namespace))

## <span id="spark.kubernetes.context"><span id="KUBERNETES_CONTEXT"> spark.kubernetes.context

The desired context from your K8S config file used to configure the K8S client for interacting with the cluster. Useful if your config file has multiple clusters or user identities defined. The client library used locates the config file via the `KUBECONFIG` environment variable or by defaulting to `.kube/config` under your home directory. If not specified then your current context is used.  You can always override specific aspects of the config file provided configuration using other Spark on K8S configuration options.

Default: (undefined)

Used when:

* `SparkKubernetesClientFactory` is requested to [create a KubernetesClient](SparkKubernetesClientFactory.md#createKubernetesClient)

## <span id="spark.kubernetes.submitInDriver"><span id="KUBERNETES_DRIVER_SUBMIT_CHECK"> spark.kubernetes.submitInDriver

**(internal)** Whether executing in `cluster` deploy mode

Default: `false`

`spark.kubernetes.submitInDriver` is `true` in [BasicDriverFeatureStep](BasicDriverFeatureStep.md#getAdditionalPodSystemProperties).

Used when:

* `BasicDriverFeatureStep` is requested to [getAdditionalPodSystemProperties](BasicDriverFeatureStep.md#getAdditionalPodSystemProperties)
* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)

## <span id="spark.kubernetes.driver.podTemplateFile"><span id="KUBERNETES_DRIVER_PODTEMPLATE_FILE"> spark.kubernetes.driver.podTemplateFile

Pod template file for drivers

Default: (undefined)

Used when:

* `KubernetesDriverBuilder` is requested to [buildFromFeatures](KubernetesDriverBuilder.md#buildFromFeatures)

## <span id="spark.kubernetes.executor.podTemplateFile"><span id="KUBERNETES_EXECUTOR_PODTEMPLATE_FILE"> spark.kubernetes.executor.podTemplateFile

Pod template file for executors

Default: (undefined)

Used when:

* `KubernetesClusterManager` is requested to [createSchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)
* `KubernetesExecutorBuilder` is requested to [buildFromFeatures](KubernetesExecutorBuilder.md#buildFromFeatures)
* `PodTemplateConfigMapStep` is [created](PodTemplateConfigMapStep.md#hasTemplate) and requested to [configurePod](PodTemplateConfigMapStep.md#configurePod), [getAdditionalPodSystemProperties](PodTemplateConfigMapStep.md#getAdditionalPodSystemProperties), [getAdditionalKubernetesResources](PodTemplateConfigMapStep.md#getAdditionalKubernetesResources)

## <span id="spark.kubernetes.driver.podTemplateContainerName"><span id="KUBERNETES_DRIVER_PODTEMPLATE_CONTAINER_NAME"> spark.kubernetes.driver.podTemplateContainerName

Container name for a driver in the given [pod template](#spark.kubernetes.driver.podTemplateFile)

Default: (undefined)

Used when:

* `KubernetesDriverBuilder` is requested to [buildFromFeatures](KubernetesDriverBuilder.md#buildFromFeatures)

## <span id="spark.kubernetes.memoryOverheadFactor"><span id="MEMORY_OVERHEAD_FACTOR"> spark.kubernetes.memoryOverheadFactor

**Memory Overhead Factor** that will allocate memory to non-JVM jobs which in the case of JVM tasks will default to 0.10 and 0.40 for non-JVM jobs

Must be a double between (0, 1.0)

Default: `0.1`

## <span id="spark.kubernetes.container.image"><span id="CONTAINER_IMAGE"> spark.kubernetes.container.image

Container image to use for Spark containers (unless [spark.kubernetes.driver.container.image](#spark.kubernetes.driver.container.image) or [spark.kubernetes.executor.container.image](#spark.kubernetes.executor.container.image) are defined)

Default: (undefined)

## <span id="spark.kubernetes.driver.container.image"><span id="DRIVER_CONTAINER_IMAGE"> spark.kubernetes.driver.container.image

Container image for drivers

Default: [spark.kubernetes.container.image](#spark.kubernetes.container.image)

Used when:

* `BasicDriverFeatureStep` is requested for a [driverContainerImage](BasicDriverFeatureStep.md#driverContainerImage)

## <span id="spark.kubernetes.executor.container.image"><span id="EXECUTOR_CONTAINER_IMAGE"> spark.kubernetes.executor.container.image

Container image for executors

Default: [spark.kubernetes.container.image](#spark.kubernetes.container.image)

Used when:

* `BasicExecutorFeatureStep` is requested for a [driverContainerImage](BasicExecutorFeatureStep.md#executorContainerImage)

## <span id="spark.kubernetes.allocation.batch.delay"><span id="KUBERNETES_ALLOCATION_BATCH_DELAY"> spark.kubernetes.allocation.batch.delay

Time (in millis) to wait between each round of executor allocation

Default: `1s`

Used when:

* [ExecutorPodsAllocator](ExecutorPodsAllocator.md#podAllocationDelay) is created

## <span id="spark.kubernetes.driver.pod.name"><span id="KUBERNETES_DRIVER_POD_NAME"> spark.kubernetes.driver.pod.name

Name of the driver pod

Default: `(undefined)`

Must be provided if a Spark application is deployed using `spark-submit` in cluster mode

## <span id="spark.kubernetes.executor.podNamePrefix"><span id="KUBERNETES_EXECUTOR_POD_NAME_PREFIX"> spark.kubernetes.executor.podNamePrefix

**(internal)** Prefix to use in front of the executor pod names

Default: `(undefined)`

## <span id="spark.kubernetes.executor.podTemplateContainerName"><span id="KUBERNETES_EXECUTOR_PODTEMPLATE_CONTAINER_NAME"> spark.kubernetes.executor.podTemplateContainerName

Container name to be used as a basis for executors in the given pod template

Default: `(undefined)`

## <span id="spark.kubernetes.authenticate.driver.mounted"><span id="KUBERNETES_AUTH_DRIVER_MOUNTED_CONF_PREFIX"> spark.kubernetes.authenticate.driver.mounted

FIXME

## <span id="spark.kubernetes.driver.master"><span id="KUBERNETES_DRIVER_MASTER_URL"> spark.kubernetes.driver.master

The internal Kubernetes master (API server) address to be used for driver to request executors.

Default: `https://kubernetes.default.svc`

## <span id="spark.kubernetes.authenticate"><span id="KUBERNETES_AUTH_CLIENT_MODE_PREFIX"> spark.kubernetes.authenticate

FIXME
