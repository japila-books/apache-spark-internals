# ShuffleInMemorySorter

`ShuffleInMemorySorter` is used by [ShuffleExternalSorter](ShuffleExternalSorter.md#inMemSorter) to <<getSortedIterator, sort pointers of key-value records and partition IDs>> using <<useRadixSort, radix or tim>> sort algorithms.

![ShuffleInMemorySorter and ShuffleExternalSorter](../images/shuffle/ShuffleInMemorySorter.png)

== [[creating-instance]] Creating Instance

ShuffleInMemorySorter takes the following to be created:

* [[consumer]] memory:MemoryConsumer.md[MemoryConsumer]
* [[initialSize]] Initial size
* [[useRadixSort]] useRadixSort flag (to indicate whether to use <<getSortedIterator, radix or tim sorting algorithms>>)

ShuffleInMemorySorter requests the given <<consumer, MemoryConsumer>> to memory:MemoryConsumer.md#allocateArray[allocate an array] of the given <<initialSize, initial size>> for the <<array, Unsafe LongArray of Record Pointers and Partition IDs>>.

ShuffleInMemorySorter is created for a shuffle:ShuffleExternalSorter.md#inMemSorter[ShuffleExternalSorter].

== [[getSortedIterator]] Iterator of Records Sorted

[source, java]
----
ShuffleSorterIterator getSortedIterator()
----

getSortedIterator...FIXME

getSortedIterator is used when ShuffleExternalSorter is requested to shuffle:ShuffleExternalSorter.md#writeSortedFile[writeSortedFile].

== [[reset]] Resetting

[source, java]
----
void reset()
----

reset...FIXME

reset is used when...FIXME

== [[numRecords]] numRecords Method

[source, java]
----
int numRecords()
----

numRecords...FIXME

numRecords is used when...FIXME

== [[getUsableCapacity]] Calculating Usable Capacity

[source, java]
----
int getUsableCapacity()
----

getUsableCapacity calculates the capacity that is a half or two-third of the memory used for the <<array, LongArray>>.

getUsableCapacity is used when...FIXME

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.shuffle.sort.ShuffleExternalSorter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source,plaintext]
----
log4j.logger.org.apache.spark.shuffle.sort.ShuffleExternalSorter=ALL
----

Refer to spark-logging.md[Logging].

== [[internal-properties]] Internal Properties

=== [[array]] Unsafe LongArray of Record Pointers and Partition IDs

ShuffleInMemorySorter uses a LongArray.

=== [[usableCapacity]] Usable Capacity

ShuffleInMemorySorter...FIXME
