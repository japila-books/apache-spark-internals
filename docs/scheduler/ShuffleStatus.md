# ShuffleStatus

`ShuffleStatus` is used by [MapOutputTrackerMaster](MapOutputTrackerMaster.md) to keep track of the [shuffle map outputs](MapOutputTrackerMaster.md#shuffleStatuses) of a [ShuffleMapStage](ShuffleMapStage.md).

## Creating Instance

`ShuffleStatus` takes the following to be created:

* <span id="numPartitions"> Number of Partitions (of the [RDD](../rdd/ShuffleDependency.md#rdd) of a [ShuffleDependency](../rdd/ShuffleDependency.md))

`ShuffleStatus` is created when:

* `MapOutputTrackerMaster` is requested to [register a shuffle](MapOutputTrackerMaster.md#registerShuffle) (when `DAGScheduler` is requested to [createShuffleMapStage](DAGScheduler.md#createShuffleMapStage))

## <span id="addMapOutput"> Registering Shuffle Map Output

```scala
addMapOutput(
  mapIndex: Int,
  status: MapStatus): Unit
```

`addMapOutput`...FIXME

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
