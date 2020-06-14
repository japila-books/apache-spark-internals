= MemoryPool

*MemoryPool* is a bookkeeping abstraction of <<extensions, memory pools>>.

MemoryPool is used by the xref:memory:MemoryManager.adoc[MemoryManager] to track the division of memory between storage and execution.

== [[extensions]] Extensions

.MemoryPools
[cols="30,70",options="header",width="100%"]
|===
| MemoryPool
| Description

| xref:ExecutionMemoryPool.adoc[ExecutionMemoryPool]
| [[ExecutionMemoryPool]]

| xref:StorageMemoryPool.adoc[StorageMemoryPool]
| [[StorageMemoryPool]]

|===

== [[creating-instance]][[lock]] Creating Instance

MemoryPool takes a single lock object to be created (used for synchronization).

== [[_poolSize]][[poolSize]] Pool Size

[source,scala]
----
_poolSize: Long = 0
----

++_poolSize++ is the maximum size of the memory pool.

++_poolSize++ can be <<incrementPoolSize, expanded>> or <<decrementPoolSize, shrinked>>.

++_poolSize++ is used to report <<memoryFree, memory free>>.

== [[memoryUsed]] Amount of Memory Used

[source, scala]
----
memoryUsed: Long
----

memoryUsed gives the amount of memory used in this pool (in bytes).

memoryUsed is used when:

* MemoryManager is requested for the xref:memory:MemoryManager.adoc#storageMemoryUsed[total storage memory in use]

* MemoryPool is requested for the current <<memoryFree, memory free>> and to <<decrementPoolSize, shrink pool size>>

* StorageMemoryPool is requested to acquireMemory

* UnifiedMemoryManager is requested to xref:memory:UnifiedMemoryManager.adoc#maxOnHeapStorageMemory[maxOnHeapStorageMemory], xref:memory:UnifiedMemoryManager.adoc#maxOffHeapStorageMemory[maxOffHeapStorageMemory] and xref:memory:UnifiedMemoryManager.adoc#acquireExecutionMemory[acquireExecutionMemory]

== [[memoryFree]] Amount of Free Memory

[source, scala]
----
memoryFree: Long
----

memoryFree gives the amount of free memory in the pool (in bytes) by simply subtracting the <<memoryUsed, memory used>> from the <<_poolSize, _poolSize>>.

memoryFree is used when...FIXME

== [[decrementPoolSize]] Shrinking Pool Size

[source, scala]
----
decrementPoolSize(
  delta: Long): Unit
----

decrementPoolSize makes the <<_poolSize, _poolSize>> smaller by the given `delta` bytes.

decrementPoolSize requires that the given delta bytes has to meet the requirements:

* be positive

* up to the current <<_poolSize, _poolSize>>

* Does not shrink the current <<_poolSize, _poolSize>> below the <<memoryUsed, memory used>> threshold

decrementPoolSize is used when...FIXME

== [[incrementPoolSize]] Expanding Pool Size

[source, scala]
----
incrementPoolSize(
  delta: Long): Unit
----

incrementPoolSize makes the <<_poolSize, _poolSize>> bigger by the given `delta` bytes.

incrementPoolSize requires that the given delta bytes has to be positive.

incrementPoolSize is used when...FIXME
