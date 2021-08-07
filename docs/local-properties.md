# Local Properties

`SparkContext.setLocalProperty` lets you set key-value pairs that will be propagated down to tasks and can be accessed there using [TaskContext.getLocalProperty](scheduler/TaskContext.md#getLocalProperty).

## Creating Logical Job Groups

One of the purposes of local properties is to create logical groups of Spark jobs by means of properties that (regardless of the threads used to submit the jobs) makes the separate jobs launched from different threads belong to a single logical group.

A common use case for the local property concept is to set a local property in a thread, say spark-scheduler-FairSchedulableBuilder.md[spark.scheduler.pool], after which all jobs submitted within the thread will be grouped, say into a pool by FAIR job scheduler.

```scala
val data = sc.parallelize(0 to 9)

sc.setLocalProperty("spark.scheduler.pool", "myPool")

// these two jobs (one per action) will run in the myPool pool
data.count
data.collect

sc.setLocalProperty("spark.scheduler.pool", null)

// this job will run in the default pool
data.count
```
