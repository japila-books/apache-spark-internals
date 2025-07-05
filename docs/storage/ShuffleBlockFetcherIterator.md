# ShuffleBlockFetcherIterator

`ShuffleBlockFetcherIterator` is an `Iterator[(BlockId, InputStream)]` ([Scala]({{ scala.api }}/scala/collection/Iterator.html)) that fetches shuffle blocks from [local](#blockManager) or remote [BlockManager](BlockManager.md)s (and makes them available as an `InputStream`).

`ShuffleBlockFetcherIterator` allows for a [synchronous iteration](#next) over shuffle blocks so a caller can handle them in a pipelined fashion as they are received.

`ShuffleBlockFetcherIterator` is exhausted (and [can provide no elements](#hasNext)) when the [number of blocks already processed](#numBlocksProcessed) is at least the [total number of blocks to fetch](#numBlocksToFetch).

`ShuffleBlockFetcherIterator` [throttles the remote fetches](#fetchUpToMaxBytes) to avoid consuming too much memory.

## Creating Instance

`ShuffleBlockFetcherIterator` takes the following to be created:

* <span id="context"> [TaskContext](../scheduler/TaskContext.md)
* <span id="shuffleClient"> [BlockStoreClient](BlockStoreClient.md)
* <span id="blockManager"> [BlockManager](BlockManager.md)
* <span id="blocksByAddress"> [Block](BlockId.md)s to Fetch by [Address](BlockManagerId.md) (`Iterator[(BlockManagerId, Seq[(BlockId, Long, Int)])]`)
* <span id="streamWrapper"> Stream Wrapper Function (`(BlockId, InputStream) => InputStream`)
* <span id="maxBytesInFlight"> [spark.reducer.maxSizeInFlight](../configuration-properties.md#spark.reducer.maxSizeInFlight)
* <span id="maxReqsInFlight"> [spark.reducer.maxReqsInFlight](../configuration-properties.md#spark.reducer.maxReqsInFlight)
* <span id="maxBlocksInFlightPerAddress"> [spark.reducer.maxBlocksInFlightPerAddress](../configuration-properties.md#spark.reducer.maxBlocksInFlightPerAddress)
* <span id="maxReqSizeShuffleToMem"> [spark.network.maxRemoteBlockSizeFetchToMem](../configuration-properties.md#spark.network.maxRemoteBlockSizeFetchToMem)
* <span id="detectCorrupt"> [spark.shuffle.detectCorrupt](../configuration-properties.md#spark.shuffle.detectCorrupt)
* <span id="detectCorruptUseExtraMemory"> [spark.shuffle.detectCorrupt.useExtraMemory](../configuration-properties.md#spark.shuffle.detectCorrupt.useExtraMemory)
* <span id="shuffleMetrics"> `ShuffleReadMetricsReporter`
* <span id="doBatchFetch"> `doBatchFetch` flag

While being created, `ShuffleBlockFetcherIterator` [initializes itself](#initialize).

`ShuffleBlockFetcherIterator` is created when:

* `BlockStoreShuffleReader` is requested to [read combined key-value records for a reduce task](../shuffle/BlockStoreShuffleReader.md#read)

### Initializing { #initialize }

```scala
initialize(): Unit
```

`initialize` registers a [task cleanup](#onCompleteCallback) and fetches shuffle blocks from remote and local storage:BlockManager.md[BlockManagers].

Internally, `initialize` uses the [TaskContext](#context) to [register](../scheduler/TaskContext.md#addTaskCompletionListener) the [ShuffleFetchCompletionListener](#onCompleteCallback) (to [cleanup](#cleanup)).

`initialize` [partitionBlocksByFetchMode](#partitionBlocksByFetchMode).

`initialize`...FIXME

### partitionBlocksByFetchMode { #partitionBlocksByFetchMode }

```scala
partitionBlocksByFetchMode(): ArrayBuffer[FetchRequest]
```

`partitionBlocksByFetchMode`...FIXME

### collectFetchRequests { #collectFetchRequests }

```scala
collectFetchRequests(
  address: BlockManagerId,
  blockInfos: Seq[(BlockId, Long, Int)],
  collectedRemoteRequests: ArrayBuffer[FetchRequest]): Unit
```

`collectFetchRequests`...FIXME

### createFetchRequests { #createFetchRequests }

```scala
createFetchRequests(
  curBlocks: Seq[FetchBlockInfo],
  address: BlockManagerId,
  isLast: Boolean,
  collectedRemoteRequests: ArrayBuffer[FetchRequest]): Seq[FetchBlockInfo]
```

`createFetchRequests`...FIXME

## fetchUpToMaxBytes { #fetchUpToMaxBytes }

```scala
fetchUpToMaxBytes(): Unit
```

`fetchUpToMaxBytes`...FIXME

`fetchUpToMaxBytes` is used when:

* `ShuffleBlockFetcherIterator` is requested to [initialize](#initialize) and [next](#next)

## Sending Remote Shuffle Block Fetch Request { #sendRequest }

```scala
sendRequest(
  req: FetchRequest): Unit
```

`sendRequest` prints out the following DEBUG message to the logs:

```text
Sending request for [n] blocks ([size]) from [hostPort]
```

`sendRequest` add the size of the blocks in the `FetchRequest` to [bytesInFlight](#bytesInFlight) and increments the [reqsInFlight](#reqsInFlight) internal counters.

`sendRequest` requests the [ShuffleClient](#shuffleClient) to [fetch the blocks](#fetchBlocks) with a new [BlockFetchingListener](#BlockFetchingListener) (and this `ShuffleBlockFetcherIterator` when the size of the blocks in the `FetchRequest` is higher than the [maxReqSizeShuffleToMem](#maxReqSizeShuffleToMem)).

`sendRequest` is used when:

* `ShuffleBlockFetcherIterator` is requested to [fetch remote shuffle blocks](#fetchUpToMaxBytes)

### BlockFetchingListener { #BlockFetchingListener }

`sendRequest` creates a new [BlockFetchingListener](../core/BlockFetchingListener.md) to be notified about [successes](#onBlockFetchSuccess) or [failures](#onBlockFetchFailure) of shuffle block fetch requests.

#### onBlockFetchSuccess { #onBlockFetchSuccess }

On [onBlockFetchSuccess](../core/BlockFetchingListener.md#onBlockFetchSuccess) the `BlockFetchingListener` adds a `SuccessFetchResult` to the [results](#results) registry and prints out the following DEBUG message to the logs (when not a [zombie](#isZombie)):

```text
remainingBlocks: [remainingBlocks]
```

In the end, `onBlockFetchSuccess` prints out the following TRACE message to the logs:

```text
Got remote block [blockId] after [time]
```

#### onBlockFetchFailure { #onBlockFetchFailure }

On [onBlockFetchFailure](../core/BlockFetchingListener.md#onBlockFetchFailure) the `BlockFetchingListener` adds a `FailureFetchResult` to the [results](#results) registry and prints out the following ERROR message to the logs:

```text
Failed to get block(s) from [host]:[port]
```

## FetchResults { #results }

```scala
results: LinkedBlockingQueue[FetchResult]
```

`ShuffleBlockFetcherIterator` uses an internal FIFO blocking queue ([Java]({{ java.api }}/java/util/concurrent/LinkedBlockingQueue.html)) of `FetchResult`s.

`results` is used for [fetching the next element](#next).

For remote blocks, `FetchResult`s are added in [sendRequest](#sendRequest):

* `SuccessFetchResult`s after a `BlockFetchingListener` is notified about [onBlockFetchSuccess](../core/BlockFetchingListener.md#onBlockFetchSuccess)
* `FailureFetchResult`s after a `BlockFetchingListener` is notified about [onBlockFetchFailure](../core/BlockFetchingListener.md#onBlockFetchFailure)

For local blocks, `FetchResult`s are added in [fetchLocalBlocks](#fetchLocalBlocks):

* `SuccessFetchResult`s after the [BlockManager](#blockManager) has successfully [getLocalBlockData](BlockManager.md#getLocalBlockData)
* `FailureFetchResult`s otherwise

For local blocks, `FetchResult`s are added in [fetchHostLocalBlock](#fetchHostLocalBlock):

* `SuccessFetchResult`s after the [BlockManager](#blockManager) has successfully [getHostLocalShuffleData](BlockManager.md#getHostLocalShuffleData)
* `FailureFetchResult`s otherwise

`FailureFetchResult`s can also be added in [fetchHostLocalBlocks](#fetchHostLocalBlocks).

Cleaned up in [cleanup](#cleanup)

## hasNext { #hasNext }

```scala
hasNext: Boolean
```

`hasNext` is part of the `Iterator` ([Scala]({{ scala.api }}/scala/collection/Iterator.html#hasNext:Boolean)) abstraction (to test whether this iterator can provide another element).

`hasNext` is `true` when [numBlocksProcessed](#numBlocksProcessed) is below [numBlocksToFetch](#numBlocksToFetch).

## Retrieving Next Element { #next }

```scala
next(): (BlockId, InputStream)
```

`next` increments the [numBlocksProcessed](#numBlocksProcessed) registry.

`next` takes (and removes) the head of the [results](#results) queue.

`next` requests the [ShuffleReadMetricsReporter](#shuffleMetrics) to `incFetchWaitTime`.

`next`...FIXME

`next` throws a `NoSuchElementException` if there is [no element left](#hasNext).

`next` is part of the `Iterator` ([Scala]({{ scala.api }}/scala/collection/Iterator.html#next():A)) abstraction (to produce the next element of this iterator).

## numBlocksProcessed { #numBlocksProcessed }

The number of blocks [fetched and consumed](#next)

## numBlocksToFetch { #numBlocksToFetch }

Total number of blocks to [fetch and consume](#next)

`ShuffleBlockFetcherIterator` can [produce](#hasNext) up to `numBlocksToFetch` elements.

`numBlocksToFetch` is increased every time `ShuffleBlockFetcherIterator` is requested to [partitionBlocksByFetchMode](#partitionBlocksByFetchMode) that prints it out as the INFO message to the logs:

```text
Getting [numBlocksToFetch] non-empty blocks out of [totalBlocks] blocks
```

## releaseCurrentResultBuffer { #releaseCurrentResultBuffer }

```scala
releaseCurrentResultBuffer(): Unit
```

`releaseCurrentResultBuffer`...FIXME

`releaseCurrentResultBuffer` is used when:

* `ShuffleBlockFetcherIterator` is requested to [cleanup](#cleanup)
* `BufferReleasingInputStream` is requested to `close`

## ShuffleFetchCompletionListener { #onCompleteCallback }

`ShuffleBlockFetcherIterator` creates a [ShuffleFetchCompletionListener](ShuffleFetchCompletionListener.md) when [created](#creating-instance).

`ShuffleFetchCompletionListener` is used when [initialize](#initialize) and [toCompletionIterator](#toCompletionIterator).

## Cleaning Up { #cleanup }

```scala
cleanup(): Unit
```

`cleanup` marks this `ShuffleBlockFetcherIterator` a [zombie](#isZombie).

`cleanup` [releases the current result buffer](#releaseCurrentResultBuffer).

`cleanup` iterates over [results](#results) internal queue and for every `SuccessFetchResult`, increments remote bytes read and blocks fetched shuffle task metrics, and eventually releases the managed buffer.

## bytesInFlight { #bytesInFlight }

The bytes of fetched remote shuffle blocks in flight

Starts at `0` when `ShuffleBlockFetcherIterator` is [created](#creating-instance)

Incremented every [sendRequest](#sendRequest) and decremented every [next](#next).

`ShuffleBlockFetcherIterator` makes sure that the invariant of `bytesInFlight` is below [maxBytesInFlight](#maxBytesInFlight) every [remote shuffle block fetch](#fetchUpToMaxBytes).

## reqsInFlight { #reqsInFlight }

The number of remote shuffle block fetch requests in flight.

Starts at `0` when `ShuffleBlockFetcherIterator` is [created](#creating-instance)

Incremented every [sendRequest](#sendRequest) and decremented every [next](#next).

`ShuffleBlockFetcherIterator` makes sure that the invariant of `reqsInFlight` is below [maxReqsInFlight](#maxReqsInFlight) every [remote shuffle block fetch](#fetchUpToMaxBytes).

## isZombie { #isZombie }

Controls whether `ShuffleBlockFetcherIterator` is still active and records `SuccessFetchResult`s on [successful shuffle block fetches](#onBlockFetchSuccess).

Starts `false` when `ShuffleBlockFetcherIterator` is [created](#creating-instance)

Enabled (`true`) in [cleanup](#cleanup).

When enabled, [registerTempFileToClean](#registerTempFileToClean) is a noop.

## DownloadFileManager { #DownloadFileManager }

`ShuffleBlockFetcherIterator` is a [DownloadFileManager](../shuffle/DownloadFileManager.md).

## throwFetchFailedException { #throwFetchFailedException }

```scala
throwFetchFailedException(
  blockId: BlockId,
  mapIndex: Int,
  address: BlockManagerId,
  e: Throwable,
  message: Option[String] = None): Nothing
```

`throwFetchFailedException` takes the `message` (if defined) or uses the message of the given `Throwable`.

In the end, `throwFetchFailedException` throws a [FetchFailedException](../shuffle/FetchFailedException.md) if the [BlockId](BlockId.md) is either a `ShuffleBlockId` or a `ShuffleBlockBatchId`. Otherwise, `throwFetchFailedException` throws a `SparkException`:

```text
Failed to get block [blockId], which is not a shuffle block
```

`throwFetchFailedException` is used when:

* `ShuffleBlockFetcherIterator` is requested to [next](#next)
* `BufferReleasingInputStream` is requested to `tryOrFetchFailedException`

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.ShuffleBlockFetcherIterator` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.ShuffleBlockFetcherIterator=ALL
```

Refer to [Logging](../spark-logging.md).
