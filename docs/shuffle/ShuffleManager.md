# ShuffleManager

`ShuffleManager` is an abstraction of <<implementations, shuffle systems>> that manage shuffle data.

`ShuffleManager` is selected using [spark.shuffle.manager](../configuration-properties.md#spark.shuffle.manager) configuration property.

`ShuffleManager` is used to create a [BlockManager](../storage/BlockManager.md#shuffleManager).

== [[implementations]] Available ShuffleManagers

shuffle:SortShuffleManager.md[SortShuffleManager] is the default and only known ShuffleManager in Apache Spark.

== [[SparkEnv]] Accessing ShuffleManager using SparkEnv

The driver and executor access the ShuffleManager instance using core:SparkEnv.md#shuffleManager[SparkEnv.shuffleManager].

[source, scala]
----
val shuffleManager = SparkEnv.get.shuffleManager
----

== [[getReader]] Getting ShuffleReader for ShuffleHandle

[source, scala]
----
getReader[K, C](
  handle: ShuffleHandle,
  startPartition: Int,
  endPartition: Int,
  context: TaskContext): ShuffleReader[K, C]
----

Gives shuffle:spark-shuffle-ShuffleReader.md[ShuffleReader] to read shuffle data in the shuffle:spark-shuffle-ShuffleHandle.md[ShuffleHandle]

Used when the following RDDs are requested to rdd:RDD.md#compute[compute a partition]:

* rdd:spark-rdd-CoGroupedRDD.md[CoGroupedRDD]

* rdd:ShuffledRDD.md[ShuffledRDD]

* rdd:spark-rdd-SubtractedRDD.md[SubtractedRDD]

== [[getWriter]] Getting ShuffleWriter for ShuffleHandle

[source, scala]
----
getWriter[K, V](
  handle: ShuffleHandle,
  mapId: Int,
  context: TaskContext): ShuffleWriter[K, V]
----

Gives shuffle:ShuffleWriter.md[ShuffleWriter] to write shuffle data in the shuffle:spark-shuffle-ShuffleHandle.md[ShuffleHandle]

Used exclusively when ShuffleMapTask is requested to scheduler:ShuffleMapTask.md#runTask[run] (and requests the shuffle:ShuffleWriter.md[ShuffleWriter] to write records for a partition)

== [[registerShuffle]] Registering Shuffle of ShuffleDependency (and Getting ShuffleHandle)

[source, scala]
----
registerShuffle[K, V, C](
  shuffleId: Int,
  numMaps: Int,
  dependency: ShuffleDependency[K, V, C]): ShuffleHandle
----

Registers a shuffle (by the given shuffleId and rdd:ShuffleDependency.md[ShuffleDependency]) and returns a shuffle:spark-shuffle-ShuffleHandle.md[ShuffleHandle]

Used when ShuffleDependency is rdd:ShuffleDependency.md#shuffleHandle[created] (and registers with the shuffle system)

== [[shuffleBlockResolver]] Getting ShuffleBlockResolver

[source, scala]
----
shuffleBlockResolver: ShuffleBlockResolver
----

Gives shuffle:ShuffleBlockResolver.md[ShuffleBlockResolver] of the shuffle system

Used when:

* SortShuffleManager is requested for a shuffle:SortShuffleManager.md#getWriter[ShuffleWriter for a ShuffleHandle], to shuffle:SortShuffleManager.md#unregisterShuffle[unregister a shuffle] and shuffle:SortShuffleManager.md#stop[stop]

* BlockManager is requested to storage:BlockManager.md#getBlockData[get shuffle data] and storage:BlockManager.md#getLocalBytes[getLocalBytes]

== [[stop]] Stopping ShuffleManager

[source, scala]
----
stop(): Unit
----

Stops the shuffle system

Used when SparkEnv is requested to core:SparkEnv.md#stop[stop]

== [[unregisterShuffle]] Unregistering Shuffle

[source, scala]
----
unregisterShuffle(
  shuffleId: Int): Boolean
----

Unregisters a given shuffle

Used when BlockManagerSlaveEndpoint is requested to storage:BlockManagerSlaveEndpoint.md#RemoveShuffle[handle a RemoveShuffle message]
