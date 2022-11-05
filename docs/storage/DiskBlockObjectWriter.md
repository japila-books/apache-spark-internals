# DiskBlockObjectWriter

`DiskBlockObjectWriter` is a disk writer of [BlockManager](BlockManager.md#getDiskWriter).

`DiskBlockObjectWriter` is an `OutputStream` ([Java]({{ java.api }}/java/io/OutputStream.html)) that [BlockManager](BlockManager.md#getDiskWriter) offers for [writing data blocks to disk](#write).

`DiskBlockObjectWriter` is used when:

* `BypassMergeSortShuffleWriter` is requested for [partition writers](../shuffle/BypassMergeSortShuffleWriter.md#partitionWriters)

* `UnsafeSorterSpillWriter` is requested for a [partition writer](../memory/UnsafeSorterSpillWriter.md#writer)

* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)

* `ExternalSorter` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalSorter.md#spillMemoryIteratorToDisk)

## Creating Instance

`DiskBlockObjectWriter` takes the following to be created:

* <span id="file"> `File` ([Java]({{ java.api }}/java/io/File.html))
* <span id="serializerManager"> [SerializerManager](../serializer/SerializerManager.md)
* <span id="serializerInstance"> [SerializerInstance](../serializer/SerializerInstance.md)
* [Buffer size](#bufferSize)
* <span id="syncWrites"> `syncWrites` flag (based on [spark.shuffle.sync](../configuration-properties.md#spark.shuffle.sync) configuration property)
* <span id="writeMetrics"> [ShuffleWriteMetricsReporter](../shuffle/ShuffleWriteMetricsReporter.md)
* <span id="blockId"> [BlockId](BlockId.md) (default: `null`)

`DiskBlockObjectWriter` is created when:

* `BlockManager` is requested for a [disk writer](BlockManager.md#getDiskWriter)

### <span id="bufferSize"> Buffer Size

`DiskBlockObjectWriter` is given a buffer size when [created](#creating-instance).

The buffer size is specified by [BlockManager](BlockManager.md#getDiskWriter) and is based on [spark.shuffle.file.buffer](../configuration-properties.md#spark.shuffle.file.buffer) configuration property (in most cases) or is hardcoded to `32k` (in some cases but is in fact the default value).

The buffer size is exactly the buffer size of the [BufferedOutputStream](#mcs).

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

---

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

With [streamOpen](#streamOpen) enabled, `commitAndGet`...FIXME

Otherwise, `commitAndGet` returns a new `FileSegment` (with the [File](#file), [committedPosition](#committedPosition) and `0` length).

---

`commitAndGet` is used when:

* `BypassMergeSortShuffleWriter` is requested to [write](../shuffle/BypassMergeSortShuffleWriter.md#write)
* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)
* `DiskBlockObjectWriter` is requested to [close](#close)
* `ExternalAppendOnlyMap` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalAppendOnlyMap.md#spillMemoryIteratorToDisk)
* `ExternalSorter` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalSorter.md#spillMemoryIteratorToDisk), [writePartitionedFile](../shuffle/ExternalSorter.md#writePartitionedFile)
* `UnsafeSorterSpillWriter` is requested to [close](../memory/UnsafeSorterSpillWriter.md#close)

## <span id="close"> Committing Writes and Closing Resources

```scala
close(): Unit
```

Only if [initialized](#initialized), `close` [commitAndGet](#commitAndGet) followed by [closeResources](#closeResources). Otherwise, `close` does nothing.

---

`close` is used when:

* FIXME

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

### <span id="initialize"> Initialization

```scala
initialize(): Unit
```

`initialize` creates a [FileOutputStream](#fos) to write to the [file](#file) (with the`append` enabled) and takes the [FileChannel](#channel) associated with this file output stream.

`initialize` creates a [TimeTrackingOutputStream](#ts) (with the [ShuffleWriteMetricsReporter](#writeMetrics) and the [FileOutputStream](#fos)).

With [checksumEnabled](#checksumEnabled), `initialize`...FIXME

In the end, `initialize` creates a [BufferedOutputStream](#mcs).

## <span id="checksumEnabled"> checksumEnabled Flag

`DiskBlockObjectWriter` defines `checksumEnabled` flag to...FIXME

`checksumEnabled` is `false` by default and can be enabled using [setChecksum](#setChecksum).

### <span id="setChecksum"> setChecksum

```scala
setChecksum(
  checksum: Checksum): Unit
```

`setChecksum`...FIXME

---

`setChecksum` is used when:

* `BypassMergeSortShuffleWriter` is requested to [write records](../shuffle/BypassMergeSortShuffleWriter.md#write) (with [spark.shuffle.checksum.enabled](#spark.shuffle.checksum.enabled) enabled)
* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile) (with [spark.shuffle.checksum.enabled](#spark.shuffle.checksum.enabled) enabled)

## <span id="recordWritten"> Recording Bytes Written

```scala
recordWritten(): Unit
```

`recordWritten` increases the [numRecordsWritten](#numRecordsWritten) counter.

`recordWritten` requests the [ShuffleWriteMetricsReporter](#writeMetrics) to [incRecordsWritten](../shuffle/ShuffleWriteMetricsReporter.md#incRecordsWritten).

`recordWritten` [updates the bytes written metric](#updateBytesWritten) every `16384` bytes written (based on the [numRecordsWritten](#numRecordsWritten) counter).

---

`recordWritten` is used when:

* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)
* `DiskBlockObjectWriter` is requested to [write](#write)
* `UnsafeSorterSpillWriter` is requested to [write](../memory/UnsafeSorterSpillWriter.md#write)

### <span id="updateBytesWritten"> Updating Bytes Written Metric

```scala
updateBytesWritten(): Unit
```

`updateBytesWritten` requests the [FileChannel](#channel) for the file position (i.e., the number of bytes from the beginning of the file to the current position) that is used to [incBytesWritten](../shuffle/ShuffleWriteMetricsReporter.md#incBytesWritten) (using the [ShuffleWriteMetricsReporter](#writeMetrics) and the [reportedPosition](#reportedPosition) counter).

In the end, `updateBytesWritten` updates the [reportedPosition](#reportedPosition) counter to the current file position (so it can report [incBytesWritten](../shuffle/ShuffleWriteMetricsReporter.md#incBytesWritten) properly).

## <span id="mcs"> BufferedOutputStream

```scala
mcs: ManualCloseOutputStream
```

`DiskBlockObjectWriter` creates a custom `BufferedOutputStream` ([Java]({{ java.api }}/java/io/BufferedOutputStream.html)) when requested to [initialize](#initialize).

The `BufferedOutputStream` is closed (and dereferenced) in [closeResources](#closeResources).

The `BufferedOutputStream` is used to create the [OutputStream](#bs) when requested to [open](#open).

## <span id="bs"> OutputStream

```scala
bs: OutputStream
```

`DiskBlockObjectWriter` [creates an OutputStream](../serializer/SerializerManager.md#wrapStream) when requested to [open](#open). The `OutputStream` can be encrypted and compressed if enabled.

The `OutputStream` is closed (and dereferenced) in [closeResources](#closeResources).

The `OutputStream` is used to create the [SerializationStream](#objOut) when requested to [open](#open).

The `OutputStream` is requested for the following:

* Write bytes out in [write](#write)
* Flush in [flush](#flush) (and [commitAndGet](#commitAndGet))
