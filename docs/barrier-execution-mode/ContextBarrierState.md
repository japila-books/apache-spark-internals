# ContextBarrierState

`ContextBarrierState` represents the state of global sync of a [barrier stage](#barrierId) (with the [number of tasks](#numTasks)).

`ContextBarrierState` is used by [BarrierCoordinator](BarrierCoordinator.md) to [handle RequestToSync messages](#handleRequest) (and to keep track of [active barrier stage attempts](BarrierCoordinator.md#states)).

??? note "ContextBarrierState"
    `ContextBarrierState` is a `private class` of [BarrierCoordinator](BarrierCoordinator.md).

## Creating Instance

`ContextBarrierState` takes the following to be created:

* [ContextBarrierId](#barrierId)
* <span id="numTasks"> Number of Tasks (of a barrier stage)

`ContextBarrierState` is created when:

* `BarrierCoordinator` is requested to [handle a RequestToSync message](BarrierCoordinator.md#receiveAndReply) for a new stage and stage attempt IDs

### Barrier Stage Attempt (ContextBarrierId) { #barrierId }

`ContextBarrierState` is given a `ContextBarrierId` (of a barrier stage) when [created](#creating-instance).

The `ContextBarrierId` uniquely identifies a barrier stage by the stage and stage attempt IDs.

## Barrier Epoch { #barrierEpoch }

`ContextBarrierState` initializes `barrierEpoch` counter to be `0` when [created](#creating-instance).

## Barrier Tasks { #requesters }

```scala
requesters: ArrayBuffer[RpcCallContext]
```

`requesters` is a registry of `RpcCallContext`s of the barrier tasks (of a [barrier stage attempt](#barrierId)) pending a reply.

It is only when the number of `RpcCallContext`s in the `requesters` reaches the [number of tasks](#numTasks) expected (while [handling RequestToSync requests](#handleRequest)) that this `ContextBarrierState` is considered finished successfully.

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

## messages

`ContextBarrierState` initializes `messages` registry of messages from all [numTasks](#numTasks) barrier tasks (of a [barrier stage attempt](#barrierId)) when [created](#creating-instance).

`messages` registry is empty.

A new message is registered (_added_) when [handling a RequestToSync request](#handleRequest).

## Handling RequestToSync Message { #handleRequest }

```scala
handleRequest(
  requester: RpcCallContext,
  request: RequestToSync): Unit
```

`handleRequest` makes sure that the [RequestMethod](RequestMethod.md) (of the given [RequestToSync](RequestToSync.md)) is consistent across barrier tasks (using [requestMethods](#requestMethods) registry).

`handleRequest` asserts that the [number of tasks](RequestToSync.md#numTasks) is this [numTasks](#numTasks), and so consistent across barrier tasks. Otherwise, `handleRequest` reports `IllegalArgumentException`:

```text
Number of tasks of [barrierId] is [numTasks] from Task [taskId], previously it was [numTasks].
```

`handleRequest` prints out the following INFO message to the logs (with the [ContextBarrierId](#barrierId) and [barrierEpoch](#barrierEpoch)):

```text
Current barrier epoch for [barrierId] is [barrierEpoch].
```

For the first sync message received ([requesters](#requesters) is empty), `handleRequest` [initializes the TimerTask](#initTimerTask) and schedules it for execution after the [timeoutInSecs](BarrierCoordinator.md#timeoutInSecs).

!!! note "Timeout"
    Starting the [timerTask](#timerTask) ensures that a sync may eventually time out (after a configured delay).

`handleRequest` registers the given `requester` in the [requesters](#requesters).

`handleRequest` registers the [message](RequestToSync.md#message) of the [RequestToSync](RequestToSync.md) in the [messages](#messages) for the [partitionId](RequestToSync.md#partitionId).

`handleRequest` prints out the following INFO message to the logs:

```text
Barrier sync epoch [barrierEpoch] from [barrierId] received update from Task taskId,
current progress: [requesters]/[numTasks].
```

### Updates from All Barrier Tasks Received

When the barrier sync received updates from all barrier tasks (i.e., the number of [requesters](#requesters) is the [numTasks](#numTasks)), `handleRequest` replies back to all the [requesters](#requesters) with the [messages](#messages).

`handleRequest` prints out the following INFO message to the logs:

```text
Barrier sync epoch [barrierEpoch] from [barrierId] received all updates from tasks,
finished successfully.
```

`handleRequest` increments the [barrierEpoch](#barrierEpoch), clears the [requesters](#requesters) and the [requestMethods](#requestMethods), and then [cancelTimerTask](#cancelTimerTask).

---

In case of the [epoch](RequestToSync.md#epoch) of the given [RequestToSync](RequestToSync.md) being different from this [barrierEpoch](#barrierEpoch), `handleRequest` sends back a failure message (with a `SparkException`) to the given `requester`:

```text
The request to sync of [barrierId] with barrier epoch [barrierEpoch] has already finished.
Maybe task [taskId] is not properly killed.
```

---

In case of different [RequestMethod](RequestMethod.md)s (in [requestMethods](#requestMethods) registry), `handleRequest` sends back a failure message to the [requesters](#requesters) (incl. the given `requester`):

```text
Different barrier sync types found for the sync [barrierId]: [requestMethods].
Please use the same barrier sync type within a single sync.
```

`handleRequest` [clear](#clear).

---

`handleRequest` is used when:

* `BarrierCoordinator` is requested to [handle a RequestToSync message](BarrierCoordinator.md#receiveAndReply)

## Logging

`ContextBarrierState` is a private class of [BarrierCoordinator](BarrierCoordinator.md) and logging is configured using the logger of [BarrierCoordinator](BarrierCoordinator.md#logging).
