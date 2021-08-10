# UnsafeExternalSorter

`UnsafeExternalSorter` is a [MemoryConsumer](MemoryConsumer.md).

## Creating Instance

`UnsafeExternalSorter` takes the following to be created:

* <span id="taskMemoryManager"> [TaskMemoryManager](TaskMemoryManager.md)
* <span id="blockManager"> [BlockManager](../storage/BlockManager.md)
* <span id="serializerManager"> [SerializerManager](../serializer/SerializerManager.md)
* <span id="taskContext"> [TaskContext](../scheduler/TaskContext.md)
* <span id="recordComparatorSupplier"> RecordComparator Supplier
* <span id="prefixComparator"> `PrefixComparator`
* <span id="initialSize"> Initial Size
* <span id="pageSizeBytes"> Page size (in bytes)
* <span id="numElementsForSpillThreshold"> numElementsForSpillThreshold
* <span id="existingInMemorySorter"> [UnsafeInMemorySorter](UnsafeInMemorySorter.md)
* <span id="canUseRadixSort"> `canUseRadixSort` flag

`UnsafeExternalSorter` is created when:

* `UnsafeExternalSorter` utility is used to [createWithExistingInMemorySorter](#createWithExistingInMemorySorter) and [create](#create)

## <span id="createWithExistingInMemorySorter"> createWithExistingInMemorySorter

```java
UnsafeExternalSorter createWithExistingInMemorySorter(
  TaskMemoryManager taskMemoryManager,
  BlockManager blockManager,
  SerializerManager serializerManager,
  TaskContext taskContext,
  Supplier<RecordComparator> recordComparatorSupplier,
  PrefixComparator prefixComparator,
  int initialSize,
  long pageSizeBytes,
  int numElementsForSpillThreshold,
  UnsafeInMemorySorter inMemorySorter,
  long existingMemoryConsumption)
```

`createWithExistingInMemorySorter`...FIXME

`createWithExistingInMemorySorter` is used when:

* `UnsafeKVExternalSorter` is created

## <span id="create"> create

```java
UnsafeExternalSorter create(
  TaskMemoryManager taskMemoryManager,
  BlockManager blockManager,
  SerializerManager serializerManager,
  TaskContext taskContext,
  Supplier<RecordComparator> recordComparatorSupplier,
  PrefixComparator prefixComparator,
  int initialSize,
  long pageSizeBytes,
  int numElementsForSpillThreshold,
  boolean canUseRadixSort)
```

`create` creates a new [UnsafeExternalSorter](#creating-instance) with no [UnsafeInMemorySorter](#existingInMemorySorter) given (`null`).

`create` is used when:

* `UnsafeExternalRowSorter` and `UnsafeKVExternalSorter` are created
