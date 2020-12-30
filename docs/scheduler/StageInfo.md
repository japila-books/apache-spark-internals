# StageInfo

`StageInfo` is a metadata about a [stage](#stageId) to pass from the scheduler to SparkListeners.

## Creating Instance

`StageInfo` takes the following to be created:

* <span id="stageId"> Stage ID
* <span id="attemptId"> Stage Attempt ID
* <span id="name"> Name
* <span id="numTasks"> Number of Tasks
* <span id="rddInfos"> [RDDInfo](../storage/RDDInfo.md)s
* <span id="parentIds"> Parent IDs
* <span id="details"> Details
* <span id="taskMetrics"> [TaskMetrics](../executor/TaskMetrics.md) (default: `null`)
* <span id="taskLocalityPreferences"> [Task Locality Preferences](TaskLocation.md) (default: empty)
* <span id="shuffleDepId"> Optional Shuffle Dependency ID (default: undefined)

`StageInfo` is created when:

* `StageInfo` utility is used to [fromStage](#fromStage)
* `JsonProtocol` (History Server) is used to [stageInfoFromJson](../history-server/JsonProtocol.md#stageInfoFromJson)

## <span id="fromStage"> fromStage Utility

```scala
fromStage(
  stage: Stage,
  attemptId: Int,
  numTasks: Option[Int] = None,
  taskMetrics: TaskMetrics = null,
  taskLocalityPreferences: Seq[Seq[TaskLocation]] = Seq.empty): StageInfo
```

`fromStage`...FIXME

`fromStage` is used when:

* `Stage` is [created](Stage.md#_latestInfo) and [make a new Stage attempt](Stage.md#makeNewStageAttempt)
