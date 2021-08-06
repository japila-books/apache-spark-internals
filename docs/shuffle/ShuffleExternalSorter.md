# ShuffleExternalSorter

`ShuffleExternalSorter` is a specialized cache-efficient sorter that sorts arrays of compressed record pointers and partition ids.

`ShuffleExternalSorter` uses only 8 bytes of space per record in the sorting array to fit more of the array into cache.

`ShuffleExternalSorter` is created and used by [UnsafeShuffleWriter](UnsafeShuffleWriter.md#ShuffleExternalSorter) only.

![ShuffleExternalSorter and UnsafeShuffleWriter](../images/shuffle/ShuffleExternalSorter.png)

## <span id="MemoryConsumer"> MemoryConsumer

`ShuffleExternalSorter` is a [MemoryConsumer](../memory/MemoryConsumer.md) with page size of 128 MB (unless [TaskMemoryManager](../memory/TaskMemoryManager.md#pageSizeBytes) uses smaller).

`ShuffleExternalSorter` can [spill to disk to free up execution memory](#spill).

## Configuration Properties

### <span id="fileBufferSizeBytes"> spark.shuffle.file.buffer

`ShuffleExternalSorter` uses [spark.shuffle.file.buffer](../configuration-properties.md#spark.shuffle.file.buffer) configuration property for...FIXME

### <span id="numElementsForSpillThreshold"> spark.shuffle.spill.numElementsForceSpillThreshold

`ShuffleExternalSorter` uses [spark.shuffle.spill.numElementsForceSpillThreshold](../configuration-properties.md#spark.shuffle.spill.numElementsForceSpillThreshold) configuration property for...FIXME

## Creating Instance

`ShuffleExternalSorter` takes the following to be created:

* <span id="memoryManager"> [TaskMemoryManager](../memory/TaskMemoryManager.md)
* <span id="blockManager"> [BlockManager](../storage/BlockManager.md)
* <span id="taskContext"> [TaskContext](../scheduler/TaskContext.md)
* <span id="initialSize"> Initial Size
* <span id="numPartitions"> Number of Partitions
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="writeMetrics"> [ShuffleWriteMetricsReporter](ShuffleWriteMetricsReporter.md)

`ShuffleExternalSorter` is created when `UnsafeShuffleWriter` is requested to [open a ShuffleExternalSorter](UnsafeShuffleWriter.md#open).

## <span id="inMemSorter"> ShuffleInMemorySorter

`ShuffleExternalSorter` manages a [ShuffleInMemorySorter](ShuffleInMemorySorter.md):

* `ShuffleInMemorySorter` is created immediately when `ShuffleExternalSorter` is

* `ShuffleInMemorySorter` is requested to [free up memory](ShuffleInMemorySorter.md#free) and dereferenced (``null``ed) when `ShuffleExternalSorter` is requested to [cleanupResources](#cleanupResources) and [closeAndGetSpills](#closeAndGetSpills)

`ShuffleExternalSorter` uses the `ShuffleInMemorySorter` for the following:

* [writeSortedFile](#writeSortedFile)
* [spill](#spill)
* [getMemoryUsage](#getMemoryUsage)
* [growPointerArrayIfNecessary](#growPointerArrayIfNecessary)
* [insertRecord](#insertRecord)

## <span id="spill"> Spilling To Disk

```java
long spill(
  long size,
  MemoryConsumer trigger)
```

`spill` returns the memory bytes spilled (_spill size_).

`spill` prints out the following INFO message to the logs:

```text
Thread [threadId] spilling sort data of [memoryUsage] to disk ([spillsSize] [time|times] so far)
```

`spill` [writeSortedFile](#writeSortedFile) (with the `isLastFile` flag disabled).

`spill` [frees up execution memory](#freeMemory) (and records the memory bytes spilled as `spillSize`).

`spill` requests the [ShuffleInMemorySorter](#inMemSorter) to [reset](ShuffleInMemorySorter.md#reset).

In the end, `spill` requests the [TaskContext](#taskContext) for [TaskMetrics](../scheduler/TaskContext.md#taskMetrics) to [increase the memory bytes spilled](../executor/TaskMetrics.md#incMemoryBytesSpilled).

`spill` is part of the [MemoryConsumer](../memory/MemoryConsumer.md#spill) abstraction.

## <span id="closeAndGetSpills"> closeAndGetSpills

```java
SpillInfo[] closeAndGetSpills()
```

`closeAndGetSpills`...FIXME

`closeAndGetSpills` is used when `UnsafeShuffleWriter` is requested to [closeAndWriteOutput](UnsafeShuffleWriter.md#closeAndWriteOutput).

## <span id="getMemoryUsage"> getMemoryUsage

```java
long getMemoryUsage()
```

`getMemoryUsage`...FIXME

`getMemoryUsage` is used when `ShuffleExternalSorter` is created and requested to [spill](#spill) and [updatePeakMemoryUsed](#updatePeakMemoryUsed).

## <span id="updatePeakMemoryUsed"> updatePeakMemoryUsed

```java
void updatePeakMemoryUsed()
```

`updatePeakMemoryUsed`...FIXME

`updatePeakMemoryUsed` is used when `ShuffleExternalSorter` is requested to [getPeakMemoryUsedBytes](#getPeakMemoryUsedBytes) and [freeMemory](#freeMemory).

## <span id="writeSortedFile"> writeSortedFile

```java
void writeSortedFile(
  boolean isLastFile)
```

`writeSortedFile`...FIXME

`writeSortedFile` is used when `ShuffleExternalSorter` is requested to [spill](#spill) and [closeAndGetSpills](#closeAndGetSpills).

## <span id="cleanupResources"> cleanupResources

```java
void cleanupResources()
```

`cleanupResources`...FIXME

`cleanupResources` is used when `UnsafeShuffleWriter` is requested to [write records](UnsafeShuffleWriter.md#write) and [stop](UnsafeShuffleWriter.md#stop).

## <span id="insertRecord"> Inserting Serialized Record Into ShuffleInMemorySorter

```java
void insertRecord(
  Object recordBase,
  long recordOffset,
  int length,
  int partitionId)
```

`insertRecord`...FIXME

`insertRecord` [growPointerArrayIfNecessary](#growPointerArrayIfNecessary).

`insertRecord`...FIXME

`insertRecord` [acquireNewPageIfNecessary](#acquireNewPageIfNecessary).

`insertRecord`...FIXME

`insertRecord` is used when `UnsafeShuffleWriter` is requested to [insertRecordIntoSorter](UnsafeShuffleWriter.md#insertRecordIntoSorter)

### <span id="growPointerArrayIfNecessary"> growPointerArrayIfNecessary

```java
void growPointerArrayIfNecessary()
```

`growPointerArrayIfNecessary`...FIXME

### <span id="acquireNewPageIfNecessary"> acquireNewPageIfNecessary

```java
void acquireNewPageIfNecessary(
  int required)
```

`acquireNewPageIfNecessary`...FIXME

## <span id="freeMemory"> freeMemory

```java
long freeMemory()
```

`freeMemory`...FIXME

`freeMemory` is used when `ShuffleExternalSorter` is requested to [spill](#spill), [cleanupResources](#cleanupResources), and [closeAndGetSpills](#closeAndGetSpills).

## <span id="getPeakMemoryUsedBytes"> Peak Memory Used

```java
long getPeakMemoryUsedBytes()
```

`getPeakMemoryUsedBytes`...FIXME

`getPeakMemoryUsedBytes` is used when `UnsafeShuffleWriter` is requested to [updatePeakMemoryUsed](UnsafeShuffleWriter.md#updatePeakMemoryUsed).

## Logging

Enable `ALL` logging level for `org.apache.spark.shuffle.sort.ShuffleExternalSorter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.shuffle.sort.ShuffleExternalSorter=ALL
```

Refer to [Logging](../spark-logging.md).
