# Spark Scheduler

**Spark Scheduler** is a core component of Apache Spark that is responsible for scheduling tasks for execution.

Spark Scheduler uses the high-level stage-oriented [DAGScheduler](DAGScheduler.md) and the low-level task-oriented [TaskScheduler](TaskScheduler.md).

## Stage Execution

Every partition of a [Stage](Stage.md) is transformed into a [Task](Task.md) ([ShuffleMapTask](ShuffleMapTask.md) or [ResultTask](ResultTask.md) for [ShuffleMapStage](ShuffleMapStage.md) and [ResultStage](ResultStage.md), respectively).

Submitting a stage can therefore trigger execution of a series of dependent parent stages.

![Submitting a job triggers execution of the stage and its parent stages](../images/scheduler/job-stage.png)

When a Spark job is submitted, a new stage is created (they can be created from scratch or linked to, i.e. shared, if other jobs use them already).

![DAGScheduler and Stages for a job](../images/scheduler/scheduler-job-shuffles-result-stages.png)

`DAGScheduler` splits up a job into a collection of [Stage](Stage.md)s. A `Stage` contains a sequence of [narrow transformations](../rdd/index.md) that can be completed without shuffling data set, separated at **shuffle boundaries** (where shuffle occurs). Stages are thus a result of breaking the RDD graph at shuffle boundaries.

![Graph of Stages](../images/scheduler/dagscheduler-stages.png)

Shuffle boundaries introduce a barrier where stages/tasks must wait for the previous stage to finish before they fetch map outputs.

![DAGScheduler splits a job into stages](../images/scheduler/scheduler-job-splits-into-stages.png)

## Resources

* [Deep Dive into the Apache Spark Scheduler](https://databricks.com/session/apache-spark-scheduler) by Xingbo Jiang (Databricks)
