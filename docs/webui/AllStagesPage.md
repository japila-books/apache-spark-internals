== [[AllStagesPage]] Stages for All Jobs Page

`AllStagesPage` is a web page (section) that is registered with the spark-webui-StagesTab.md[Stages tab] that <<render, displays all stages in a Spark application>> - active, pending, completed, and failed stages with their count.

.Stages Tab in web UI for FAIR scheduling mode (with pools only)
image::spark-webui-stages-alljobs.png[align="center"]

[[pool-names]]
In spark-scheduler-SchedulingMode.md#FAIR[FAIR scheduling mode] you have access to the table showing the scheduler pools as well as the pool names per stage.

NOTE: Pool names are calculated using ROOT:SparkContext.md#getAllPools[SparkContext.getAllPools].

Internally, `AllStagesPage` is a spark-webui-WebUIPage.md[WebUIPage] with access to the parent spark-webui-StagesTab.md[Stages tab] and more importantly the spark-webui-JobProgressListener.md[JobProgressListener] to have access to current state of the entire Spark application.

=== [[render]] Rendering AllStagesPage (render method)

[source, scala]
----
render(request: HttpServletRequest): Seq[Node]
----

`render` generates a HTML page to display in a web browser.

It uses the parent's spark-webui-JobProgressListener.md[JobProgressListener] to know about:

* active stages (as `activeStages`)
* pending stages (as `pendingStages`)
* completed stages (as `completedStages`)
* failed stages (as `failedStages`)
* the number of completed stages (as `numCompletedStages`)
* the number of failed stages (as `numFailedStages`)

NOTE: Stage information is available as [StageInfo](../scheduler/StageInfo.md) object.

There are 4 different tables for the different states of stages - active, pending, completed, and failed. They are displayed only when there are stages in a given state.

.Stages Tab in web UI for FAIR scheduling mode (with pools and stages)
image::spark-webui-stages.png[align="center"]

You could also notice "retry" for stage when it was retried.

CAUTION: FIXME A screenshot
