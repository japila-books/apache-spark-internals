# ShuffleStatus

`ShuffleStatus` is a registry of [MapStatuses per Partition](#mapStatuses) of a [ShuffleMapStage](ShuffleMapStage.md).

`ShuffleStatus` is used by [MapOutputTrackerMaster](MapOutputTrackerMaster.md#shuffleStatuses).

## Creating Instance

`ShuffleStatus` takes the following to be created:

* <span id="numPartitions"> Number of Partitions (of the [RDD](../rdd/ShuffleDependency.md#rdd) of the [ShuffleDependency](ShuffleMapStage.md#shuffleDep) of a [ShuffleMapStage](ShuffleMapStage.md))

`ShuffleStatus` is created when:

* `MapOutputTrackerMaster` is requested to [register a shuffle](MapOutputTrackerMaster.md#registerShuffle) (when `DAGScheduler` is requested to [create a ShuffleMapStage](DAGScheduler.md#createShuffleMapStage))

## <span id="mapStatuses"> MapStatuses per Partition

`ShuffleStatus` creates a `mapStatuses` internal registry of [MapStatus](MapStatus.md)es per partition (using the [numPartitions](#numPartitions)) when [created](#creating-instance).

A missing partition is when there is no `MapStatus` for a partition (`null` at the index of the partition ID) and can be requested using [findMissingPartitions](#findMissingPartitions).

`mapStatuses` is all `null` (for every partition) initially (and so all partitions are missing / uncomputed).

A new `MapStatus` is added in [addMapOutput](#addMapOutput) and [updateMapOutput](#updateMapOutput).

A `MapStatus` is removed (`null`ed) in [removeMapOutput](#removeMapOutput) and [removeOutputsByFilter](#removeOutputsByFilter).

The number of available `MapStatus`es is tracked by [_numAvailableMapOutputs](#_numAvailableMapOutputs) internal counter.

Used when:

* [serializedMapStatus](#serializedMapStatus) and [withMapStatuses](#withMapStatuses)

## <span id="addMapOutput"> Registering Shuffle Map Output

```scala
addMapOutput(
  mapIndex: Int,
  status: MapStatus): Unit
```

`addMapOutput` adds the [MapStatus](MapStatus.md) to the [mapStatuses](#mapStatuses) internal registry.

In case the [mapStatuses](#mapStatuses) internal registry had no `MapStatus` for the `mapIndex` already available, `addMapOutput` increments the [_numAvailableMapOutputs](#_numAvailableMapOutputs) internal counter and [invalidateSerializedMapOutputStatusCache](#invalidateSerializedMapOutputStatusCache).

`addMapOutput` is used when:

* `MapOutputTrackerMaster` is requested to [registerMapOutput](MapOutputTrackerMaster.md#registerMapOutput)

## <span id="removeMapOutput"> Deregistering Shuffle Map Output

```scala
removeMapOutput(
  mapIndex: Int,
  bmAddress: BlockManagerId): Unit
```

`removeMapOutput`...FIXME

`removeMapOutput` is used when:

* `MapOutputTrackerMaster` is requested to [unregisterMapOutput](MapOutputTrackerMaster.md#unregisterMapOutput)

## <span id="findMissingPartitions"> Missing Partitions

```scala
findMissingPartitions(): Seq[Int]
```

`findMissingPartitions`...FIXME

`findMissingPartitions` is used when:

* `MapOutputTrackerMaster` is requested to [findMissingPartitions](MapOutputTrackerMaster.md#findMissingPartitions)

## <span id="serializedMapStatus"> Serializing Shuffle Map Output Statuses

```scala
serializedMapStatus(
  broadcastManager: BroadcastManager,
  isLocal: Boolean,
  minBroadcastSize: Int,
  conf: SparkConf): Array[Byte]
```

`serializedMapStatus`...FIXME

`serializedMapStatus` is used when:

* `MessageLoop` (of the [MapOutputTrackerMaster](MapOutputTrackerMaster.md)) is requested to send map output locations for shuffle

## Logging

Enable `ALL` logging level for `org.apache.spark.ShuffleStatus` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.ShuffleStatus=ALL
```

Refer to [Logging](../spark-logging.md).
