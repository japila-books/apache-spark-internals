= Serializer

*Serializer* is an abstraction of <<implementations, serializers>> that are intended to be used to serialize/de-serialize data in a single Spark application.

== [[implementations]] Available Serializers

[cols="30,70",options="header",width="100%"]
|===
| Serializer
| Description

| JavaSerializer
| [[JavaSerializer]]

| KryoSerializer
| [[KryoSerializer]]

|===

== [[newInstance]] newInstance Method

[source, scala]
----
newInstance(): SerializerInstance
----

newInstance...FIXME

newInstance is used when...FIXME

== [[setDefaultClassLoader]] setDefaultClassLoader Method

[source, scala]
----
setDefaultClassLoader(
  classLoader: ClassLoader): Serializer
----

setDefaultClassLoader...FIXME

setDefaultClassLoader is used when...FIXME

== [[supportsRelocationOfSerializedObjects]] supportsRelocationOfSerializedObjects Property

[source, scala]
----
supportsRelocationOfSerializedObjects: Boolean
----

supportsRelocationOfSerializedObjects should be enabled (i.e. true) only when reordering the bytes of serialized objects in serialization stream output is equivalent to having re-ordered those elements prior to serializing them.

supportsRelocationOfSerializedObjects is disabled (`false`) by default.

NOTE: `KryoSerializer` uses `autoReset` for supportsRelocationOfSerializedObjects.

NOTE: supportsRelocationOfSerializedObjects is enabled in `UnsafeRowSerializer`.
