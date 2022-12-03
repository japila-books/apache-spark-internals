# BytesToBytesMap

`BytesToBytesMap` is a [memory consumer](memory/MemoryConsumer.md) that supports [spilling](#spill).

!!! note "Spark SQL"
    `BytesToBytesMap` is used in [Spark SQL]({{ book.spark_sql }}) only in the following:

    * [UnsafeFixedWidthAggregationMap]({{ book.spark_sql }}/UnsafeFixedWidthAggregationMap)
    * [UnsafeHashedRelation]({{ book.spark_sql }}/UnsafeHashedRelation)

## Creating Instance

`BytesToBytesMap` takes the following to be created:

* <span id="taskMemoryManager"> [TaskMemoryManager](memory/TaskMemoryManager.md)
* <span id="blockManager"> [BlockManager](storage/BlockManager.md)
* <span id="serializerManager"> [SerializerManager](serializer/SerializerManager.md)
* <span id="initialCapacity"> Initial Capacity
* <span id="loadFactor"> Load Factor (default: `0.5`)
* <span id="pageSizeBytes"> Page Size (bytes)

`BytesToBytesMap` is created when:

* `UnsafeFixedWidthAggregationMap` ([Spark SQL]({{ book.spark_sql }}/UnsafeFixedWidthAggregationMap)) is created
* `UnsafeHashedRelation` ([Spark SQL]({{ book.spark_sql }}/UnsafeHashedRelation)) is created

## <span id="destructiveIterator"> Destructive MapIterator

```java
MapIterator destructiveIterator
```

`BytesToBytesMap` defines a reference to a "destructive" `MapIterator` (if ever created for `UnsafeFixedWidthAggregationMap` ([Spark SQL]({{ book.spark_sql }}/UnsafeFixedWidthAggregationMap#mapLocationIterator))).

The `destructiveIterator` reference is in two states:

* Undefined (`null`) initially when `BytesToBytesMap` is [created](#creating-instance)
* The `MapIterator` if [created](#destructiveIterator)

### <span id="destructiveIterator"> Creating Destructive MapIterator

```scala
MapIterator destructiveIterator()
```

`destructiveIterator` [updatePeakMemoryUsed](#updatePeakMemoryUsed) and then creates a `MapIterator` with the following:

* [numValues](#numValues) for the number of records
* A new `Location`
* Destructive flag enabled (`true`)

---

`destructiveIterator` is used when:

* `UnsafeFixedWidthAggregationMap` ([Spark SQL]({{ book.spark_sql }}/UnsafeFixedWidthAggregationMap#mapLocationIterator)) is created

## <span id="spill"> Spilling

```java
long spill(
  long size,
  MemoryConsumer trigger)
```

`spill` is part of the [MemoryConsumer](memory/MemoryConsumer.md#spill) abstraction.

---

Only when the given [MemoryConsumer](memory/MemoryConsumer.md) is not this `BytesToBytesMap` and the [destructive MapIterator](#destructiveIterator) has been used, `spill` requests the destructive `MapIterator` to `spill` (the given `size` bytes).

`spill` returns `0` when the `trigger` is this `BytesToBytesMap` or there is no [destructiveIterator](#destructiveIterator) in use. Otherwise, `spill` returns how much bytes the [destructiveIterator](#destructiveIterator) managed to release.

## <span id="numValues"> numValues

`numValues` registry is `0` after [reset](#reset).

`numValues` is incremented when `Location` is requested to `append`

`numValues` can never be bigger than maximum capacity of this `BytesToBytesMap` or [growthThreshold](#growthThreshold).

## <span id="MAX_CAPACITY"> Maximum Capacity

`BytesToBytesMap` supports up to `1 << 29` keys.

`BytesToBytesMap` makes sure that the [initialCapacity](#initialCapacity) is not bigger when [creted](#creating-instance).

## <span id="allocate"> Allocating Memory

```java
void allocate(
  int capacity)
```

`allocate`...FIXME

---

`allocate` is used when:

* `BytesToBytesMap` is [created](#creating-instance), [reset](#reset), [growAndRehash](#growAndRehash)

## <span id="growAndRehash"> Growing Memory And Rehashing

```java
void growAndRehash()
```

`growAndRehash`...FIXME

---

`growAndRehash` is used when:

* `Location` is requested to `append` (a new value for a key)

<!---
## Review Me

== [[serializerManager]] SerializerManager

BytesToBytesMap is given a serializer:SerializerManager.md[SerializerManager] when <<creating-instance, created>>.

BytesToBytesMap uses the SerializerManager when (MapIterator is) requested to advanceToNextPage (to request UnsafeSorterSpillWriter for a memory:UnsafeSorterSpillWriter.md#getReader[UnsafeSorterSpillReader]).

== [[spillWriters]] UnsafeSorterSpillWriters

BytesToBytesMap manages UnsafeSorterSpillWriter.md[UnsafeSorterSpillWriters].

BytesToBytesMap registers a new UnsafeSorterSpillWriter when requested to <<spill, spill>>.

BytesToBytesMap uses the UnsafeSorterSpillWriters when:

* <<free, Freeing Up Allocated Memory>>

* FIXME

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
-->
