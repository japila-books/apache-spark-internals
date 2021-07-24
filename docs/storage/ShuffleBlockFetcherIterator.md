# ShuffleBlockFetcherIterator

`ShuffleBlockFetcherIterator` is a `Iterator[(BlockId, InputStream)]` ([Scala]({{ scala.api }}/scala/collection/Iterator.html)) that fetches shuffle blocks (aka _shuffle map outputs_) from block managers.

## Creating Instance

`ShuffleBlockFetcherIterator` takes the following to be created:

* <span id="context"> [TaskContext](../scheduler/TaskContext.md)
* <span id="shuffleClient"> [BlockStoreClient](BlockStoreClient.md)
* <span id="blockManager"> [BlockManager](BlockManager.md)
* <span id="blocksByAddress"> Blocks by [Address](BlockManagerId.md) (`Iterator[(BlockManagerId, Seq[(BlockId, Long, Int)])]`)
* <span id="streamWrapper"> Stream Wrapper Function (`(BlockId, InputStream) => InputStream`)
* <span id="maxBytesInFlight"> maxBytesInFlight
* <span id="maxReqsInFlight"> maxReqsInFlight
* <span id="maxBlocksInFlightPerAddress"> maxBlocksInFlightPerAddress
* <span id="maxReqSizeShuffleToMem"> maxReqSizeShuffleToMem
* <span id="detectCorrupt"> `detectCorrupt` flag
* <span id="detectCorruptUseExtraMemory"> `detectCorruptUseExtraMemory` flag
* <span id="shuffleMetrics"> `ShuffleReadMetricsReporter`
* <span id="doBatchFetch"> `doBatchFetch` flag

