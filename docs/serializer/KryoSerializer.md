# KryoSerializer

`KryoSerializer` is a [Serializer](Serializer.md) that uses the [Kryo serialization library](https://github.com/EsotericSoftware/kryo).

## Creating Instance

`KryoSerializer` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)

`KryoSerializer` is created when:

* `SerializerManager` is [created](SerializerManager.md#kryoSerializer)
* `SparkConf` is requested to [registerKryoClasses](../SparkConf.md#registerKryoClasses)
* `SerializerSupport` (Spark SQL) is requested for a [SerializerInstance](SerializerInstance.md)

## <span id="useUnsafe"> useUnsafe Flag

`KryoSerializer` uses the [spark.kryo.unsafe](../configuration-properties.md#spark.kryo.unsafe) configuration property for `useUnsafe` flag (initialized when `KryoSerializer` is [created](#creating-instance)).

`useUnsafe` is used when `KryoSerializer` is requested to create the following:

* [KryoSerializerInstance](#newInstance)
* [KryoOutput](#newKryoOutput)

## <span id="newInstance"> Creating New SerializerInstance

```scala
newInstance(): SerializerInstance
```

`newInstance` is part of the [Serializer](Serializer.md#newInstance) abstraction.

`newInstance` creates a [KryoSerializerInstance](KryoSerializerInstance.md) with this `KryoSerializer` (and the [useUnsafe](#useUnsafe) and [usePool](#usePool) flags).

## <span id="newKryoOutput"> newKryoOutput

```scala
newKryoOutput(): KryoOutput
```

`newKryoOutput`...FIXME

`newKryoOutput` is used when:

* `KryoSerializerInstance` is requested for the [output](KryoSerializerInstance.md#output)

## <span id="newKryo"> newKryo

```scala
newKryo(): Kryo
```

`newKryo`...FIXME

`newKryo` is used when:

* `KryoSerializer` is requested for a [KryoFactory](#factory)
* `KryoSerializerInstance` is requested to [borrowKryo](KryoSerializerInstance.md#borrowKryo)

## <span id="factory"> KryoFactory

```scala
factory: KryoFactory
```

`KryoSerializer` creates a `KryoFactory` lazily (on demand and once only) for [internalPool](#internalPool).

## <span id="internalPool"> KryoPool

`KryoSerializer` creates a custom `KryoPool` lazily (on demand and once only).

`KryoPool` is used when:

* [pool](#pool)
* [setDefaultClassLoader](#setDefaultClassLoader)

## <span id="supportsRelocationOfSerializedObjects"> supportsRelocationOfSerializedObjects

```scala
supportsRelocationOfSerializedObjects: Boolean
```

`supportsRelocationOfSerializedObjects` is part of the [Serializer](Serializer.md#supportsRelocationOfSerializedObjects) abstraction.

`supportsRelocationOfSerializedObjects` [creates a new SerializerInstance](#newInstance) (that is assumed to be a [KryoSerializerInstance](KryoSerializerInstance.md)) and requests it to [get the value of the autoReset field](KryoSerializerInstance.md#getAutoReset).
