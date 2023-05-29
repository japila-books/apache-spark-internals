---
title: RequestToSync
---

# RequestToSync RPC Message

`RequestToSync` is a [BarrierCoordinatorMessage](BarrierCoordinatorMessage.md) to start [Global Sync](BarrierTaskContext.md#runBarrier) phase.

`RequestToSync` is sent out from [BarrierTaskContext](BarrierTaskContext.md) (i.e., barrier tasks on executors) to a [BarrierCoordinator](BarrierCoordinator.md) (on the driver) to [handle](ContextBarrierState.md#handleRequest).

 Operation | Message | Request Message
----------|---------|----------------
 [allGather](BarrierTaskContext.md#allGather) | User-defined message | `ALL_GATHER`
 [barrier](BarrierTaskContext.md#barrier) | _empty_ | `BARRIER`

## Creating Instance

`RequestToSync` takes the following to be created:

* <span id="numTasks"> Number of tasks (_partitions_)
* <span id="stageId"> Stage ID
* <span id="stageAttemptId"> Stage Attempt ID
* <span id="taskAttemptId"> Task Attempt ID
* <span id="barrierEpoch"> [BarrierEpoch](BarrierTaskContext.md#barrierEpoch)
* <span id="partitionId"> Partition ID
* <span id="message"> Message
* <span id="requestMethod"> Request Method

`RequestToSync` is created when:

* `BarrierTaskContext` is requested for a [Global Sync](BarrierTaskContext.md#runBarrier)
