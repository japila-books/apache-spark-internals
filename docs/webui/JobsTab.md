# JobsTab

## Review Me

[[prefix]]
`JobsTab` is a spark-webui-SparkUITab.md[SparkUITab] with the spark-webui-SparkUITab.md#prefix[prefix] as *jobs* and the following pages:

* [AllJobsPage](AllJobsPage.md)

* [JobPage](JobPage.md)

`JobsTab` is <<creating-instance, created>> when `SparkUI` is requested to spark-webui-SparkUI.md#initialize[initialize].

== [[creating-instance]] Creating JobsTab Instance

`JobsTab` takes the following to be created:

* [[parent]] spark-webui-SparkUI.md[SparkUI]
* [[store]] core:AppStatusStore.md[]

While <<creating-instance, being created>>, `JobsTab` creates and spark-webui-WebUITab.md#attachPage[attaches] the pages:

* [AllJobsPage](AllJobsPage.md)

* [JobPage](JobPage.md)

== [[handleKillRequest]] `handleKillRequest` Method

[source, scala]
----
handleKillRequest(
  request: HttpServletRequest): Unit
----

`handleKillRequest`...FIXME

NOTE: `handleKillRequest` is used when `SparkUI` is requested to spark-webui-SparkUI.md#initialize[initialize] (and registers the `/jobs/job/kill` URL handler).
