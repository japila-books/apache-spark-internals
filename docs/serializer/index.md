# Serialization System

**Serialization System** is a core component of Apache Spark with pluggable serializers for task closures and block data.

Serialization System uses [SerializerManager](SerializerManager.md) to select the [Serializer](Serializer.md) (based on [spark.serializer](../configuration-properties.md#spark.serializer) configuration property).
