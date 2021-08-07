# DAGSchedulerEvent

`DAGSchedulerEvent` is an abstraction of events that are handled by the [DAGScheduler](DAGScheduler.md) (on [dag-scheduler-event-loop daemon thread](DAGSchedulerEventProcessLoop.md)).

## <span id="AllJobsCancelled"> AllJobsCancelled

Carries no extra information

Posted when `DAGScheduler` is requested to [cancelAllJobs](DAGScheduler.md#cancelAllJobs)

Event handler: [doCancelAllJobs](DAGScheduler.md#doCancelAllJobs)

## <span id="BeginEvent"> BeginEvent

Carries the following:

* [Task](Task.md)
* [TaskInfo](TaskInfo.md)

Posted when `DAGScheduler` is requested to [taskStarted](DAGScheduler.md#taskStarted)

Event handler: [handleBeginEvent](DAGScheduler.md#handleBeginEvent)

## <span id="CompletionEvent"> CompletionEvent

Carries the following:

* <span id="CompletionEvent-task"> Completed [Task](Task.md)
* <span id="CompletionEvent-reason"> `TaskEndReason`
* <span id="CompletionEvent-result"> Result (value computed)
* <span id="CompletionEvent-accumUpdates"> [AccumulatorV2](../accumulators/AccumulatorV2.md) Updates
* <span id="CompletionEvent-metricPeaks"> Metric Peaks
* <span id="CompletionEvent-taskInfo"> [TaskInfo](TaskInfo.md)

Posted when `DAGScheduler` is requested to [taskEnded](DAGScheduler.md#taskEnded)

Event handler: [handleTaskCompletion](DAGScheduler.md#handleTaskCompletion)

## <span id="ExecutorAdded"> ExecutorAdded

Carries the following:

* Executor ID
* Host name

Posted when `DAGScheduler` is requested to [executorAdded](DAGScheduler.md#executorAdded)

Event handler: [handleExecutorAdded](DAGScheduler.md#handleExecutorAdded)

## <span id="ExecutorLost"> ExecutorLost

Carries the following:

* Executor ID
* Reason

Posted when `DAGScheduler` is requested to [executorLost](DAGScheduler.md#executorLost)

Event handler: [handleExecutorLost](DAGScheduler.md#handleExecutorLost)

## <span id="GettingResultEvent"> GettingResultEvent

Carries the following:

* [TaskInfo](TaskInfo.md)

Posted when `DAGScheduler` is requested to [taskGettingResult](DAGScheduler.md#taskGettingResult)

Event handler: [handleGetTaskResult](DAGScheduler.md#handleGetTaskResult)

## <span id="JobCancelled"> JobCancelled

JobCancelled event carries the following:

* Job ID
* Reason (optional)

Posted when `DAGScheduler` is requested to [cancelJob](DAGScheduler.md#cancelJob)

Event handler: [handleJobCancellation](DAGScheduler.md#handleJobCancellation)

## <span id="JobGroupCancelled"> JobGroupCancelled

Carries the following:

* Group ID

Posted when `DAGScheduler` is requested to [cancelJobGroup](DAGScheduler.md#cancelJobGroup)

Event handler: [handleJobGroupCancelled](DAGScheduler.md#handleJobGroupCancelled)

## <span id="JobSubmitted"> JobSubmitted

Carries the following:

* [Job ID](DAGScheduler.md#nextJobId)
* [RDD](../rdd/RDD.md)
* Partition processing function (with a [TaskContext](TaskContext.md) and the partition data, i.e. `(TaskContext, Iterator[_]) => _`)
* Partition IDs to compute
* `CallSite`
* [JobListener](JobListener.md) to keep updated about the status of the stage execution
* [Execution properties](../SparkContext.md#localProperties)

Posted when:

* `DAGScheduler` is requested to [submit a job](DAGScheduler.md#submitJob), [run an approximate job](DAGScheduler.md#runApproximateJob) and [handleJobSubmitted](DAGScheduler.md#handleJobSubmitted)

Event handler: [handleJobSubmitted](DAGScheduler.md#handleJobSubmitted)

## <span id="MapStageSubmitted"> MapStageSubmitted

Carries the following:

* Job ID
* [ShuffleDependency](../rdd/ShuffleDependency.md)
* CallSite
* [JobListener](JobListener.md)
* Execution properties

Posted when `DAGScheduler` is requested to [submitMapStage](DAGScheduler.md#submitMapStage)

Event handler: [handleMapStageSubmitted](DAGScheduler.md#handleMapStageSubmitted)

## <span id="ResubmitFailedStages"> ResubmitFailedStages

Carries no extra information.

Posted when `DAGScheduler` is requested to [handleTaskCompletion](DAGScheduler.md#handleTaskCompletion)

Event handler: [resubmitFailedStages](DAGScheduler.md#resubmitFailedStages)

## <span id="SpeculativeTaskSubmitted"> SpeculativeTaskSubmitted

Carries the following:

* [Task](Task.md)

Posted when `DAGScheduler` is requested to [speculativeTaskSubmitted](DAGScheduler.md#speculativeTaskSubmitted)

Event handler: [handleSpeculativeTaskSubmitted](DAGScheduler.md#handleSpeculativeTaskSubmitted)

## <span id="StageCancelled"> StageCancelled

Carries the following:

* Stage ID
* Reason (optional)

Posted when `DAGScheduler` is requested to [cancelStage](DAGScheduler.md#cancelStage)

Event handler: [handleStageCancellation](DAGScheduler.md#handleStageCancellation)

## <span id="TaskSetFailed"> TaskSetFailed

Carries the following:

* [TaskSet](TaskSet.md)
* Reason
* Exception (optional)

Posted when `DAGScheduler` is requested to [taskSetFailed](DAGScheduler.md#taskSetFailed)

Event handler: [handleTaskSetFailed](DAGScheduler.md#handleTaskSetFailed)

## <span id="WorkerRemoved"> WorkerRemoved

Carries the following:

* Worked ID
* Host name
* Reason

Posted when `DAGScheduler` is requested to [workerRemoved](DAGScheduler.md#workerRemoved)

Event handler: [handleWorkerRemoved](DAGScheduler.md#handleWorkerRemoved)
