== [[AllJobsPage]] AllJobsPage -- Showing All Jobs in Web UI

[[prefix]]
`AllJobsPage` is a spark-webui-WebUIPage.md[WebUIPage] with an empty spark-webui-WebUIPage.md#prefix[prefix].

`AllJobsPage` is <<creating-instance, created>> exclusively when `JobsTab` is spark-webui-JobsTab.md#creating-instance[created].

`AllJobsPage` renders a summary, an event timeline, and active, completed, and failed jobs of a Spark application.

TIP: Jobs (in any state) are displayed when their number is greater than `0`.

`AllJobsPage` displays the *Summary* section with the spark-webui-SparkUI.md#getSparkUser[current Spark user], total uptime, scheduling mode, and the number of jobs per status.

NOTE: `AllJobsPage` uses spark-webui-JobProgressListener.md[JobProgressListener] for `Scheduling Mode`.

.Summary Section in Jobs Tab
image::spark-webui-jobs-summary-section.png[align="center"]

Under the summary section is the *Event Timeline* section.

.Event Timeline in Jobs Tab
image::spark-webui-jobs-event-timeline.png[align="center"]

NOTE: spark-webui-AllJobsPage.md[AllJobsPage] uses spark-webui-executors-ExecutorsListener.md[ExecutorsListener] to build the event timeline.

*Active Jobs*, *Completed Jobs*, and *Failed Jobs* sections follow.

.Job Status Section in Jobs Tab
image::spark-webui-jobs-status-section.png[align="center"]

Jobs are clickable, i.e. you can click on a job to <<JobPage, see information about the stages of tasks inside it>>.

When you hover over a job in Event Timeline not only you see the job legend but also the job is highlighted in the Summary section.

.Hovering Over Job in Event Timeline Highlights The Job in Status Section
image::spark-webui-jobs-timeline-popup.png[align="center"]

The Event Timeline section shows not only jobs but also executors.

.Executors in Event Timeline
image::spark-webui-jobs-timeline-executors.png[align="center"]

TIP: Use ROOT:SparkContext.md#dynamic-allocation[Programmable Dynamic Allocation] (using `SparkContext`) to manage executors for demo purposes.

=== [[creating-instance]] Creating AllJobsPage Instance

`AllJobsPage` takes the following when created:

* [[parent]] Parent spark-webui-JobsTab.md[JobsTab]
* [[store]] core:AppStatusStore.md[]
