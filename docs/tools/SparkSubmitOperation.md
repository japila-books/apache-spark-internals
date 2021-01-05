# SparkSubmitOperation

`SparkSubmitOperation` is an [abstraction](#contract) of [operations](#implementations) of [spark-submit](spark-submit.md) (when requested to [kill a submission](SparkSubmit.md#kill) or for a [submission status](SparkSubmit.md#requestStatus)).

## Contract

### <span id="kill"> Killing Submission

```scala
kill(
  submissionId: String,
  conf: SparkConf): Unit
```

Kills a given submission

Used when:

* `SparkSubmit` is requested to [kill a submission](SparkSubmit.md#kill)

### <span id="printSubmissionStatus"> Displaying Submission Status

```scala
printSubmissionStatus(
  submissionId: String,
  conf: SparkConf): Unit
```

Displays status of a given submission

Used when:

* `SparkSubmit` is requested for [submission status](SparkSubmit.md#requestStatus)

### <span id="supports"> Checking Whether Master URL Supported

```scala
supports(
  master: String): Boolean
```

Used when:

* `SparkSubmit` is requested to [kill a submission](SparkSubmit.md#kill) and for a [submission status](SparkSubmit.md#requestStatus) (via [getSubmitOperations](SparkSubmitUtils.md#getSubmitOperations) utility)

## Implementations

* `K8SSparkSubmitOperation` ([Spark on Kubernetes]({{ book.spark_k8s }}/K8SSparkSubmitOperation))
