# KryoSerializer

`KryoSerializer` is a [Serializer](Serializer.md) that uses the [Kryo serialization library](https://github.com/EsotericSoftware/kryo).

## Creating Instance

`KryoSerializer` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)

`KryoSerializer` is created when:

* `SerializerManager` is [created](SerializerManager.md#kryoSerializer)
* `SparkConf` is requested to [registerKryoClasses](../SparkConf.md#registerKryoClasses)
* `SerializerSupport` (Spark SQL) is requested for a [SerializerInstance](SerializerInstance.md)
