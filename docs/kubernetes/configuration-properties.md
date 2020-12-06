# Configuration Properties of Kubernetes Cluster Manager

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

## <span id="spark.kubernetes.submitInDriver"><span id="KUBERNETES_DRIVER_SUBMIT_CHECK"> spark.kubernetes.submitInDriver

**(internal)**

Default: `false`

Used when:

* `BasicDriverFeatureStep` is requested to [getAdditionalPodSystemProperties](BasicDriverFeatureStep.md#getAdditionalPodSystemProperties)
* `KubernetesClusterManager` is requested for a [SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)

## <span id="spark.kubernetes.driver.pod.name"><span id="KUBERNETES_DRIVER_POD_NAME"> spark.kubernetes.driver.pod.name

Name of the driver pod

Default: `(undefined)`

Must be provided if a Spark application is deployed using `spark-submit` in cluster mode

## <span id="spark.kubernetes.executor.podNamePrefix"><span id="KUBERNETES_EXECUTOR_POD_NAME_PREFIX"> spark.kubernetes.executor.podNamePrefix

**(internal)** Prefix to use in front of the executor pod names

Default: `(undefined)`

## <span id="spark.kubernetes.namespace"><span id="KUBERNETES_NAMESPACE"> spark.kubernetes.namespace

The namespace that will be used for running the driver and executor pods.

Default: `default`

## <span id="spark.kubernetes.executor.podTemplateFile"><span id="KUBERNETES_EXECUTOR_PODTEMPLATE_FILE"> spark.kubernetes.executor.podTemplateFile

File containing a template pod spec for executors

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

## <span id="spark.kubernetes.executor.eventProcessingInterval"><span id="KUBERNETES_EXECUTOR_EVENT_PROCESSING_INTERVAL"> spark.kubernetes.executor.eventProcessingInterval

Interval between successive inspection of executor events sent from the Kubernetes API

Default: `1s`

## <span id="spark.kubernetes.executor.deleteOnTermination"><span id="KUBERNETES_DELETE_EXECUTORS"> spark.kubernetes.executor.deleteOnTermination

When disabled (`false`), executor pods will not be deleted in case of failure or normal termination

Default: `true`
