# MemoryAllocator

`MemoryAllocator` is an [abstraction](#contract) of [memory allocators](#implementations) that [TaskMemoryManager](TaskMemoryManager.md) uses to [allocate](#allocate) and [release](#free) memory.

`MemoryAllocator` creates the available [MemoryAllocator](#implementations)s to be available under the names [HEAP](#HEAP) and [UNSAFE](#UNSAFE).

A [MemoryAllocator](#implementations) to use is selected when `MemoryManager` is [created](MemoryManager.md#tungstenMemoryAllocator) (based on [MemoryMode](MemoryManager.md#tungstenMemoryMode)).

## Contract

### <span id="allocate"> Allocating Contiguous Block of Memory

```java
MemoryBlock allocate(
  long size)
```

Used when:

* `TaskMemoryManager` is requested to [allocate a memory page](TaskMemoryManager.md#allocatePage)

### <span id="free"> Releasing Memory

```java
void free(
  MemoryBlock memory)
```

Used when:

* `TaskMemoryManager` is requested to [release a memory page](TaskMemoryManager.md#freePage) and [clean up all the allocated memory](TaskMemoryManager.md#cleanUpAllAllocatedMemory)

## Implementations

* <span id="HEAP"> HeapMemoryAllocator
* <span id="UNSAFE"> UnsafeMemoryAllocator
