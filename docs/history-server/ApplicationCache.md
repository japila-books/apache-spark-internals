== [[ApplicationCache]] ApplicationCache

`ApplicationCache` is...FIXME

`ApplicationCache` is <<creating-instance, created>> exclusively when `HistoryServer` is HistoryServer.md#appCache[created].

`ApplicationCache` uses https://github.com/google/guava/wiki/Release14[Google Guava 14.0.1] library for the internal <<appLoader, appLoader>>.

[[internal-registries]]
.ApplicationCache's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `appLoader`
| [[appLoader]] Google Guava's https://google.github.io/guava/releases/14.0/api/docs/com/google/common/cache/CacheLoader.html[CacheLoader] with a custom ++https://google.github.io/guava/releases/14.0/api/docs/com/google/common/cache/CacheLoader.html#load(K)++[load] which is simply <<loadApplicationEntry, loadApplicationEntry>>.

Used when...FIXME

| `removalListener`
| [[removalListener]]

| `appCache`
a| [[appCache]] Google Guava's https://google.github.io/guava/releases/14.0/api/docs/com/google/common/cache/LoadingCache.html[LoadingCache] of `CacheKey` keys and `CacheEntry` entries

Used when `ApplicationCache` is requested for the following:

* <<get, Cached UI of a Spark application>> given `appId` and `attemptId` IDs

* FIXME (other uses)

| `metrics`
| [[metrics]]
|===

=== [[creating-instance]] Creating ApplicationCache Instance

`ApplicationCache` takes the following when created:

* [[operations]] ApplicationCacheOperations.md[ApplicationCacheOperations]
* [[retainedApplications]] `retainedApplications`
* [[clock]] `Clock`

`ApplicationCache` initializes the <<internal-registries, internal registries and counters>>.

=== [[loadApplicationEntry]] `loadApplicationEntry` Internal Method

[source, scala]
----
loadApplicationEntry(appId: String, attemptId: Option[String]): CacheEntry
----

`loadApplicationEntry`...FIXME

NOTE: `loadApplicationEntry` is used exclusively when `ApplicationCache` is requested to <<load, load a cached entry>>.

=== [[load]] Loading Cached Spark Application UI -- `load` Method

[source, scala]
----
load(key: CacheKey): CacheEntry
----

NOTE: `load` is part of Google Guava's https://google.github.io/guava/releases/14.0/api/docs/com/google/common/cache/CacheLoader.html[CacheLoader] to retrieve a `CacheEntry`, based on a `CacheKey`, for <<appCache, LoadingCache>>.

`load` simply relays to <<loadApplicationEntry, loadApplicationEntry>> with the `appId` and `attemptId` of the input `CacheKey`.

=== [[get]] Requesting Cached UI of Spark Application (CacheEntry) -- `get` Method

[source, scala]
----
get(appId: String, attemptId: Option[String] = None): CacheEntry
----

`get`...FIXME

NOTE: `get` is used exclusively when `ApplicationCache` is requested to <<withSparkUI, execute a closure while holding an application's UI read lock>>.

=== [[withSparkUI]] Executing Closure While Holding Application's UI Read Lock -- `withSparkUI` Method

[source, scala]
----
withSparkUI[T](appId: String, attemptId: Option[String])(fn: SparkUI => T): T
----

`withSparkUI`...FIXME

NOTE: `withSparkUI` is used when `HistoryServer` is requested to HistoryServer.md#withSparkUI[withSparkUI] and HistoryServer.md#loadAppUi[loadAppUi].
