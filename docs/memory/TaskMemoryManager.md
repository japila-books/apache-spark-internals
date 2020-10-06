= TaskMemoryManager

*TaskMemoryManager* manages the memory allocated to execute a single <<taskAttemptId, task>> (using <<memoryManager, MemoryManager>>).

TaskMemoryManager is <<creating-instance, created>> when `TaskRunner` is requested to xref:executor:TaskRunner.adoc#run[run].

.Creating TaskMemoryManager for Task
image::TaskMemoryManager.png[align="center"]

TaskMemoryManager assumes that:

* The number of bits to address pages (aka `PAGE_NUMBER_BITS`) is `13`
* The number of bits to encode offsets in data pages (aka `OFFSET_BITS`) is `51` (i.e. 64 bits - `PAGE_NUMBER_BITS`)
* The number of entries in the <<pageTable, page table>> and <<allocatedPages, allocated pages>> (aka `PAGE_TABLE_SIZE`) is `8192` (i.e. 1 << `PAGE_NUMBER_BITS`)
* The maximum page size (aka `MAXIMUM_PAGE_SIZE_BYTES`) is `15GB` (i.e. `((1L << 31) - 1) * 8L`)

== [[creating-instance]] Creating Instance

TaskMemoryManager takes the following to be created:

* <<memoryManager, MemoryManager>>
* [[taskAttemptId]] xref:executor:TaskRunner.adoc#taskId[Task attempt ID]

TaskMemoryManager initializes the <<internal-properties, internal properties>>.

== [[consumers]] Spillable Memory Consumers

TaskMemoryManager tracks xref:memory:MemoryConsumer.adoc[spillable memory consumers].

TaskMemoryManager registers a new memory consumer when requested to <<acquireExecutionMemory, acquire execution memory>>.

TaskMemoryManager removes (_clears_) all registered memory consumer when requested to <<cleanUpAllAllocatedMemory, clean up all allocated memory>>.

Memory consumers are used to report memory usage when TaskMemoryManager is requested to <<showMemoryUsage, show memory usage>>.

== [[memoryManager]] MemoryManager

TaskMemoryManager is given a xref:memory:MemoryManager.adoc[MemoryManager] when <<creating-instance, created>>.

TaskMemoryManager uses the MemoryManager for the following:

* <<acquireExecutionMemory, Acquiring>>, <<releaseExecutionMemory, releasing>> or <<cleanUpAllAllocatedMemory, cleaning up>> execution memory

* <<showMemoryUsage, showMemoryUsage>>

* <<pageSizeBytes, pageSizeBytes>>

* <<allocatePage, Allocating a memory block for Tungsten consumers>>

* <<freePage, freePage>>

* <<getMemoryConsumptionForThisTask, getMemoryConsumptionForThisTask>>

== [[cleanUpAllAllocatedMemory]] Cleaning Up All Allocated Memory

[source, java]
----
long cleanUpAllAllocatedMemory()
----

`cleanUpAllAllocatedMemory` clears <<pageTable, page table>>.

CAUTION: FIXME

All recorded <<consumers, consumers>> are queried for the size of used memory. If the memory used is greater than 0, the following WARN message is printed out to the logs:

```
WARN TaskMemoryManager: leak [bytes] memory from [consumer]
```

The `consumers` collection is then cleared.

link:MemoryManager.adoc#releaseExecutionMemory[MemoryManager.releaseExecutionMemory] is executed to release the memory that is not used by any consumer.

Before `cleanUpAllAllocatedMemory` returns, it calls link:MemoryManager.adoc#releaseAllExecutionMemoryForTask[MemoryManager.releaseAllExecutionMemoryForTask] that in turn becomes the return value.

CAUTION: FIXME Image with the interactions to `MemoryManager`.

NOTE: `cleanUpAllAllocatedMemory` is used exclusively when `TaskRunner` is requested to xref:executor:TaskRunner.adoc#run[run] (and cleans up after itself).

== [[acquireExecutionMemory]] Acquiring Execution Memory

[source, java]
----
long acquireExecutionMemory(
  long required,
  MemoryConsumer consumer)
----

`acquireExecutionMemory` allocates up to `required` size of memory for the xref:memory:MemoryConsumer.adoc[MemoryConsumer].

When no memory could be allocated, it calls `spill` on every consumer, itself including. Finally, `acquireExecutionMemory` returns the allocated memory.

NOTE: `acquireExecutionMemory` synchronizes on itself, and so no other calls on the object could be completed.

NOTE: xref:memory:MemoryConsumer.adoc[MemoryConsumer] knows its mode -- on- or off-heap.

`acquireExecutionMemory` first calls `memoryManager.acquireExecutionMemory(required, taskAttemptId, mode)`.

