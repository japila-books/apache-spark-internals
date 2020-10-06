= [[MemoryConsumer]] MemoryConsumer

*MemoryConsumer* is an abstraction of <<extensions, spillable memory consumers>> of memory:TaskMemoryManager.md#consumers[TaskMemoryManager].

MemoryConsumers correspond to individual operators and data structures within a task. The TaskMemoryManager receives memory allocation requests from MemoryConsumers and issues callbacks to consumers in order to trigger <<spill, spilling>> when running low on memory.

A MemoryConsumer basically tracks <<used, how much memory is allocated>>.

Creating a MemoryConsumer requires a TaskMemoryManager.md[TaskMemoryManager] with optional `pageSize` and a `MemoryMode`.

== [[creating-instance]] Creating Instance

MemoryConsumer takes the following to be created:

* [[taskMemoryManager]] memory:TaskMemoryManager.md[TaskMemoryManager]
* [[pageSize]] Page size (in bytes)
* [[mode]] MemoryMode

MemoryConsumer initializes the <<internal-properties, internal properties>>.

== [[extensions]] Extensions

.MemoryConsumers (Direct Implementations and Extensions Only)
[cols="30,70",options="header",width="100%"]
|===
| MemoryConsumer
| Description

| BytesToBytesMap.md[BytesToBytesMap]
| [[BytesToBytesMap]] Used in Spark SQL

| HybridRowQueue
| [[HybridRowQueue]]

| LongToUnsafeRowMap
| [[LongToUnsafeRowMap]]

| RowBasedKeyValueBatch
| [[RowBasedKeyValueBatch]]

| ShuffleExternalSorter
| [[ShuffleExternalSorter]]

| shuffle:Spillable.md[Spillable]
| [[Spillable]]

| UnsafeExternalSorter
| [[UnsafeExternalSorter]]

|===

== [[contract]][[spill]] Spilling

[source, java]
----
long spill(
  long size,
  MemoryConsumer trigger)
----

CAUTION: FIXME

NOTE: `spill` is used when TaskMemoryManager.md#acquireExecutionMemory[`TaskMemoryManager` forces `MemoryConsumers` to release memory when requested to acquire execution memory]

== [[used]][[getUsed]] Memory Allocated (Used)

`used` is the amount of memory in use (i.e. allocated) by the MemoryConsumer.

== [[freePage]] Deallocate MemoryBlock

[source, java]
----
void freePage(
  MemoryBlock page)
----

`freePage` is a protected method to deallocate the `MemoryBlock`.

Internally, it decrements <<used, used>> registry by the size of `page` and TaskMemoryManager.md#freePage[frees the page].

== [[allocateArray]] Allocating Array

[source, java]
----
LongArray allocateArray(
  long size)
----

`allocateArray` allocates `LongArray` of `size` length.

Internally, it TaskMemoryManager.md#allocatePage[allocates a page] for the requested `size`. The size is recorded in the internal <<used, used>> counter.

However, if it was not possible to allocate the `size` memory, it TaskMemoryManager.md#showMemoryUsage[shows the current memory usage] and a `OutOfMemoryError` is thrown.

```
Unable to acquire [required] bytes of memory, got [got]
```

allocateArray is used when:

* BytesToBytesMap is requested to memory:BytesToBytesMap.md#allocate[allocate]

* ShuffleExternalSorter is requested to shuffle:ShuffleExternalSorter.md#growPointerArrayIfNecessary[growPointerArrayIfNecessary]

* ShuffleInMemorySorter is shuffle:ShuffleInMemorySorter.md[created] and shuffle:ShuffleInMemorySorter.md#reset[reset]

* UnsafeExternalSorter is requested to UnsafeExternalSorter.md#growPointerArrayIfNecessary[growPointerArrayIfNecessary]

* UnsafeInMemorySorter is UnsafeInMemorySorter.md[created] and UnsafeInMemorySorter.md#reset[reset]

* Spark SQL's UnsafeKVExternalSorter is created

== [[acquireMemory]] Acquiring Execution Memory (Allocating Memory)

[source, java]
----
long acquireMemory(
  long size)
----

acquireMemory requests the <<taskMemoryManager, TaskMemoryManager>> to memory:TaskMemoryManager.md#acquireExecutionMemory[acquire execution memory] (of the given size).

The memory allocated is then added to the <<used, used>> internal registry.

acquireMemory is used when:

* Spillable is requested to shuffle:Spillable.md#maybeSpill[maybeSpill]

* Spark SQL's LongToUnsafeRowMap is requested to ensureAcquireMemory

== [[allocatePage]] Allocating Memory Block (Page)

[source, java]
----
MemoryBlock allocatePage(
  long required)
----

allocatePage...FIXME

allocatePage is used when...FIXME

== [[throwOom]] Throwing OutOfMemoryError

[source, java]
----
void throwOom(
  MemoryBlock page,
  long required)
----

`throwOom`...FIXME

`throwOom` is used when MemoryConsumer is requested to <<allocateArray, allocate an array>> or a <<allocatePage, memory block (page)>> and failed to acquire enough.
