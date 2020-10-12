# DAGSchedulerEventProcessLoop

`DAGSchedulerEventProcessLoop` is an event processing daemon thread to handle [DAGSchedulerEvents](DAGSchedulerEvent.md) (on a separate thread from the parent [DAGScheduler](#dagScheduler)'s).

`DAGSchedulerEventProcessLoop` is registered under the name of **dag-scheduler-event-loop**.

`DAGSchedulerEventProcessLoop` uses [java.util.concurrent.LinkedBlockingDeque]({{ java.doc }}/java/util/concurrent/LinkedBlockingDeque.html) blocking deque that can grow indefinitely.

## Creating Instance

`DAGSchedulerEventProcessLoop` takes the following to be created:

* <span id="dagScheduler"> [DAGScheduler](DAGScheduler.md)

`DAGSchedulerEventProcessLoop` is created when `DAGScheduler` is [created](DAGScheduler.md#eventProcessLoop).

## <span id="onReceive"><span id="doOnReceive"> Processing Event

DAGSchedulerEvent | Event Handler
------------------|--------------
 [AllJobsCancelled](DAGSchedulerEvent.md#AllJobsCancelled) | [doCancelAllJobs](DAGScheduler.md#doCancelAllJobs)
 [BeginEvent](DAGSchedulerEvent.md#BeginEvent) | [handleBeginEvent](DAGScheduler.md#handleBeginEvent)
 [CompletionEvent](DAGSchedulerEvent.md#CompletionEvent) | [handleTaskCompletion](DAGScheduler.md#handleTaskCompletion)
 [ExecutorAdded](DAGSchedulerEvent.md#ExecutorAdded) | [handleExecutorAdded](DAGScheduler.md#handleExecutorAdded)
 [ExecutorLost](DAGSchedulerEvent.md#ExecutorLost) | [handleExecutorLost](DAGScheduler.md#handleExecutorLost)
 [GettingResultEvent](DAGSchedulerEvent.md#GettingResultEvent) | [handleGetTaskResult](DAGScheduler.md#handleGetTaskResult)
 [JobCancelled](DAGSchedulerEvent.md#JobCancelled) | [handleJobCancellation](DAGScheduler.md#handleJobCancellation)
 [JobGroupCancelled](DAGSchedulerEvent.md#JobGroupCancelled) | [handleJobGroupCancelled](DAGScheduler.md#handleJobGroupCancelled)
 [JobSubmitted](DAGSchedulerEvent.md#JobSubmitted) | [handleJobSubmitted](DAGScheduler.md#handleJobSubmitted)
 [MapStageSubmitted](DAGSchedulerEvent.md#MapStageSubmitted) | [handleMapStageSubmitted](DAGScheduler.md#handleMapStageSubmitted)
 [ResubmitFailedStages](DAGSchedulerEvent.md#ResubmitFailedStages) | [resubmitFailedStages](DAGScheduler.md#resubmitFailedStages)
 [SpeculativeTaskSubmitted](DAGSchedulerEvent.md#SpeculativeTaskSubmitted) | [handleSpeculativeTaskSubmitted](DAGScheduler.md#handleSpeculativeTaskSubmitted)
 [StageCancelled](DAGSchedulerEvent.md#StageCancelled) | [handleStageCancellation](DAGScheduler.md#handleStageCancellation)
 [TaskSetFailed](DAGSchedulerEvent.md#TaskSetFailed) | [handleTaskSetFailed](DAGScheduler.md#handleTaskSetFailed)
 [WorkerRemoved](DAGSchedulerEvent.md#WorkerRemoved) | [handleWorkerRemoved](DAGScheduler.md#handleWorkerRemoved)

## <span id="timer"> messageProcessingTime Timer

`DAGSchedulerEventProcessLoop` uses [messageProcessingTime](DAGSchedulerSource.md#messageProcessingTimer) timer to measure time of [processing events](#onReceive).
