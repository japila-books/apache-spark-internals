<style>
code {
  white-space : pre-wrap !important;
}
</style>

# BarrierJobSlotsNumberCheckFailed

`BarrierJobSlotsNumberCheckFailed` is a [BarrierJobAllocationFailed](BarrierJobAllocationFailed.md) with the following [exception message](BarrierJobAllocationFailed.md#message):

```text
[SPARK-24819]: Barrier execution mode does not allow run a barrier stage that requires more slots than the total number of slots in the cluster currently.
Please init a new cluster with more resources(e.g. CPU, GPU) or repartition the input RDD(s) to reduce the number of slots required to run this barrier stage.
```

`BarrierJobSlotsNumberCheckFailed` can be thrown when `DAGScheduler` is requested to [handle a JobSubmitted event](../scheduler/DAGScheduler.md#handleJobSubmitted).

## Creating Instance

`BarrierJobSlotsNumberCheckFailed` takes the following to be created:

* <span id="requiredConcurrentTasks"> Required Concurrent Tasks (based on the [number of partitions](../rdd/RDD.md#getNumPartitions) of a [barrier RDD](../rdd/RDD.md#isBarrier))
* <span id="maxConcurrentTasks"> Maximum Number of Concurrent Tasks (based on a [ResourceProfile](../stage-level-scheduling/ResourceProfile.md) used)

`BarrierJobSlotsNumberCheckFailed` is created when:

* `SparkCoreErrors` is requested to [numPartitionsGreaterThanMaxNumConcurrentTasksError](../SparkCoreErrors.md#numPartitionsGreaterThanMaxNumConcurrentTasksError)
