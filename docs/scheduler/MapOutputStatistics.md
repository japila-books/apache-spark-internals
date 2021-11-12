# MapOutputStatistics

`MapOutputStatistics` holds statistics about the [output partition sizes](#bytesByPartitionId) in a [map stage](#shuffleId).

`MapOutputStatistics` is the result of executing the following (currently internal APIs):

* `SparkContext` is requested to [submitMapStage](../SparkContext.md#submitMapStage)
* `DAGScheduler` is requested to [submitMapStage](DAGScheduler.md#submitMapStage)

## Creating Instance

`MapOutputStatistics` takes the following to be created:

* <span id="shuffleId"> Shuffle Id (of a [ShuffleDependency](../rdd/ShuffleDependency.md))
* <span id="bytesByPartitionId"> Output Partition Sizes (`Array[Long]`)

`MapOutputStatistics` is created when:

* `MapOutputTrackerMaster` is requested for the [statistics (of a ShuffleDependency)](MapOutputTrackerMaster.md#getStatistics)
