== [[StagesResource]] StagesResource

`StagesResource` is...FIXME

[[paths]]
.StagesResource's Paths
[cols="1,1,2",options="header",width="100%"]
|===
| Path
| HTTP Method
| Description

|
| GET
| <<stageList, stageList>>

| `{stageId: \d+}`
| GET
| <<stageData, stageData>>

| `{stageId: \d+}/{stageAttemptId: \d+}`
| GET
| <<oneAttemptData, oneAttemptData>>

| `{stageId: \d+}/{stageAttemptId: \d+}/taskSummary`
| GET
| <<taskSummary, taskSummary>>

| `{stageId: \d+}/{stageAttemptId: \d+}/taskList`
| GET
| <<taskList, taskList>>
|===

=== [[stageList]] `stageList` Method

[source, scala]
----
stageList(@QueryParam("status") statuses: JList[StageStatus]): Seq[StageData]
----

`stageList`...FIXME

NOTE: `stageList` is used when...FIXME

=== [[stageData]] `stageData` Method

[source, scala]
----
stageData(
  @PathParam("stageId") stageId: Int,
  @QueryParam("details") @DefaultValue("true") details: Boolean): Seq[StageData]
----

`stageData`...FIXME

NOTE: `stageData` is used when...FIXME

=== [[oneAttemptData]] `oneAttemptData` Method

[source, scala]
----
oneAttemptData(
  @PathParam("stageId") stageId: Int,
  @PathParam("stageAttemptId") stageAttemptId: Int,
  @QueryParam("details") @DefaultValue("true") details: Boolean): StageData
----

`oneAttemptData`...FIXME

NOTE: `oneAttemptData` is used when...FIXME

=== [[taskSummary]] `taskSummary` Method

[source, scala]
----
taskSummary(
  @PathParam("stageId") stageId: Int,
  @PathParam("stageAttemptId") stageAttemptId: Int,
  @DefaultValue("0.05,0.25,0.5,0.75,0.95") @QueryParam("quantiles") quantileString: String)
: TaskMetricDistributions
----

`taskSummary`...FIXME

NOTE: `taskSummary` is used when...FIXME

=== [[taskList]] `taskList` Method

[source, scala]
----
taskList(
  @PathParam("stageId") stageId: Int,
  @PathParam("stageAttemptId") stageAttemptId: Int,
  @DefaultValue("0") @QueryParam("offset") offset: Int,
  @DefaultValue("20") @QueryParam("length") length: Int,
  @DefaultValue("ID") @QueryParam("sortBy") sortBy: TaskSorting): Seq[TaskData]
----

`taskList`...FIXME

NOTE: `taskList` is used when...FIXME
