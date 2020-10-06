= ExternalClusterManager

ExternalClusterManager is a <<contract, contract for pluggable cluster managers>>. It returns a scheduler:TaskScheduler.md[task scheduler] and a scheduler:SchedulerBackend.md[backend scheduler] that will be used by ROOT:SparkContext.md[SparkContext] to schedule tasks.

NOTE: The support for pluggable cluster managers was introduced in https://issues.apache.org/jira/browse/SPARK-13904[SPARK-13904 Add support for pluggable cluster manager].

External cluster managers are spark-SparkContext-creating-instance-internals.md#getClusterManager[registered using the `java.util.ServiceLoader` mechanism] (with service markers under `META-INF/services` directory). This allows auto-loading implementations of ExternalClusterManager interface.

NOTE: ExternalClusterManager is a `private[spark]` trait in `org.apache.spark.scheduler` package.

NOTE: The two implementations of the <<contract, ExternalClusterManager contract>> in Spark 2.0 are yarn/spark-yarn-YarnClusterManager.md[YarnClusterManager] and `MesosClusterManager`.

== [[contract]] ExternalClusterManager Contract

=== [[canCreate]] `canCreate` Method

[source, scala]
----
canCreate(masterURL: String): Boolean
----

`canCreate` is a mechanism to match a ExternalClusterManager implementation to a given master URL.

NOTE: `canCreate` is used when spark-SparkContext-creating-instance-internals.md#getClusterManager[`SparkContext` loads the external cluster manager for a master URL].

=== [[createTaskScheduler]] `createTaskScheduler` Method

[source, scala]
----
createTaskScheduler(sc: SparkContext, masterURL: String): TaskScheduler
----

`createTaskScheduler` creates a scheduler:TaskScheduler.md[TaskScheduler] given a ROOT:SparkContext.md[SparkContext] and the input `masterURL`.

=== [[createSchedulerBackend]] `createSchedulerBackend` Method

[source, scala]
----
createSchedulerBackend(sc: SparkContext,
  masterURL: String,
  scheduler: TaskScheduler): SchedulerBackend
----

`createSchedulerBackend` creates a scheduler:SchedulerBackend.md[SchedulerBackend] given a ROOT:SparkContext.md[SparkContext], the input `masterURL`, and scheduler:TaskScheduler.md[TaskScheduler].

=== [[initialize]] Initializing Scheduling Components -- `initialize` Method

[source, scala]
----
initialize(scheduler: TaskScheduler, backend: SchedulerBackend): Unit
----

`initialize` is called after the scheduler:TaskScheduler.md[task scheduler] and the scheduler:SchedulerBackend.md[backend scheduler] were created and initialized separately.

NOTE: There is a cyclic dependency between a task scheduler and a backend scheduler that begs for this additional initialization step.

NOTE: scheduler:TaskScheduler.md[TaskScheduler] and scheduler:SchedulerBackend.md[SchedulerBackend] (with scheduler:DAGScheduler.md[DAGScheduler]) are commonly referred to as *scheduling components*.
