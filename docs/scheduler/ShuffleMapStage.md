= [[ShuffleMapStage]] ShuffleMapStage

*ShuffleMapStage* (_shuffle map stage_ or simply _map stage_) is one of the two types of scheduler:Stage.md[stages] in a physical execution DAG (beside a scheduler:ResultStage.md[ResultStage]).

NOTE: The *logical DAG* or *logical execution plan* is the rdd:spark-rdd-lineage.md[RDD lineage].

ShuffleMapStage corresponds to (and is associated with) a <<shuffleDep, ShuffleDependency>>.

ShuffleMapStage is created when DAGScheduler is requested to scheduler:DAGScheduler.md#createShuffleMapStage[plan a ShuffleDependency for execution].

ShuffleMapStage can also be scheduler:DAGScheduler.md#submitMapStage[submitted independently as a Spark job] for scheduler:DAGScheduler.md#adaptive-query-planning[Adaptive Query Planning / Adaptive Scheduling].

ShuffleMapStage is an input for the other following stages in the DAG of stages and is also called a *shuffle dependency's map side*.

== [[creating-instance]] Creating Instance

ShuffleMapStage takes the following to be created:

* [[id]] Stage ID
* [[rdd]] rdd:ShuffleDependency.md#rdd[RDD] of the <<shuffleDep, ShuffleDependency>>
* [[numTasks]] Number of tasks
* [[parents]] Parent scheduler:Stage.md[stages]
* [[firstJobId]] ID of the scheduler:spark-scheduler-ActiveJob.md[ActiveJob] that created it
* [[callSite]] CallSite
* [[shuffleDep]] rdd:ShuffleDependency.md[ShuffleDependency]
* [[mapOutputTrackerMaster]] scheduler:MapOutputTrackerMaster.md[MapOutputTrackerMaster]

ShuffleMapStage initializes the <<internal-registries, internal registries and counters>>.

== [[_mapStageJobs]][[mapStageJobs]][[addActiveJob]][[removeActiveJob]] Jobs Registry

ShuffleMapStage keeps track of scheduler:spark-scheduler-ActiveJob.md[jobs] that were submitted to execute it independently (if any).

The registry is used when DAGScheduler is requested to scheduler:DAGScheduler.md#markMapStageJobsAsFinished[markMapStageJobsAsFinished] (FIXME: when scheduler:DAGSchedulerEventProcessLoop.md#handleTaskCompletion[`DAGScheduler` is notified that a `ShuffleMapTask` has finished successfully] and the task made ShuffleMapStage completed and so marks any map-stage jobs waiting on this stage as finished).

A new job is registered (_added_) when DAGScheduler is scheduler:DAGScheduler.md#handleMapStageSubmitted[notified that a ShuffleDependency was submitted for execution (as a MapStageSubmitted event)].

An active job is deregistered (_removed_) when DAGScheduler is requested to scheduler:DAGScheduler.md#cleanupStateForJobAndIndependentStages[clean up after a job and independent stages].

== [[isAvailable]][[numAvailableOutputs]] ShuffleMapStage is Available (Fully Computed)

When executed, a ShuffleMapStage saves *map output files* (for reduce tasks).

When all <<numPartitions, partitions>> have shuffle map outputs available, ShuffleMapStage is considered *available* (_done_ or _ready_).

ShuffleMapStage is asked about its availability when DAGScheduler is requested for scheduler:DAGScheduler.md#getMissingParentStages[missing parent map stages for a stage], scheduler:DAGScheduler.md#handleMapStageSubmitted[handleMapStageSubmitted], scheduler:DAGScheduler.md#submitMissingTasks[submitMissingTasks], scheduler:DAGScheduler.md#handleTaskCompletion[handleTaskCompletion], scheduler:DAGScheduler.md#markMapStageJobsAsFinished[markMapStageJobsAsFinished], scheduler:DAGScheduler.md#stageDependsOn[stageDependsOn].

ShuffleMapStage uses the <<mapOutputTrackerMaster, MapOutputTrackerMaster>> for the scheduler:MapOutputTrackerMaster.md#getNumAvailableOutputs[number of partitions with shuffle map outputs available] (of the <<shuffleDep, ShuffleDependency>> by the shuffle ID).

== [[findMissingPartitions]] Finding Missing Partitions

[source, scala]
----
findMissingPartitions(): Seq[Int]
----

findMissingPartitions requests the <<mapOutputTrackerMaster, MapOutputTrackerMaster>> for the scheduler:MapOutputTrackerMaster.md#findMissingPartitions[missing partitions] (of the <<shuffleDep, ShuffleDependency>> by the shuffle ID) and returns them.

If MapOutputTrackerMaster does not track the ShuffleDependency yet, findMissingPartitions simply returns all the scheduler:Stage.md#numPartitions[partitions] as missing.

findMissingPartitions is part of the scheduler:Stage.md#findMissingPartitions[Stage] abstraction.

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