TIP: TaskMemoryManager is a mere wrapper of `MemoryManager` to track <<consumers, consumers>>?

CAUTION: FIXME

When the memory obtained is less than requested (by `required`), `acquireExecutionMemory` requests all <<consumers, consumers>> to link:MemoryConsumer.adoc#spill[release memory (by spilling it to disk)].

NOTE: `acquireExecutionMemory` requests memory from consumers that work in the same mode except the requesting one.

You may see the following DEBUG message when `spill` released some memory:

```
DEBUG Task [taskAttemptId] released [bytes] from [consumer] for [consumer]
```

`acquireExecutionMemory` calls `memoryManager.acquireExecutionMemory(required, taskAttemptId, mode)` again (it called it at the beginning).

It does the memory acquisition until it gets enough memory or there are no more consumers to request `spill` from.

You may also see the following ERROR message in the logs when there is an error while requesting `spill` with `OutOfMemoryError` followed.

```
ERROR error while calling spill() on [consumer]
```

If the earlier `spill` on the consumers did not work out and there is still memory to be acquired, `acquireExecutionMemory` link:MemoryConsumer.adoc#spill[requests the input `consumer` to spill memory to disk] (that in fact requested more memory!)

If the `consumer` releases some memory, you should see the following DEBUG message in the logs:

```
DEBUG Task [taskAttemptId] released [bytes] from itself ([consumer])
```

`acquireExecutionMemory` calls `memoryManager.acquireExecutionMemory(required, taskAttemptId, mode)` once more.

NOTE: `memoryManager.acquireExecutionMemory(required, taskAttemptId, mode)` could have been called "three" times, i.e. at the very beginning, for each consumer, and on itself.

It records the `consumer` in <<consumers, consumers>> registry.

You should see the following DEBUG message in the logs:

```
DEBUG Task [taskAttemptId] acquired [bytes] for [consumer]
```

acquireExecutionMemory is used when:

* MemoryConsumer is requested to xref:memory:MemoryConsumer.adoc#acquireMemory[acquire execution memory]

* TaskMemoryManager is requested to <<allocatePage, allocate a page>>

== [[allocatePage]] Allocating Memory Block for Tungsten Consumers

[source, java]
----
MemoryBlock allocatePage(
  long size,
  MemoryConsumer consumer)
----

NOTE: It only handles *Tungsten Consumers*, i.e. link:MemoryConsumer.adoc[MemoryConsumers] in `tungstenMemoryMode` mode.

`allocatePage` allocates a block of memory (aka _page_) smaller than `MAXIMUM_PAGE_SIZE_BYTES` maximum size.

It checks `size` against the internal `MAXIMUM_PAGE_SIZE_BYTES` maximum size. If it is greater than the maximum size, the following `IllegalArgumentException` is thrown:

```
Cannot allocate a page with more than [MAXIMUM_PAGE_SIZE_BYTES] bytes
```

It then <<acquireExecutionMemory, acquires execution memory>> (for the input `size` and `consumer`).

It finishes by returning `null` when no execution memory could be acquired.

With the execution memory acquired, it finds the smallest unallocated page index and records the page number (using <<allocatedPages, allocatedPages>> registry).

If the index is `PAGE_TABLE_SIZE` or higher, <<releaseExecutionMemory, releaseExecutionMemory(acquired, consumer)>> is called and then the following `IllegalStateException` is thrown:

```
Have already allocated a maximum of [PAGE_TABLE_SIZE] pages
```

It then attempts to allocate a `MemoryBlock` from `Tungsten MemoryAllocator` (calling `memoryManager.tungstenMemoryAllocator().allocate(acquired)`).

CAUTION: FIXME What is `MemoryAllocator`?

When successful, `MemoryBlock` gets assigned `pageNumber` and it gets added to the internal <<pageTable, pageTable>> registry.

You should see the following TRACE message in the logs:

```
TRACE Allocate page number [pageNumber] ([acquired] bytes)
```

The `page` is returned.

If a `OutOfMemoryError` is thrown when allocating a `MemoryBlock` page, the following WARN message is printed out to the logs:

```
WARN Failed to allocate a page ([acquired] bytes), try again.
```

And `acquiredButNotUsed` gets `acquired` memory space with the `pageNumber` cleared in <<allocatedPages, allocatedPages>> (i.e. the index for `pageNumber` gets `false`).

CAUTION: FIXME Why is the code tracking `acquiredButNotUsed`?

Another <<allocatePage, allocatePage>> attempt is recursively tried.

CAUTION: FIXME Why is there a hope for being able to allocate a page?

== [[releaseExecutionMemory]] `releaseExecutionMemory` Method

