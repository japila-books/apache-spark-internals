# SerializedShuffleHandle

`SerializedShuffleHandle` is a [ShuffleHandle](BaseShuffleHandle.md) to identify the choice of a **serialized shuffle**.

`SerializedShuffleHandle` is used to create an [UnsafeShuffleWriter](UnsafeShuffleWriter.md#handle).

## Creating Instance

`SerializedShuffleHandle` takes the following to be created:

* [[shuffleId]] Shuffle ID
* [[numMaps]] Number of mappers
* [[dependency]] [ShuffleDependency[K, V, V]](../rdd/ShuffleDependency.md)

`SerializedShuffleHandle` is created when `SortShuffleManager` is requested for a [ShuffleHandle](SortShuffleManager.md#registerShuffle) (for a [ShuffleDependency](../rdd/ShuffleDependency.md)). `SortShuffleManager` determines what shuffle handle to use by first checking out the requirements of [BypassMergeSortShuffleHandle](SortShuffleWriter.md#shouldBypassMergeSort) before [SerializedShuffleHandle](SortShuffleManager.md#canUseSerializedShuffle)'s.
