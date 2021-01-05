# SparkApplication

`SparkApplication` is an [abstraction](#contract) of [entry points](#implementations) to Spark applications that can be [started](#start) (_submitted for execution_ using [spark-submit](spark-submit.md)).

## Contract

### <span id="start"> Starting Spark Application

```scala
start(
  args: Array[String], conf: SparkConf): Unit
```

Used when:

* `SparkSubmit` is requested to [submit an application for execution](SparkSubmit.md#runMain)

## Implementations

* ClientApp
* [JavaMainApplication](JavaMainApplication.md)
* `KubernetesClientApplication` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesClientApplication))
* RestSubmissionClientApp
* YarnClusterApplication
