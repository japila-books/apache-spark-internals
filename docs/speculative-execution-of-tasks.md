# Speculative Execution of Tasks

*Speculative tasks* (also *speculatable tasks* or *task strugglers*) are tasks that run slower than most (FIXME the setting) of the all tasks in a job.

*Speculative execution of tasks* is a health-check procedure that checks for tasks to be *speculated*, i.e. running slower in a stage than the median of all successfully completed tasks in a taskset (FIXME the setting). Such slow tasks will be re-submitted to another worker. It will not stop the slow tasks, but run a new copy in parallel.

The thread starts as `TaskSchedulerImpl` starts in spark-cluster.md[clustered deployment modes] with configuration-properties.md#spark.speculation[spark.speculation] enabled. It executes periodically every configuration-properties.md#spark.speculation.interval[spark.speculation.interval] after the initial `spark.speculation.interval` passes.

When enabled, you should see the following INFO message in the logs:

[source,plaintext]
----
Starting speculative execution thread
----

It works as scheduler:TaskSchedulerImpl.md#task-scheduler-speculation[`task-scheduler-speculation` daemon thread pool] (using `j.u.c.ScheduledThreadPoolExecutor` with core pool size of 1).

The job with speculatable tasks should finish while speculative tasks are running, and it will leave these tasks running - no KILL command yet.

It uses `checkSpeculatableTasks` method that asks `rootPool` to check for speculatable tasks. If there are any, `SchedulerBackend` is called for scheduler:SchedulerBackend.md#reviveOffers[reviveOffers].

CAUTION: FIXME How does Spark handle repeated results of speculative tasks since there are copies launched?
