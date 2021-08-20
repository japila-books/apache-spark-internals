# TaskMemoryManager

`TaskMemoryManager` manages the memory allocated to a [single task](#taskAttemptId) (using [MemoryManager](#memoryManager)).

`TaskMemoryManager` assumes that:

1. <span id="PAGE_NUMBER_BITS"> The number of bits to address pages is `13`
1. <span id="OFFSET_BITS"> The number of bits to encode offsets in pages is `51` (64 bits - [13 bits](#PAGE_NUMBER_BITS))
1. <span id="PAGE_TABLE_SIZE"> Number of pages in the [page table](#pageTable) and [to be allocated](#allocatedPages) is `8192` (`1 <<` [13](#PAGE_NUMBER_BITS))
1. <span id="MAXIMUM_PAGE_SIZE_BYTES"> The maximum page size is `15GB` (`((1L << 31) - 1) * 8L`)

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

## <span id="pageTable"> Page Table (MemoryBlocks)

`TaskMemoryManager` uses an array of `MemoryBlock`s (to mimic an operating system's page table).

The page table uses 13 bits for addressing pages.

A page is "stored" in [allocatePage](#allocatePage) and "removed" in [freePage](#freePage).

All pages are released (_removed_) in [cleanUpAllAllocatedMemory](#cleanUpAllAllocatedMemory).

`TaskMemoryManager` uses the page table when requested to:

* [getPage](#getPage)
* [getOffsetInPage](#getOffsetInPage)

## <span id="consumers"> Spillable Memory Consumers

```java
HashSet<MemoryConsumer> consumers
```

`TaskMemoryManager` tracks [spillable memory consumers](MemoryConsumer.md).

`TaskMemoryManager` registers a new memory consumer when requested to [acquire execution memory](#acquireExecutionMemory).

`TaskMemoryManager` removes (_clears_) all registered memory consumers when [cleaning up all the allocated memory](#cleanUpAllAllocatedMemory).

Memory consumers are used to report memory usage when `TaskMemoryManager` is requested to [show memory usage](#showMemoryUsage).

## <span id="acquiredButNotUsed"> Memory Acquired But Not Used

`TaskMemoryManager` tracks the size of memory [allocated](#allocatePage) but not used (by any of the [MemoryConsumer](#consumers)s due to a `OutOfMemoryError` upon trying to use it).

`TaskMemoryManager` releases the memory when [cleaning up all the allocated memory](#cleanUpAllAllocatedMemory).

## <span id="allocatedPages"> Allocated Pages

```java
BitSet allocatedPages
```

`TaskMemoryManager` uses a `BitSet` ([Java]({{ java.api }}/java.base.java/util/BitSet.html)) to track [allocated pages](#allocatePage).

The size is exactly the number of entries in the [page table](#pageTable) ([8192](#PAGE_TABLE_SIZE)).

## <span id="tungstenMemoryMode"><span id="getTungstenMemoryMode"> MemoryMode

`TaskMemoryManager` can be in `ON_HEAP` or `OFF_HEAP` mode (to avoid extra work for off-heap and hoping that the JIT handles branching well).

`TaskMemoryManager` is given the `MemoryMode` matching the [MemoryMode](MemoryManager.md#tungstenMemoryMode) (of the given [MemoryManager](#memoryManager)) when [created](#creating-instance).

`TaskMemoryManager` uses the `MemoryMode` to match to for the following:

* [allocatePage](#allocatePage)
* [cleanUpAllAllocatedMemory](#cleanUpAllAllocatedMemory)

For `OFF_HEAP` mode, `TaskMemoryManager` has to change offset while [encodePageNumberAndOffset](#encodePageNumberAndOffset) and [getOffsetInPage](#getOffsetInPage).

For `OFF_HEAP` mode, `TaskMemoryManager` returns no [page](#getPage).

The `MemoryMode` is used when:

* `ShuffleExternalSorter` is [created](../shuffle/ShuffleExternalSorter.md)
* `BytesToBytesMap` is [created](BytesToBytesMap.md)
* `UnsafeExternalSorter` is [created](UnsafeExternalSorter.md)
* `Spillable` is requested to [spill](../shuffle/Spillable.md#spill) (only when in `ON_HEAP` mode)

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

## <span id="cleanUpAllAllocatedMemory"> Cleaning Up All Allocated Memory

```java
long cleanUpAllAllocatedMemory()
```

The `consumers` collection is then cleared.

`cleanUpAllAllocatedMemory` finds all the registered [MemoryConsumer](MemoryConsumer.md)s (in the [consumers](#consumers) registry) that still keep [some memory used](MemoryConsumer.md#getUsed) and, for every such consumer, prints out the following DEBUG message to the logs:

```text
unreleased [getUsed] memory from [consumer]
```

`cleanUpAllAllocatedMemory` removes all the [consumers](#consumers).

---

For every `MemoryBlock` in the [pageTable](#pageTable), `cleanUpAllAllocatedMemory` prints out the following DEBUG message to the logs:

```text
unreleased page: [page] in task [taskAttemptId]
```

`cleanUpAllAllocatedMemory` marks the pages to be freed (`FREED_IN_TMM_PAGE_NUMBER`) and requests the [MemoryManager](#memoryManager) for the [tungstenMemoryAllocator](MemoryManager.md#tungstenMemoryAllocator) to [free up the MemoryBlock](MemoryAllocator.md#free).

`cleanUpAllAllocatedMemory` clears the [pageTable](#pageTable) registry (by assigning `null` values).

---

`cleanUpAllAllocatedMemory` requests the [MemoryManager](#memoryManager) to [release execution memory](MemoryManager.md#releaseExecutionMemory) that is not used by any consumer (with the [acquiredButNotUsed](#acquiredButNotUsed) and the [tungstenMemoryMode](#tungstenMemoryMode)).

In the end, `cleanUpAllAllocatedMemory` requests the [MemoryManager](#memoryManager) to [release all execution memory for the task](MemoryManager.md#releaseAllExecutionMemoryForTask).

---

`cleanUpAllAllocatedMemory` is used when:

* `TaskRunner` is requested to [run a task](../executor/TaskRunner.md#run) (and the task has finished successfully)

## <span id="allocatePage"> Allocating Memory Page

```java
MemoryBlock allocatePage(
  long size,
  MemoryConsumer consumer)
```

`allocatePage` allocates a block of memory (_page_) that is:

1. Below [MAXIMUM_PAGE_SIZE_BYTES](#MAXIMUM_PAGE_SIZE_BYTES) maximum size
1. For [MemoryConsumer](MemoryConsumer.md)s with the same [MemoryMode](MemoryConsumer.md#getMode) as the [TaskMemoryManager](#tungstenMemoryMode)

`allocatePage` [acquireExecutionMemory](#acquireExecutionMemory) (for the `size` and the [MemoryConsumer](MemoryConsumer.md)). `allocatePage` returns immediately (with `null`) when this allocation ended up with `0` or less bytes.

`allocatePage` allocates the first clear bit in the [allocatedPages](#allocatedPages) (unless the whole page table is taken and `allocatePage` throws an `IllegalStateException`).

`allocatePage` requests the [MemoryManager](#memoryManager) for the [tungstenMemoryAllocator](MemoryManager.md#tungstenMemoryAllocator) that is requested to [allocate the acquired memory](MemoryAllocator.md#allocate).

`allocatePage` registers the page in the [pageTable](#pageTable).

In the end, `allocatePage` prints out the following TRACE message to the logs and returns the `MemoryBlock` allocated.

```text
Allocate page number [pageNumber] ([acquired] bytes)
```

### <span id="allocatePage-usage"> Usage

`allocatePage` is used when:

* `MemoryConsumer` is requested to allocate an [array](MemoryConsumer.md#allocateArray) and a [page](MemoryConsumer.md#allocatePage)

### <span id="allocatePage-TooLargePageException"> TooLargePageException

For sizes larger than the [MAXIMUM_PAGE_SIZE_BYTES](#MAXIMUM_PAGE_SIZE_BYTES) `allocatePage` throws a `TooLargePageException`.

### <span id="allocatePage-OutOfMemoryError"> OutOfMemoryError

Requesting the [tungstenMemoryAllocator](MemoryManager.md#tungstenMemoryAllocator) to [allocate the acquired memory](MemoryAllocator.md#allocate) may throw an `OutOfMemoryError`. If so, `allocatePage` prints out the following WARN message to the logs:

```text
Failed to allocate a page ([acquired] bytes), try again.
```

`allocatePage` adds the acquired memory to the [acquiredButNotUsed](#acquiredButNotUsed) and removes the page from the [allocatedPages](#allocatedPages) (by clearing the bit).

In the end, `allocatePage` tries to [allocate the page](#allocatePage) again (recursively).

## <span id="freePage"> Releasing Memory Page

```java
void freePage(
  MemoryBlock page,
  MemoryConsumer consumer)
```

`pageSizeBytes` requests the [MemoryManager](#memoryManager) for [pageSizeBytes](MemoryManager.md#pageSizeBytes).

`pageSizeBytes` is used when:

* `MemoryConsumer` is requested to [freePage](MemoryConsumer.md#freePage) and [throwOom](MemoryConsumer.md#throwOom)

## <span id="getPage"> Getting Page

```java
Object getPage(
  long pagePlusOffsetAddress)
```

`getPage` handles the `ON_HEAP` mode of the [tungstenMemoryMode](#tungstenMemoryMode) only.

`getPage` looks up the page (by the given address) in the [page table](#pageTable) and requests it for the base object.

`getPage` is used when:

* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)
* `Location` (of [BytesToBytesMap](BytesToBytesMap.md)) is requested to `updateAddressesAndSizes`
* `SortComparator` (of [UnsafeInMemorySorter](UnsafeInMemorySorter.md)) is requested to `compare` two record pointers
* `SortedIterator` (of [UnsafeInMemorySorter](UnsafeInMemorySorter.md)) is requested to `loadNext` record

## <span id="getOffsetInPage"> getOffsetInPage

```java
long getOffsetInPage(
  long pagePlusOffsetAddress)
```

`getOffsetInPage` gives the offset associated with the given `pagePlusOffsetAddress` (encoded by `encodePageNumberAndOffset`).

`getOffsetInPage` is used when:

* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)
* `Location` (of [BytesToBytesMap](BytesToBytesMap.md)) is requested to `updateAddressesAndSizes`
* `SortComparator` (of [UnsafeInMemorySorter](UnsafeInMemorySorter.md)) is requested to `compare` two record pointers
* `SortedIterator` (of [UnsafeInMemorySorter](UnsafeInMemorySorter.md)) is requested to `loadNext` record

## Logging

Enable `ALL` logging level for `org.apache.spark.memory.TaskMemoryManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.memory.TaskMemoryManager=ALL
```

Refer to [Logging](../spark-logging.md).
