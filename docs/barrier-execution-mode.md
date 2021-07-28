= Barrier Execution Mode

*Barrier Execution Mode* is...FIXME

See https://jira.apache.org/jira/browse/SPARK-24374[SPIP: Barrier Execution Mode] and https://jira.apache.org/jira/browse/SPARK-24582[Design Doc].

NOTE: The barrier execution mode is experimental and it only handles limited scenarios.

In case of a task failure, instead of only restarting the failed task, Spark will abort the entire stage and re-launch all tasks for this stage.

Use <<spark-rdd-transformations.md#barrier, RDD.barrier>> transformation to mark the current stage as a <<barrier-stage, barrier stage>>.

[[barrier]]
[source, scala]
----
barrier(): RDDBarrier[T]
----

`barrier` simply creates a <<spark-RDDBarrier.md#, RDDBarrier>> that comes with the barrier-aware <<spark-RDDBarrier.md#mapPartitions, mapPartitions>> transformation.

[[mapPartitions]]
[source, scala]
----
mapPartitions[S: ClassTag](
  f: Iterator[T] => Iterator[S],
  preservesPartitioning: Boolean = false): RDD[S]
----

`mapPartitions` is simply changes the regular <<spark-rdd-transformations.md#mapPartitions, RDD.mapPartitions>> transformation to create a rdd:MapPartitionsRDD.md[MapPartitionsRDD] with the rdd:MapPartitionsRDD.md#isFromBarrier[isFromBarrier] flag enabled.

* `Task` has a scheduler:Task.md#isBarrier[isBarrier] flag that says whether this task belongs to a barrier stage (default: `false`).

Spark must launch all the tasks at the same time for a <<barrier-stage, barrier stage>>.

An RDD is in a <<barrier-stage, barrier stage>>, if at least one of its parent RDD(s), or itself, are mapped from an `RDDBarrier`.

rdd:ShuffledRDD.md[ShuffledRDD] has the rdd:RDD.md#isBarrier[isBarrier] flag always disabled (`false`).

rdd:MapPartitionsRDD.md[MapPartitionsRDD] is the only one RDD that can have the rdd:RDD.md#isBarrier_[isBarrier] flag enabled.

rdd:spark-RDDBarrier.md#mapPartitions[RDDBarrier.mapPartitions] is the only transformation that creates a rdd:MapPartitionsRDD.md[MapPartitionsRDD] with the rdd:MapPartitionsRDD.md#isFromBarrier[isFromBarrier] flag enabled.

== [[barrier-stage]] Barrier Stage

*Barrier Stage* is a scheduler:Stage.md[stage] that...FIXME
