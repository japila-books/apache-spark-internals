# SparkListenerTaskEnd

`SparkListenerTaskEnd` is a [SparkListenerEvent](SparkListenerEvent.md).

`SparkListenerTaskEnd` is posted (and [created](#creating-instance)) when:

* `DAGScheduler` is requested to [postTaskEnd](scheduler/DAGScheduler.md#postTaskEnd)

`SparkListenerTaskEnd` is intercepted using [SparkListenerInterface.onTaskEnd](SparkListenerInterface.md#onTaskEnd)

## Creating Instance

`SparkListenerTaskEnd` takes the following to be created:

* <span id="stageId"> Stage ID
* <span id="stageAttemptId"> Stage Attempt ID
* <span id="taskType"> Task Type
* <span id="reason"> `TaskEndReason`
* <span id="taskInfo"> [TaskInfo](scheduler/TaskInfo.md)
* <span id="taskExecutorMetrics"> `ExecutorMetrics`
* <span id="taskMetrics"> [TaskMetrics](executor/TaskMetrics.md)
