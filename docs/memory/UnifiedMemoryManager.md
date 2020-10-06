= [[UnifiedMemoryManager]] UnifiedMemoryManager

*UnifiedMemoryManager* is the default MemoryManager.md[MemoryManager] (based on ROOT:configuration-properties.md#spark.memory.useLegacyMode[spark.memory.useLegacyMode] configuration property).

== [[creating-instance]] Creating Instance

UnifiedMemoryManager takes the following to be created:

* [[conf]] ROOT:SparkConf.md[SparkConf]
* [[maxHeapMemory]] Maximum heap memory
* [[onHeapStorageRegionSize]] Size of the on-heap storage region
* [[numCores]] Number of CPU cores

UnifiedMemoryManager requires that:

* Sum of the pool size of the MemoryManager.md#onHeapExecutionMemoryPool[on-heap ExecutionMemoryPool] and MemoryManager.md#onHeapStorageMemoryPool[on-heap StorageMemoryPool] is exactly the <<maxHeapMemory, maximum heap memory>>

* Sum of the pool size of the MemoryManager.md#offHeapExecutionMemoryPool[off-heap ExecutionMemoryPool] and MemoryManager.md#offHeapStorageMemoryPool[off-heap StorageMemoryPool] is exactly the maximum off-heap memory (based on ROOT:configuration-properties.md#spark.memory.offHeap.size[spark.memory.offHeap.size] configuration property)

== [[apply]] Creating UnifiedMemoryManager

[source, scala]
----
apply(
  conf: SparkConf,
  numCores: Int): UnifiedMemoryManager
----

`apply` computes the <<getMaxMemory, maximum heap memory>> (using the input ROOT:SparkConf.md[SparkConf]).

`apply` computes the size of the on-heap storage region which is a fraction of the maximum heap memory based on ROOT:configuration-properties.md#spark.memory.storageFraction[spark.memory.storageFraction] configuration property (default: `0.5`).

In the end, `apply` creates a <<creating-instance, UnifiedMemoryManager>> (with the given and computed values).

`apply` is used when `SparkEnv` utility is used to core:SparkEnv.md#create[create a SparkEnv] (for the driver and executors).

== [[getMaxMemory]] Calculating Maximum Heap Memory

[source, scala]
----
getMaxMemory(
  conf: SparkConf): Long
----

`getMaxMemory` calculates the maximum memory to use for execution and storage.

[source, scala]
----
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
----

`getMaxMemory` reads <<spark_testing_memory, the maximum amount of memory that the Java virtual machine will attempt to use>> and decrements it by <<spark_testing_reservedMemory, reserved system memory>> (for non-storage and non-execution purposes).

`getMaxMemory` makes sure that the following requirements are met:

1. System memory is not smaller than about 1,5 of the reserved system memory.
2. executor:Executor.md#spark.executor.memory[spark.executor.memory] is not smaller than about 1,5 of the reserved system memory.

Ultimately, `getMaxMemory` returns <<spark_memory_fraction, spark.memory.fraction>> of the maximum amount of memory for the JVM (minus the reserved system memory).

CAUTION: FIXME omnigraffle it.

== [[acquireExecutionMemory]] `acquireExecutionMemory` Method

[source, scala]
----
acquireExecutionMemory(
  numBytes: Long,
  taskAttemptId: Long,
  memoryMode: MemoryMode): Long
----

NOTE: `acquireExecutionMemory` is part of the memory:MemoryManager.md#acquireExecutionMemory[MemoryManager] contract

`acquireExecutionMemory` does...FIXME

Internally, `acquireExecutionMemory` varies per `MemoryMode`, i.e. `ON_HEAP` and `OFF_HEAP`.

.`acquireExecutionMemory` and `MemoryMode`
[cols="1m,1m,1m",options="header",width="100%"]
|===
|
| ON_HEAP
| OFF_HEAP

| executionPool
| onHeapExecutionMemoryPool
| offHeapExecutionMemoryPool

| storagePool
| onHeapStorageMemoryPool
| offHeapStorageMemoryPool

| storageRegionSize
| onHeapStorageRegionSize
| offHeapStorageMemory

| maxMemory
| maxHeapMemory
| maxOffHeapMemory
|===

CAUTION: FIXME

== [[acquireStorageMemory]] `acquireStorageMemory` Method

[source, scala]
----
acquireStorageMemory(
  blockId: BlockId,
  numBytes: Long,
  memoryMode: MemoryMode): Boolean
----

NOTE: `acquireStorageMemory` is part of the memory:MemoryManager.md#acquireStorageMemory[MemoryManager] contract.

`acquireStorageMemory` has two modes of operation per `memoryMode`, i.e. `MemoryMode.ON_HEAP` or `MemoryMode.OFF_HEAP`, for execution and storage pools, and the maximum amount of memory to use.

CAUTION: FIXME Where are they used?

In `MemoryMode.ON_HEAP`, `onHeapExecutionMemoryPool`, `onHeapStorageMemoryPool`, and <<maxOnHeapStorageMemory, maxOnHeapStorageMemory>> are used.

In `MemoryMode.OFF_HEAP`, `offHeapExecutionMemoryPool`, `offHeapStorageMemoryPool`, and `maxOffHeapMemory` are used.

CAUTION: FIXME What is the difference between them?

It makes sure that the requested number of bytes `numBytes` (for a block to store) fits the available memory. If it is not the case, you should see the following INFO message in the logs and the method returns `false`.

```
INFO Will not store [blockId] as the required space ([numBytes] bytes) exceeds our memory limit ([maxMemory] bytes)
```

If the requested number of bytes `numBytes` is greater than `memoryFree` in the storage pool, `acquireStorageMemory` will attempt to use the free memory from the execution pool.

NOTE: The storage pool can use the free memory from the execution pool.

It will take as much memory as required to fit `numBytes` from `memoryFree` in the execution pool (up to the whole free memory in the pool).

Ultimately, `acquireStorageMemory` requests the storage pool for `numBytes` for `blockId`.

[NOTE]
====
`acquireStorageMemory` is used when `MemoryStore` storage:MemoryStore.md#putBytes[acquires storage memory to putBytes] or storage:MemoryStore.md#putIteratorAsValues[putIteratorAsValues] and storage:MemoryStore.md#putIteratorAsBytes[putIteratorAsBytes].

It is also used internally when UnifiedMemoryManager <<acquireUnrollMemory, acquires unroll memory>>.
====

== [[acquireUnrollMemory]] `acquireUnrollMemory` Method

NOTE: `acquireUnrollMemory` is part of the memory:MemoryManager.md#acquireUnrollMemory[MemoryManager] contract.

`acquireUnrollMemory` simply forwards all the calls to <<acquireStorageMemory, acquireStorageMemory>>.

== [[maxOnHeapStorageMemory]] `maxOnHeapStorageMemory` Method

[source, scala]
----
maxOnHeapStorageMemory: Long
----

NOTE: `maxOnHeapStorageMemory` is part of the memory:MemoryManager.md#acquireExecutionMemory[MemoryManager] contract

`maxOnHeapStorageMemory` is the difference between `maxHeapMemory` of the UnifiedMemoryManager and the memory currently in use in `onHeapExecutionMemoryPool` execution memory pool.
