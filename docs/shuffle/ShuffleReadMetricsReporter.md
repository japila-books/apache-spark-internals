# ShuffleReadMetricsReporter

`ShuffleReadMetricsReporter` is an abstraction of [reporters](#implementations) that allow tracking the following **Shuffle Read Metrics** (for each shuffle):

Shuffle Read Metric | When used
-|-
 Corrupt Merged Block Chunks | FIXME
 Fetch Wait Time | FIXME
 Local Blocks Fetched | FIXME
 Local Bytes Read | FIXME
 Merged Local Blocks Fetched | FIXME
 Merged Local Bytes Read | FIXME
 Merged Local Chunks Fetched | FIXME
 Merged Fetch Fallback Count | FIXME
 Merged Remote Blocks Fetched | FIXME
 Merged Remote Chunks Fetched | FIXME
 Merged Remote Bytes Read | FIXME
 Merged Remote Requests Duration | FIXME
 Remote Blocks Fetched | [ShuffleBlockFetcherIterator](../storage/ShuffleBlockFetcherIterator.md#shuffleRemoteMetricsUpdate) for [ShuffleBlockChunkId](../storage/BlockId.md#ShuffleBlockChunkId)s
 Remote Bytes Read | FIXME
 Remote Bytes Read To Disk | FIXME
 Remote Requests Duration | FIXME
 Total Records Read | FIXME

`ShuffleReadMetricsReporter` is used to create the following:

* [BlockStoreShuffleReader](BlockStoreShuffleReader.md#readMetrics)
* `PushBasedFetchHelper`
* [ShuffleBlockFetcherIterator](../storage/ShuffleBlockFetcherIterator.md#shuffleMetrics)

## Implementations

* `TempShuffleReadMetrics`
