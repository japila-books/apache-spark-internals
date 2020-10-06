== [[StagesTab]] StagesTab -- Stages for All Jobs

[[prefix]]
`StagesTab` is a spark-webui-SparkUITab.md[SparkUITab] with *stages* spark-webui-SparkUITab.md#prefix[prefix].

`StagesTab` is <<creating-instance, created>> exclusively when `SparkUI` is spark-webui-SparkUI.md#initialize[initialized].

When <<creating-instance, created>>, `StagesTab` creates the following pages and spark-webui-WebUITab.md#attachPage[attaches] them immediately:

* spark-webui-AllStagesPage.md[AllStagesPage]

* spark-webui-StagePage.md[StagePage]

* spark-webui-PoolPage.md[PoolPage]

*Stages* tab in spark-webui.md[web UI] shows spark-webui-AllStagesPage.md[the current state of all stages of all jobs in a Spark application] (i.e. a ROOT:SparkContext.md[]) with two optional pages for spark-webui-StagePage.md[the tasks and statistics for a stage] (when a stage is selected) and spark-webui-PoolPage.md[pool details] (when the application works in spark-scheduler-SchedulingMode.md#FAIR[FAIR scheduling mode]).

The title of the tab is *Stages for All Jobs*.

You can access the Stages tab under `/stages` URL, i.e. http://localhost:4040/stages.

With no jobs submitted yet (and hence no stages to display), the page shows nothing but the title.

.Stages Page Empty
image::spark-webui-stages-empty.png[align="center"]

The Stages page shows the stages in a Spark application per state in their respective sections -- *Active Stages*, *Pending Stages*, *Completed Stages*, and *Failed Stages*.

.Stages Page With One Stage Completed
image::spark-webui-stages-completed.png[align="center"]

NOTE: The state sections are only displayed when there are stages in a given state. Refer to spark-webui-AllStagesPage.md[Stages for All Jobs].

In spark-scheduler-SchedulingMode.md#FAIR[FAIR scheduling mode] you have access to the table showing the scheduler pools.

.Fair Scheduler Pools Table
image::spark-webui-stages-fairschedulerpools.png[align="center"]

Internally, the page is represented by https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/ui/jobs/StagesTab.scala[org.apache.spark.ui.jobs.StagesTab] class.

The page uses the parent's spark-webui-SparkUI.md[SparkUI] to access required services, i.e. ROOT:SparkContext.md[], spark-sql-SQLConf.md[SparkConf], spark-webui-JobProgressListener.md[JobProgressListener], spark-webui-RDDOperationGraphListener.md[RDDOperationGraphListener], and to know whether <<killEnabled, kill is enabled or not>>.

`StagesTab` is <<creating-instance, created>> when...FIXME

=== [[killEnabled]] `killEnabled` flag

CAUTION: FIXME

=== [[creating-instance]] Creating StagesTab Instance

`StagesTab` takes the following when created:

* [[parent]] spark-webui-SparkUI.md[SparkUI]
* [[store]] core:AppStatusStore.md[]

=== [[handleKillRequest]] Handling Request to Kill Stage (from web UI) -- `handleKillRequest` Method

[source, scala]
----
handleKillRequest(request: HttpServletRequest): Unit
----

`handleKillRequest`...FIXME

NOTE: `handleKillRequest` is used when...FIXME
