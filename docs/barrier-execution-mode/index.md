# Barrier Execution Mode

From the [Design doc: Barrier Execution Mode]({{ spark.jira }}/SPARK-24582):

> In Spark, a task in a stage doesn't depend on any other task in the same stage, and hence it can be scheduled independently.
> In MPI, all workers start at the same time and pass messages around.
>
> To embed this workload in Spark, we need to introduce a new scheduling model, tentatively named **"barrier scheduling"**, which launches the tasks at the same time and provides users enough information and tooling to embed distributed DL training into a Spark pipeline.

Spark launches all the tasks of a [RDDBarrier](RDDBarrier.md) at the same time.

!!! note "Barrier Scheduling"
    Barrier Execution Mode is also known as **Barrier Scheduling** (see [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md#resourceOffers)).

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

## Barrier Stage

**Barrier Stage** is a [Stage](../scheduler/Stage.md) that...FIXME

## isFromBarrier Flag { #isFromBarrier }

An RDD is in a [barrier stage](#barrier-stage), if at least one of its parent RDD(s), or itself, are mapped from an `RDDBarrier`.

[ShuffledRDD](../rdd/ShuffledRDD.md) has the [isBarrier](../rdd/RDD.md#isBarrier) flag always disabled (`false`).

[MapPartitionsRDD](../rdd/MapPartitionsRDD.md) is the only RDD that can have the [isBarrier](../rdd/RDD.md#isBarrier_) flag enabled.

[RDDBarrier.mapPartitions](RDDBarrier.md#mapPartitions) is the only transformation that creates a [MapPartitionsRDD](../rdd/MapPartitionsRDD.md) with the [isFromBarrier](../rdd/MapPartitionsRDD.md#isFromBarrier) flag enabled.

## Push-Based Shuffle

[Push-based shuffle](../push-based-shuffle.md) is currently not supported for barrier stages.

## Learn More

1. [SPIP: Support Barrier Execution Mode in Apache Spark]({{ spark.jira }}/SPARK-24374) (esp. [Design: Barrier execution mode]({{ spark.jira }}/SPARK-24582))
1. [Barrier Execution Mode in Spark 3.0 - Part 1 : Introduction](https://blog.madhukaraphatak.com/barrier-execution-mode-part-1)
