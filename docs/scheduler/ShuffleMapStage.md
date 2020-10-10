# ShuffleMapStage

`ShuffleMapStage` (_shuffle map stage_ or simply _map stage_) is one of the two types of [stages](Stage.md) in a physical execution DAG (beside a [ResultStage](ResultStage.md)).

NOTE: The *logical DAG* or *logical execution plan* is the [RDD lineage](../rdd/spark-rdd-lineage.md).

ShuffleMapStage corresponds to (and is associated with) a <<shuffleDep, ShuffleDependency>>.

ShuffleMapStage is created when DAGScheduler is requested to DAGScheduler.md#createShuffleMapStage[plan a ShuffleDependency for execution].

ShuffleMapStage can also be DAGScheduler.md#submitMapStage[submitted independently as a Spark job] for DAGScheduler.md#adaptive-query-planning[Adaptive Query Planning / Adaptive Scheduling].

ShuffleMapStage is an input for the other following stages in the DAG of stages and is also called a *shuffle dependency's map side*.

## Creating Instance

ShuffleMapStage takes the following to be created:

* [[id]] Stage ID
* [[rdd]] [RDD](../rdd/ShuffleDependency.md#rdd) of the <<shuffleDep, ShuffleDependency>>
* [[numTasks]] Number of tasks
* [[parents]] Parent Stage.md[stages]
* [[firstJobId]] ID of the [ActiveJob](ActiveJob.md) that created it
* [[callSite]] CallSite
* [[shuffleDep]] [ShuffleDependency](../rdd/ShuffleDependency.md)
* [[mapOutputTrackerMaster]] [MapOutputTrackerMaster](MapOutputTrackerMaster.md)

== [[_mapStageJobs]][[mapStageJobs]][[addActiveJob]][[removeActiveJob]] Jobs Registry

ShuffleMapStage keeps track of [jobs](ActiveJob.md) that were submitted to execute it independently (if any).

The registry is used when DAGScheduler is requested to DAGScheduler.md#markMapStageJobsAsFinished[markMapStageJobsAsFinished] (FIXME: when DAGSchedulerEventProcessLoop.md#handleTaskCompletion[`DAGScheduler` is notified that a `ShuffleMapTask` has finished successfully] and the task made ShuffleMapStage completed and so marks any map-stage jobs waiting on this stage as finished).

A new job is registered (_added_) when DAGScheduler is DAGScheduler.md#handleMapStageSubmitted[notified that a ShuffleDependency was submitted for execution (as a MapStageSubmitted event)].

An active job is deregistered (_removed_) when DAGScheduler is requested to DAGScheduler.md#cleanupStateForJobAndIndependentStages[clean up after a job and independent stages].

== [[isAvailable]][[numAvailableOutputs]] ShuffleMapStage is Available (Fully Computed)

When executed, a ShuffleMapStage saves *map output files* (for reduce tasks).

When all <<numPartitions, partitions>> have shuffle map outputs available, ShuffleMapStage is considered *available* (_done_ or _ready_).

ShuffleMapStage is asked about its availability when DAGScheduler is requested for DAGScheduler.md#getMissingParentStages[missing parent map stages for a stage], DAGScheduler.md#handleMapStageSubmitted[handleMapStageSubmitted], DAGScheduler.md#submitMissingTasks[submitMissingTasks], DAGScheduler.md#handleTaskCompletion[handleTaskCompletion], DAGScheduler.md#markMapStageJobsAsFinished[markMapStageJobsAsFinished], DAGScheduler.md#stageDependsOn[stageDependsOn].

ShuffleMapStage uses the <<mapOutputTrackerMaster, MapOutputTrackerMaster>> for the MapOutputTrackerMaster.md#getNumAvailableOutputs[number of partitions with shuffle map outputs available] (of the <<shuffleDep, ShuffleDependency>> by the shuffle ID).

== [[findMissingPartitions]] Finding Missing Partitions

[source, scala]
----
findMissingPartitions(): Seq[Int]
----

findMissingPartitions requests the <<mapOutputTrackerMaster, MapOutputTrackerMaster>> for the MapOutputTrackerMaster.md#findMissingPartitions[missing partitions] (of the <<shuffleDep, ShuffleDependency>> by the shuffle ID) and returns them.

If MapOutputTrackerMaster does not track the ShuffleDependency yet, findMissingPartitions simply returns all the Stage.md#numPartitions[partitions] as missing.

findMissingPartitions is part of the Stage.md#findMissingPartitions[Stage] abstraction.

== [[stage-sharing]] ShuffleMapStage Sharing

A ShuffleMapStage can be shared across multiple jobs, if these jobs reuse the same RDDs.

.Skipped Stages are already-computed ShuffleMapStages
image::dagscheduler-webui-skipped-stages.png[align="center"]

[source, scala]
----
val rdd = sc.parallelize(0 to 5).map((_,1)).sortByKey()  // <1>
rdd.count  // <2>
rdd.count  // <3>
----
<1> Shuffle at `sortByKey()`
<2> Submits a job with two stages with two being executed
<3> Intentionally repeat the last action that submits a new job with two stages with one being shared as already-being-computed
