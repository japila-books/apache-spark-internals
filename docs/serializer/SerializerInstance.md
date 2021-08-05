# SerializerInstance

`SerializerInstance` is an [abstraction](#contract) of [serializer instances](#implementations) (for use by one thread at a time).

## Contract

### <span id="deserialize"> Deserializing (from ByteBuffer)

```scala
deserialize[T: ClassTag](
  bytes: ByteBuffer): T
deserialize[T: ClassTag](
  bytes: ByteBuffer,
  loader: ClassLoader): T
```

Used when:

* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run)
* `ResultTask` is requested to [run](../scheduler/ResultTask.md#runTask)
* `ShuffleMapTask` is requested to [run](../scheduler/ShuffleMapTask.md#runTask)
* `TaskResultGetter` is requested to [enqueueFailedTask](../scheduler/TaskResultGetter.md#enqueueFailedTask)
* _others_

### <span id="deserializeStream"> Deserializing (from InputStream)

```scala
deserializeStream(
  s: InputStream): DeserializationStream
```

### <span id="serialize"> Serializing (to ByteBuffer)

```scala
serialize[T: ClassTag](
  t: T): ByteBuffer
```

### <span id="serializeStream"> Serializing (to OutputStream)

```scala
serializeStream(
  s: OutputStream): SerializationStream
```

## Implementations

* [JavaSerializerInstance](JavaSerializerInstance.md)
* [KryoSerializerInstance](KryoSerializerInstance.md)
* UnsafeRowSerializerInstance ([Spark SQL]({{ book.spark_sql }}/UnsafeRowSerializerInstance))
