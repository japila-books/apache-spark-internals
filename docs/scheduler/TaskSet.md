# TaskSet

`TaskSet` is a [collection of independent tasks](#tasks) of a [stage](#stageId) (and a [stage execution attempt](#stageAttemptId)) that are **missing** (_uncomputed_), i.e. for which computation results are unavailable (as RDD blocks on [BlockManagers](../storage/BlockManager.md) on executors).

In other words, a `TaskSet` represents the missing partitions of a stage that (as tasks) can be run right away based on the data that is already on the cluster, e.g. map output files from previous stages, though they may fail if this data becomes unavailable.

Since the [tasks](#tasks) are only the missing tasks, their number does not necessarily have to be the number of all the tasks of a [stage](#stageId). For a brand new stage (that has never been attempted to compute) their numbers are exactly the same.

Once `DAGScheduler` [submits the missing tasks](DAGScheduler.md#submitMissingTasks) for execution (to the [TaskScheduler](TaskScheduler.md)), the execution of the `TaskSet` is managed by a [TaskSetManager](TaskSetManager.md) that allows for [spark.task.maxFailures](../configuration-properties.md#spark.task.maxFailures).

## Creating Instance

`TaskSet` takes the following to be created:

* <span id="tasks"> [Task](Task.md)s
* <span id="stageId"> Stage ID
* <span id="stageAttemptId"> Stage (Execution) Attempt ID
* [FIFO Priority](#priority)
* <span id="properties"> [Local Properties](../SparkContext.md#localProperties)
* <span id="resourceProfileId"> Resource Profile ID

`TaskSet` is created when:

* `DAGScheduler` is requested to [submit the missing tasks of a stage](DAGScheduler.md#submitMissingTasks)

## <span id="id"> ID

```scala
id: String
```

`TaskSet` is uniquely identified by an `id` that uses the [stageId](#stageId) followed by the [stageAttemptId](#stageAttemptId) with the comma (`.`) in-between:

```text
[stageId].[stageAttemptId]
```

## <span id="toString"> Textual Representation

```scala
toString: String
```

`toString` follows the pattern:

```text
TaskSet [stageId].[stageAttemptId]
```

## <span id="priority"><span id="fifo-scheduling"> Task Scheduling Prioritization (FIFO Scheduling)

`TaskSet` is given a `priority` when [created](#creating-instance).

The priority is the ID of the earliest-created active job that needs the stage (that is given when `DAGScheduler` is requested to [submit the missing tasks of a stage](DAGScheduler.md#submitMissingTasks)).

Once submitted for execution, the priority is the [priority](TaskSetManager.md#priority) of the `TaskSetManager` (which is a [Schedulable](Schedulable.md)) that is used for **task prioritization** (_prioritizing scheduling of tasks_) in the [FIFO](Pool.md#FIFOSchedulingAlgorithm) scheduling mode.
