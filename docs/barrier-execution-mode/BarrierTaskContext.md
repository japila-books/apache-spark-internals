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

## runBarrier { #runBarrier }

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

`runBarrier`...FIXME

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