While being created, `ShuffleBlockFetcherIterator` is requested to [initialize](#initialize).

`ShuffleBlockFetcherIterator` is created when:

* `BlockStoreShuffleReader` is requested to [read combined key-value records for a reduce task](../shuffle/BlockStoreShuffleReader.md#read)

### <span id="initialize"> Initializing

```scala
initialize(): Unit
```

`initialize`...FIXME

### <span id="partitionBlocksByFetchMode"> partitionBlocksByFetchMode

```scala
partitionBlocksByFetchMode(): ArrayBuffer[FetchRequest]
```

`partitionBlocksByFetchMode`...FIXME

### <span id="collectFetchRequests"> collectFetchRequests

```scala
collectFetchRequests(
  address: BlockManagerId,
  blockInfos: Seq[(BlockId, Long, Int)],
  collectedRemoteRequests: ArrayBuffer[FetchRequest]): Unit
```

`collectFetchRequests`...FIXME

### <span id="createFetchRequests"> createFetchRequests

```scala
createFetchRequests(
  curBlocks: Seq[FetchBlockInfo],
  address: BlockManagerId,
  isLast: Boolean,
  collectedRemoteRequests: ArrayBuffer[FetchRequest]): Seq[FetchBlockInfo]
```

`createFetchRequests`...FIXME

## <span id="DownloadFileManager"> DownloadFileManager

`ShuffleBlockFetcherIterator` is [DownloadFileManager](../shuffle/DownloadFileManager.md).

## <span id="hasNext"> hasNext

```scala
hasNext: Boolean
```

`hasNext` is part of the `Iterator` ([Scala]({{ scala.api }}/scala/collection/Iterator.html#hasNext:Boolean)) abstraction (to test whether this iterator can provide another element).

`hasNext` is `true` when [numBlocksProcessed](#numBlocksProcessed) is below [numBlocksToFetch](#numBlocksToFetch).

## <span id="next"> Retrieving Next Element

```scala
next(): (BlockId, InputStream)
```

`next` is part of the `Iterator` ([Scala]({{ scala.api }}/scala/collection/Iterator.html#next():A)) abstraction (to produce the next element of this iterator).

`next`...FIXME

## <span id="numBlocksProcessed"> numBlocksProcessed

The number of blocks [fetched and consumed](#next)

## <span id="numBlocksToFetch"> numBlocksToFetch

Total number of blocks to [fetch and consume](#next)

`ShuffleBlockFetcherIterator` can [produce](#hasNext) up to `numBlocksToFetch` elements.

`numBlocksToFetch` is increased every time `ShuffleBlockFetcherIterator` is requested to [partitionBlocksByFetchMode](#partitionBlocksByFetchMode) that prints it out as the INFO message to the logs:

```text
Getting [numBlocksToFetch] non-empty blocks out of [totalBlocks] blocks
```

## <span id="releaseCurrentResultBuffer"> releaseCurrentResultBuffer

```scala
releaseCurrentResultBuffer(): Unit
```

`releaseCurrentResultBuffer` is part of the [HERE](HERE.md#releaseCurrentResultBuffer) abstraction.

`releaseCurrentResultBuffer`...FIXME

`releaseCurrentResultBuffer` is used when:

* `ShuffleBlockFetcherIterator` is requested to [cleanup](#cleanup)
* `BufferReleasingInputStream` is requested to `close`

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.ShuffleBlockFetcherIterator` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.ShuffleBlockFetcherIterator=ALL
```

Refer to [Logging](../spark-logging.md).

## Review Me

ShuffleBlockFetcherIterator allows for <<next, iterating over a sequence of blocks>> as `(BlockId, InputStream)` pairs so a caller can handle shuffle blocks in a pipelined fashion as they are received.

ShuffleBlockFetcherIterator is exhausted (i.e. <<hasNext, can provide no elements>>) when the <<numBlocksProcessed, number of blocks already processed>> is at least the <<numBlocksToFetch, total number of blocks to fetch>>.

ShuffleBlockFetcherIterator <<fetchUpToMaxBytes, throttles the remote fetches>> to avoid consuming too much memory.

[[internal-registries]]
.ShuffleBlockFetcherIterator's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[results]] `results`
| Internal FIFO blocking queue (using Java's https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/LinkedBlockingQueue.html[java.util.concurrent.LinkedBlockingQueue]) to hold `FetchResult` remote and local fetch results.

Used in:

1. <<next, next>> to take one `FetchResult` off the queue,

2. <<sendRequest, sendRequest>> to put `SuccessFetchResult` or `FailureFetchResult` remote fetch results (as part of `BlockFetchingListener` callback),

3. <<fetchLocalBlocks, fetchLocalBlocks>> (similarly to <<sendRequest, sendRequest>>) to put local fetch results,

4. <<cleanup, cleanup>> to release managed buffers for `SuccessFetchResult` results.

| [[maxBytesInFlight]] `maxBytesInFlight`
| The maximum size (in bytes) of all the remote shuffle blocks to fetch.

Set when <<creating-instance, ShuffleBlockFetcherIterator is created>>.

| [[maxReqsInFlight]] `maxReqsInFlight`
| The maximum number of remote requests to fetch shuffle blocks.

Set when <<creating-instance, ShuffleBlockFetcherIterator is created>>.

| [[bytesInFlight]] `bytesInFlight`
| The bytes of fetched remote shuffle blocks in flight

Starts at `0` when <<creating-instance, ShuffleBlockFetcherIterator is created>>.

Incremented every <<sendRequest, sendRequest>> and decremented every <<next, next>>.

ShuffleBlockFetcherIterator makes sure that the invariant of `bytesInFlight` below <<maxBytesInFlight, maxBytesInFlight>> holds every <<fetchUpToMaxBytes, remote shuffle block fetch>>.

| [[reqsInFlight]] `reqsInFlight`
| The number of remote shuffle block fetch requests in flight.

Starts at `0` when <<creating-instance, ShuffleBlockFetcherIterator is created>>.

Incremented every <<sendRequest, sendRequest>> and decremented every <<next, next>>.

ShuffleBlockFetcherIterator makes sure that the invariant of `reqsInFlight` below <<maxReqsInFlight, maxReqsInFlight>> holds every <<fetchUpToMaxBytes, remote shuffle block fetch>>.

| [[isZombie]] `isZombie`
| Flag whether ShuffleBlockFetcherIterator is still active. It is disabled, i.e. `false`, when <<creating-instance, ShuffleBlockFetcherIterator is created>>.

<<cleanup, When enabled>> (when the task using ShuffleBlockFetcherIterator finishes), the <<sendRequest-BlockFetchingListener-onBlockFetchSuccess, block fetch successful callback>> (registered in `sendRequest`) will no longer add fetched remote shuffle blocks into <<results, results>> internal queue.

| [[currentResult]] `currentResult`
| The currently-processed `SuccessFetchResult`

Set when ShuffleBlockFetcherIterator <<next, returns the next `(BlockId, InputStream)` tuple>> and <<releaseCurrentResultBuffer, released>> (on <<cleanup, cleanup>>).
|===

## Creating Instance

When created, ShuffleBlockFetcherIterator takes the following:

* [[context]] [TaskContext](../scheduler/TaskContext.md)
* [[shuffleClient]] storage:ShuffleClient.md[]
* [[blockManager]] storage:BlockManager.md[BlockManager]
* [[blocksByAddress]] Blocks to fetch per storage:BlockManager.md[BlockManager] (as `Seq[(BlockManagerId, Seq[(BlockId, Long)])]`)
* [[streamWrapper]] Function to wrap the returned input stream (as `(BlockId, InputStream) => InputStream`)
* <<maxBytesInFlight, maxBytesInFlight>> -- the maximum size (in bytes) of map outputs to fetch simultaneously from each reduce task (controlled by shuffle:BlockStoreShuffleReader.md#spark_reducer_maxSizeInFlight[spark.reducer.maxSizeInFlight] Spark property)
* <<maxReqsInFlight, maxReqsInFlight>> -- the maximum number of remote requests to fetch blocks at any given point (controlled by shuffle:BlockStoreShuffleReader.md#spark_reducer_maxReqsInFlight[spark.reducer.maxReqsInFlight] Spark property)
* [[maxBlocksInFlightPerAddress]] `maxBlocksInFlightPerAddress`
* [[maxReqSizeShuffleToMem]] `maxReqSizeShuffleToMem`
* [[detectCorrupt]] `detectCorrupt` flag to detect any corruption in fetched blocks (controlled by shuffle:BlockStoreShuffleReader.md#spark_shuffle_detectCorrupt[spark.shuffle.detectCorrupt] Spark property)

== [[initialize]] Initializing ShuffleBlockFetcherIterator -- `initialize` Internal Method

[source, scala]
----
initialize(): Unit
----

`initialize` registers a task cleanup and fetches shuffle blocks from remote and local storage:BlockManager.md[BlockManagers].

Internally, `initialize` [registers a `TaskCompletionListener`](../scheduler/TaskContext.md#addTaskCompletionListener) (that will <<cleanup, clean up>> right after the task finishes).

`initialize` <<splitLocalRemoteBlocks, splitLocalRemoteBlocks>>.

`initialize` <<fetchRequests, registers the new remote fetch requests (with `fetchRequests` internal registry)>>.

As ShuffleBlockFetcherIterator is in initialization phase, `initialize` makes sure that <<reqsInFlight, reqsInFlight>> and <<bytesInFlight, bytesInFlight>> internal counters are both `0`. Otherwise, `initialize` throws an exception.

`initialize` <<fetchUpToMaxBytes, fetches shuffle blocks>> (from remote storage:BlockManager.md[BlockManagers]).

You should see the following INFO message in the logs:

```
INFO ShuffleBlockFetcherIterator: Started [numFetches] remote fetches in [time] ms
```

`initialize` <<fetchLocalBlocks, fetches local shuffle blocks>>.

You should see the following DEBUG message in the logs:

```
DEBUG ShuffleBlockFetcherIterator: Got local blocks in  [time] ms
```

NOTE: `initialize` is used exclusively when ShuffleBlockFetcherIterator is <<creating-instance, created>>.

== [[sendRequest]] Sending Remote Shuffle Block Fetch Request -- `sendRequest` Internal Method

[source, scala]
----
sendRequest(req: FetchRequest): Unit
----

Internally, when `sendRequest` runs, you should see the following DEBUG message in the logs:

```
DEBUG ShuffleBlockFetcherIterator: Sending request for [blocks.size] blocks ([size] B) from [hostPort]
```

`sendRequest` increments <<bytesInFlight, bytesInFlight>> and <<reqsInFlight, reqsInFlight>> internal counters.

NOTE: The input `FetchRequest` contains the remote storage:BlockManagerId.md[] address and the shuffle blocks to fetch (as a sequence of storage:BlockId.md[] and their sizes).

`sendRequest` storage:ShuffleClient.md#fetchBlocks[requests `ShuffleClient` to fetch shuffle blocks] (from the host, the port, and the executor as defined in the input `FetchRequest`).

NOTE: `ShuffleClient` was defined when <<creating-instance, ShuffleBlockFetcherIterator was created>>.

`sendRequest` registers a `BlockFetchingListener` with `ShuffleClient` that:

1. <<sendRequest-BlockFetchingListener-onBlockFetchSuccess, For every successfully fetched shuffle block>> adds it as `SuccessFetchResult` to <<results, results>> internal queue.

2. <<sendRequest-BlockFetchingListener-onBlockFetchFailure, For every shuffle block fetch failure>> adds it as `FailureFetchResult` to <<results, results>> internal queue.

NOTE: `sendRequest` is used exclusively when ShuffleBlockFetcherIterator is requested to <<fetchUpToMaxBytes, fetch remote shuffle blocks>>.

=== [[sendRequest-BlockFetchingListener-onBlockFetchSuccess]] onBlockFetchSuccess Callback

[source, scala]
----
onBlockFetchSuccess(blockId: String, buf: ManagedBuffer): Unit
----

Internally, `onBlockFetchSuccess` checks if the <<isZombie, iterator is not zombie>> and does the further processing if it is not.

`onBlockFetchSuccess` marks the input `blockId` as received (i.e. removes it from all the blocks to fetch as requested in <<sendRequest, sendRequest>>).

`onBlockFetchSuccess` adds the managed `buf` (as `SuccessFetchResult`) to <<results, results>> internal queue.

You should see the following DEBUG message in the logs:

```
DEBUG ShuffleBlockFetcherIterator: remainingBlocks: [blocks]
```

Regardless of zombie state of ShuffleBlockFetcherIterator, you should see the following TRACE message in the logs:

```
TRACE ShuffleBlockFetcherIterator: Got remote block [blockId] after [time] ms
```

=== [[sendRequest-BlockFetchingListener-onBlockFetchFailure]] onBlockFetchFailure Callback

[source, scala]
----
onBlockFetchFailure(blockId: String, e: Throwable): Unit
----

When `onBlockFetchFailure` is called, you should see the following ERROR message in the logs:

```
ERROR ShuffleBlockFetcherIterator: Failed to get block(s) from [hostPort]
```

`onBlockFetchFailure` adds the block (as `FailureFetchResult`) to <<results, results>> internal queue.

== [[throwFetchFailedException]] Throwing FetchFailedException (for ShuffleBlockId) -- `throwFetchFailedException` Internal Method

[source, scala]
----
throwFetchFailedException(
  blockId: BlockId,
  address: BlockManagerId,
  e: Throwable): Nothing
----

`throwFetchFailedException` throws a shuffle:FetchFailedException.md[FetchFailedException] when the input `blockId` is a `ShuffleBlockId`.

NOTE: `throwFetchFailedException` creates a `FetchFailedException` passing on the root cause of a failure, i.e. the input `e`.

Otherwise, `throwFetchFailedException` throws a `SparkException`:

```
Failed to get block [blockId], which is not a shuffle block
```

NOTE: `throwFetchFailedException` is used when ShuffleBlockFetcherIterator is requested for the <<next, next element>>.

== [[cleanup]] Releasing Resources -- `cleanup` Internal Method

[source, scala]
----
cleanup(): Unit
----

Internally, `cleanup` marks ShuffleBlockFetcherIterator a <<isZombie, zombie>>.

`cleanup` <<releaseCurrentResultBuffer, releases the current result buffer>>.

`cleanup` iterates over <<results, results>> internal queue and for every `SuccessFetchResult`, increments remote bytes read and blocks fetched shuffle task metrics, and eventually releases the managed buffer.

NOTE: `cleanup` is used when <<initialize, ShuffleBlockFetcherIterator initializes itself>>.
