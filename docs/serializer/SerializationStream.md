# SerializationStream

`SerializationStream` is an [abstraction](#contract) of [serialized streams](#implementations) for [writing out serialized key-value records](#writeAll).

## Contract

### <span id="close"> Closing Stream

```scala
close(): Unit
```

### <span id="flush"> Flushing Stream

```scala
flush(): Unit
```

Used when:

* `UnsafeShuffleWriter` is requested to [insert a record into a ShuffleExternalSorter](../shuffle/UnsafeShuffleWriter.md#insertRecordIntoSorter)
* `DiskBlockObjectWriter` is requested to [commitAndGet](../storage/DiskBlockObjectWriter.md#commitAndGet)

### <span id="writeObject"> Writing Out Object

```scala
writeObject[T: ClassTag](
  t: T): SerializationStream
```

Used when:

* `MemoryStore` is requested to [putIteratorAsBytes](../storage/MemoryStore.md#putIteratorAsBytes)
* `JavaSerializerInstance` is requested to [serialize](JavaSerializerInstance.md#serialize)
* `RequestMessage` is requested to `serialize` (for [NettyRpcEnv](../rpc/NettyRpcEnv.md))
* `ParallelCollectionPartition` is requested to `writeObject` (for [ParallelCollectionRDD](../rdd/ParallelCollectionRDD.md))
* `ReliableRDDCheckpointData` is requested to [doCheckpoint](../rdd/ReliableRDDCheckpointData.md#doCheckpoint)
* `TorrentBroadcast` is [created](../broadcast-variables/TorrentBroadcast.md) (and requested to [writeBlocks](../broadcast-variables/TorrentBroadcast.md#writeBlocks))
* `RangePartitioner` is requested to [writeObject](../rdd/RangePartitioner.md#writeObject)
* `SerializationStream` is requested to [writeKey](#writeKey), [writeValue](#writeValue) or [writeAll](#writeAll)
* `FileSystemPersistenceEngine` is requested to `serializeIntoFile` (for Spark Standalone's `Master`)

## Implementations

* `JavaSerializationStream`
* `KryoSerializationStream`

## <span id="writeAll"> Writing Out All Records

```scala
writeAll[T: ClassTag](
  iter: Iterator[T]): SerializationStream
```

`writeAll` writes out records of the given iterator ([one by one as objects](#writeObject)).

`writeAll` is used when:

* `ReliableCheckpointRDD` is requested to [doCheckpoint](../rdd/ReliableCheckpointRDD.md#doCheckpoint)
* `SerializerManager` is requested to [dataSerializeStream](SerializerManager.md#dataSerializeStream) and [dataSerializeWithExplicitClassTag](SerializerManager.md#dataSerializeWithExplicitClassTag)

## <span id="writeKey"> Writing Out Key

```scala
writeKey[T: ClassTag](
  key: T): SerializationStream
```

[Writes out](#writeObject) the key

`writeKey` is used when:

* `UnsafeShuffleWriter` is requested to [insert a record into a ShuffleExternalSorter](../shuffle/UnsafeShuffleWriter.md#insertRecordIntoSorter)
* `DiskBlockObjectWriter` is requested to [write the key and value of a record](../storage/DiskBlockObjectWriter.md#write)

## <span id="writeValue"> Writing Out Value

```scala
writeValue[T: ClassTag](
  value: T): SerializationStream
```

[Writes out](#writeObject) the value

`writeValue` is used when:

* `UnsafeShuffleWriter` is requested to [insert a record into a ShuffleExternalSorter](../shuffle/UnsafeShuffleWriter.md#insertRecordIntoSorter)
* `DiskBlockObjectWriter` is requested to [write the key and value of a record](../storage/DiskBlockObjectWriter.md#write)
