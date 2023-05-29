---
title: BarrierCoordinator
---

# Barrier Coordinator RPC Endpoint

`BarrierCoordinator` is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) that is registered as **barrierSync** RPC Endpoint when `TaskSchedulerImpl` is requested to [maybeInitBarrierCoordinator](../scheduler/TaskSchedulerImpl.md#maybeInitBarrierCoordinator).

`BarrierCoordinator` is responsible to manage [Global Sync](BarrierTaskContext.md#runBarrier)s from barrier tasks (using [BarrierTaskContext](BarrierTaskContext.md) and [RequestToSync](RequestToSync.md) messages).

In other words, the driver sets up a `BarrierCoordinator` ([TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md#maybeInitBarrierCoordinator) precisely) upon startup that [BarrierTaskContext](BarrierTaskContext.md)s talk to using [RequestToSync](RequestToSync.md) messages. `BarrierCoordinator` knows how many tasks to wait for until a barrier stage can be considered complete and a response can be sent back to the tasks to continue (that are [paused](BarrierTaskContext.md#barrier) for 365 days (!)).

## Creating Instance

`BarrierCoordinator` takes the following to be created:

* <span id="timeoutInSecs"> Timeout (seconds)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)
* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)

`BarrierCoordinator` is created when:

* `TaskSchedulerImpl` is requested to [maybeInitBarrierCoordinator](../scheduler/TaskSchedulerImpl.md#maybeInitBarrierCoordinator)

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
