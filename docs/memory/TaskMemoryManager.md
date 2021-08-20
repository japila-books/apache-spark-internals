# TaskMemoryManager

`TaskMemoryManager` manages the memory allocated to a [single task](#taskAttemptId) (using [MemoryManager](#memoryManager)).

## Creating Instance

`TaskMemoryManager` takes the following to be created:

* [MemoryManager](#memoryManager)
* <span id="taskAttemptId"> Task Attempt ID

`TaskMemoryManager` is created when:

* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run)

![Creating TaskMemoryManager for Task](../images/memory/TaskMemoryManager.png)

## <span id="memoryManager"> MemoryManager

`TaskMemoryManager` is given a [MemoryManager](MemoryManager.md) when [created](#creating-instance).

`TaskMemoryManager` uses the `MemoryManager` when requested for the following:

* [Acquiring](#acquireExecutionMemory), [releasing](#releaseExecutionMemory) or [cleaning up](#cleanUpAllAllocatedMemory) execution memory
* [Report memory usage](#showMemoryUsage)
* [pageSizeBytes](#pageSizeBytes)
* [Allocating a memory block for Tungsten consumers](#allocatePage)
* [freePage](#freePage)
* [getMemoryConsumptionForThisTask](#getMemoryConsumptionForThisTask)

## <span id="consumers"> Spillable Memory Consumers

```java
HashSet<MemoryConsumer> consumers
```

`TaskMemoryManager` tracks [spillable memory consumers](MemoryConsumer.md).

`TaskMemoryManager` registers a new memory consumer when requested to [acquire execution memory](#acquireExecutionMemory).

`TaskMemoryManager` removes (_clears_) all registered memory consumers when [cleaning up all the allocated memory](#cleanUpAllAllocatedMemory).

Memory consumers are used to report memory usage when `TaskMemoryManager` is requested to [show memory usage](#showMemoryUsage).

## <span id="acquireExecutionMemory"> Acquiring Execution Memory

```java
long acquireExecutionMemory(
  long required,
  MemoryConsumer consumer)
```

`acquireExecutionMemory` allocates up to `required` execution memory (bytes) for the [MemoryConsumer](MemoryConsumer.md) (from the [MemoryManager](#memoryManager)).

When not enough memory could be allocated initially, `acquireExecutionMemory` requests every consumer (with the same [MemoryMode](MemoryConsumer.md#getMode), itself including) to [spill](MemoryConsumer.md#spill).

`acquireExecutionMemory` returns the amount of memory allocated.

`acquireExecutionMemory` is used when:

* `MemoryConsumer` is requested to [acquire execution memory](MemoryConsumer.md#acquireMemory)
* `TaskMemoryManager` is requested to [allocate a page](#allocatePage)

---

`acquireExecutionMemory` requests the [MemoryManager](#memoryManager) to [acquire execution memory](MemoryManager.md#acquireExecutionMemory) (with `required` bytes, the [taskAttemptId](#taskAttemptId) and the [MemoryMode](MemoryConsumer.md#getMode) of the [MemoryConsumer](MemoryConsumer.md)).

In the end, `acquireExecutionMemory` registers the `MemoryConsumer` (and adds it to the [consumers](#consumers) registry) and prints out the following DEBUG message to the logs:

```text
Task [taskAttemptId] acquired [got] for [consumer]
```

---

In case `MemoryManager` will have offerred less memory than `required`, `acquireExecutionMemory` finds the [MemoryConsumer](MemoryConsumer.md)s (in the [consumers](#consumers) registry) with the [MemoryMode](MemoryConsumer.md#getMode) and non-zero [memory used](MemoryConsumer.md#getUsed), sorts them by memory usage, requests them (one by one) to [spill](MemoryConsumer.md#spill) until enough memory is acquired or there are no more consumers to release memory from (by spilling).

When a `MemoryConsumer` releases memory, `acquireExecutionMemory` prints out the following DEBUG message to the logs:

```text
Task [taskAttemptId] released [released] from [c] for [consumer]
```

---

In case there is still not enough memory (less than `required`), `acquireExecutionMemory` requests the `MemoryConsumer` (to acquire memory for) to [spill](MemoryConsumer.md#spill).

`acquireExecutionMemory` prints out the following DEBUG message to the logs:

```text
Task [taskAttemptId] released [released] from itself ([consumer])
```

## <span id="releaseExecutionMemory"> Releasing Execution Memory

```java
void releaseExecutionMemory(
  long size,
  MemoryConsumer consumer)
```

`releaseExecutionMemory` prints out the following DEBUG message to the logs:

```text
Task [taskAttemptId] release [size] from [consumer]
```

In the end, `releaseExecutionMemory` requests the [MemoryManager](#memoryManager) to [releaseExecutionMemory](MemoryManager.md#releaseExecutionMemory).

`releaseExecutionMemory` is used when:

* `MemoryConsumer` is requested to [free up memory](MemoryConsumer.md#freeMemory)
* `TaskMemoryManager` is requested to [allocatePage](#allocatePage) and [freePage](#freePage)

## <span id="pageSizeBytes"> Page Size

```java
long pageSizeBytes()
```

`pageSizeBytes` requests the [MemoryManager](#memoryManager) for the [pageSizeBytes](MemoryManager.md#pageSizeBytes).

`pageSizeBytes` is used when:

* `MemoryConsumer` is [created](MemoryConsumer.md#pageSize)
* `ShuffleExternalSorter` is [created](../shuffle/ShuffleExternalSorter.md#pageSize) (as a `MemoryConsumer`)

## <span id="showMemoryUsage"> Reporting Memory Usage

```java
void showMemoryUsage()
```

`showMemoryUsage` prints out the following INFO message to the logs (with the [taskAttemptId](#taskAttemptId)):

```text
Memory used in task [taskAttemptId]
```

`showMemoryUsage` requests every [MemoryConsumer](#consumers) to [report memory used](MemoryConsumer.md#getUsed). For consumers with non-zero memory usage, `showMemoryUsage` prints out the following INFO message to the logs:

```text
Acquired by [consumer]: [memUsage]
```

`showMemoryUsage` requests the [MemoryManager](#memoryManager) to [getExecutionMemoryUsageForTask](MemoryManager.md#getExecutionMemoryUsageForTask) to calculate memory not accounted for (that is not associated with a specific consumer).

`showMemoryUsage` prints out the following INFO messages to the logs:

```text
[memoryNotAccountedFor] bytes of memory were used by task [taskAttemptId] but are not associated with specific consumers
```

`showMemoryUsage` requests the [MemoryManager](#memoryManager) for the [executionMemoryUsed](MemoryManager.md#executionMemoryUsed) and [storageMemoryUsed](MemoryManager.md#storageMemoryUsed) and prints out the following INFO message to the logs:

```text
[executionMemoryUsed] bytes of memory are used for execution and
[storageMemoryUsed] bytes of memory are used for storage
```

`showMemoryUsage` is used when:

* `MemoryConsumer` is requested to [throw an OutOfMemoryError](MemoryConsumer.md#throwOom)

## Logging

Enable `ALL` logging level for `org.apache.spark.memory.TaskMemoryManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.memory.TaskMemoryManager=ALL
```

Refer to [Logging](../spark-logging.md).

## Review Me

TaskMemoryManager assumes that:

* The number of bits to address pages (aka `PAGE_NUMBER_BITS`) is `13`
* The number of bits to encode offsets in data pages (aka `OFFSET_BITS`) is `51` (i.e. 64 bits - `PAGE_NUMBER_BITS`)
* The number of entries in the <<pageTable, page table>> and <<allocatedPages, allocated pages>> (aka `PAGE_TABLE_SIZE`) is `8192` (i.e. 1 << `PAGE_NUMBER_BITS`)
* The maximum page size (aka `MAXIMUM_PAGE_SIZE_BYTES`) is `15GB` (i.e. `((1L << 31) - 1) * 8L`)

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

MemoryManager.md#releaseExecutionMemory[MemoryManager.releaseExecutionMemory] is executed to release the memory that is not used by any consumer.

Before `cleanUpAllAllocatedMemory` returns, it calls MemoryManager.md#releaseAllExecutionMemoryForTask[MemoryManager.releaseAllExecutionMemoryForTask] that in turn becomes the return value.

CAUTION: FIXME Image with the interactions to `MemoryManager`.

NOTE: `cleanUpAllAllocatedMemory` is used exclusively when `TaskRunner` is requested to executor:TaskRunner.md#run[run] (and cleans up after itself).

== [[allocatePage]] Allocating Memory Block for Tungsten Consumers

[source, java]
----
MemoryBlock allocatePage(
  long size,
  MemoryConsumer consumer)
----

NOTE: It only handles *Tungsten Consumers*, i.e. MemoryConsumer.md[MemoryConsumers] in `tungstenMemoryMode` mode.

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

== [[getMemoryConsumptionForThisTask]] `getMemoryConsumptionForThisTask` Method

[source, java]
----
long getMemoryConsumptionForThisTask()
----

`getMemoryConsumptionForThisTask`...FIXME

NOTE: `getMemoryConsumptionForThisTask` is used exclusively in Spark tests.

== [[freePage]] Freeing Memory Page -- `freePage` Method

[source, java]
----
void freePage(MemoryBlock page, MemoryConsumer consumer)
----

`pageSizeBytes` simply requests the <<memoryManager, MemoryManager>> for MemoryManager.md#pageSizeBytes[pageSizeBytes].

NOTE: `pageSizeBytes` is used when `MemoryConsumer` is requested to MemoryConsumer.md#freePage[freePage] and MemoryConsumer.md#throwOom[throwOom].

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

Set to the MemoryManager.md#tungstenMemoryMode[tungstenMemoryMode] of the <<memoryManager, MemoryManager>> while TaskMemoryManager is <<creating-instance, created>>
|===
