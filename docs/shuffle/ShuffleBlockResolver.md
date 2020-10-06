= [[ShuffleBlockResolver]] ShuffleBlockResolver

*ShuffleBlockResolver* is an <<contract, abstraction>> of <<implementations, shuffle block resolvers>> that storage:BlockManager.md[BlockManager] uses to <<getBlockData, retrieve a shuffle block data>> for a logical shuffle block identifier (i.e. map, reduce, and shuffle).

NOTE: Shuffle block data files are often referred to as *map outputs files*.

[[implementations]]
NOTE: shuffle:IndexShuffleBlockResolver.md[IndexShuffleBlockResolver] is the default and only known ShuffleBlockResolver in Apache Spark.

[[contract]]
.ShuffleBlockResolver Contract
[cols="1m,3",options="header",width="100%"]
|===
| Method
| Description

| getBlockData
a| [[getBlockData]]

[source, scala]
----
getBlockData(
  blockId: ShuffleBlockId): ManagedBuffer
----

Retrieves the data (as a network:ManagedBuffer.md[]) for the given storage:BlockId.md#ShuffleBlockId[block] (a tuple of `shuffleId`, `mapId` and `reduceId`).

Used when `BlockManager` is requested to retrieve a storage:BlockManager.md#getLocalBytes[block data from a local block manager] and storage:BlockManager.md#getBlockData[block data]

| stop
a| [[stop]]

[source, scala]
----
stop(): Unit
----

Stops the `ShuffleBlockResolver`

Used when `SortShuffleManager` is requested to SortShuffleManager.md#stop[stop]

|===
