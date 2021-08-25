# MemoryPool

`MemoryPool` is an [abstraction](#contract) of [memory pools](#implementations).

## Contract

### <span id="memoryUsed"> Size of Memory Used

```scala
memoryUsed: Long
```

Used when:

* `MemoryPool` is requested for the [amount of free memory](#memoryFree) and [decrementPoolSize](#decrementPoolSize)

## Implementations

* [ExecutionMemoryPool](ExecutionMemoryPool.md)
* [StorageMemoryPool](StorageMemoryPool.md)

## Creating Instance

`MemoryPool` takes the following to be created:

* <span id="lock"> Lock Object

??? note "Abstract Class"
    `MemoryPool` is an abstract class and cannot be created directly. It is created indirectly for the [concrete MemoryPools](#implementations).

## <span id="memoryFree"> Free Memory

```scala
memoryFree
```

`memoryFree`...FIXME

`memoryFree` is used when:

* `ExecutionMemoryPool` is requested to [acquireMemory](ExecutionMemoryPool.md#acquireMemory)
* `StorageMemoryPool` is requested to [acquireMemory](StorageMemoryPool.md#acquireMemory) and [freeSpaceToShrinkPool](StorageMemoryPool.md#freeSpaceToShrinkPool)
* `UnifiedMemoryManager` is requested to acquire [execution](UnifiedMemoryManager.md#acquireExecutionMemory) and [storage](UnifiedMemoryManager.md#acquireStorageMemory) memory

## <span id="decrementPoolSize"> decrementPoolSize

```scala
decrementPoolSize(
  delta: Long): Unit
```

`decrementPoolSize`...FIXME

`decrementPoolSize` is used when:

* `UnifiedMemoryManager` is requested to [acquireExecutionMemory](UnifiedMemoryManager.md#acquireExecutionMemory) and [acquireStorageMemory](UnifiedMemoryManager.md#acquireStorageMemory)
