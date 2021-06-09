# JobsTab

![Jobs Tab in Web UI](../images/webui/spark-webui-jobs.png)

## Event Timeline

![Event Timeline in Jobs Tab](../images/webui/spark-webui-jobs-event-timeline.png)

## Details for Job

Clicking a job in [AllJobsPage](AllJobsPage.md), leads to **Details for Job** page.

![Details for Job Page](../images/webui/spark-webui-jobs-details-for-job.png)

When a job id is not found, you should see "No information to display for job ID" message.

!["No information to display for job" in Details for Job Page](../images/webui/spark-webui-jobs-details-for-job-no-job.png)

![Details for Job Page with Active and Pending Stages](../images/webui/spark-webui-jobs-details-for-job-active-pending-stages.png)

![Details for Job Page with Four Stages](../images/webui/spark-webui-jobs-details-for-job-four-stages.png)

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
