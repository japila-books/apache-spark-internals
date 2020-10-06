= LevelDB

LevelDB is a xref:core:KVStore.adoc[].

== [[creating-instance]] Creating Instance

LevelDB takes the following to be created:

* [[path]] File
* [[serializer]] KVStoreSerializer

LevelDB is created when KVUtils utility is used to open or create a LevelDB store (for xref:spark-history-server:FsHistoryProvider.adoc[]).
