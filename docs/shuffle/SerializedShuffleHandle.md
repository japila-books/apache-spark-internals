# SerializedShuffleHandle

`SerializedShuffleHandle` is a [ShuffleHandle](BaseShuffleHandle.md) to identify the choice of a **serialized shuffle**.

`SerializedShuffleHandle` is used to create an shuffle:UnsafeShuffleWriter.md#handle[UnsafeShuffleWriter].

## Creating Instance

`SerializedShuffleHandle` takes the following to be created:

* [[shuffleId]] Shuffle ID
* [[numMaps]] Number of mappers
* [[dependency]] rdd:ShuffleDependency.md[+++ShuffleDependency[K, V, V]+++]

`SerializedShuffleHandle` is created when SortShuffleManager is requested for a shuffle:SortShuffleManager.md#registerShuffle[ShuffleHandle] (for a rdd:ShuffleDependency.md[ShuffleDependency]). SortShuffleManager determines what shuffle handle to use by first checking out the requirements of shuffle:SortShuffleWriter.md#shouldBypassMergeSort[BypassMergeSortShuffleHandle] before shuffle:SortShuffleManager.md#canUseSerializedShuffle[SerializedShuffleHandle]'s.
