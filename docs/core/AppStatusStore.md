= AppStatusStore

AppStatusStore is...FIXME

.AppStatusStore in Spark Application
image::AppStatusStore-createLiveStore.png[align="center"]

AppStatusStore is available as xref:ROOT:SparkContext.adoc#statusStore[SparkContext.statusStore] to other Spark services.

== [[creating-instance]] Creating Instance

AppStatusStore takes the following to be created:

* [[store]] xref:core:KVStore.adoc[]
* [[listener]] Optional xref:core:AppStatusListener.adoc[] (default: `None`)

AppStatusStore is created when:

* SparkContext is xref:ROOT:spark-SparkContext-creating-instance-internals.adoc#_statusStore[created] (that triggers <<createLiveStore, creating an AppStatusStore for an active Spark application>>)

* FsHistoryProvider is requested to xref:spark-history-server:FsHistoryProvider.adoc#getAppUI[create a LoadedAppUI]

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

Internally, createLiveStore creates a xref:core:ElementTrackingStore.adoc[] (with a new xref:core:InMemoryStore.adoc[] and the input xref:ROOT:SparkConf.adoc[SparkConf]).

createLiveStore creates a xref:core:AppStatusListener.adoc[] (with the `ElementTrackingStore` created, the input `SparkConf` and the `live` flag enabled).

In the end, createLiveStore creates an <<creating-instance, AppStatusStore>> (with the `ElementTrackingStore` and `AppStatusListener` just created).

createLiveStore is used when SparkContext is xref:ROOT:spark-SparkContext-creating-instance-internals.adoc#_statusStore[created].

== [[close]] Closing AppStatusStore

[source, scala]
----
close(): Unit
----

`close` simply requests <<store, KVStore>> to xref:core:KVStore.adoc#close[close].

NOTE: `close` is used when...FIXME

== [[rddList]] `rddList` Method

[source, scala]
----
rddList(cachedOnly: Boolean = true): Seq[v1.RDDStorageInfo]
----

`rddList` requests the <<store, KVStore>> for a xref:core:KVStore.adoc#view[view] over `RDDStorageInfoWrapper` entities.

In the end, `rddList` takes `RDDStorageInfos` with at least one link:spark-webui-RDDStorageInfo.adoc#numCachedPartitions[partition cached] (when `cachedOnly` flag is on) or all `RDDStorageInfos` (when `cachedOnly` flag is off).

NOTE: `cachedOnly` flag is on and therefore `rddList` gives RDDs cached only.

[NOTE]
====
`rddList` is used when:

* `StoragePage` is requested to link:spark-webui-StoragePage.adoc#render[render] itself

* `AbstractApplicationResource` is requested to handle link:spark-api-AbstractApplicationResource.adoc#storage_rdd[ storage/rdd] REST API

* `StagePagedTable` is requested to `makeDescription`
====
