# DAGSchedulerSource

`DAGSchedulerSource` is the [metrics source](Source.md) of [DAGScheduler](../scheduler/DAGScheduler.md).

`DAGScheduler` uses [Spark Metrics System](MetricsSystem.md) to report metrics about internal status.

The name of the source is **DAGScheduler**.

`DAGSchedulerSource` emits the following metrics:

* **stage.failedStages** - the number of failed stages
* **stage.runningStages** - the number of running stages
* **stage.waitingStages** - the number of waiting stages
* **job.allJobs** - the number of all jobs
* **job.activeJobs** - the number of active jobs
