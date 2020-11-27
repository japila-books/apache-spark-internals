= DiskStore

*DiskStore* manages data blocks on disk for storage:BlockManager.md#diskStore[BlockManager].

.DiskStore and BlockManager
image::DiskStore-BlockManager.png[align="center"]

== [[creating-instance]] Creating Instance

DiskStore takes the following to be created:

* [[conf]] SparkConf.md[]
* [[diskManager]] storage:DiskBlockManager.md[]
* [[securityManager]] SecurityManager

== [[getBytes]] getBytes Method

[source,scala]
----
getBytes(
  blockId: BlockId): BlockData
----

getBytes...FIXME

getBytes is used when BlockManager is requested to storage:BlockManager.md#getLocalValues[getLocalValues] and storage:BlockManager.md#doGetLocalBytes[doGetLocalBytes].

== [[blockSizes]] blockSizes Internal Registry

[source, scala]
----
blockSizes: ConcurrentHashMap[BlockId, Long]
----

blockSizes is a Java {java-javadoc-url}/java/util/concurrent/ConcurrentHashMap.html[java.util.concurrent.ConcurrentHashMap] that DiskStore uses to track storage:BlockId.md[]s by their size on disk.

== [[contains]] Checking if Block File Exists

[source, scala]
----
contains(
  blockId: BlockId): Boolean
----

`contains` requests the <<diskManager, DiskBlockManager>> for the storage:DiskBlockManager.md#getFile[block file] by (the name of) the input storage:BlockId.md[] and check whether the file actually exists or not.

`contains` is used when:

* BlockManager is requested to storage:BlockManager.md#getStatus[getStatus], storage:BlockManager.md#getCurrentBlockStatus[getCurrentBlockStatus], storage:BlockManager.md#getLocalValues[getLocalValues], storage:BlockManager.md#doGetLocalBytes[doGetLocalBytes], storage:BlockManager.md#dropFromMemory[dropFromMemory]

* DiskStore is requested to <<put, put>>

== [[put]] Writing Block to Disk

[source, scala]
----
put(
  blockId: BlockId)(
  writeFunc: WritableByteChannel => Unit): Unit
----

`put` prints out the following DEBUG message to the logs:

```
Attempting to put block [blockId]
```

`put` requests the <<diskManager, DiskBlockManager>> for the storage:DiskBlockManager.md#getFile[block file] for the input storage:BlockId.md[].

`put` <<openForWrite, opens the block file for writing>> (wrapped into a CountingWritableChannel to count the bytes written).

`put` executes the given writeFunc function with the WritableByteChannel of the block file and registers the bytes written to the <<blockSizes, blockSizes>> internal registry.

In the end, `put` prints out the following DEBUG message to the logs:

```
Block [fileName] stored as [size] file on disk in [time] ms
```

In case of any exception, `put` <<remove, deletes the block file>>.

`put` throws an `IllegalStateException` when the BlockId is already <<contains, is already present in the disk store>>:

```
Block [blockId] is already present in the disk store
```

`put` is used when:

* BlockManager is requested to storage:BlockManager.md#doPutIterator[doPutIterator] and storage:BlockManager.md#dropFromMemory[dropFromMemory]

* DiskStore is requested to <<putBytes, putBytes>>

== [[putBytes]] putBytes Method

[source, scala]
----
putBytes(
  blockId: BlockId,
  bytes: ChunkedByteBuffer): Unit
----

`putBytes`...FIXME

`putBytes` is used when BlockManager is requested to storage:BlockManager.md#doPutBytes[doPutBytes] and storage:BlockManager.md#dropFromMemory[dropFromMemory].

== [[remove]] Removing Block

[source, scala]
----
remove(
  blockId: BlockId): Boolean
----

`remove`...FIXME

`remove` is used when:

* BlockManager is requested to storage:BlockManager.md#removeBlockInternal[removeBlockInternal]

* DiskStore is requested to <<put, put>> (when an exception was thrown)

== [[openForWrite]] Opening Block File For Writing

[source, scala]
----
openForWrite(
  file: File): WritableByteChannel
----

`openForWrite`...FIXME

`openForWrite` is used when DiskStore is requested to <<put, write a block to disk>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.storage.DiskStore` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.storage.DiskStore=ALL
----

Refer to spark-logging.md[Logging].
