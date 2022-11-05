# SerializedShuffleHandle

`SerializedShuffleHandle` is a [BaseShuffleHandle](BaseShuffleHandle.md) that `SortShuffleManager` uses when [canUseSerializedShuffle](SortShuffleWriter.md#canUseSerializedShuffle) (when requested to [register a shuffle](SortShuffleManager.md#registerShuffle) and [BypassMergeSortShuffleHandles](BypassMergeSortShuffleHandle.md) could not be selected).

`SerializedShuffleHandle` tells `SortShuffleManager` to use [UnsafeShuffleWriter](UnsafeShuffleWriter.md) when requested for a [ShuffleWriter](SortShuffleManager.md#getWriter).

## Creating Instance

`SerializedShuffleHandle` takes the following to be created:

* <span id="shuffleId"> Shuffle ID
* <span id="dependency"> [ShuffleDependency](../rdd/ShuffleDependency.md)

`SerializedShuffleHandle` is created when:

* `SortShuffleManager` is requested for a [ShuffleHandle](SortShuffleManager.md#registerShuffle) (for the [ShuffleDependency](#dependency))
