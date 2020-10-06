# Serialization System

**Serialization System** is a core component of Apache Spark with pluggable serializers for RDD and shuffle data.

Serialization System uses [SerializerManager](SerializerManager.md) to select the [Serializer](Serializer.md) to use (based on [spark.serializer](configuration-properties.adoc#spark.serializer) configuration property).
