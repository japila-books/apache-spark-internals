# DAGSchedulerEvents

== [[AllJobsCancelled]] AllJobsCancelled

AllJobsCancelled event carries no extra information.

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#cancelAllJobs[cancelAllJobs]

Event handler: scheduler:DAGScheduler.md#doCancelAllJobs[doCancelAllJobs]

== [[BeginEvent]] BeginEvent

BeginEvent event carries the following:

* scheduler:Task.md[Task]
* scheduler:spark-scheduler-TaskInfo.md[TaskInfo]

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#taskStarted[taskStarted]

Event handler: scheduler:DAGScheduler.md#handleBeginEvent[handleBeginEvent]

== [[CompletionEvent]] CompletionEvent

CompletionEvent event carries the following:

* scheduler:Task.md[Task]
* Reason
* Result (value computed)
* Accumulator updates
* scheduler:spark-scheduler-TaskInfo.md[TaskInfo]

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#taskEnded[taskEnded]

Event handler: scheduler:DAGScheduler.md#handleTaskCompletion[handleTaskCompletion]

== [[ExecutorAdded]] ExecutorAdded

ExecutorAdded event carries the following:

* Executor ID
* Host name

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#executorAdded[executorAdded]

Event handler: scheduler:DAGScheduler.md#handleExecutorAdded[handleExecutorAdded]

== [[ExecutorLost]] ExecutorLost

ExecutorLost event carries the following:

* Executor ID
* Reason

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#executorLost[executorLost]

Event handler: scheduler:DAGScheduler.md#handleExecutorLost[handleExecutorLost]

== [[GettingResultEvent]] GettingResultEvent

GettingResultEvent event carries the following:

* scheduler:spark-scheduler-TaskInfo.md[TaskInfo]

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#taskGettingResult[taskGettingResult]

Event handler: scheduler:DAGScheduler.md#handleGetTaskResult[handleGetTaskResult]

== [[JobCancelled]] JobCancelled

JobCancelled event carries the following:

* Job ID
* Reason (optional)

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#cancelJob[cancelJob]

Event handler: scheduler:DAGScheduler.md#handleJobCancellation[handleJobCancellation]

== [[JobGroupCancelled]] JobGroupCancelled

JobGroupCancelled event carries the following:

* Group ID

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#cancelJobGroup[cancelJobGroup]

Event handler: scheduler:DAGScheduler.md#handleJobGroupCancelled[handleJobGroupCancelled]

== [[JobSubmitted]] JobSubmitted

JobSubmitted event carries the following:

* Job ID
* rdd:RDD.md[RDD]
* Partition function (`(TaskContext, Iterator[_]) => _`)
* Partitions to compute
* CallSite
* scheduler:spark-scheduler-JobListener.md[JobListener] to keep updated about the status of the stage execution
* Execution properties

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#submitJob[submit a job], scheduler:DAGScheduler.md#runApproximateJob[run an approximate job] and scheduler:DAGScheduler.md#handleJobSubmitted[handleJobSubmitted]

Event handler: scheduler:DAGScheduler.md#handleJobSubmitted[handleJobSubmitted]

== [[MapStageSubmitted]] MapStageSubmitted

MapStageSubmitted event carries the following:

* Job ID
* [ShuffleDependency](../rdd/ShuffleDependency.md)
* CallSite
* [JobListener](../scheduler/spark-scheduler-JobListener.md)
* Execution properties

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#submitMapStage[submitMapStage]

Event handler: scheduler:DAGScheduler.md#handleMapStageSubmitted[handleMapStageSubmitted]

== [[ResubmitFailedStages]] ResubmitFailedStages

ResubmitFailedStages event carries no extra information.

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#handleTaskCompletion[handleTaskCompletion]

Event handler: scheduler:DAGScheduler.md#resubmitFailedStages[resubmitFailedStages]

== [[SpeculativeTaskSubmitted]] SpeculativeTaskSubmitted

SpeculativeTaskSubmitted event carries the following:

* scheduler:Task.md[Task]

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#speculativeTaskSubmitted[speculativeTaskSubmitted]

Event handler: scheduler:DAGScheduler.md#handleSpeculativeTaskSubmitted[handleSpeculativeTaskSubmitted]

== [[StageCancelled]] StageCancelled

StageCancelled event carries the following:

* Stage ID
* Reason (optional)

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#cancelStage[cancelStage]

Event handler: scheduler:DAGScheduler.md#handleStageCancellation[handleStageCancellation]

== [[TaskSetFailed]] TaskSetFailed

TaskSetFailed event carries the following:

* scheduler:TaskSet.md[TaskSet]
* Reason
* Exception (optional)

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#taskSetFailed[taskSetFailed]

Event handler: scheduler:DAGScheduler.md#handleTaskSetFailed[handleTaskSetFailed]

== [[WorkerRemoved]] WorkerRemoved

WorkerRemoved event carries the following:

* Worked ID
* Host name
* Reason

Posted when DAGScheduler is requested to scheduler:DAGScheduler.md#workerRemoved[workerRemoved]

Event handler: scheduler:DAGScheduler.md#handleWorkerRemoved[handleWorkerRemoved]
