# MemoryManager

`MemoryManager` is an [abstraction](#contract) of [memory managers](#implementations) that can share available memory between task execution ([TaskMemoryManager](TaskMemoryManager.md#memoryManager)) and storage ([BlockManager](../storage/BlockManager.md#memoryManager)).

![MemoryManager and Core Services](../images/memory/MemoryManager.png)

`MemoryManager` splits assigned memory into two regions:

* **Execution Memory** for shuffles, joins, sorts and aggregations

* **Storage Memory** for caching and propagating internal data across Spark nodes (in [on](#onHeapStorageMemoryPool)- and [off-heap](#offHeapStorageMemoryPool) modes)

`MemoryManager` is used to create [BlockManager](../storage/BlockManager.md#memoryManager) (and [MemoryStore](../storage/MemoryStore.md#memoryManager)) and [TaskMemoryManager](TaskMemoryManager.md#memoryManager).

## Contract

### <span id="acquireExecutionMemory"> Acquiring Execution Memory for Task

```scala
acquireExecutionMemory(
  numBytes: Long,
  taskAttemptId: Long,
  memoryMode: MemoryMode): Long
```

Used when:

* `TaskMemoryManager` is requested to [acquire execution memory](TaskMemoryManager.md#acquireExecutionMemory)

### <span id="acquireStorageMemory"> Acquiring Storage Memory for Block

```scala
acquireStorageMemory(
  blockId: BlockId,
  numBytes: Long,
  memoryMode: MemoryMode): Boolean
```

Used when:

* `MemoryStore` is requested for the [putBytes](../storage/MemoryStore.md#putBytes) and [putIterator](../storage/MemoryStore.md#putIterator)

### <span id="acquireUnrollMemory"> Acquiring Unroll Memory for Block

```scala
acquireUnrollMemory(
  blockId: BlockId,
  numBytes: Long,
  memoryMode: MemoryMode): Boolean
```

Used when:

* `MemoryStore` is requested for the [reserveUnrollMemoryForThisTask](../storage/MemoryStore.md#reserveUnrollMemoryForThisTask)

### <span id="maxOffHeapStorageMemory"> Total Available Off-Heap Storage Memory

```scala
maxOffHeapStorageMemory: Long
```

May vary over time

Used when:

* `BlockManager` is [created](../storage/BlockManager.md#maxOffHeapMemory)
* `MemoryStore` is requested for the [maxMemory](../storage/MemoryStore.md#maxMemory)

### <span id="maxOnHeapStorageMemory"> Total Available On-Heap Storage Memory

```scala
maxOnHeapStorageMemory: Long
```

May vary over time

Used when:

* `BlockManager` is [created](../storage/BlockManager.md#maxOnHeapMemory)
* `MemoryStore` is requested for the [maxMemory](../storage/MemoryStore.md#maxMemory)

## Implementations

* [UnifiedMemoryManager](UnifiedMemoryManager.md)

## Creating Instance

`MemoryManager` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="numCores"> Number of CPU Cores
* <span id="onHeapStorageMemory"> Size of the On-Heap Storage Memory
* <span id="onHeapExecutionMemory"> Size of the On-Heap Execution Memory

??? note "Abstract Class"
    `MemoryManager` is an abstract class and cannot be created directly. It is created indirectly for the [concrete MemoryManagers](#implementations).

## <span id="SparkEnv"> Accessing MemoryManager (SparkEnv)

`MemoryManager` is available as [SparkEnv.memoryManager](../SparkEnv.md#memoryManager) on the driver and executors.

```text
import org.apache.spark.SparkEnv
val mm = SparkEnv.get.memoryManager

scala> :type mm
org.apache.spark.memory.MemoryManager
```

## <span id="setMemoryStore"> Associating MemoryStore with Storage Memory Pools

```scala
setMemoryStore(
  store: MemoryStore): Unit
```

`setMemoryStore` requests the [on-heap](#onHeapStorageMemoryPool) and [off-heap](#offHeapStorageMemoryPool) storage memory pools to [use](StorageMemoryPool.md#setMemoryStore) the given [MemoryStore](../storage/MemoryStore.md).

`setMemoryStore` is used when:

* `BlockManager` is [created](../storage/BlockManager.md#creating-instance)

## Execution Memory Pools

### <span id="onHeapExecutionMemoryPool"> On-Heap

```scala
onHeapExecutionMemoryPool: ExecutionMemoryPool
```

`MemoryManager` creates an [ExecutionMemoryPool](ExecutionMemoryPool.md) for `ON_HEAP` memory mode when [created](#creating-instance) and immediately requests it to [incrementPoolSize](MemoryPool.md#incrementPoolSize) to [onHeapExecutionMemory](#onHeapExecutionMemory).

### <span id="offHeapExecutionMemoryPool"> Off-Heap

```scala
offHeapExecutionMemoryPool: ExecutionMemoryPool
```

`MemoryManager` creates an [ExecutionMemoryPool](ExecutionMemoryPool.md) for `OFF_HEAP` memory mode when [created](#creating-instance) and immediately requests it to [incrementPoolSize](MemoryPool.md#incrementPoolSize) to...FIXME

## Storage Memory Pools

### <span id="onHeapStorageMemoryPool"> On-Heap

```scala
onHeapStorageMemoryPool: StorageMemoryPool
```

`MemoryManager` creates a [StorageMemoryPool](StorageMemoryPool.md) for `ON_HEAP` memory mode when [created](#creating-instance) and immediately requests it to [incrementPoolSize](MemoryPool.md#incrementPoolSize) to [onHeapExecutionMemory](#onHeapExecutionMemory).

`onHeapStorageMemoryPool` is requested to [setMemoryStore](StorageMemoryPool.md#setMemoryStore) when `MemoryManager` is requested to [setMemoryStore](#setMemoryStore).

`onHeapStorageMemoryPool` is requested to [release memory](StorageMemoryPool.md#releaseMemory) when `MemoryManager` is requested to [release on-heap storage memory](#releaseStorageMemory).

`onHeapStorageMemoryPool` is requested to [release all memory](StorageMemoryPool.md#releaseAllMemory) when `MemoryManager` is requested to [release all storage memory](#releaseAllStorageMemory).

`onHeapStorageMemoryPool` is used when:

* `MemoryManager` is requested for the [storageMemoryUsed](#storageMemoryUsed) and [onHeapStorageMemoryUsed](#onHeapStorageMemoryUsed)
* `UnifiedMemoryManager` is requested to acquire on-heap [execution](UnifiedMemoryManager.md#acquireExecutionMemory) and [storage](UnifiedMemoryManager.md#acquireStorageMemory) memory

### <span id="offHeapStorageMemoryPool"> Off-Heap

```scala
offHeapStorageMemoryPool: StorageMemoryPool
```

`MemoryManager` creates a [StorageMemoryPool](StorageMemoryPool.md) for `OFF_HEAP` memory mode when [created](#creating-instance) and immediately requested it to [incrementPoolSize](MemoryPool.md#incrementPoolSize) to [offHeapStorageMemory](#offHeapStorageMemory).

`MemoryManager` requests the `MemoryPool`s to [use a given MemoryStore](StorageMemoryPool.md#setMemoryStore) when requested to [setMemoryStore](#setMemoryStore).

`MemoryManager` requests the `MemoryPool`s to [release memory](StorageMemoryPool.md#releaseMemory) when requested to [releaseStorageMemory](#releaseStorageMemory).

`MemoryManager` requests the `MemoryPool`s to [release all memory](StorageMemoryPool.md#releaseAllMemory) when requested to [release all storage memory](#releaseAllStorageMemory).

`MemoryManager` requests the `MemoryPool`s for the [memoryUsed](StorageMemoryPool.md#memoryUsed) when requested for [storageMemoryUsed](#storageMemoryUsed).

`offHeapStorageMemoryPool` is used when:

* `MemoryManager` is requested for the [offHeapStorageMemoryUsed](#offHeapStorageMemoryUsed)
* `UnifiedMemoryManager` is requested to acquire off-heap [execution](UnifiedMemoryManager.md#acquireExecutionMemory) and [storage](UnifiedMemoryManager.md#acquireStorageMemory) memory

## <span id="storageMemoryUsed"> Total Storage Memory Used

```scala
storageMemoryUsed: Long
```

`storageMemoryUsed` is the sum of the [memory used](StorageMemoryPool.md#memoryUsed) of the [on-heap](#onHeapStorageMemoryPool) and [off-heap](#offHeapStorageMemoryPool) storage memory pools.

`storageMemoryUsed` is used when:

* `TaskMemoryManager` is requested to [showMemoryUsage](TaskMemoryManager.md#showMemoryUsage)
* `MemoryStore` is requested to [memoryUsed](../storage/MemoryStore.md#memoryUsed)

## <span id="tungstenMemoryMode"> MemoryMode

```scala
tungstenMemoryMode: MemoryMode
```

`tungstenMemoryMode` tracks whether Tungsten memory will be allocated on the JVM heap or off-heap (using `sun.misc.Unsafe`).

!!! note "final val"
    `tungstenMemoryMode` is a `final val`ue so initialized once when `MemoryManager` is [created](#creating-instance).

`tungstenMemoryMode` is `OFF_HEAP` when the following are all met:

* [spark.memory.offHeap.enabled](../configuration-properties.md#spark.memory.offHeap.enabled) configuration property is enabled

* [spark.memory.offHeap.size](../configuration-properties.md#spark.memory.offHeap.size) configuration property is greater than `0`

* JVM supports unaligned memory access (aka **unaligned Unsafe**, i.e. `sun.misc.Unsafe` package is available and the underlying system has unaligned-access capability)

Otherwise, `tungstenMemoryMode` is `ON_HEAP`.

!!! note
    Given that [spark.memory.offHeap.enabled](../configuration-properties.md#spark.memory.offHeap.enabled) configuration property is turned off by default and [spark.memory.offHeap.size](../configuration-properties.md#spark.memory.offHeap.size) configuration property is `0` by default, Apache Spark seems to encourage using Tungsten memory allocated on the JVM heap (`ON_HEAP`).

`tungstenMemoryMode` is used when:

* `MemoryManager` is [created](#creating-instance) (and initializes the [pageSizeBytes](#pageSizeBytes) and [tungstenMemoryAllocator](#tungstenMemoryAllocator) internal properties)
* `TaskMemoryManager` is [created](TaskMemoryManager.md#tungstenMemoryMode)

## <span id="tungstenMemoryAllocator"> MemoryAllocator

```scala
tungstenMemoryAllocator: MemoryAllocator
```

`MemoryManager` selects the [MemoryAllocator](MemoryAllocator.md) to use based on the [MemoryMode](#tungstenMemoryMode).

!!! note "final val"
    `tungstenMemoryAllocator` is a `final val`ue so initialized once when `MemoryManager` is [created](#creating-instance).

MemoryMode  | MemoryAllocator
------------|----------------
 `ON_HEAP`  | [HeapMemoryAllocator](MemoryAllocator.md#HEAP)
 `OFF_HEAP` | [UnsafeMemoryAllocator](MemoryAllocator.md#UNSAFE)

`tungstenMemoryAllocator` is used when:

* `TaskMemoryManager` is requested to [allocate a memory page](TaskMemoryManager.md#allocatePage), [release a memory page](TaskMemoryManager.md#freePage) and [clean up all the allocated memory](TaskMemoryManager.md#cleanUpAllAllocatedMemory)
