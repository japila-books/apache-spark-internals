= KVStore

*KVStore* is an <<contract, abstraction>> of <<implementations, key-value stores>>.

== [[contract]] Contract

=== [[count]] count

[source,java]
----
long count(
  Class<?> type)
long count(
  Class<?> type,
  String index,
  Object indexedValue)
----

=== [[delete]] delete

[source,java]
----
void delete(
  Class<?> type,
  Object naturalKey)
----

=== [[getMetadata]] getMetadata

[source,java]
----
T getMetadata(
  Class<T> klass)
----

=== [[read]] read

[source,java]
----
T read(
  Class<T> klass,
  Object naturalKey)
----

=== [[removeAllByIndexValues]] removeAllByIndexValues

[source,java]
----
boolean removeAllByIndexValues(
  Class<T> klass,
  String index,
  Collection<?> indexValues)
----

=== [[setMetadata]] setMetadata

[source,java]
----
void setMetadata(
  Object value)
----

=== [[view]] view

[source,java]
----
KVStoreView<T> view(
  Class<T> type)
----

=== [[write]] write

[source,java]
----
void write(
  Object value)
----

== [[implementations]] KVStores

[cols="30,70",options="header",width="100%"]
|===
| KVStore
| Description

| xref:core:ElementTrackingStore.adoc[]
| [[ElementTrackingStore]]

| xref:core:InMemoryStore.adoc[]
| [[InMemoryStore]]

| xref:core:LevelDB.adoc[]
| [[LevelDB]]

|===
