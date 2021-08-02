# LocalCheckpointRDD

`LocalCheckpointRDD[T]` is a [CheckpointRDD](CheckpointRDD.md).

## Creating Instance

`LocalCheckpointRDD` takes the following to be created:

* <span id="rdd"> [RDD](RDD.md)
* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="rddId"> RDD ID
* <span id="numPartitions"> Number of Partitions

`LocalCheckpointRDD` is created when:

* `LocalRDDCheckpointData` is requested to [doCheckpoint](LocalRDDCheckpointData.md#doCheckpoint)

## <span id="getPartitions"> Partitions

```scala
getPartitions: Array[Partition]
```

`getPartitions` is part of the [RDD](RDD.md#getPartitions) abstraction.

`getPartitions` creates a `CheckpointRDDPartition` for every input partition (index).

## <span id="compute"> Computing Partition

```scala
compute(
  partition: Partition,
  context: TaskContext): Iterator[T]
```

`compute` is part of the [RDD](RDD.md#compute) abstraction.

`compute` merely throws an `SparkException` (that explains the reason):

```text
Checkpoint block [RDDBlockId] not found! Either the executor
that originally checkpointed this partition is no longer alive, or the original RDD is
unpersisted. If this problem persists, you may consider using `rdd.checkpoint()`
instead, which is slower than local checkpointing but more fault-tolerant."
```
