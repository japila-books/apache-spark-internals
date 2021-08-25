# MemoryConsumer

`MemoryConsumer` is an [abstraction](#contract) of [spillable memory consumers](#implementations) (of [TaskMemoryManager](TaskMemoryManager.md#consumers)).

`MemoryConsumer`s correspond to individual operators and data structures within a task. `TaskMemoryManager` receives memory allocation requests from `MemoryConsumer`s and issues callbacks to consumers in order to trigger [spilling](#spill) when running low on memory.

A `MemoryConsumer` basically tracks [how much memory is allocated](#used).

## Contract

### <span id="spill"> spill

```java
void spill() // (1)
long spill(
  long size,
  MemoryConsumer trigger)
```

1. Uses `MAX_VALUE` for the size and this MemoryConsumer

Used when:

* `TaskMemoryManager` is requested to [acquire execution memory](TaskMemoryManager.md#acquireExecutionMemory)
* `UnsafeExternalSorter` is requested to [createWithExistingInMemorySorter](UnsafeExternalSorter.md#createWithExistingInMemorySorter)

## Implementations

* [BytesToBytesMap](BytesToBytesMap.md)
* `LongToUnsafeRowMap`
* `RowBasedKeyValueBatch`
* [ShuffleExternalSorter](../shuffle/ShuffleExternalSorter.md)
* [Spillable](../shuffle/Spillable.md)
* [UnsafeExternalSorter](UnsafeExternalSorter.md)

## Creating Instance

`MemoryConsumer` takes the following to be created:

* <span id="taskMemoryManager"> [TaskMemoryManager](TaskMemoryManager.md)
* <span id="pageSize"> Page Size
* <span id="mode"> `MemoryMode` (`ON_HEAP` or `OFF_HEAP`)

??? note "Abstract Class"
    `MemoryConsumer` is an abstract class and cannot be created directly. It is created indirectly for the [concrete MemoryConsumers](#implementations).
