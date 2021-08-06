# DiskBlockObjectWriter

`DiskBlockObjectWriter` is a custom [java.io.OutputStream]({{ java.api }}/java.base/java/io/OutputStream.html) that [BlockManager](BlockManager.md#getDiskWriter) offers for [writing data blocks to disk](#write).

`DiskBlockObjectWriter` is used when:

* `BypassMergeSortShuffleWriter` is requested for [partition writers](../shuffle/BypassMergeSortShuffleWriter.md#partitionWriters)

* `UnsafeSorterSpillWriter` is requested for a [partition writer](../memory/UnsafeSorterSpillWriter.md#writer)

* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)

* `ExternalSorter` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalSorter.md#spillMemoryIteratorToDisk)

## Creating Instance

`DiskBlockObjectWriter` takes the following to be created:

* <span id="file"> Java [File]({{ java.api }}/java.base/java/io/File.html)
* <span id="serializerManager"> [SerializerManager](../serializer/SerializerManager.md)
* <span id="serializerInstance"> [SerializerInstance](../serializer/SerializerInstance.md)
* <span id="bufferSize"> Buffer size
* <span id="syncWrites"> `syncWrites` flag (based on [spark.shuffle.sync](../configuration-properties.md#spark.shuffle.sync) configuration property)
* <span id="writeMetrics"> [ShuffleWriteMetricsReporter](../shuffle/ShuffleWriteMetricsReporter.md)
* <span id="blockId"> [BlockId](BlockId.md) (default: `null`)

`DiskBlockObjectWriter` is created when:

* `BlockManager` is requested for [one](BlockManager.md#getDiskWriter)

## <span id="objOut"> SerializationStream

`DiskBlockObjectWriter` manages a [SerializationStream](../serializer/SerializationStream.md) for [writing a key-value record](#write):

* Opens it when requested to [open](#open)

* Closes it when requested to [commitAndGet](#commitAndGet)

* Dereferences it (``null``s it) when [closeResources](#closeResources)

## <span id="states"><span id="streamOpen"> States

`DiskBlockObjectWriter` can be in one of the following states (that match the state of the underlying output streams):

* Initialized
* Open
* Closed

## <span id="write"> Writing Out Record

```scala
write(
  key: Any,
  value: Any): Unit
```

`write` [opens the underlying stream](#open) unless [open](#streamOpen) already.

`write` requests the [SerializationStream](#objOut) to [write the key](../serializer/SerializationStream.md#writeKey) and then the [value](../serializer/SerializationStream.md#writeValue).

In the end, `write` [updates the write metrics](#recordWritten).

`write` is used when:

* `BypassMergeSortShuffleWriter` is requested to [write records of a partition](../shuffle/BypassMergeSortShuffleWriter.md#write)

* `ExternalAppendOnlyMap` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalAppendOnlyMap.md#spillMemoryIteratorToDisk)

* `ExternalSorter` is requested to [write all records into a partitioned file](../shuffle/ExternalSorter.md#writePartitionedFile)
    * `SpillableIterator` is requested to `spill`

* `WritablePartitionedPairCollection` is requested for a `destructiveSortedWritablePartitionedIterator`

## <span id="commitAndGet"> commitAndGet

```scala
commitAndGet(): FileSegment
```

`commitAndGet`...FIXME

`commitAndGet` is used when...FIXME

## <span id="close"> Committing Writes and Closing Resources

```scala
close(): Unit
```

`close`...FIXME

`close` is used when...FIXME

## <span id="revertPartialWritesAndClose"> revertPartialWritesAndClose

```scala
revertPartialWritesAndClose(): File
```

`revertPartialWritesAndClose`...FIXME

`revertPartialWritesAndClose` is used when...FIXME

## <span id="write-bytes"> Writing Bytes (From Byte Array Starting From Offset)

```scala
write(
  kvBytes: Array[Byte],
  offs: Int,
  len: Int): Unit
```

`write`...FIXME

`write` is used when...FIXME

## <span id="open"> Opening DiskBlockObjectWriter

```scala
open(): DiskBlockObjectWriter
```

`open` opens the `DiskBlockObjectWriter`, i.e. [initializes](#initialize) and re-sets [bs](#bs) and [objOut](#objOut) internal output streams.

Internally, `open` makes sure that `DiskBlockObjectWriter` is not closed ([hasBeenClosed](#hasBeenClosed) flag is disabled). If it was, `open` throws a `IllegalStateException`:

```text
Writer already closed. Cannot be reopened.
```

Unless `DiskBlockObjectWriter` has already been initialized ([initialized](#initialized) flag is enabled), `open` [initializes](#initialize) it (and turns [initialized](#initialized) flag on).

Regardless of whether `DiskBlockObjectWriter` was already initialized or not, `open` [requests `SerializerManager` to wrap `mcs` output stream for encryption and compression](../serializer/SerializerManager.md#wrapStream) (for [blockId](#blockId)) and sets it as [bs](#bs).

`open` requests the [SerializerInstance](#serializerInstance) to [serialize `bs` output stream](../serializer/SerializerInstance.md#serializeStream) and sets it as [objOut](#objOut).

!!! note
    `open` uses the [SerializerInstance](#serializerInstance) that was used to create the `DiskBlockObjectWriter`.

In the end, `open` turns [streamOpen](#streamOpen) flag on.

`open` is used when `DiskBlockObjectWriter` [writes out a record](#write) or [bytes from a specified byte array](#write-bytes) and the [stream is not open yet](#streamOpen).

## Internal Properties

### <span id="initialized"> initialized Flag

### <span id="hasBeenClosed"> hasBeenClosed Flag

### <span id="mcs"> mcs

### <span id="bs"> bs
