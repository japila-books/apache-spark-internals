= [[JobsTab]] JobsTab

[[prefix]]
`JobsTab` is a spark-webui-SparkUITab.md[SparkUITab] with the spark-webui-SparkUITab.md#prefix[prefix] as *jobs* and the following pages:

* spark-webui-AllJobsPage.md[AllJobsPage]

* spark-webui-JobPage.md[JobPage]

`JobsTab` is <<creating-instance, created>> when `SparkUI` is requested to spark-webui-SparkUI.md#initialize[initialize].

NOTE: The Jobs tab uses spark-webui-JobProgressListener.md[JobProgressListener] to access statistics of job executions in a Spark application to display.

== [[creating-instance]] Creating JobsTab Instance

`JobsTab` takes the following to be created:

* [[parent]] spark-webui-SparkUI.md[SparkUI]
* [[store]] core:AppStatusStore.md[]

While <<creating-instance, being created>>, `JobsTab` creates and spark-webui-WebUITab.md#attachPage[attaches] the pages:

* spark-webui-AllJobsPage.md[AllJobsPage]

* spark-webui-JobPage.md[JobPage]

== [[handleKillRequest]] `handleKillRequest` Method

[source, scala]
----
handleKillRequest(
  request: HttpServletRequest): Unit
----

`handleKillRequest`...FIXME

NOTE: `handleKillRequest` is used when `SparkUI` is requested to spark-webui-SparkUI.md#initialize[initialize] (and registers the `/jobs/job/kill` URL handler).

== [[isFairScheduler]] `isFairScheduler` Method

[source, scala]
----
isFairScheduler: Boolean
----

`isFairScheduler`...FIXME

NOTE: `isFairScheduler` is used when `JobPage` is requested to spark-webui-JobPage.md#render[render itself (as a HTML page)].
