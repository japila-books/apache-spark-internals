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
