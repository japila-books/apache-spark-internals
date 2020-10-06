= StorageMemoryPool

*StorageMemoryPool* is a memory:MemoryPool.md[].

StorageMemoryPool is <<creating-instance, created>> along with MemoryManager.md#creating-instance[MemoryManager] (as MemoryManager.md#onHeapStorageMemoryPool[onHeapStorageMemoryPool] and MemoryManager.md#offHeapStorageMemoryPool[offHeapStorageMemoryPool] pools).

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
| [[_memoryStore]][[memoryStore]] storage:MemoryStore.md[MemoryStore]

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

* `StaticMemoryManager` is requested to StaticMemoryManager.md#acquireUnrollMemory[acquireUnrollMemory] and StaticMemoryManager.md#acquireStorageMemory[acquireStorageMemory]

* `UnifiedMemoryManager` is requested to UnifiedMemoryManager.md#acquireStorageMemory[acquireStorageMemory]
====

== [[freeSpaceToShrinkPool]] `freeSpaceToShrinkPool` Method

[source, scala]
----
freeSpaceToShrinkPool(spaceToFree: Long): Long
----

`freeSpaceToShrinkPool`...FIXME

NOTE: `freeSpaceToShrinkPool` is used exclusively when `UnifiedMemoryManager` is requested to UnifiedMemoryManager.md#acquireExecutionMemory[acquireExecutionMemory].

== [[creating-instance]] Creating StorageMemoryPool Instance

StorageMemoryPool takes the following when created:

* [[lock]] Lock
* [[memoryMode]] `MemoryMode` (either `ON_HEAP` or `OFF_HEAP`)

StorageMemoryPool initializes the <<internal-registries, internal registries and counters>>.
