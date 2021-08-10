# UnsafeInMemorySorter

## Creating Instance

`UnsafeInMemorySorter` takes the following to be created:

* <span id="consumer"> [MemoryConsumer](MemoryConsumer.md)
* <span id="memoryManager"> [TaskMemoryManager](TaskMemoryManager.md)
* <span id="recordComparator"> `RecordComparator`
* <span id="prefixComparator"> `PrefixComparator`
* <span id="array"><span id="initialSize"> Long Array or Size
* <span id="canUseRadixSort"> `canUseRadixSort` flag

`UnsafeInMemorySorter` is created when:

* `UnsafeExternalSorter` is [created](UnsafeExternalSorter.md#inMemSorter)
* `UnsafeKVExternalSorter` is created
