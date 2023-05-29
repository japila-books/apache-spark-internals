---
title: BarrierTaskContext
---

# BarrierTaskContext &mdash; TaskContext for Barrier Tasks

`BarrierTaskContext` is a concrete [TaskContext](../scheduler/TaskContext.md) of the tasks in a [Barrier Stage](index.md#barrier-stage) in [Barrier Execution Mode](index.md).

## Creating Instance

`BarrierTaskContext` takes the following to be created:

* <span id="taskContext"> [TaskContext](../scheduler/TaskContext.md)

`BarrierTaskContext` is created when:

* `Task` is requested to [run](../scheduler/Task.md#run) (with [isBarrier](../scheduler/Task.md#isBarrier) flag enabled)

## Barrier Coordinator RPC Endpoint { #barrierCoordinator }

```scala
barrierCoordinator: RpcEndpointRef
```

`BarrierTaskContext` creates a [RpcEndpointRef](../rpc/RpcUtils.md#makeDriverRef) to [Barrier Coordinator RPC Endpoint](BarrierCoordinator.md) when [created](#creating-instance).

`barrierCoordinator` is used to handle [barrier](#barrier) and [allGather](#allGather) operators (through [runBarrier](#runBarrier)).

## allGather { #allGather }

```scala
allGather(
  message: String): Array[String]
```

`allGather` [runBarrier](#runBarrier) with the given `message` and `ALL_GATHER` request method.

??? note "Public API and PySpark"
    `allGather` is part of a public API.

    `allGather` is used in `BasePythonRunner.WriterThread` ([PySpark]({{ book.pyspark }}/runners/BasePythonRunner/)) when requested to `barrierAndServe`.

## barrier

```scala
barrier(): Unit
```

`barrier` [runBarrier](#runBarrier) with no message and `BARRIER` request method.

??? note "Public API and PySpark"
    `barrier` is part of a public API.

    `barrier` is used in `BasePythonRunner.WriterThread` ([PySpark]({{ book.pyspark }}/runners/BasePythonRunner/)) when requested to `barrierAndServe`.

## Global Sync { #runBarrier }

```scala
runBarrier(
  message: String,
  requestMethod: RequestMethod.Value): Array[String]
```

`runBarrier` prints out the following INFO message to the logs:

```text
Task [taskAttemptId] from Stage [stageId](Attempt [stageAttemptNumber]) has entered the global sync, current barrier epoch is [barrierEpoch].
```

`runBarrier` prints out the following TRACE message to the logs:

```text
Current callSite: [callSite]
```

`runBarrier` schedules a `TimerTask` ([Java]({{ java.api }}/java/util/TimerTask.html)) to print out the following INFO message to the logs every minute:

```text
Task [taskAttemptId] from Stage [stageId](Attempt [stageAttemptNumber]) waiting under the global sync since [startTime],
has been waiting for [duration] seconds,
current barrier epoch is [barrierEpoch].
```

`runBarrier` requests the [Barrier Coordinator RPC Endpoint](#barrierCoordinator) to [send](../rpc/RpcEndpointRef.md#askAbortable) a [RequestToSync](RequestToSync.md) one-off message and waits 365 days (!) for a response (a collection of responses from all the barrier tasks).

!!! note "1 Year to Wait for Response from Barrier Coordinator"
    `runBarrier` uses 1 year to wait until the response arrives.

`runBarrier` checks every second if the response "bundle" arrived.

`runBarrier` increments the [barrierEpoch](#barrierEpoch).

`runBarrier` prints out the following INFO message to the logs:

```text
Task [taskAttemptId] from Stage [stageId](Attempt [stageAttemptNumber]) finished global sync successfully,
waited for [duration] seconds,
current barrier epoch is [barrierEpoch].
```

In the end, `runBarrier` returns the response "bundle" (a collection of responses from all the barrier tasks).

---

In case of a `SparkException`, `runBarrier` prints out the following INFO message to the logs and reports (_re-throws_) the exception up (_the call chain_):

```text
Task [taskAttemptId] from Stage [stageId](Attempt [stageAttemptNumber]) failed to perform global sync,
waited for [duration] seconds,
current barrier epoch is [barrierEpoch].
```

---

`runBarrier` is used when:

* `BarrierTaskContext` is requested to [barrier](#barrier), [allGather](#allGather)

## Logging

Enable `ALL` logging level for `org.apache.spark.BarrierTaskContext` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.BarrierTaskContext.name = org.apache.spark.BarrierTaskContext
logger.BarrierTaskContext.level = all
```

Refer to [Logging](../spark-logging.md).
