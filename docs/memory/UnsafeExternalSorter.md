= [[UnsafeExternalSorter]] UnsafeExternalSorter

*UnsafeExternalSorter* is...FIXME

== [[creating-instance]] Creating Instance

UnsafeExternalSorter takes the following to be created:

* [[taskMemoryManager]] xref:memory:TaskMemoryManager.adoc[TaskMemoryManager]
* [[blockManager]] xref:storage:BlockManager.adoc[BlockManager]
* <<serializerManager, SerializerManager>>
* [[taskContext]] xref:scheduler:spark-TaskContext.adoc[TaskContext]
* [[recordComparatorSupplier]] Supplier<RecordComparator>
* [[prefixComparator]] PrefixComparator
* [[initialSize]] Initial size
* [[pageSizeBytes]] Page size (in bytes)
* [[numElementsForSpillThreshold]] numElementsForSpillThreshold
* [[existingInMemorySorter]] xref:memory:UnsafeInMemorySorter.adoc[UnsafeInMemorySorter]
* [[canUseRadixSort]] canUseRadixSort flag

== [[serializerManager]] SerializerManager

UnsafeExternalSorter is given a xref:serializer:SerializerManager.adoc[SerializerManager] when <<creating-instance, created>>.

UnsafeExternalSorter uses the SerializerManager for <<getSortedIterator, getSortedIterator>>, <<getIterator, getIterator>>, and (SpillableIterator) <<spill, spill>> (to request UnsafeSorterSpillWriter for a xref:memory:UnsafeSorterSpillWriter.adoc#getReader[UnsafeSorterSpillReader]).
