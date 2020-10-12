# ResultStage

`ResultStage` is the final stage in a job that applies a function on one or many partitions of the target RDD to compute the result of an action.

![Job creates ResultStage as the first stage](../images/scheduler/dagscheduler-job-resultstage.png)

The partitions are given as a collection of partition ids (`partitions`) and the function `func: (TaskContext, Iterator[_]) => _`.

![ResultStage and partitions](../images/scheduler/dagscheduler-resultstage-partitions.png)

== [[findMissingPartitions]] Finding Missing Partitions

[source, scala]
----
findMissingPartitions(): Seq[Int]
----

NOTE: findMissingPartitions is part of the scheduler:Stage.md#findMissingPartitions[Stage] abstraction.

findMissingPartitions...FIXME

.ResultStage.findMissingPartitions and ActiveJob
image::resultstage-findMissingPartitions.png[align="center"]

In the above figure, partitions 1 and 2 are not finished (`F` is false while `T` is true).

== [[func]] `func` Property

CAUTION: FIXME

== [[setActiveJob]] `setActiveJob` Method

CAUTION: FIXME

== [[removeActiveJob]] `removeActiveJob` Method

CAUTION: FIXME

== [[activeJob]] `activeJob` Method

[source, scala]
----
activeJob: Option[ActiveJob]
----

`activeJob` returns the optional `ActiveJob` associated with a `ResultStage`.

CAUTION: FIXME When/why would that be `NONE` (empty)?
