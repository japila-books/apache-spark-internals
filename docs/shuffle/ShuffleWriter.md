# ShuffleWriter

`ShuffleWriter[K, V]` (of `K` keys and `V` values) is an [abstraction](#contract) of [shuffle writers](#implementations) that can [write out key-value records](#write) (of a RDD partition) to a shuffle system.

`ShuffleWriter` is used when [ShuffleMapTask](../scheduler/ShuffleMapTask.md) is requested to [run](../scheduler/ShuffleMapTask.md#runTask) (and uses a `ShuffleWriteProcessor` to [write partition records to a shuffle system](ShuffleWriteProcessor.md#write)).

## Contract

### <span id="write"> Writing Out Partition Records to Shuffle System

```scala
write(
  records: Iterator[Product2[K, V]]): Unit
```

Writes key-value records (of a partition) out to a shuffle system

Used when:

* `ShuffleWriteProcessor` is requested to [write](ShuffleWriteProcessor.md#write)

### <span id="stop"> Stopping ShuffleWriter

```scala
stop(
  success: Boolean): Option[MapStatus]
```

Stops (_closes_) the `ShuffleWriter` and returns a [MapStatus](../scheduler/MapStatus.md) if the writing completed successfully. The `success` flag is the status of the task execution.

Used when:

* `ShuffleWriteProcessor` is requested to [write](ShuffleWriteProcessor.md#write)

## Implementations

* [BypassMergeSortShuffleWriter](BypassMergeSortShuffleWriter.md)
* [SortShuffleWriter](SortShuffleWriter.md)
* [UnsafeShuffleWriter](UnsafeShuffleWriter.md)
