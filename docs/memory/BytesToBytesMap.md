= [[BytesToBytesMap]] BytesToBytesMap

*BytesToBytesMap* is a MemoryConsumer.md[MemoryConsumer].

BytesToBytesMap is used to create Spark SQL's UnsafeKVExternalSorter and UnsafeHashedRelation.

== [[creating-instance]] Creating Instance

BytesToBytesMap takes the following to be created:

* [[taskMemoryManager]] memory:TaskMemoryManager.md[TaskMemoryManager]
* [[blockManager]] storage:BlockManager.md[BlockManager]
* <<serializerManager, SerializerManager>>
* [[initialCapacity]] Initial capacity
* [[loadFactor]] Load factor (default: 0.5)
* [[pageSizeBytes]] Page size (in bytes)
* [[enablePerfMetrics]] enablePerfMetrics flag

BytesToBytesMap is created for Spark SQL's UnsafeFixedWidthAggregationMap and UnsafeHashedRelation.

== [[serializerManager]] SerializerManager

BytesToBytesMap is given a serializer:SerializerManager.md[SerializerManager] when <<creating-instance, created>>.

BytesToBytesMap uses the SerializerManager when (MapIterator is) requested to advanceToNextPage (to request UnsafeSorterSpillWriter for a memory:UnsafeSorterSpillWriter.md#getReader[UnsafeSorterSpillReader]).

== [[MAX_CAPACITY]] Maximum Supported Capacity

BytesToBytesMap supports up to `1 << 29` keys.

== [[spillWriters]] UnsafeSorterSpillWriters

BytesToBytesMap manages UnsafeSorterSpillWriter.md[UnsafeSorterSpillWriters].

BytesToBytesMap registers a new UnsafeSorterSpillWriter when requested to <<spill, spill>>.

BytesToBytesMap uses the UnsafeSorterSpillWriters when:

* <<free, Freeing Up Allocated Memory>>

* FIXME

== [[destructiveIterator]] MapIterator

BytesToBytesMap manages a "destructive" MapIterator.

BytesToBytesMap creates it when requested for <<destructiveIterator, one>>.

BytesToBytesMap requests it to spill when requested to <<spill, spill>>.

== [[destructiveIterator]] Creating Destructive MapIterator

[source, java]
----
MapIterator destructiveIterator()
----

destructiveIterator <<updatePeakMemoryUsed, updatePeakMemoryUsed>> and creates a MapIterator (with the <<numValues, numValues>> and <<loc, Location>>).

destructiveIterator is used when Spark SQL's UnsafeFixedWidthAggregationMap is requested for a key-value iterator.

== [[allocate]] Allocating

[source, java]
----
void allocate(
  int capacity)
----

allocate uses the input capacity to compute a number that is a power of 2 and greater or equal than capacity, but not greater than <<MAX_CAPACITY, maximum supported capacity>>. The computed number is at least 64.

[source,scala]
----
def _c(capacity: Int) = {
  import org.apache.spark.unsafe.array.ByteArrayMethods
  val MAX_CAPACITY = (1 << 29)
  Math.max(Math.min(MAX_CAPACITY, ByteArrayMethods.nextPowerOf2(capacity)), 64)
}
----

allocate MemoryConsumer.md#allocateArray[allocates an array] twice as big as the power-of-two capacity and fills it all with 0s.

allocate initializes the <<growthThreshold, growthThreshold>> and <<mask, mask>> internal properties.

allocate requires that the input capacity is positive.

allocate is used when...FIXME

== [[spill]] Spilling

[source, java]
----
long spill(
  long size,
  MemoryConsumer trigger)
----

NOTE: spill is part of the memory:MemoryConsumer.md#spill[MemoryConsumer] abstraction.

spill requests the <<destructiveIterator, MapIterator>> to spill when the given MemoryConsumer is not this BytesToBytesMap and the MapIterator is available.

== [[free]] Freeing Up Allocated Memory

[source, java]
----
void free()
----

free...FIXME

free is used when...FIXME

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| growthThreshold
a| [[growthThreshold]] Growth threshold

| mask
a| [[mask]] Mask for truncating hashcodes so that they do not exceed the long array's size

|===
