# MapStatus

`MapStatus` is an [abstraction](#contract) of [shuffle map output statuses](#implementations) with an [estimated size](#getSizeForBlock), [location](#location) and [map Id](#mapId).

`MapStatus` is a result of [executing a ShuffleMapTask](ShuffleMapTask.md#runTask).

After a [ShuffleMapTask has finished execution successfully](ShuffleMapTask.md#runTask), `DAGScheduler` is requested to [handle a ShuffleMapTask completion](DAGScheduler.md#handleTaskCompletion) that in turn requests the [MapOutputTrackerMaster](DAGScheduler.md#mapOutputTracker) to [register the MapStatus](MapOutputTrackerMaster.md#registerMapOutput).

## Contract

### <span id="getSizeForBlock"> Estimated Size

```scala
getSizeForBlock(
  reduceId: Int): Long
```

Estimated size (in bytes)

Used when:

* `MapOutputTrackerMaster` is requested for a [MapOutputStatistics](MapOutputTrackerMaster.md#getStatistics) and [locations with the largest number of shuffle map outputs](MapOutputTrackerMaster.md#getLocationsWithLargestOutputs)
* `MapOutputTracker` utility is used to [convert MapStatuses](MapOutputTracker.md#convertMapStatuses)
* `OptimizeSkewedJoin` ([Spark SQL]({{ book.spark_sql }}/physical-optimizations/OptimizeSkewedJoin/)) physical optimization is executed

### <span id="location"> Location

```scala
location: BlockManagerId
```

[BlockManagerId](../storage/BlockManagerId.md) of the shuffle map output (i.e. the [BlockManager](../storage/BlockManager.md) where a `ShuffleMapTask` ran and the result is stored)

Used when:

* `ShuffleStatus` is requested to [removeMapOutput](ShuffleStatus.md#removeMapOutput) and [removeOutputsByFilter](ShuffleStatus.md##removeOutputsByFilter)
* `MapOutputTrackerMaster` is requested for [locations with the largest number of shuffle map outputs](MapOutputTrackerMaster.md#getLocationsWithLargestOutputs) and [getMapLocation](MapOutputTrackerMaster.md#getMapLocation)
* `MapOutputTracker` utility is used to [convert MapStatuses](MapOutputTracker.md#convertMapStatuses)
* `DAGScheduler` is requested to [handle a ShuffleMapTask completion](DAGScheduler.md#handleTaskCompletion)

### <span id="mapId"> Map Id

```scala
mapId: Long
```

Map Id of the shuffle map output

Used when:

* `MapOutputTracker` utility is used to [convert MapStatuses](MapOutputTracker.md#convertMapStatuses)

## Implementations

* [CompressedMapStatus](CompressedMapStatus.md)
* [HighlyCompressedMapStatus](HighlyCompressedMapStatus.md)

??? note "Sealed Trait"
    `MapStatus` is a Scala **sealed trait** which means that all of the implementations are in the same compilation unit (a single file).

## <span id="minPartitionsToUseHighlyCompressMapStatus"> spark.shuffle.minNumPartitionsToHighlyCompress

`MapStatus` utility uses [spark.shuffle.minNumPartitionsToHighlyCompress](../configuration-properties.md#spark.shuffle.minNumPartitionsToHighlyCompress) internal configuration property for the **minimum number of partitions** to [prefer a HighlyCompressedMapStatus](#apply).

## <span id="apply"> Creating MapStatus

```scala
apply(
  loc: BlockManagerId,
  uncompressedSizes: Array[Long],
  mapTaskId: Long): MapStatus
```

`apply` creates a [HighlyCompressedMapStatus](HighlyCompressedMapStatus.md) when the number of `uncompressedSizes` is above [minPartitionsToUseHighlyCompressMapStatus](#minPartitionsToUseHighlyCompressMapStatus) threshold. Otherwise, `apply` creates a [CompressedMapStatus](CompressedMapStatus.md).

`apply` is used when:

* `SortShuffleWriter` is requested to [write records](../shuffle/SortShuffleWriter.md#write)
* `BypassMergeSortShuffleWriter` is requested to [write records](../shuffle/BypassMergeSortShuffleWriter.md#write)
* `UnsafeShuffleWriter` is requested to [close resources and write out merged spill files](../shuffle/UnsafeShuffleWriter.md#closeAndWriteOutput)
