# UnifiedMemoryManager

`UnifiedMemoryManager` is a [MemoryManager](MemoryManager.md) (with the [onHeapExecutionMemory](MemoryManager.md#onHeapExecutionMemory) being the [Maximum Heap Memory](#maxHeapMemory) with the [onHeapStorageRegionSize](#onHeapStorageRegionSize) taken out).

`UnifiedMemoryManager` allows for soft boundaries between storage and execution memory (allowing requests for memory in one region to be fulfilled by borrowing memory from the other).

## Creating Instance

`UnifiedMemoryManager` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="maxHeapMemory"> Maximum Heap Memory
* <span id="onHeapStorageRegionSize">  Size of the On-Heap Storage Region
* <span id="numCores"> Number of CPU Cores

While being created, `UnifiedMemoryManager` [asserts the invariants](#assertInvariants).

`UnifiedMemoryManager` is created using [apply](#apply) factory.

### <span id="assertInvariants"> Invariants

`UnifiedMemoryManager` asserts the following:

* Sum of the pool size of the [on-heap ExecutionMemoryPool](MemoryManager.md#onHeapExecutionMemoryPool) and [on-heap StorageMemoryPool](MemoryManager.md#onHeapStorageMemoryPool) is exactly the [maximum heap memory](#maxHeapMemory)

* Sum of the pool size of the [off-heap ExecutionMemoryPool](MemoryManager.md#offHeapExecutionMemoryPool) and [off-heap StorageMemoryPool](MemoryManager.md#offHeapStorageMemoryPool) is exactly the [maximum off-heap memory](MemoryManager.md#maxOffHeapMemory)

## <span id="apply"> Creating UnifiedMemoryManager

```scala
apply(
  conf: SparkConf,
  numCores: Int): UnifiedMemoryManager
```

`apply` creates a [UnifiedMemoryManager](#creating-instance) with the following:

Property | Value
---------|---------
 [Maximum Heap Memory](#maxHeapMemory) | [Maximum Memory](#getMaxMemory)
 [onHeapStorageRegionSize](#onHeapStorageRegionSize) | [spark.memory.storageFraction](#spark.memory.storageFraction) of the [Maximum Memory](#getMaxMemory)

`apply` is used when:

* `SparkEnv` utility is used to [create a base SparkEnv](../SparkEnv.md#create) (for the driver and executors)

### <span id="getMaxMemory"> Maximum Heap Memory

```scala
getMaxMemory(
  conf: SparkConf): Long
```

`getMaxMemory` calculates the maximum memory to use for execution and storage based on...FIXME

### Demo

```text
// local mode with --conf spark.driver.memory=2g
scala> sc.getConf.getSizeAsBytes("spark.driver.memory")
res0: Long = 2147483648

scala> val systemMemory = Runtime.getRuntime.maxMemory

// fixed amount of memory for non-storage, non-execution purposes
val reservedMemory = 300 * 1024 * 1024

// minimum system memory required
val minSystemMemory = (reservedMemory * 1.5).ceil.toLong

val usableMemory = systemMemory - reservedMemory

val memoryFraction = sc.getConf.getDouble("spark.memory.fraction", 0.6)
scala> val maxMemory = (usableMemory * memoryFraction).toLong
maxMemory: Long = 956615884

import org.apache.spark.network.util.JavaUtils
scala> JavaUtils.byteStringAsMb(maxMemory + "b")
res1: Long = 912
```

## <span id="maxOnHeapStorageMemory"> Total Available On-Heap Memory for Storage

```scala
maxOnHeapStorageMemory: Long
```

`maxOnHeapStorageMemory` is part of the [MemoryManager](MemoryManager.md#maxOnHeapStorageMemory) abstraction.

`maxOnHeapStorageMemory` is the difference between [Maximum Heap Memory](#maxHeapMemory) and the [memory used](ExecutionMemoryPool.md#memoryUsed) in the [on-heap execution memory pool](MemoryManager.md#onHeapExecutionMemoryPool).
