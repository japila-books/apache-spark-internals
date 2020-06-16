= InMemoryStore

InMemoryStore is a xref:core:KVStore.adoc[].

== [[creating-instance]] Creating Instance

InMemoryStore takes no arguments when created.

InMemoryStore is created when:

* FsHistoryProvider is xref:spark-history-server:FsHistoryProvider.adoc#listing[created] and requested to xref:spark-history-server:FsHistoryProvider.adoc#createInMemoryStore[createInMemoryStore]

* AppStatusStore utility is used to xref:core:AppStatusStore.adoc#createLiveStore[create an AppStatusStore for a live Spark application]
