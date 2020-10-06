# MemoryManager

`MemoryManager` is an <<contract, abstraction>> of <<implementations, memory managers>> that manage shared memory for task execution (memory:TaskMemoryManager.md#memoryManager[TaskMemoryManager]) and block storage (storage:BlockManager.md#memoryManager[BlockManager]).

`MemoryManager` splits available memory into two regions:

* *Execution memory* for computations in shuffles, joins, sorts and aggregations

* *Storage memory* for caching and propagating internal data across Spark nodes (in <<onHeapStorageMemoryPool, on->> and <<offHeapStorageMemoryPool, off-heap>> mode)

`MemoryManager` is used to create storage:BlockManager.md#memoryManager[BlockManager] (and storage:MemoryStore.md#memoryManager[MemoryStore]) and memory:TaskMemoryManager.md#memoryManager[TaskMemoryManager].

![MemoryManager and Core Services](../images/memory/MemoryManager.png)

== [[contract]] Contract

=== [[acquireExecutionMemory]] Acquiring Execution Memory for Task

[source,scala]
----
acquireExecutionMemory(
  numBytes: Long,
  taskAttemptId: Long,
  memoryMode: MemoryMode): Long
----

acquireExecutionMemory tries to acquire up to `numBytes` of execution memory for the current task (by `taskAttemptId`) and return the number of bytes obtained, or 0 if none can be allocated.

acquireExecutionMemory is used when TaskMemoryManager is requested to memory:TaskMemoryManager.md#acquireExecutionMemory[acquire execution memory].

=== [[acquireStorageMemory]] Acquiring Storage Memory for Block

[source, scala]
----
acquireStorageMemory(
  blockId: BlockId,
  numBytes: Long,
  memoryMode: MemoryMode): Boolean
----

acquireStorageMemory tries to acquire `numBytes` bytes of memory to cache the given storage:BlockId.md[block], evicting existing ones if necessary.

acquireStorageMemory is used when:

* UnifiedMemoryManager is requested to memory:UnifiedMemoryManager.md#acquireUnrollMemory[acquireUnrollMemory]

* `MemoryStore` is requested to storage:MemoryStore.md#putBytes[putBytes] and storage:MemoryStore.md#putIterator[putIterator]

=== [[acquireUnrollMemory]] Acquiring Unroll Memory for Block

[source, scala]
----
acquireUnrollMemory(
  blockId: BlockId,
  numBytes: Long,
  memoryMode: MemoryMode): Boolean
----

acquireUnrollMemory tries to acquire `numBytes` bytes of memory to unroll the given storage:BlockId.md[block], evicting existing ones if necessary.

acquireUnrollMemory is used when MemoryStore is requested to storage:MemoryStore.md#reserveUnrollMemoryForThisTask[reserveUnrollMemoryForThisTask].

=== [[maxOffHeapStorageMemory]] Total Available Off-Heap Storage Memory

[source, scala]
----
maxOffHeapStorageMemory: Long
----

maxOffHeapStorageMemory is the total available off-heap memory for storage (in bytes).

maxOffHeapStorageMemory may vary over time.

maxOffHeapStorageMemory is used when:

* UnifiedMemoryManager is requested to memory:UnifiedMemoryManager.md#acquireStorageMemory[acquireStorageMemory]

* BlockManager is storage:BlockManager.md#maxOffHeapMemory[created]

* MemoryStore is requested for the storage:MemoryStore.md#maxMemory[total amount of memory available]

=== [[maxOnHeapStorageMemory]] Total Available On-Heap Storage Memory

[source, scala]
----
maxOnHeapStorageMemory: Long
----

maxOnHeapStorageMemory is the total available on-heap memory for storage (in bytes).

maxOnHeapStorageMemory may vary over time.

maxOnHeapStorageMemory is used when:

* UnifiedMemoryManager is requested to memory:UnifiedMemoryManager.md#acquireStorageMemory[acquireStorageMemory]

* BlockManager is storage:BlockManager.md#maxOnHeapMemory[created]

* MemoryStore is requested for the storage:MemoryStore.md#maxMemory[total amount of memory available]

* (legacy) StaticMemoryManager is memory:StaticMemoryManager.md#maxOnHeapStorageMemory[created] and requested to memory:StaticMemoryManager.md#acquireStorageMemory[acquireStorageMemory]

== [[implementations]] Available MemoryManagers

[cols="30m,70",options="header",width="100%"]
|===
| MemoryManager
| Description

| StaticMemoryManager.md[StaticMemoryManager]
| [[StaticMemoryManager]] Legacy memory manager

| UnifiedMemoryManager.md[UnifiedMemoryManager]
| [[UnifiedMemoryManager]] Default memory manager
|===

== [[creating-instance]] Creating Instance

MemoryManager takes the following to be created:

* [[conf]] ROOT:SparkConf.md[]
* [[numCores]] Number of CPU cores
* [[onHeapStorageMemory]] Size of the on-heap storage memory
* [[onHeapExecutionMemory]] Size of the on-heap execution memory

MemoryManager is an abstract class and cannot be created directly. It is created indirectly for the <<implementations, concrete MemoryManagers>>.

== [[onHeapStorageMemoryPool]][[offHeapStorageMemoryPool]] MemoryPools for Storage

MemoryManager creates two memory:StorageMemoryPool.md[]s for on- and off-heap storage (ON_HEAP and OFF_HEAP memory modes, respectively) when <<creating-instance, created>>.

MemoryManager immediately requests them to memory:MemoryPool.md#incrementPoolSize[incrementPoolSize] as follows:

* On-heap storage memory pool is initialized to the assigned <<onHeapStorageMemory, onHeapStorageMemory>> size

* Off-heap storage memory pool is initialized to the ROOT:configuration-properties.md#spark.memory.storageFraction[spark.memory.storageFraction] of ROOT:configuration-properties.md#spark.memory.offHeap.size[spark.memory.offHeap.size]

MemoryManager requests the MemoryPools to memory:StorageMemoryPool.md#setMemoryStore[use a given MemoryStore] when requested to <<setMemoryStore, setMemoryStore>>.

MemoryManager requests the MemoryPools to memory:StorageMemoryPool.md#releaseMemory[releaseMemory] when requested to <<releaseStorageMemory, releaseStorageMemory>>.

MemoryManager requests the MemoryPools to memory:StorageMemoryPool.md#releaseAllMemory[releaseAllMemory] when requested to <<releaseAllStorageMemory, releaseAllStorageMemory>>.

MemoryManager requests the MemoryPools for the memory:StorageMemoryPool.md#memoryUsed[memoryUsed] when requested for <<storageMemoryUsed, storageMemoryUsed>>.

== [[SparkEnv]] Accessing MemoryManager Using SparkEnv

MemoryManager is available as core:SparkEnv.md#memoryManager[SparkEnv] on the driver and executors.

[source,plaintext]
----
import org.apache.spark.SparkEnv
val mm = SparkEnv.get.memoryManager

scala> :type mm
org.apache.spark.memory.MemoryManager
----

== [[spark.memory.useLegacyMode]] spark.memory.useLegacyMode Configuration Property

A <<implementations, concrete MemoryManager>> is chosen based on ROOT:configuration-properties.md#spark.memory.useLegacyMode[spark.memory.useLegacyMode] configuration property (when core:SparkEnv.md#memoryManager[SparkEnv] is created for the driver and executors).

== [[executionMemoryUsed]] executionMemoryUsed Method

[source,scala]
----
executionMemoryUsed: Long
----

executionMemoryUsed...FIXME

executionMemoryUsed is used when...FIXME

== [[releaseAllStorageMemory]] releaseAllStorageMemory Method

[source,scala]
----
releaseAllStorageMemory(): Unit
----

releaseAllStorageMemory...FIXME

releaseAllStorageMemory is used when...FIXME

== [[releaseUnrollMemory]] releaseUnrollMemory Method

[source,scala]
----
releaseUnrollMemory(
  numBytes: Long,
  memoryMode: MemoryMode): Unit
----

releaseUnrollMemory...FIXME

releaseUnrollMemory is used when...FIXME

== [[setMemoryStore]] Associating MemoryStore with Storage MemoryPools

[source,scala]
----
setMemoryStore(
  store: MemoryStore): Unit
----

setMemoryStore requests the <<onHeapStorageMemoryPool, onHeapStorageMemoryPool>> and <<offHeapStorageMemoryPool, offHeapStorageMemoryPool>> to memory:StorageMemoryPool.md#setMemoryStore[use] the given storage:MemoryStore.md[].

setMemoryStore is used when storage:BlockManager.md[] is created.

== [[releaseExecutionMemory]] `releaseExecutionMemory` Method

[source, scala]
----
releaseExecutionMemory(
  numBytes: Long,
  taskAttemptId: Long,
  memoryMode: MemoryMode): Unit
----

`releaseExecutionMemory`...FIXME

NOTE: `releaseExecutionMemory` is used when `TaskMemoryManager` is requested to TaskMemoryManager.md#releaseExecutionMemory[releaseExecutionMemory] and TaskMemoryManager.md#cleanUpAllAllocatedMemory[cleanUpAllAllocatedMemory]

== [[releaseAllExecutionMemoryForTask]] `releaseAllExecutionMemoryForTask` Method

[source, scala]
----
releaseAllExecutionMemoryForTask(taskAttemptId: Long): Long
----

`releaseAllExecutionMemoryForTask`...FIXME

NOTE: `releaseAllExecutionMemoryForTask` is used exclusively when `TaskRunner` is requested to executor:TaskRunner.md#run[run] (and cleans up after itself).

== [[tungstenMemoryMode]] `tungstenMemoryMode` Flag

[source, scala]
----
tungstenMemoryMode: MemoryMode
----

`tungstenMemoryMode` returns `OFF_HEAP` only when the following are all met:

* ROOT:configuration-properties.md#spark.memory.offHeap.enabled[spark.memory.offHeap.enabled] configuration property is enabled (it is not by default)

* ROOT:configuration-properties.md#spark.memory.offHeap.size[spark.memory.offHeap.size] configuration property is greater than `0` (it is `0` by default)

* JVM supports unaligned memory access (aka *unaligned Unsafe*, i.e. `sun.misc.Unsafe` package is available and the underlying system has unaligned-access capability)

Otherwise, `tungstenMemoryMode` returns `ON_HEAP`.

NOTE: Given that ROOT:configuration-properties.md#spark.memory.offHeap.enabled[spark.memory.offHeap.enabled] configuration property is disabled (`false`) by default and ROOT:configuration-properties.md#spark.memory.offHeap.size[spark.memory.offHeap.size] configuration property is `0` by default, Spark seems to encourage using Tungsten memory allocated on the JVM heap (`ON_HEAP`).

NOTE: `tungstenMemoryMode` is a Scala `final val` and cannot be changed by custom <<implementations, MemoryManagers>>.

[NOTE]
====
`tungstenMemoryMode` is used when:

* `TaskMemoryManager` is TaskMemoryManager.md#tungstenMemoryMode[created]

* MemoryManager is created (and initializes the <<pageSizeBytes, pageSizeBytes>> and <<tungstenMemoryAllocator, tungstenMemoryAllocator>> internal properties)
====

== [[freePage]] `freePage` Method

[source, java]
----
void freePage(MemoryBlock page)
----

`freePage`...FIXME

NOTE: `freePage` is used when...FIXME

== [[storageMemoryUsed]] storageMemoryUsed Method

[source, scala]
----
storageMemoryUsed: Long
----

storageMemoryUsed gives the total of the memory used by the <<onHeapStorageMemoryPool, on-heap>> and <<offHeapStorageMemoryPool, off-heap>> StorageMemoryPools.

storageMemoryUsed is used when:

* MemoryStore is requested for storage:MemoryStore.md#memoryUsed[memoryUsed]

* TaskMemoryManager is requested to memory:TaskMemoryManager.md#showMemoryUsage[showMemoryUsage]

== [[releaseStorageMemory]] releaseStorageMemory Method

[source, scala]
----
releaseStorageMemory(
  numBytes: Long,
  memoryMode: MemoryMode): Unit
----

releaseStorageMemory...FIXME

releaseStorageMemory is used when:

* MemoryManager is requested to <<releaseUnrollMemory, releaseUnrollMemory>>

* MemoryStore is requested to storage:MemoryStore.md#remove[remove a block]

== [[getExecutionMemoryUsageForTask]] getExecutionMemoryUsageForTask Method

[source, scala]
----
getExecutionMemoryUsageForTask(
  taskAttemptId: Long): Long
----

getExecutionMemoryUsageForTask...FIXME

getExecutionMemoryUsageForTask is used when...FIXME

== [[maxOffHeapMemory]] maxOffHeapMemory

[source, scala]
----
maxOffHeapMemory: Long
----

maxOffHeapMemory...FIXME

maxOffHeapMemory is used when...FIXME

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| pageSizeBytes
| [[pageSizeBytes]] FIXME

| tungstenMemoryAllocator
a| [[tungstenMemoryAllocator]] FIXME

|===
