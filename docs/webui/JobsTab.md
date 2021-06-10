# JobsTab

`JobsTab` is a [SparkUITab](SparkUITab.md) with `jobs` [URL prefix](SparkUITab.md#prefix).

![Jobs Tab in Web UI](../images/webui/spark-webui-jobs.png)

## Creating Instance

`JobsTab` takes the following to be created:

* <span id="parent"> Parent [SparkUI](SparkUI.md)
* <span id="store"> [AppStatusStore](../status/AppStatusStore.md)

`JobsTab` is created when:

* `SparkUI` is requested to [initialize](SparkUI.md#initialize)

## Pages

When [created](#creating-instance), `JobsTab` [attaches](WebUITab.md#attachPage) the following pages (with a reference to itself and the [AppStatusStore](#store)):

* [AllJobsPage](AllJobsPage.md)
* [JobPage](JobPage.md)

## Event Timeline

![Event Timeline in Jobs Tab](../images/webui/spark-webui-jobs-event-timeline.png)

## Details for Job

Clicking a job in [AllJobsPage](AllJobsPage.md), leads to **Details for Job** page.

![Details for Job Page](../images/webui/spark-webui-jobs-details-for-job.png)

When a job id is not found, you should see "No information to display for job ID" message.

!["No information to display for job" in Details for Job Page](../images/webui/spark-webui-jobs-details-for-job-no-job.png)

![Details for Job Page with Active and Pending Stages](../images/webui/spark-webui-jobs-details-for-job-active-pending-stages.png)

![Details for Job Page with Four Stages](../images/webui/spark-webui-jobs-details-for-job-four-stages.png)