[source, java]
----
void releaseExecutionMemory(long size, MemoryConsumer consumer)
----

`releaseExecutionMemory`...FIXME

[NOTE]
====
`releaseExecutionMemory` is used when:

* `MemoryConsumer` is requested to link:MemoryConsumer.adoc#freeMemory[freeMemory]

* TaskMemoryManager is requested to <<allocatePage, allocatePage>> and <<freePage, freePage>>
====

== [[getMemoryConsumptionForThisTask]] `getMemoryConsumptionForThisTask` Method

[source, java]
----
long getMemoryConsumptionForThisTask()
----

`getMemoryConsumptionForThisTask`...FIXME

NOTE: `getMemoryConsumptionForThisTask` is used exclusively in Spark tests.

== [[showMemoryUsage]] Displaying Memory Usage

[source, java]
----
void showMemoryUsage()
----

showMemoryUsage prints out the following INFO message to the logs (with the <<taskAttemptId, taskAttemptId>>):

[source,plaintext]
----
Memory used in task [taskAttemptId]
----

showMemoryUsage requests every <<consumers, MemoryConsumer>> to xref:memory:MemoryConsumer.adoc#getUsed[report memory used]. showMemoryUsage prints out the following INFO message to the logs for a MemoryConsumer with some memory usage (and excludes zero-memory consumers):

[source,plaintext]
----
Acquired by [consumer]: [memUsage]
----

showMemoryUsage prints out the following INFO messages to the logs:

[source,plaintext]
----
[amount] bytes of memory were used by task [taskAttemptId] but are not associated with specific consumers
----

[source,plaintext]
----
[executionMemoryUsed] bytes of memory are used for execution and [storageMemoryUsed] bytes of memory are used for storage
----

showMemoryUsage is used when MemoryConsumer is requested to xref:memory:MemoryConsumer.adoc#throwOom[throw an OutOfMemoryError].

== [[pageSizeBytes]] `pageSizeBytes` Method

[source, java]
----
long pageSizeBytes()
----

`pageSizeBytes` simply requests the <<memoryManager, MemoryManager>> for link:MemoryManager.adoc#pageSizeBytes[pageSizeBytes].

NOTE: `pageSizeBytes` is used when...FIXME

== [[freePage]] Freeing Memory Page -- `freePage` Method

[source, java]
----
void freePage(MemoryBlock page, MemoryConsumer consumer)
----

`pageSizeBytes` simply requests the <<memoryManager, MemoryManager>> for link:MemoryManager.adoc#pageSizeBytes[pageSizeBytes].

NOTE: `pageSizeBytes` is used when `MemoryConsumer` is requested to link:MemoryConsumer.adoc#freePage[freePage] and link:MemoryConsumer.adoc#throwOom[throwOom].

== [[getPage]] Getting Page -- `getPage` Method

[source, java]
----
Object getPage(long pagePlusOffsetAddress)
----

`getPage`...FIXME

NOTE: `getPage` is used when...FIXME

== [[getOffsetInPage]] Getting Page Offset -- `getOffsetInPage` Method

[source, java]
----
long getOffsetInPage(long pagePlusOffsetAddress)
----

`getPage`...FIXME

NOTE: `getPage` is used when...FIXME

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.memory.TaskMemoryManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:


[source]
----
log4j.logger.org.apache.spark.memory.TaskMemoryManager=ALL
----

Refer to xref:ROOT:spark-logging.adoc[Logging].

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| acquiredButNotUsed
| [[acquiredButNotUsed]] The size of memory allocated but not used.

| allocatedPages
| [[allocatedPages]] Collection of flags (`true` or `false` values) of size `PAGE_TABLE_SIZE` with all bits initially disabled (i.e. `false`).

TIP: `allocatedPages` is https://docs.oracle.com/javase/8/docs/api/java/util/BitSet.html[java.util.BitSet].

When <<allocatePage, allocatePage>> is called, it will record the page in the registry by setting the bit at the specified index (that corresponds to the allocated page) to `true`.

| pageTable
| [[pageTable]] The array of size `PAGE_TABLE_SIZE` with indices being `MemoryBlock` objects.

When <<allocatePage, allocating a `MemoryBlock` page for Tungsten consumers>>, the index corresponds to `pageNumber` that points to the `MemoryBlock` page allocated.

| tungstenMemoryMode
| [[tungstenMemoryMode]] `MemoryMode` (i.e. `OFF_HEAP` or `ON_HEAP`)

Set to the link:MemoryManager.adoc#tungstenMemoryMode[tungstenMemoryMode] of the <<memoryManager, MemoryManager>> while TaskMemoryManager is <<creating-instance, created>>
|===
