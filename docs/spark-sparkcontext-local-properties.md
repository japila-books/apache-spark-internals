# Local Properties &mdash; Creating Logical Job Groups

The purpose of *local properties* concept is to create logical groups of jobs by means of properties that (regardless of the threads used to submit the jobs) makes the separate jobs launched from different threads belong to a single logical group.

You can <<setLocalProperty, set a local property>> that will affect Spark jobs submitted from a thread, such as the Spark fair scheduler pool. You can use your own custom properties. The properties are propagated through to worker tasks and can be accessed there via [TaskContext.getLocalProperty](scheduler/TaskContext.md#getLocalProperty).

NOTE: Propagating local properties to workers starts when `SparkContext` is requested to ROOT:SparkContext.md#runJob[run] or ROOT:SparkContext.md#submitJob[submit] a Spark job that in turn scheduler:DAGScheduler.md#runJob[passes them along to `DAGScheduler`].

NOTE: Local properties is used to spark-scheduler-FairSchedulableBuilder.md#spark.scheduler.pool[group jobs into pools in FAIR job scheduler by spark.scheduler.pool per-thread property] and in spark-sql-SQLExecution.md#withNewExecutionId[SQLExecution.withNewExecutionId Helper Methods]

A common use case for the local property concept is to set a local property in a thread, say spark-scheduler-FairSchedulableBuilder.md[spark.scheduler.pool], after which all jobs submitted within the thread will be grouped, say into a pool by FAIR job scheduler.

[source, scala]
----
val rdd = sc.parallelize(0 to 9)

sc.setLocalProperty("spark.scheduler.pool", "myPool")

// these two jobs (one per action) will run in the myPool pool
rdd.count
rdd.collect

sc.setLocalProperty("spark.scheduler.pool", null)

// this job will run in the default pool
rdd.count
----

=== [[localProperties]] Local Properties -- `localProperties` Property

[source, scala]
----
localProperties: InheritableThreadLocal[Properties]
----

`localProperties` is a `protected[spark]` property of a ROOT:SparkContext.md[SparkContext] that are the properties through which you can create logical job groups.

TIP: Read up on Java's https://docs.oracle.com/javase/8/docs/api/java/lang/InheritableThreadLocal.html[java.lang.InheritableThreadLocal].

=== [[setLocalProperty]] Setting Local Property -- `setLocalProperty` Method

[source, scala]
----
setLocalProperty(key: String, value: String): Unit
----

`setLocalProperty` sets `key` local property to `value`.

TIP: When `value` is `null` the `key` property is removed from <<localProperties, localProperties>>.

=== [[getLocalProperty]] Getting Local Property -- `getLocalProperty` Method

[source, scala]
----
getLocalProperty(key: String): String
----

`getLocalProperty` gets a local property by `key` in this thread. It returns `null` if `key` is missing.

=== [[getLocalProperties]] Getting Local Properties -- `getLocalProperties` Method

[source, scala]
----
getLocalProperties: Properties
----

`getLocalProperties` is a `private[spark]` method that gives access to <<localProperties, localProperties>>.

=== [[setLocalProperties]] `setLocalProperties` Method

[source, scala]
----
setLocalProperties(props: Properties): Unit
----

`setLocalProperties` is a `private[spark]` method that sets `props` as <<localProperties, localProperties>>.
