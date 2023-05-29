# ContextBarrierState

`ContextBarrierState` is used by [BarrierCoordinator](BarrierCoordinator.md) to keep track of [active barrier stage attempts](BarrierCoordinator.md#states).

??? note "ContextBarrierState"
    `ContextBarrierState` is a `private class` of [BarrierCoordinator](BarrierCoordinator.md).

## Creating Instance

`ContextBarrierState` takes the following to be created:

* <span id="barrierId"> `ContextBarrierId` (with a stage and stage attempt IDs)
* <span id="numTasks"> Number of Tasks

`ContextBarrierState` is created when:

* `BarrierCoordinator` is requested to [handle a RequestToSync message](BarrierCoordinator.md#receiveAndReply) for a new stage and stage attempt IDs

## Requester RpcCallContexts { #requesters }

```scala
requesters: ArrayBuffer[RpcCallContext]
```

`requesters` is a registry of `RpcCallContext`s of barrier tasks pending a reply.

Once the number of `RpcCallContext`s in the `requesters` reaches the [number of tasks](#numTasks) that is to indicate that all the updates from barrier tasks have been received, this `ContextBarrierState` is considered finished successfully.

`ContextBarrierState` initializes `requesters` when [created](#creating-instance) to be of [number of tasks](#numTasks) size.

A new `RpcCallContext` of a barrier task is added in [handleRequest](#handleRequest) only when the epoch of the barrier task matches the current [barrierEpoch](#barrierEpoch).

## TimerTask { #timerTask }

```scala
timerTask: TimerTask
```

`ContextBarrierState` uses a `TimerTask` ([Java]({{ java.api }}/java/util/TimerTask.html)) to ensure that a `barrier()` call can time out.

`ContextBarrierState` creates a `TimerTask` ([Java]({{ java.api }}/java/util/TimerTask.html)) when requested to [initTimerTask](#initTimerTask) when requested to [handle a RequestToSync message](#handleRequest) for the first global sync message received (when the [requesters](#requesters) is empty). The `TimerTask` is then immediately scheduled to be executed after [spark.barrier.sync.timeout](../configuration-properties.md#spark.barrier.sync.timeout).

!!! note "spark.barrier.sync.timeout"
    Since [spark.barrier.sync.timeout](../configuration-properties.md#spark.barrier.sync.timeout) defaults to `365d` (1 year), the `TimerTask` will run only after one year.

The `TimerTask` is stopped in [cancelTimerTask](#cancelTimerTask).

## Initializing TimerTask { #initTimerTask }

```scala
initTimerTask(
  state: ContextBarrierState): Unit
```

`initTimerTask` creates a new `TimerTask` ([Java]({{ java.api }}/java/util/TimerTask.html)) that, when executed, sends a `SparkException` to all the [requesters](#requesters) with the following message followed by [cleanupBarrierStage](BarrierCoordinator.md#cleanupBarrierStage) for this [ContextBarrierId](#barrierId).

```text
The coordinator didn't get all barrier sync requests
for barrier epoch [barrierEpoch] from [barrierId] within [timeoutInSecs] second(s).
```

The `TimerTask` is made available as [timerTask](#timerTask).

---

`initTimerTask` is used when:

* `ContextBarrierState` is requested to [handle a RequestToSync message](#handleRequest) (for the first global sync message received when the [requesters](#requesters) is empty)

## Handling RequestToSync Message { #handleRequest }

```scala
handleRequest(
  requester: RpcCallContext,
  request: RequestToSync): Unit
```

`handleRequest`...FIXME

---

`handleRequest` is used when:

* `BarrierCoordinator` is requested to [handle a RequestToSync message](BarrierCoordinator.md#receiveAndReply)
