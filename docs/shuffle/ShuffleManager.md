# ShuffleManager

`ShuffleManager` is an [abstraction](#contract) of [shuffle managers](#implementations) that manage shuffle data.

`ShuffleManager` is specified using [spark.shuffle.manager](../configuration-properties.md#spark.shuffle.manager) configuration property.

`ShuffleManager` is used to create a [BlockManager](../storage/BlockManager.md#shuffleManager).

## Contract

### <span id="getReader"> Getting ShuffleReader for ShuffleHandle

```scala
getReader[K, C](
  handle: ShuffleHandle,
  startPartition: Int,
  endPartition: Int,
  context: TaskContext,
  metrics: ShuffleReadMetricsReporter): ShuffleReader[K, C]
```

[ShuffleReader](ShuffleReader.md) to read shuffle data (for the given [ShuffleHandle](ShuffleHandle.md))

Used when the following `RDD`s are requested to [compute a partition](../rdd/RDD.md#compute):

* `CoGroupedRDD` is requested to [compute a partition](../rdd/CoGroupedRDD.md#compute)
* `ShuffledRDD` is requested to [compute a partition](../rdd/ShuffledRDD.md#compute)
* `SubtractedRDD` is requested to [compute a partition](../rdd/SubtractedRDD.md#compute)
* `ShuffledRowRDD` ([Spark SQL]({{ book.spark_sql }}/ShuffledRowRDD)) is requested to `compute` a partition

### <span id="getReaderForRange"> getReaderForRange

```scala
getReaderForRange[K, C](
  handle: ShuffleHandle,
  startMapIndex: Int,
  endMapIndex: Int,
  startPartition: Int,
  endPartition: Int,
  context: TaskContext,
  metrics: ShuffleReadMetricsReporter): ShuffleReader[K, C]
```

[ShuffleReader](ShuffleReader.md) for a range of reduce partitions to read from map output in the [ShuffleHandle](ShuffleHandle.md)

Used when `ShuffledRowRDD` (Spark SQL) is requested to compute a partition

### <span id="getWriter"> Getting ShuffleWriter for ShuffleHandle

```scala
getWriter[K, V](
  handle: ShuffleHandle,
  mapId: Long,
  context: TaskContext,
  metrics: ShuffleWriteMetricsReporter): ShuffleWriter[K, V]
```

[ShuffleWriter](ShuffleWriter.md) to write shuffle data in the [ShuffleHandle](ShuffleHandle.md)

Used when `ShuffleWriteProcessor` is requested to [write a partition](ShuffleWriteProcessor.md#write)

### <span id="registerShuffle"> Registering Shuffle of ShuffleDependency (and Getting ShuffleHandle)

```scala
registerShuffle[K, V, C](
  shuffleId: Int,
  dependency: ShuffleDependency[K, V, C]): ShuffleHandle
```

Registers a shuffle (by the given `shuffleId` and [ShuffleDependency](../rdd/ShuffleDependency.md)) and gives a [ShuffleHandle](ShuffleHandle.md)

Used when `ShuffleDependency` is [created](../rdd/ShuffleDependency.md#shuffleHandle) (and registers with the shuffle system)

### <span id="shuffleBlockResolver"> ShuffleBlockResolver

```scala
shuffleBlockResolver: ShuffleBlockResolver
```

[ShuffleBlockResolver](ShuffleBlockResolver.md) of the shuffle system

Used when:

* `SortShuffleManager` is requested for a [ShuffleWriter for a ShuffleHandle](SortShuffleManager.md#getWriter), to [unregister a shuffle](SortShuffleManager.md#unregisterShuffle) and [stop](SortShuffleManager.md#stop)
* `BlockManager` is requested to [getLocalBlockData](../storage/BlockManager.md#getLocalBlockData) and [getHostLocalShuffleData](../storage/BlockManager.md#getHostLocalShuffleData)

### <span id="stop"> Stopping ShuffleManager

```scala
stop(): Unit
```

Stops the shuffle system

Used when `SparkEnv` is requested to [stop](../SparkEnv.md#stop)

### <span id="unregisterShuffle"> Unregistering Shuffle

```scala
unregisterShuffle(
  shuffleId: Int): Boolean
```

Unregisters a given shuffle

Used when `BlockManagerSlaveEndpoint` is requested to [handle a RemoveShuffle message](../storage/BlockManagerSlaveEndpoint.md#RemoveShuffle)

## Implementations

* [SortShuffleManager](SortShuffleManager.md)

## <span id="SparkEnv"> Accessing ShuffleManager using SparkEnv

`ShuffleManager` is available on the driver and executors using [SparkEnv.shuffleManager](../SparkEnv.md#shuffleManager).

```scala
val shuffleManager = SparkEnv.get.shuffleManager
```
