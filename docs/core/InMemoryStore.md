= InMemoryStore

InMemoryStore is a core:KVStore.md[].

== [[creating-instance]] Creating Instance

InMemoryStore takes no arguments when created.

InMemoryStore is created when:

* FsHistoryProvider is spark-history-server:FsHistoryProvider.md#listing[created] and requested to spark-history-server:FsHistoryProvider.md#createInMemoryStore[createInMemoryStore]

* AppStatusStore utility is used to core:AppStatusStore.md#createLiveStore[create an AppStatusStore for a live Spark application]
