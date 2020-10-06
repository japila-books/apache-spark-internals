= DeserializationStream

*DeserializationStream* is an abstraction of streams for reading serialized objects.

== [[readObject]] readObject Method

[source, scala]
----
readObject[T: ClassTag](): T
----

readObject...FIXME

readObject is used when...FIXME

== [[readKey]] readKey Method

[source, scala]
----
readKey[T: ClassTag](): T
----

readKey <<readObject, reads the object>> representing the key of a key-value record.

readKey is used when...FIXME

== [[readValue]] readValue Method

[source, scala]
----
readValue[T: ClassTag](): T
----

readValue <<readObject, reads the object>> representing the value of a key-value record.

readValue is used when...FIXME

== [[asIterator]] asIterator Method

[source, scala]
----
asIterator: Iterator[Any]
----

asIterator...FIXME

asIterator is used when...FIXME

== [[asKeyValueIterator]] asKeyValueIterator Method

[source, scala]
----
asKeyValueIterator: Iterator[Any]
----

asKeyValueIterator...FIXME

asKeyValueIterator is used when...FIXME
