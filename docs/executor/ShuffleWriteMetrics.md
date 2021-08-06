---
tags:
  - DeveloperApi
---

# ShuffleWriteMetrics

`ShuffleWriteMetrics` is a [ShuffleWriteMetricsReporter](../shuffle/ShuffleWriteMetricsReporter.md) of metrics ([accumulators](../accumulators/index.md)) related to writing shuffle data (in shuffle map tasks):

* Shuffle Bytes Written
* Shuffle Write Time
* Shuffle Records Written

## Creating Instance

`ShuffleWriteMetrics` takes no input arguments to be created.

`ShuffleWriteMetrics` is created when:

* `TaskMetrics` is [created](TaskMetrics.md#shuffleWriteMetrics)
* `ShuffleExternalSorter` is requested to [writeSortedFile](../shuffle/ShuffleExternalSorter.md#writeSortedFile)
* `MapIterator` (of [BytesToBytesMap](../memory/BytesToBytesMap.md)) is requested to `spill`
* `ExternalAppendOnlyMap` is [created](../shuffle/ExternalAppendOnlyMap.md#writeMetrics)
* `ExternalSorter` is requested to [spillMemoryIteratorToDisk](../shuffle/ExternalSorter.md#spillMemoryIteratorToDisk)
* `UnsafeExternalSorter` is requested to [spill](../memory/UnsafeExternalSorter.md#spill)
* `SpillableIterator` (of [UnsafeExternalSorter](../memory/UnsafeExternalSorter.md)) is requested to `spill`

## <span id="TaskMetrics"> TaskMetrics

`ShuffleWriteMetrics` is available using [TaskMetrics.shuffleWriteMetrics](TaskMetrics.md#shuffleWriteMetrics).

## <span id="Serializable"> Serializable

`ShuffleWriteMetrics` is a `Serializable` ([Java]({{ java.api }}/java.base/java/io/Serializable.html)).
