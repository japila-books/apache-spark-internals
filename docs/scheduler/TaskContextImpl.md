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
* <span id="resources"> Resources (`Map[String, ResourceInformation]`)

`TaskContextImpl` is created when:

* `Task` is requested to [run](Task.md#run)

## <span id="BarrierTaskContext"> BarrierTaskContext

`TaskContextImpl` is available to [barrier tasks](Task.md#isBarrier) as a [BarrierTaskContext](BarrierTaskContext.md).
