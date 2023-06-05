---
title: BarrierCoordinator
---

# Barrier Coordinator RPC Endpoint

`BarrierCoordinator` is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) that is registered as **barrierSync** RPC Endpoint when `TaskSchedulerImpl` is requested to [maybeInitBarrierCoordinator](../scheduler/TaskSchedulerImpl.md#maybeInitBarrierCoordinator).

`BarrierCoordinator` is responsible for [handling RequestToSync messages](#receiveAndReply) to coordinate [Global Sync](BarrierTaskContext.md#runBarrier)s of barrier tasks (using [allGather](BarrierTaskContext.md#allGather) and [barrier](BarrierTaskContext.md#barrier) operators).

In other words, the driver sets up a `BarrierCoordinator` ([TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md#maybeInitBarrierCoordinator) precisely) upon startup that [BarrierTaskContext](BarrierTaskContext.md)s talk to using [RequestToSync](RequestToSync.md) messages. `BarrierCoordinator` tracks the number of tasks to wait for until a barrier stage is complete and a response can be sent back to the tasks to continue (that are [paused](BarrierTaskContext.md#barrier) for 365 days (!)).

## Creating Instance

`BarrierCoordinator` takes the following to be created:

* <span id="timeoutInSecs"> Timeout (seconds)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)
* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)

`BarrierCoordinator` is created when:

* `TaskSchedulerImpl` is requested to [maybeInitBarrierCoordinator](../scheduler/TaskSchedulerImpl.md#maybeInitBarrierCoordinator)

## Processing RequestToSync Messages (from Barrier Tasks) { #receiveAndReply }

??? note "RpcEndpoint"

    ```scala
    receiveAndReply(
      context: RpcCallContext): PartialFunction[Any, Unit]
    ```

    `receiveAndReply` is part of the [RpcEndpoint](../rpc/RpcEndpoint.md#receiveAndReply) abstraction.

`receiveAndReply` handles [RequestToSync](RequestToSync.md) messages.

---

Unless already registered, `receiveAndReply` registers a new `ContextBarrierId` (for the [stageId](RequestToSync.md#stageId) and the [stageAttemptId](RequestToSync.md#stageAttemptId)) in the [Barrier States](#states) registry.

!!! note "Multiple Tasks and One BarrierCoordinator"
    `receiveAndReply` handles [RequestToSync](RequestToSync.md) messages, one per task in a barrier stage.
    Out of all the properties of `RequestToSync`, [numTasks](RequestToSync.md#numTasks), [stageId](RequestToSync.md#stageId) and [stageAttemptId](RequestToSync.md#stageAttemptId) are used.

    The very first `RequestToSync` is used to register the [stageId](RequestToSync.md#stageId) and [stageAttemptId](RequestToSync.md#stageAttemptId) (as `ContextBarrierId`) with [numTasks](RequestToSync.md#numTasks).

`receiveAndReply` finds the [ContextBarrierState](ContextBarrierState.md) for the stage and the stage attempt (in the [Barrier States](#states) registry) to [handle the RequestToSync](ContextBarrierState.md#handleRequest).

## Barrier States { #states }

```scala
states: ConcurrentHashMap[ContextBarrierId, ContextBarrierState]
```

`BarrierCoordinator` creates an empty `ConcurrentHashMap` ([Java]({{ java.api }}/java/util/concurrent/ConcurrentHashMap.html)) when [created](#creating-instance).

`states` registry is used to keep track of all the active barrier stage attempts and the corresponding internal [ContextBarrierState](ContextBarrierState.md).

`states` is used when:

* [onStop](#onStop) to clean up
* [cleanupBarrierStage](#cleanupBarrierStage) to remove a specific stage attempt
* [receiveAndReply](#receiveAndReply) to handle [RequestToSync](RequestToSync.md) messages

## SparkListener { #listener }

`BarrierCoordinator` creates a [SparkListener](../SparkListener.md) when [created](#creating-instance).

The `SparkListener` is used to [intercept SparkListenerStageCompleted events](#onStageCompleted).

The `SparkListener` is [addToStatusQueue](../scheduler/LiveListenerBus.md#addToStatusQueue) upon [startup](#onStart) and [removed](../scheduler/LiveListenerBus.md#removeListener) at [stop](#onStop).

### onStageCompleted { #onStageCompleted }

??? note "SparkListener"

    ```scala
    onStageCompleted(
      stageCompleted: SparkListenerStageCompleted): Unit
    ```

    `onStageCompleted` is part of the [SparkListenerInterface](../SparkListenerInterface.md#onStageCompleted) abstraction.

`onStageCompleted` [cleanupBarrierStage](#cleanupBarrierStage) for the stage and the attempt number (based on the given `SparkListenerStageCompleted`).

## Logging

Enable `ALL` logging level for `org.apache.spark.BarrierCoordinator` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.BarrierCoordinator.name = org.apache.spark.BarrierCoordinator
logger.BarrierCoordinator.level = all
```

Refer to [Logging](../spark-logging.md).
