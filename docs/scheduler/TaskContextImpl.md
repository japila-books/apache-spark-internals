# TaskContextImpl

`TaskContextImpl` is a concrete [TaskContext](TaskContext.md).

## Creating Instance

`TaskContextImpl` takes the following to be created:

* <span id="stageId"> [Stage](Stage.md) ID
* <span id="stageAttemptNumber"> `Stage` Execution Attempt ID
* <span id="partitionId"> Partition ID
* <span id="taskAttemptId"> Task Execution Attempt ID
* <span id="attemptNumber"> Attempt Number
* <span id="taskMemoryManager"> [TaskMemoryManager](../memory/TaskMemoryManager.md)
* <span id="localProperties"> [Local Properties](../SparkContext.md#localProperties)
* <span id="metricsSystem"> [MetricsSystem](../metrics/MetricsSystem.md)
* <span id="taskMetrics"> [TaskMetrics](../executor/TaskMetrics.md)
* [Resources](#resources)

`TaskContextImpl` is created when:

* `Task` is requested to [run](Task.md#run)

### Resources

??? note "TaskContext"

    ```scala
    resources: Map[String, ResourceInformation]
    ```

    `resources` is part of the [TaskContext](TaskContext.md#resources) abstraction.

`TaskContextImpl` can be given resources (names) when [created](#creating-instance).

The resources are given when a `Task` is requested to [run](Task.md#run) that in turn come from a [TaskDescription](TaskDescription.md#resources) (of a [TaskRunner](../executor/TaskRunner.md#taskDescription)).

## <span id="BarrierTaskContext"> BarrierTaskContext

`TaskContextImpl` is available to [barrier tasks](Task.md#isBarrier) as a [BarrierTaskContext](../barrier-execution-mode/BarrierTaskContext.md).
