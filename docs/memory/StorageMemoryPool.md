= StorageMemoryPool

*StorageMemoryPool* is a xref:memory:MemoryPool.adoc[].

StorageMemoryPool is <<creating-instance, created>> along with link:MemoryManager.adoc#creating-instance[MemoryManager] (as link:MemoryManager.adoc#onHeapStorageMemoryPool[onHeapStorageMemoryPool] and link:MemoryManager.adoc#offHeapStorageMemoryPool[offHeapStorageMemoryPool] pools).

[[internal-registries]]
.StorageMemoryPool's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `poolName`
| [[poolName]] FIXME

Used when...FIXME

| `_memoryUsed`
| [[_memoryUsed]][[memoryUsed]] The amount of memory in use for storage (caching)

Used when...FIXME

| `_memoryStore`
| [[_memoryStore]][[memoryStore]] xref:storage:MemoryStore.adoc[MemoryStore]

Used when...FIXME
|===

== [[memoryFree]] `memoryFree` Method

[source, scala]
----
memoryFree: Long
----

`memoryFree`...FIXME

NOTE: `memoryFree` is used when...FIXME

== [[acquireMemory]] `acquireMemory` Method

[source, scala]
----
acquireMemory(blockId: BlockId, numBytes: Long): Boolean  // <1>
acquireMemory(
  blockId: BlockId,
  numBytesToAcquire: Long,
  numBytesToFree: Long): Boolean
----
<1> Calls `acquireMemory` with `numBytesToFree` as a difference between `numBytes` and <<memoryFree, memoryFree>>

`acquireMemory`...FIXME

[NOTE]
====
`acquireMemory` is used when:

* `StaticMemoryManager` is requested to link:StaticMemoryManager.adoc#acquireUnrollMemory[acquireUnrollMemory] and link:StaticMemoryManager.adoc#acquireStorageMemory[acquireStorageMemory]

* `UnifiedMemoryManager` is requested to link:UnifiedMemoryManager.adoc#acquireStorageMemory[acquireStorageMemory]
====

== [[freeSpaceToShrinkPool]] `freeSpaceToShrinkPool` Method

[source, scala]
----
freeSpaceToShrinkPool(spaceToFree: Long): Long
----

`freeSpaceToShrinkPool`...FIXME

NOTE: `freeSpaceToShrinkPool` is used exclusively when `UnifiedMemoryManager` is requested to link:UnifiedMemoryManager.adoc#acquireExecutionMemory[acquireExecutionMemory].

== [[creating-instance]] Creating StorageMemoryPool Instance

StorageMemoryPool takes the following when created:

* [[lock]] Lock
* [[memoryMode]] `MemoryMode` (either `ON_HEAP` or `OFF_HEAP`)

StorageMemoryPool initializes the <<internal-registries, internal registries and counters>>.
