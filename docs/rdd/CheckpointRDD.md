# CheckpointRDD

`CheckpointRDD` is an extension of the [RDD](RDD.md) abstraction for [RDDs](#implementations) that recovers checkpointed data from storage.

`CheckpointRDD` cannot be checkpointed again (and [doCheckpoint](RDD.md#doCheckpoint), [checkpoint](RDD.md#checkpoint), and [localCheckpoint](RDD.md#localCheckpoint) are simply noops).

[getPartitions](RDD.md##getPartitions) and [compute](RDD.md##compute) throw an `NotImplementedError` and are supposed to be overriden by the [implementations](#implementations).

## Implementations

* [LocalCheckpointRDD](LocalCheckpointRDD.md)
* [ReliableCheckpointRDD](ReliableCheckpointRDD.md)
