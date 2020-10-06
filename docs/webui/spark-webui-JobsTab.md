= [[JobsTab]] JobsTab

[[prefix]]
`JobsTab` is a xref:spark-webui-SparkUITab.adoc[SparkUITab] with the xref:spark-webui-SparkUITab.adoc#prefix[prefix] as *jobs* and the following pages:

* xref:spark-webui-AllJobsPage.adoc[AllJobsPage]

* xref:spark-webui-JobPage.adoc[JobPage]

`JobsTab` is <<creating-instance, created>> when `SparkUI` is requested to xref:spark-webui-SparkUI.adoc#initialize[initialize].

NOTE: The Jobs tab uses xref:spark-webui-JobProgressListener.adoc[JobProgressListener] to access statistics of job executions in a Spark application to display.

== [[creating-instance]] Creating JobsTab Instance

`JobsTab` takes the following to be created:

* [[parent]] xref:spark-webui-SparkUI.adoc[SparkUI]
* [[store]] xref:core:AppStatusStore.adoc[]

While <<creating-instance, being created>>, `JobsTab` creates and xref:spark-webui-WebUITab.adoc#attachPage[attaches] the pages:

* xref:spark-webui-AllJobsPage.adoc[AllJobsPage]

* xref:spark-webui-JobPage.adoc[JobPage]

== [[handleKillRequest]] `handleKillRequest` Method

[source, scala]
----
handleKillRequest(
  request: HttpServletRequest): Unit
----

`handleKillRequest`...FIXME

NOTE: `handleKillRequest` is used when `SparkUI` is requested to xref:spark-webui-SparkUI.adoc#initialize[initialize] (and registers the `/jobs/job/kill` URL handler).

== [[isFairScheduler]] `isFairScheduler` Method

[source, scala]
----
isFairScheduler: Boolean
----

`isFairScheduler`...FIXME

NOTE: `isFairScheduler` is used when `JobPage` is requested to xref:spark-webui-JobPage.adoc#render[render itself (as a HTML page)].
