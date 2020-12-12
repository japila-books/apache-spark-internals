# K8SSparkSubmitOperation

`K8SSparkSubmitOperation` is a [SparkSubmitOperation](../tools/SparkSubmitOperation.md).

## <span id="kill"> Killing Submission

```scala
kill(
  submissionId: String,
  conf: SparkConf): Unit
```

`kill` is part of the [SparkSubmitOperation](../tools/SparkSubmitOperation.md#kill) abstraction.

`kill` prints out the following message to standard error:

```text
Submitting a request to kill submission [submissionId] in [spark.master]. Grace period in secs: [[getGracePeriod] | not set].
```

`kill` creates a `KillApplication` to [execute](#execute) it (with the input `submissionId` and [SparkConf](../SparkConf.md)).

## <span id="printSubmissionStatus"> Displaying Submission Status

```scala
printSubmissionStatus(
  submissionId: String,
  conf: SparkConf): Unit
```

`printSubmissionStatus` is part of the [SparkSubmitOperation](../tools/SparkSubmitOperation.md#printSubmissionStatus) abstraction.

`printSubmissionStatus` prints out the following message to standard error:

```text
Submitting a request for the status of submission [submissionId] in [spark.master].
```

`printSubmissionStatus` creates a `ListStatus` to [execute](#execute) it (with the input `submissionId` and [SparkConf](../SparkConf.md)).

## <span id="supports"> Checking Whether Master URL Supported

```scala
supports(
  master: String): Boolean
```

`supports` is part of the [SparkSubmitOperation](../tools/SparkSubmitOperation.md#supports) abstraction.

`supports` is `true` when the input `master` starts with **k8s://** prefix.

## <span id="execute"> Executing Operation

```scala
execute(
  submissionId: String,
  sparkConf: SparkConf,
  op: K8sSubmitOp): Unit
```

`execute`...FIXME

`execute` is used for [kill](#kill) and [printSubmissionStatus](#printSubmissionStatus).
