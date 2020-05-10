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

fromStage is used when Stage is created (and initializes the xref:scheduler:Stage.adoc#_latestInfo[StageInfo]) and xref:scheduler:Stage.adoc#makeNewStageAttempt[makeNewStageAttempt].
