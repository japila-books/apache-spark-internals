# Serializer

`Serializer` is an [abstraction](#contract) of [serializers](#implementations) for serialization and deserialization of [tasks](#SparkEnv-closureSerializer) (closures) and [data blocks](#SparkEnv-serializer) in a Spark application.

## Contract

### <span id="newInstance"> Creating New SerializerInstance

```scala
newInstance(): SerializerInstance
```

Creates a new [SerializerInstance](SerializerInstance.md)

Used when:

* `Task` is [created](../scheduler/Task.md#serializedTaskMetrics) (only used in tests)
* `SerializerSupport` (Spark SQL) utility is used to `newSerializer`
* `RangePartitioner` is requested to [writeObject](../rdd/RangePartitioner.md#writeObject) and [readObject](../rdd/RangePartitioner.md#readObject)
* `TorrentBroadcast` utility is used to [blockifyObject](../broadcast-variables/TorrentBroadcast.md#blockifyObject) and [unBlockifyObject](../broadcast-variables/TorrentBroadcast.md#unBlockifyObject)
* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run)
* `NettyBlockRpcServer` is requested to [deserializeMetadata](../storage/NettyBlockRpcServer.md#deserializeMetadata)
* `NettyBlockTransferService` is requested to [uploadBlock](../storage/NettyBlockTransferService.md#uploadBlock)
* `PairRDDFunctions` is requested to...FIXME
* `ParallelCollectionPartition` is requested to...FIXME
* `RDD` is requested to...FIXME
* `ReliableCheckpointRDD` utility is used to...FIXME
* `NettyRpcEnvFactory` is requested to [create a RpcEnv](../rpc/NettyRpcEnvFactory.md#create)
* `DAGScheduler` is [created](../scheduler/DAGScheduler.md#closureSerializer)
* _others_

## Implementations

* `JavaSerializer`
* [KryoSerializer](KryoSerializer.md)
* `UnsafeRowSerializer` ([Spark SQL]({{ book.spark_sql }}/UnsafeRowSerializer))

## Accessing Serializer

`Serializer` is available using [SparkEnv](../SparkEnv.md) as the [closureSerializer](../SparkEnv.md#closureSerializer) and [serializer](../SparkEnv.md#serializer).

### <span id="SparkEnv-closureSerializer"> closureSerializer

```scala
SparkEnv.get.closureSerializer
```

### <span id="SparkEnv-serializer"> serializer

```scala
SparkEnv.get.serializer
```

## <span id="supportsRelocationOfSerializedObjects"> Serialized Objects Relocation Requirements

```scala
supportsRelocationOfSerializedObjects: Boolean
```

`supportsRelocationOfSerializedObjects` is disabled (`false`) by default.

`supportsRelocationOfSerializedObjects` is used when:

* `BlockStoreShuffleReader` is requested to [fetchContinuousBlocksInBatch](../shuffle/BlockStoreShuffleReader.md#fetchContinuousBlocksInBatch)
* `SortShuffleManager` is requested to [create a ShuffleHandle for a given ShuffleDependency](../shuffle/SortShuffleManager.md#registerShuffle) (and [checks out SerializedShuffleHandle requirements](../shuffle/SortShuffleManager.md#canUseSerializedShuffle))
