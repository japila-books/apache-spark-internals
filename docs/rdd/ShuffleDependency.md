# ShuffleDependency

`ShuffleDependency` is a [Dependency](Dependency.md) on the output of a scheduler:ShuffleMapStage.md[ShuffleMapStage] for a <<rdd, key-value pair RDD>>.

ShuffleDependency uses the <<rdd, RDD>> to know the number of (map-side/pre-shuffle) partitions and the <<partitioner, Partitioner>> for the number of (reduce-size/post-shuffle) partitions.

ShuffleDependency is created as a dependency of ShuffledRDD.md[ShuffledRDD]. ShuffleDependency can also be created as a dependency of [CoGroupedRDD](CoGroupedRDD.md) and [SubtractedRDD](SubtractedRDD.md).

== [[creating-instance]] Creating Instance

ShuffleDependency takes the following to be created:

* <<rdd, RDD>> of key-value pairs (`RDD[_ <: Product2[K, V]]`)
* <<partitioner, Partitioner>>
* [[serializer]] serializer:Serializer.md[Serializer]
* [[keyOrdering]] Ordering for K keys (`Option[Ordering[K]]`)
* <<aggregator, Aggregator>> (`Option[Aggregator[K, V, C]]`)
* <<mapSideCombine, mapSideCombine>> flag (default: `false`)

When created, ShuffleDependency gets ROOT:SparkContext.md#nextShuffleId[shuffle id] (as `shuffleId`).

NOTE: ShuffleDependency uses the index.md#context[input RDD to access `SparkContext`] and so the `shuffleId`.

ShuffleDependency shuffle:ShuffleManager.md#registerShuffle[registers itself with `ShuffleManager`] and gets a `ShuffleHandle` (available as <<shuffleHandle, shuffleHandle>> property).

NOTE: ShuffleDependency accesses core:SparkEnv.md#shuffleManager[`ShuffleManager` using `SparkEnv`].

In the end, ShuffleDependency core:ContextCleaner.md#registerShuffleForCleanup[registers itself for cleanup with `ContextCleaner`].

NOTE: ShuffleDependency accesses the ROOT:SparkContext.md#cleaner[optional `ContextCleaner` through `SparkContext`].

NOTE: ShuffleDependency is created when ShuffledRDD.md#getDependencies[ShuffledRDD], [CoGroupedRDD](CoGroupedRDD.md#getDependencies), and [SubtractedRDD](SubtractedRDD.md#getDependencies) return their RDD dependencies.

== [[shuffleId]] Shuffle ID

Every ShuffleDependency has a unique application-wide *shuffle ID* that is assigned when <<creating-instance, ShuffleDependency is created>> (and is used throughout Spark's code to reference a ShuffleDependency).

Shuffle IDs are tracked by ROOT:SparkContext.md#nextShuffleId[SparkContext].

== [[rdd]] Parent RDD

ShuffleDependency is given the parent RDD.md[RDD] of key-value pairs (`RDD[_ <: Product2[K, V]]`).

The parent RDD is available as rdd property that is part of the [Dependency](Dependency.md#rdd) abstraction.

[source,scala]
----
 RDD[Product2[K, V]]
----

== [[partitioner]] Partitioner

ShuffleDependency is given a Partitioner.md[Partitioner] that is used to partition the shuffle output (when shuffle:SortShuffleWriter.md[SortShuffleWriter], shuffle:BypassMergeSortShuffleWriter.md[BypassMergeSortShuffleWriter] and shuffle:UnsafeShuffleWriter.md[UnsafeShuffleWriter] are requested to write).

== [[shuffleHandle]] ShuffleHandle

[source, scala]
----
shuffleHandle: ShuffleHandle
----

shuffleHandle is the `ShuffleHandle` of a ShuffleDependency as assigned eagerly when <<creating-instance, ShuffleDependency was created>>.

shuffleHandle is used to compute [CoGroupedRDDs](CoGroupedRDD.md#compute), ShuffledRDD.md#compute[ShuffledRDD], [SubtractedRDD](SubtractedRDD.md#compute), and spark-sql-ShuffledRowRDD.md[ShuffledRowRDD] (to get a spark-shuffle-ShuffleReader.md[ShuffleReader] for a ShuffleDependency) and when a scheduler:ShuffleMapTask.md#runTask[`ShuffleMapTask` runs] (to get a `ShuffleWriter` for a ShuffleDependency).

== [[mapSideCombine]] Map-Size Partial Aggregation Flag

ShuffleDependency uses a mapSideCombine flag that controls whether to perform *map-side partial aggregation* (_map-side combine_) using an <<aggregator, Aggregator>>.

mapSideCombine is disabled (`false`) by default and can be enabled (`true`) for some use cases of ShuffledRDD.md#mapSideCombine[ShuffledRDD].

ShuffleDependency requires that the optional <<aggregator, Aggregator>> is defined when the flag is enabled.

mapSideCombine is used when:

* BlockStoreShuffleReader is requested to shuffle:BlockStoreShuffleReader.md#read[read combined records for a reduce task]

* SortShuffleManager is requested to shuffle:SortShuffleManager.md#registerShuffle[register a shuffle]

* SortShuffleWriter is requested to shuffle:SortShuffleWriter.md#write[write records]

== [[aggregator]] Optional Aggregator

[source, scala]
----
aggregator: Option[Aggregator[K, V, C]] = None
----

`aggregator` is a Aggregator.md[map/reduce-side Aggregator] (for a RDD's shuffle).

`aggregator` is by default undefined (i.e. `None`) when <<creating-instance, ShuffleDependency is created>>.

NOTE: `aggregator` is used when shuffle:SortShuffleWriter.md#write[`SortShuffleWriter` writes records] and shuffle:BlockStoreShuffleReader.md#read[`BlockStoreShuffleReader` reads combined key-values for a reduce task].
