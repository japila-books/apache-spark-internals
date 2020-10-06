= BlockEvictionHandler

*BlockEvictionHandler* is an <<contract, abstraction>> of <<implementations, eviction handlers>> that can <<dropFromMemory, drop a block from memory>>.

== [[contract]] Contract

=== [[dropFromMemory]] dropFromMemory Method

[source,scala]
----
dropFromMemory[T: ClassTag](
  blockId: BlockId,
  data: () => Either[Array[T], ChunkedByteBuffer]): StorageLevel
----

Used when MemoryStore is requested to xref:storage:MemoryStore.adoc#evictBlocksToFreeSpace[evictBlocksToFreeSpace].

== [[implementations]] Available BlockEvictionHandlers

xref:storage:BlockManager.adoc[] is the default and only known BlockEvictionHandler in Apache Spark.
