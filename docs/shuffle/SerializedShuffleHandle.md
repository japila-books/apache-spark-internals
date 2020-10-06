= [[SerializedShuffleHandle]] SerializedShuffleHandle

*SerializedShuffleHandle* is a xref:shuffle:spark-shuffle-BaseShuffleHandle.adoc[ShuffleHandle] to identify the choice of a *serialized shuffle*.

SerializedShuffleHandle is <<creating-instance, created>> when SortShuffleManager is requested for a xref:shuffle:SortShuffleManager.adoc#registerShuffle[ShuffleHandle] (for a xref:rdd:ShuffleDependency.adoc[ShuffleDependency]). SortShuffleManager determines what shuffle handle to use by first checking out the requirements of xref:shuffle:SortShuffleWriter.adoc#shouldBypassMergeSort[BypassMergeSortShuffleHandle] before xref:shuffle:SortShuffleManager.adoc#canUseSerializedShuffle[SerializedShuffleHandle]'s.

SerializedShuffleHandle is used to create an xref:shuffle:UnsafeShuffleWriter.adoc#handle[UnsafeShuffleWriter].

== [[creating-instance]] Creating Instance

SerializedShuffleHandle takes the following to be created:

* [[shuffleId]] Shuffle ID
* [[numMaps]] Number of mappers
* [[dependency]] xref:rdd:ShuffleDependency.adoc[+++ShuffleDependency[K, V, V]+++]
