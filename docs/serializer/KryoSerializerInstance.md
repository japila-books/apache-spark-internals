# KryoSerializerInstance

`KryoSerializerInstance` is a [SerializerInstance](SerializerInstance.md).

## Creating Instance

`KryoSerializerInstance` takes the following to be created:

* <span id="ks"> [KryoSerializer](KryoSerializer.md)
* <span id="useUnsafe"> `useUnsafe` flag
* <span id="usePool"> `usePool` flag

`KryoSerializerInstance` is created when:

* `KryoSerializer` is requested for a [new SerializerInstance](KryoSerializer.md#newInstance)

## <span id="output"> Output

`KryoSerializerInstance` creates Kryo's `Output` lazily (on demand and once only).

`KryoSerializerInstance` requests the [KryoSerializer](#ks) for a [newKryoOutput](KryoSerializer.md#newKryoOutput).

`output` is used for [serialization](#serialize).

## <span id="serialize"> serialize

```scala
serialize[T: ClassTag](
  t: T): ByteBuffer
```

`serialize` is part of the [SerializerInstance](SerializerInstance.md#serialize) abstraction.

`serialize`...FIXME

## <span id="deserialize"> deserialize

```scala
deserialize[T: ClassTag](
  bytes: ByteBuffer): T
```

`deserialize` is part of the [SerializerInstance](SerializerInstance.md#deserialize) abstraction.

`deserialize`...FIXME

## <span id="releaseKryo"> Releasing Kryo Instance

```scala
releaseKryo(
  kryo: Kryo): Unit
```

`releaseKryo`...FIXME

`releaseKryo` is used when:

* `KryoSerializationStream` is requested to `close`
* `KryoDeserializationStream` is requested to `close`
* `KryoSerializerInstance` is requested to [serialize](#serialize) and [deserialize](#deserialize) (and [getAutoReset](#getAutoReset))

## <span id="getAutoReset"> getAutoReset

```scala
getAutoReset(): Boolean
```

`getAutoReset` uses [Java Reflection]({{ java.api }}/java.base/java/lang/reflect/package-summary.html) to access the value of the `autoReset` field of the `Kryo` class.

`getAutoReset` is used when:

* `KryoSerializer` is requested for the [supportsRelocationOfSerializedObjects](KryoSerializer.md#supportsRelocationOfSerializedObjects) flag
