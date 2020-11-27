== [[PoolPage]] PoolPage -- Fair Scheduler Pool Details Page

[[prefix]]
`PoolPage` is a spark-webui-WebUIPage.md[WebUIPage] with *pool* spark-webui-WebUIPage.md#prefix[prefix].

The Fair Scheduler Pool Details page shows information about a spark-scheduler-Pool.md[`Schedulable` pool] and is only available when a Spark application uses the spark-scheduler-SchedulingMode.md#FAIR[FAIR scheduling mode] (which is controlled by configuration-properties.md#spark.scheduler.mode[spark.scheduler.mode] configuration property).

.Details Page for production Pool
image::spark-webui-pool-details.png[align="center"]

`PoolPage` renders a page under `/pool` URL and requires one request parameter <<poolname, poolname>> that is the name of the pool to display, e.g. http://localhost:4040/stages/pool/?poolname=production. It is made up of two tables: <<pool-summary, Summary>> (with the details of the pool) and <<active-stages, Active Stages>> (with the active stages in the pool).

`PoolPage` is <<creating-instance, created>> exclusively when `StagesTab` is spark-webui-StagesTab.md#creating-instance[created].

[[creating-instance]]
[[parent]]
`PoolPage` takes a spark-webui-StagesTab.md[StagesTab] when created.

`PoolPage` uses the parent's SparkContext.md#getPoolForName[`SparkContext` to access information about the pool] and spark-webui-JobProgressListener.md#poolToActiveStages[`JobProgressListener` for active stages in the pool] (sorted by `submissionTime` in descending order by default).

=== [[PoolTable]][[pool-summary]] Summary Table

The *Summary* table shows the details of a spark-scheduler-Schedulable.md[`Schedulable` pool].

.Summary for production Pool
image::spark-webui-pool-summary.png[align="center"]

It uses the following columns:

* *Pool Name*
* *Minimum Share*
* *Pool Weight*
* *Active Stages* - the number of the active stages in a `Schedulable` pool.
* *Running Tasks*
* *SchedulingMode*

All the columns are the attributes of a `Schedulable` but the number of active stages which is calculated using the spark-webui-JobProgressListener.md#poolToActiveStages[list of active stages of a pool] (from the parent's spark-webui-JobProgressListener.md[JobProgressListener]).

=== [[StageTableBase]][[active-stages]] Active Stages Table

The *Active Stages* table shows the active stages in a pool.

.Active Stages for production Pool
image::spark-webui-active-stages.png[align="center"]

It uses the following columns:

* *Stage Id*
* (optional) *Pool Name* - only available when in FAIR scheduling mode.
* *Description*
* *Submitted*
* *Duration*
* *Tasks: Succeeded/Total*
* *Input* -- Bytes and records read from Hadoop or from Spark storage.
* *Output* -- Bytes and records written to Hadoop.
* *Shuffle Read* -- Total shuffle bytes and records read (includes both data read locally and data read from remote executors).
* *Shuffle Write* -- Bytes and records written to disk in order to be read by a shuffle in a future stage.

The table uses spark-webui-JobProgressListener.md#stageIdToData[`JobProgressListener` for information per stage in the pool].

=== [[parameters]] Request Parameters

==== [[poolname]] poolname

`poolname` is the name of the scheduler pool to display on the page. It is a mandatory request parameter.
