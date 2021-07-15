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

`KryoSerializer` initializes `useUnsafe` flag when [created](#creating-instance) based on [spark.kryo.unsafe](../configuration-properties.md#spark.kryo.unsafe) configuration property.

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
