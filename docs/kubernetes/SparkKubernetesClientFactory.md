# SparkKubernetesClientFactory

`SparkKubernetesClientFactory` is a [Spark-opinionated builder for Kubernetes clients](#createKubernetesClient).

## <span id="createKubernetesClient"> createKubernetesClient Utility

```scala
createKubernetesClient(
  master: String,
  namespace: Option[String],
  kubernetesAuthConfPrefix: String,
  clientType: ClientType.Value,
  sparkConf: SparkConf,
  defaultServiceAccountToken: Option[File],
  defaultServiceAccountCaCert: Option[File]): KubernetesClient
```

`createKubernetesClient` takes the OAuth token-related configuration properties from the input [SparkConf](../SparkConf.md):

* `kubernetesAuthConfPrefix`.oauthTokenFile (or defaults to the input `defaultServiceAccountToken`)
* `kubernetesAuthConfPrefix`.oauthToken

`createKubernetesClient` takes the [spark.kubernetes.context](configuration-properties.md#spark.kubernetes.context) configuraiton property (_kubeContext_).

`createKubernetesClient` takes the certificate-related configuration properties from the input [SparkConf](../SparkConf.md):

* `kubernetesAuthConfPrefix`.caCertFile (or defaults to the input `defaultServiceAccountCaCert`)
* `kubernetesAuthConfPrefix`.clientKeyFile
* `kubernetesAuthConfPrefix`.clientCertFile

`createKubernetesClient` prints out the following INFO message to the logs:

```text
Auto-configuring K8S client using [context [kubeContext] | current context] from users K8S config file
```

`createKubernetesClient` builds a Kubernetes `Config` (based on the configuration properties).

`createKubernetesClient` builds an `OkHttpClient` with a custom `kubernetes-dispatcher` dispatcher.

In the end, `createKubernetesClient` creates a Kubernetes `DefaultKubernetesClient` (with the `OkHttpClient` and `Config`).

`createKubernetesClient` is used when:

* `K8SSparkSubmitOperation` is requested to [execute](K8SSparkSubmitOperation.md#execute)
* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)
* `KubernetesClusterManager` is requested to [create a SchedulerBackend](KubernetesClusterManager.md#createSchedulerBackend)

### Exceptions

`createKubernetesClient` throws an `IllegalArgumentException` when an OAuth token is specified through a file and a value:

```text
Cannot specify OAuth token through both a file [oauthTokenFileConf] and a value [oauthTokenConf].
```

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.k8s.SparkKubernetesClientFactory` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.k8s.SparkKubernetesClientFactory=ALL
```

Refer to [Logging](../spark-logging.md).
