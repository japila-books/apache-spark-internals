# AppStatusStore

![AppStatusStore in Spark Application](../images/core/AppStatusStore-createLiveStore.png)

AppStatusStore is available as SparkContext.md#statusStore[SparkContext.statusStore] to other Spark services.

## Creating Instance

AppStatusStore takes the following to be created:

* [[store]] core:KVStore.md[]
* [[listener]] Optional core:AppStatusListener.md[] (default: `None`)

AppStatusStore is created when:

* [SparkContext](../SparkContext.md) is created (that triggers <<createLiveStore, creating an AppStatusStore for an active Spark application>>)

* FsHistoryProvider is requested to spark-history-server:FsHistoryProvider.md#getAppUI[create a LoadedAppUI]

== [[streamBlocksList]] `streamBlocksList` Method

[source, scala]
----
streamBlocksList(): Seq[StreamBlockData]
----

`streamBlocksList`...FIXME

NOTE: `streamBlocksList` is used when...FIXME

== [[activeStages]] `activeStages` Method

[source, scala]
----
activeStages(): Seq[v1.StageData]
----

`activeStages`...FIXME

NOTE: `activeStages` is used when...FIXME

== [[createLiveStore]] Creating Event Store

[source, scala]
----
createLiveStore(
  conf: SparkConf): AppStatusStore
----

createLiveStore creates a fully-initialized AppStatusStore.

Internally, createLiveStore creates a core:ElementTrackingStore.md[] (with a new core:InMemoryStore.md[] and the input SparkConf.md[SparkConf]).

createLiveStore creates a core:AppStatusListener.md[] (with the `ElementTrackingStore` created, the input `SparkConf` and the `live` flag enabled).

In the end, createLiveStore creates an <<creating-instance, AppStatusStore>> (with the `ElementTrackingStore` and `AppStatusListener` just created).

`createLiveStore` is used when [SparkContext](../SparkContext.md) is created.

== [[close]] Closing AppStatusStore

[source, scala]
----
close(): Unit
----

`close` simply requests <<store, KVStore>> to core:KVStore.md#close[close].

NOTE: `close` is used when...FIXME

== [[rddList]] `rddList` Method

[source, scala]
----
rddList(cachedOnly: Boolean = true): Seq[v1.RDDStorageInfo]
----

`rddList` requests the <<store, KVStore>> for a core:KVStore.md#view[view] over `RDDStorageInfoWrapper` entities.

In the end, `rddList` takes `RDDStorageInfos` with at least one spark-webui-RDDStorageInfo.md#numCachedPartitions[partition cached] (when `cachedOnly` flag is on) or all `RDDStorageInfos` (when `cachedOnly` flag is off).

NOTE: `cachedOnly` flag is on and therefore `rddList` gives RDDs cached only.

[NOTE]
====
`rddList` is used when:

* `StoragePage` is requested to spark-webui-StoragePage.md#render[render] itself

* `AbstractApplicationResource` is requested to handle spark-api-AbstractApplicationResource.md#storage_rdd[ storage/rdd] REST API

* `StagePagedTable` is requested to `makeDescription`
====
