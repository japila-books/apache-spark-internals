# SparkStatusTracker

`SparkStatusTracker` is created for [SparkContext](SparkContext.md#statusTracker) for Spark developers to access the [AppStatusStore](#store) and the following:

* All active job IDs
* All active stage IDs
* All known job IDs (and possibly limited to a particular job group)
* `SparkExecutorInfo`s of all known executors
* `SparkJobInfo` of a job ID
* `SparkStageInfo` of a stage ID

## Creating Instance

`SparkStatusTracker` takes the following to be created:

* <span id="sc"> [SparkContext](SparkContext.md) (_unused_)
* <span id="store"> [AppStatusStore](status/AppStatusStore.md)

`SparkStatusTracker` is created when:

* `SparkContext` is [created](SparkContext.md#_statusTracker)
