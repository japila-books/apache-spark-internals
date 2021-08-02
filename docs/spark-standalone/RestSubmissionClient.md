# RestSubmissionClient

## Creating Instance

`RestSubmissionClient` takes the following to be created:

* <span id="master"> Master URL

`RestSubmissionClient` is created when:

* `SparkSubmit` is requested to [kill](../tools/SparkSubmit.md#kill) and [requestStatus](../tools/SparkSubmit.md#requestStatus)
* `RestSubmissionClientApp` is requested to `run`

## <span id="createSubmission"> createSubmission

```scala
createSubmission(
  request: CreateSubmissionRequest): SubmitRestProtocolResponse
```

`createSubmission` prints out the following INFO message to the logs (with the [master URL](#master)):

```text
Submitting a request to launch an application in [master].
```

`createSubmission`...FIXME

`createSubmission` is used when:

* FIXME

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.rest.RestSubmissionClient` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.rest.RestSubmissionClient=ALL
```

Refer to [Logging](../spark-logging.md).
