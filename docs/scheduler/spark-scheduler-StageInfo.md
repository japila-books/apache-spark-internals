= StageInfo

== [[fromStage]] fromStage Method

[source, scala]
----
fromStage(
  stage: Stage,
  attemptId: Int,
  numTasks: Option[Int] = None,
  taskMetrics: TaskMetrics = null,
  taskLocalityPreferences: Seq[Seq[TaskLocation]]
----

fromStage...FIXME

fromStage is used when Stage is created (and initializes the scheduler:Stage.md#_latestInfo[StageInfo]) and scheduler:Stage.md#makeNewStageAttempt[makeNewStageAttempt].
