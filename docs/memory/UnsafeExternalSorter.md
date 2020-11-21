# UnsafeExternalSorter

## Creating Instance

UnsafeExternalSorter takes the following to be created:

* [[taskMemoryManager]] memory:TaskMemoryManager.md[TaskMemoryManager]
* [[blockManager]] storage:BlockManager.md[BlockManager]
* <<serializerManager, SerializerManager>>
* [[taskContext]] [TaskContext](../scheduler/TaskContext.md)
* [[recordComparatorSupplier]] Supplier<RecordComparator>
* [[prefixComparator]] PrefixComparator
* [[initialSize]] Initial size
* [[pageSizeBytes]] Page size (in bytes)
* [[numElementsForSpillThreshold]] numElementsForSpillThreshold
* [[existingInMemorySorter]] memory:UnsafeInMemorySorter.md[UnsafeInMemorySorter]
* [[canUseRadixSort]] canUseRadixSort flag

== [[serializerManager]] SerializerManager

UnsafeExternalSorter is given a serializer:SerializerManager.md[SerializerManager] when <<creating-instance, created>>.

UnsafeExternalSorter uses the SerializerManager for <<getSortedIterator, getSortedIterator>>, <<getIterator, getIterator>>, and (SpillableIterator) <<spill, spill>> (to request UnsafeSorterSpillWriter for a memory:UnsafeSorterSpillWriter.md#getReader[UnsafeSorterSpillReader]).
