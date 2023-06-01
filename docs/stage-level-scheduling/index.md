# Stage-Level Scheduling

**Stage-Level Scheduling** uses [ResourceProfile](ResourceProfile.md)s for the following:

* Spark developers can specify task and executor resource requirements at stage level
* Spark (Scheduler) uses the stage-level requirements to acquire the necessary resources and executors and schedule tasks based on the per-stage requirements

`ResourceProfile` is associated with an `RDD` using [withResources](../rdd/RDD.md#withResources) operator.

!!! note "Apache Spark 3.1.1"
    Stage-Level Scheduling was introduced in Apache Spark 3.1.1 (cf. [SPARK-27495](https://issues.apache.org/jira/browse/SPARK-27495))
