---
title: Barrier Execution Mode
subtitle: Barrier Scheduling
---

# Barrier Execution Mode

**Barrier Execution Mode** (_Barrier Scheduling_) introduces a strong requirement on [Spark Scheduler](../scheduler/TaskScheduler.md) to launch all tasks of a [Barrier Stage](#barrier-stage) at the same time or not at all (and consequently wait until required resources are available). Moreover, a failure of a single task of a barrier stage fails the whole stage (and so the other tasks).

Barrier Execution Mode aims at making Distributed Deep Learning with Apache Spark easier (or even possible).

From the [Design doc: Barrier Execution Mode]({{ spark.jira }}/SPARK-24582):

> In Spark, a task in a stage doesn't depend on any other task in the same stage, and hence it can be scheduled independently.

That gives Spark a freedom to schedule tasks in as many task batches as needed. So, 5 tasks can be scheduled on 1 CPU core quite easily in 5 consecutive batches. That's unlike MPI (or non-MapReduce scheduling systems) that allows for greater flexibility and inter-task dependency.

Later in [Design doc: Barrier Execution Mode]({{ spark.jira }}/SPARK-24582):

> In MPI, all workers start at the same time and pass messages around.
>
> To embed this workload in Spark, we need to introduce a new scheduling model, tentatively named **"barrier scheduling"**, which launches the tasks at the same time and provides users enough information and tooling to embed distributed DL training into a Spark pipeline.

## Barrier RDD

**Barrier RDD** is a [RDDBarrier](RDDBarrier.md).

## Barrier Stage

**Barrier Stage** is a [Stage](../scheduler/Stage.md) with at least one [Barrier RDD](#barrier-rdd).

## Abstractions

* [BarrierTaskContext](BarrierTaskContext.md)
* [RDDBarrier](RDDBarrier.md)

## RDD.barrier Operator { #barrier }

Barrier Execution Mode is based on [RDD.barrier](../rdd/RDD.md#barrier) operator to indicate that Spark Scheduler must launch the tasks together for the current stage (and mark the current stage as a [barrier stage](#barrier-stage)).

```scala
barrier(): RDDBarrier[T]
```

`RDD.barrier` creates a [RDDBarrier](RDDBarrier.md) that comes with the barrier-aware [mapPartitions](RDDBarrier.md#mapPartitions) transformation.

```scala
mapPartitions[S](
  f: Iterator[T] => Iterator[S],
  preservesPartitioning: Boolean = false): RDD[S]
```

Under the covers, `RDDBarrier.mapPartitions` creates a [MapPartitionsRDD](../rdd/MapPartitionsRDD.md) like the regular `RDD.mapPartitions` transformation but with [isFromBarrier](../rdd/MapPartitionsRDD.md#isFromBarrier) flag enabled.

* `Task` has a [isBarrier](../scheduler/Task.md#isBarrier) flag that says whether this task belongs to a barrier stage (default: `false`).

## isFromBarrier Flag { #isFromBarrier }

An RDD is in a [barrier stage](#barrier-stage), if at least one of its parent RDD(s), or itself, are mapped from an `RDDBarrier`.

[ShuffledRDD](../rdd/ShuffledRDD.md) has the [isBarrier](../rdd/RDD.md#isBarrier) flag always disabled (`false`).

[MapPartitionsRDD](../rdd/MapPartitionsRDD.md) is the only RDD that can have the [isBarrier](../rdd/RDD.md#isBarrier_) flag enabled.

[RDDBarrier.mapPartitions](RDDBarrier.md#mapPartitions) is the only transformation that creates a [MapPartitionsRDD](../rdd/MapPartitionsRDD.md) with the [isFromBarrier](../rdd/MapPartitionsRDD.md#isFromBarrier) flag enabled.

## Push-Based Shuffle

[Push-based shuffle](../push-based-shuffle.md) is currently not supported for barrier stages.

## Demo

Enable `ALL` logging level for [org.apache.spark.BarrierTaskContext](BarrierTaskContext.md#logging) logger to see what happens inside.

```scala
val tasksNum = 3
val nums = sc.parallelize(seq = 0 until 9, numSlices = tasksNum)
assert(nums.getNumPartitions == tasksNum)
```

Print out the available partitions and the number of records within each (using Spark SQL for a human-friendlier output).

=== "Scala"

    ```scala
    import org.apache.spark.TaskContext
    nums
      .mapPartitions { it => Iterator.single((TaskContext.get.partitionId, it.size)) }
      .toDF("partitionId", "size")
      .show
    ```

```text
+-----------+----+
|partitionId|size|
+-----------+----+
|          0|   3|
|          1|   3|
|          2|   3|
+-----------+----+
```

[RDD.barrier](../rdd/RDD.md#barrier) creates a [Barrier Stage](#barrier-stage) (a [RDDBarrier](RDDBarrier.md)).

```scala
import org.apache.spark.rdd.RDDBarrier
assert(nums.barrier.isInstanceOf[RDDBarrier[_]])
```

Use [RDD.mapPartitions](../rdd/RDD.md#mapPartitions) transformation to access a [BarrierTaskContext](BarrierTaskContext.md).

```scala
val barrierRdd = nums
  .barrier
  .mapPartitions { ns =>
    import org.apache.spark.{BarrierTaskContext, TaskContext}
    val ctx = TaskContext.get.asInstanceOf[BarrierTaskContext]
    ctx.allGather("waiting for all the barrier tasks")
    ns
  }
```

Run a distributed computation (using [RDD.count](../rdd/RDD.md#count) action).

```scala
barrierRdd.count()
```

There should be INFO and TRACE messages printed out to the console (given `ALL` logging level for [org.apache.spark.BarrierTaskContext](BarrierTaskContext.md#logging) logger).

```text
[Executor task launch worker for task 1.0 in stage 5.0 (TID 13)] INFO  org.apache.spark.BarrierTaskContext:60 - Task 13 from Stage 5(Attempt 0) has entered the global sync, current barrier epoch is 0.
...
[Executor task launch worker for task 1.0 in stage 5.0 (TID 13)] TRACE org.apache.spark.BarrierTaskContext:68 - Current callSite: CallSite($anonfun$runBarrier$2 at Logging.scala:68,org.apache.spark.BarrierTaskContext.$anonfun$runBarrier$2(BarrierTaskContext.scala:61)
...
[Executor task launch worker for task 1.0 in stage 5.0 (TID 13)] INFO  org.apache.spark.BarrierTaskContext:60 - Task 13 from Stage 5(Attempt 0) finished global sync successfully, waited for 1 seconds, current barrier epoch is 1.
...
```

Open up [web UI](http://localhost:4040/) and explore the execution plans.

### Access MapPartitionsRDD

[MapPartitionsRDD](../rdd/MapPartitionsRDD.md) is a `private[spark]` class so to access `RDD.isBarrier` method requires to be in `org.apache.spark` package.

Paste the following code in spark-shell / Scala REPL using `:paste -raw` mode.

```scala
package org.apache.spark

object IsBarrier {
  import org.apache.spark.rdd.RDD
  implicit class BypassPrivateSpark[T](rdd: RDD[T]) {
    def isBarrier = rdd.isBarrier
  }
}
```

```scala
import org.apache.spark.IsBarrier._
assert(barrierRdd.isBarrier)
```

## Learn More

1. [SPIP: Support Barrier Execution Mode in Apache Spark]({{ spark.jira }}/SPARK-24374) (esp. [Design: Barrier execution mode]({{ spark.jira }}/SPARK-24582))
1. [Barrier Execution Mode in Spark 3.0 - Part 1 : Introduction](https://blog.madhukaraphatak.com/barrier-execution-mode-part-1)
