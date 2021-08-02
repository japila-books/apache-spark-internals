# LocalRDDCheckpointData

`LocalRDDCheckpointData` is a [RDDCheckpointData](RDDCheckpointData.md).

## Creating Instance

`LocalRDDCheckpointData` takes the following to be created:

* <span id="rdd"> [RDD](RDD.md)

`LocalRDDCheckpointData` is created when:

* `RDD` is requested to [localCheckpoint](RDD.md#localCheckpoint)

## <span id="doCheckpoint"> doCheckpoint

```scala
doCheckpoint(): CheckpointRDD[T]
```

`doCheckpoint` is part of the [RDDCheckpointData](RDDCheckpointData.md#doCheckpoint) abstraction.

`doCheckpoint` creates a [LocalCheckpointRDD](LocalCheckpointRDD.md) with the [RDD](#rdd). `doCheckpoint` triggers caching any missing partitions (by checking availability of the [RDDBlockId](../storage/BlockId.md#RDDBlockId)s for the partitions in the [BlockManagerMaster](../storage/BlockManagerMaster.md#contains)).

!!! important "Extra Spark Job"
    If there are any missing partitions (`RDDBlockId`s) `doCheckpoint` requests the `SparkContext` to [run a Spark job](../SparkContext.md#runJob) with the `RDD` and the missing partitions.

`doCheckpoint`makes sure that the [StorageLevel](RDD.md#getStorageLevel) of the `RDD` [uses disk](../storage/StorageLevel.md#useDisk) (among other persistence storages). If not, `doCheckpoint` throws an `AssertionError`:

```text
Storage level [level] is not appropriate for local checkpointing
```
