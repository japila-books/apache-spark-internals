# Configuration Properties of Kubernetes Cluster Manager

## <span id="spark.kubernetes.submitInDriver"><span id="KUBERNETES_DRIVER_SUBMIT_CHECK"> spark.kubernetes.submitInDriver

**(internal)**

Default: `false`

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
