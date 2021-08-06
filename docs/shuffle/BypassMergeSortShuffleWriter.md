# BypassMergeSortShuffleWriter

`BypassMergeSortShuffleWriter&lt;K, V&gt;` is a [ShuffleWriter](ShuffleWriter.md) for [ShuffleMapTasks](../scheduler/ShuffleMapTask.md) to [write records into one single shuffle block data file](#write).

![BypassMergeSortShuffleWriter and DiskBlockObjectWriters](../images/shuffle/BypassMergeSortShuffleWriter-write.png)

## Creating Instance

`BypassMergeSortShuffleWriter` takes the following to be created:

* <span id="blockManager"> [BlockManager](../storage/BlockManager.md)
* <span id="handle"> [BypassMergeSortShuffleHandle](BypassMergeSortShuffleHandle.md) (of `K` keys and `V` values)
* <span id="mapId"> Map ID
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="writeMetrics"> [ShuffleWriteMetricsReporter](ShuffleWriteMetricsReporter.md)
* <span id="shuffleExecutorComponents"> `ShuffleExecutorComponents`

`BypassMergeSortShuffleWriter` is created when:

* `SortShuffleManager` is requested for a [ShuffleWriter](SortShuffleManager.md#getWriter) (for a [BypassMergeSortShuffleHandle](#handle))

## <span id="partitionWriters"> DiskBlockObjectWriters

```java
DiskBlockObjectWriter[] partitionWriters
```

`BypassMergeSortShuffleWriter` uses a [DiskBlockObjectWriter](../storage/DiskBlockObjectWriter.md) per [partition](#numPartitions) (based on the [Partitioner](#partitioner)).

`BypassMergeSortShuffleWriter` asserts that no `partitionWriters` are created while [writing out records to a shuffle file](#write).

While [writing](#write), `BypassMergeSortShuffleWriter` requests the [BlockManager](#blockManager) for as many [DiskBlockObjectWriter](../storage/BlockManager.md#getDiskWriter)s as there are [partition](#numPartitions)s (in the [Partitioner](#partitioner)).

While [writing](#write), `BypassMergeSortShuffleWriter` requests the [Partitioner](#partitioner) for a [partition](../rdd/Partitioner.md#getPartition) for records (using keys) and finds the per-partition `DiskBlockObjectWriter` that is requested to [write out the partition records](../storage/DiskBlockObjectWriter.md#write). After all records are written out to their shuffle files, the `DiskBlockObjectWriter`s are requested to [commitAndGet](../storage/DiskBlockObjectWriter.md#commitAndGet).

`BypassMergeSortShuffleWriter` uses the partition writers while [writing out partition data](#writePartitionedData) and removes references to them (`null`ify them) in the end.

In other words, after [writing out partition data](#writePartitionedData) `partitionWriters` internal registry is `null`.

`partitionWriters` internal registry becomes `null` after `BypassMergeSortShuffleWriter` has finished:

* [Writing out partition data](#writePartitionedData)
* [Stopping](#stop)

## <span id="shuffleBlockResolver"> IndexShuffleBlockResolver

`BypassMergeSortShuffleWriter` is given a [IndexShuffleBlockResolver](IndexShuffleBlockResolver.md) when [created](#creating-instance).

`BypassMergeSortShuffleWriter` uses the `IndexShuffleBlockResolver` for [writing out records](#write) (to [writeIndexFileAndCommit](IndexShuffleBlockResolver.md#writeIndexFileAndCommit) and [getDataFile](IndexShuffleBlockResolver.md#getDataFile)).

## <span id="serializer"> Serializer

When created, `BypassMergeSortShuffleWriter` requests the [ShuffleDependency](BaseShuffleHandle.md#dependency) (of the given [BypassMergeSortShuffleHandle](#handle)) for the [Serializer](../rdd/ShuffleDependency.md#serializer).

`BypassMergeSortShuffleWriter` creates a new instance of the `Serializer` for [writing out records](#write).

## Configuration Properties

### <span id="fileBufferSize"><span id="spark.shuffle.file.buffer"> spark.shuffle.file.buffer

`BypassMergeSortShuffleWriter` uses [spark.shuffle.file.buffer](../configuration-properties.md#spark.shuffle.file.buffer) configuration property for...FIXME

### <span id="transferToEnabled"><span id="spark.file.transferTo"> spark.file.transferTo

BypassMergeSortShuffleWriter uses [spark.file.transferTo](../configuration-properties.md#spark.file.transferTo) configuration property to control whether to use Java New I/O while [writing to a partitioned file](#writePartitionedFile).

## <span id="write"> Writing Out Records to Shuffle File

```scala
void write(
  Iterator<Product2<K, V>> records)
```

`write` is part of the [ShuffleWriter](ShuffleWriter.md#write) abstraction.

`write` creates a new instance of the [Serializer](#serializer).

`write` initializes the [partitionWriters](#partitionWriters) and [partitionWriterSegments](#partitionWriterSegments) internal registries (for [DiskBlockObjectWriters](../storage/DiskBlockObjectWriter.md) and FileSegments for [every partition](#numPartitions), respectively).

`write` requests the [BlockManager](#blockManager) for the [DiskBlockManager](../storage/BlockManager.md#diskBlockManager) and for [every partition](#numPartitions) `write` requests it for a [shuffle block ID and the file](../storage/DiskBlockManager.md#createTempShuffleBlock). `write` creates a [DiskBlockObjectWriter](../storage/BlockManager.md#getDiskWriter) for the shuffle block (using the [BlockManager](#blockManager)). `write` stores the reference to `DiskBlockObjectWriters` in the [partitionWriters](#partitionWriters) internal registry.

After all `DiskBlockObjectWriters` are created, `write` requests the [ShuffleWriteMetrics](#writeMetrics) to [increment shuffle write time metric](../executor/ShuffleWriteMetrics.md#incWriteTime).

For every record (a key-value pair), write requests the [Partitioner](#partitioner) for the [partition ID](../rdd/Partitioner.md#getPartition) for the key. The partition ID is then used as an index of the partition writer (among the [DiskBlockObjectWriters](#partitionWriters)) to [write the current record out to a block file](../storage/DiskBlockObjectWriter.md#write).

Once all records have been writted out to their respective block files, write does the following for every [DiskBlockObjectWriter](#partitionWriters):

1. Requests the `DiskBlockObjectWriter` to [commit and return a corresponding FileSegment of the shuffle block](../storage/DiskBlockObjectWriter.md#commitAndGet)

1. Saves the (reference to) `FileSegments` in the [partitionWriterSegments](#partitionWriterSegments) internal registry

1. Requests the `DiskBlockObjectWriter` to [close](../storage/DiskBlockObjectWriter.md#close)

!!! note
    At this point, all the records are in shuffle block files on a local disk. The records are split across block files by key.

`write` requests the [IndexShuffleBlockResolver](#shuffleBlockResolver) for the [shuffle file](IndexShuffleBlockResolver.md#getDataFile) for the [shuffle](#shuffleId) and the [map](#mapId)Ds>>.

`write` creates a temporary file (based on the name of the shuffle file) and [writes all the per-partition shuffle files to it](#writePartitionedFile). The size of every per-partition shuffle files is saved as the [partitionLengths](#partitionLengths) internal registry.

!!! note
    At this point, all the per-partition shuffle block files are one single map shuffle data file.

`write` requests the [IndexShuffleBlockResolver](#shuffleBlockResolver) to [write shuffle index and data files](IndexShuffleBlockResolver.md#writeIndexFileAndCommit) for the [shuffle](#shuffleId) and the [map IDs](#mapId) (with the [partitionLengths](#partitionLengths) and the temporary shuffle output file).

`write` returns a [shuffle map output status](../scheduler/MapStatus.md) (with the [shuffle server ID](../storage/BlockManager.md#shuffleServerId) and the [partitionLengths](#partitionLengths)).

### <span id="write-no-records"> No Records

When there is no records to write out, `write` initializes the [partitionLengths](#partitionLengths) internal array (of [numPartitions](#numPartitions) size) with all elements being 0.

`write` requests the [IndexShuffleBlockResolver](#shuffleBlockResolver) to [write shuffle index and data files](IndexShuffleBlockResolver.md#writeIndexFileAndCommit), but the difference (compared to when there are records to write) is that the `dataTmp` argument is simply `null`.

`write` sets the internal `mapStatus` (with the address of [BlockManager](../storage/BlockManager.md) in use and [partitionLengths](#partitionLengths)).

### <span id="write-requirements"> Requirements

`write` requires that there are no [DiskBlockObjectWriters](#partitionWriters).

### <span id="writePartitionedData"> Writing Out Partitioned Data

```java
long[] writePartitionedData(
  ShuffleMapOutputWriter mapOutputWriter)
```

`writePartitionedData` makes sure that [DiskBlockObjectWriter](#partitionWriters)s are available (`partitionWriters != null`).

For [every partition](#numPartitions), `writePartitionedData` takes the partition file (from the [FileSegment](#partitionWriterSegments)s). Only when the partition file exists, `writePartitionedData` requests the given [ShuffleMapOutputWriter](ShuffleMapOutputWriter.md) for a [ShufflePartitionWriter](ShuffleMapOutputWriter.md#getPartitionWriter) and writes out the partitioned data. At the end, `writePartitionedData` deletes the file.

`writePartitionedData` requests the [ShuffleWriteMetricsReporter](#writeMetrics) to [increment the write time](ShuffleWriteMetricsReporter.md#incWriteTime).

In the end, `writePartitionedData` requests the `ShuffleMapOutputWriter` to [commitAllPartitions](ShuffleMapOutputWriter.md#commitAllPartitions) and returns the size of each partition of the output map file.

## <span id="copyStream"> Copying Raw Bytes Between Input Streams

```scala
copyStream(
  in: InputStream,
  out: OutputStream,
  closeStreams: Boolean = false,
  transferToEnabled: Boolean = false): Long
```

copyStream branches off depending on the type of `in` and `out` streams, i.e. whether they are both `FileInputStream` with `transferToEnabled` input flag is enabled.

If they are both `FileInputStream` with `transferToEnabled` enabled, copyStream gets their `FileChannels` and transfers bytes from the input file to the output file and counts the number of bytes, possibly zero, that were actually transferred.

NOTE: copyStream uses Java's {java-javadoc-url}/java/nio/channels/FileChannel.html[java.nio.channels.FileChannel] to manage file channels.

If either `in` and `out` input streams are not `FileInputStream` or `transferToEnabled` flag is disabled (default), copyStream reads data from `in` to write to `out` and counts the number of bytes written.

copyStream can optionally close `in` and `out` streams (depending on the input `closeStreams` -- disabled by default).

NOTE: `Utils.copyStream` is used when <<writePartitionedFile, BypassMergeSortShuffleWriter writes records into one single shuffle block data file>> (among other places).

!!! tip
    Visit the official web site of [JSR 51: New I/O APIs for the Java Platform](https://jcp.org/jsr/detail/51.jsp) and read up on [java.nio package]({{ java.api }}/java.base/java/nio/package-summary.html).

## <span id="stop"> Stopping ShuffleWriter

```java
Option<MapStatus> stop(
  boolean success)
```

`stop`...FIXME

`stop` is part of the [ShuffleWriter](ShuffleWriter.md#stop) abstraction.

## <span id="partitionLengths"> Temporary Array of Partition Lengths

```java
long[] partitionLengths
```

Temporary array of partition lengths after records are [written to a shuffle system](#write).

Initialized every time `BypassMergeSortShuffleWriter` [writes out records](#write) (before passing it in to [IndexShuffleBlockResolver](IndexShuffleBlockResolver.md#writeIndexFileAndCommit)). After `IndexShuffleBlockResolver` finishes, it is used to initialize [mapStatus](#mapStatus) internal property.

## Logging

Enable `ALL` logging level for `org.apache.spark.shuffle.sort.BypassMergeSortShuffleWriter` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.shuffle.sort.BypassMergeSortShuffleWriter=ALL
```

Refer to [Logging](../spark-logging.md).

## Internal Properties

### <span id="numPartitions"> numPartitions

### <span id="partitionWriterSegments"> partitionWriterSegments

### <span id="mapStatus"> mapStatus

[MapStatus](../scheduler/MapStatus.md) that [BypassMergeSortShuffleWriter returns when stopped](#stop)

Initialized every time `BypassMergeSortShuffleWriter` [writes out records](#write).

Used when [BypassMergeSortShuffleWriter stops](#stop) (with `success` enabled) as a marker if [any records were written](#write) and [returned if they did](#stop).
