# DAGSchedulerSource

`DAGSchedulerSource` is the [metrics source](../metrics/Source.md) of [DAGScheduler](DAGScheduler.md#DAGSchedulerSource).

The name of the source is **DAGScheduler**.

`DAGSchedulerSource` emits the following metrics:

* **stage.failedStages** - the number of failed stages
* **stage.runningStages** - the number of running stages
* **stage.waitingStages** - the number of waiting stages
* **job.allJobs** - the number of all jobs
* **job.activeJobs** - the number of active jobs
