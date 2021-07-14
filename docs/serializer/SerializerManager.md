# SerializerManager

`SerializerManager` is used to [select the Serializer](#getSerializer) for shuffle blocks.

## Creating Instance

`SerializerManager` takes the following to be created:

* [Default Serializer](#defaultSerializer)
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="encryptionKey"> (optional) Encryption Key (`Option[Array[Byte]]`)

`SerializerManager` is created when:

* `SparkEnv` utility is used to [create a SparkEnv](../SparkEnv.md#create) (for the driver and executors)

## <span id="defaultSerializer"> Default Serializer

`SerializerManager` is given a [Serializer](Serializer.md) when [created](#creating-instance) (based on [spark.serializer](../configuration-properties.md#spark.serializer) configuration property).

!!! tip
    Enable `DEBUG` logging level of [SparkEnv](../SparkEnv.md#logging) to be told about the selected `Serializer`.

    ```text
    Using serializer: [serializer]
    ```

## <span id="SparkEnv"> Accessing SerializerManager

`SerializerManager` is available using [SparkEnv](../SparkEnv.md#serializerManager) on the driver and executors.

```scala
import org.apache.spark.SparkEnv
SparkEnv.get.serializerManager
```

## <span id="kryoSerializer"> KryoSerializer

`SerializerManager` creates a [KryoSerializer](KryoSerializer.md) when [created](#creating-instance).

`KryoSerializer` is used as the [serializer](#getSerializer) when the type of a given key and value is [compatible with Kryo](#canUseKryo).

## <span id="canUseKryo"> Checking Whether Kryo Serializer Could Be Used

```scala
canUseKryo(
  ct: ClassTag[_]): Boolean
```

`canUseKryo` is `true` when the given `ClassTag` is a primitive, an array of primitives or a `String`. Otherwise, `canUseKryo` is `false`.

`canUseKryo` is used when:

* `SerializerManager` is requested for a [Serializer](#getSerializer)

## <span id="getSerializer"> Selecting Serializer

```scala
getSerializer(
  ct: ClassTag[_],
  autoPick: Boolean): Serializer
getSerializer(
  keyClassTag: ClassTag[_],
  valueClassTag: ClassTag[_]): Serializer
```

`getSerializer` returns the [KryoSerializer](#kryoSerializer) when the given arguments are [kryo-compatible](#canUseKryo) (and the given `autoPick` flag is `true`). Otherwise, `getSerializer` returns the [default Serializer](#defaultSerializer).

`getSerializer` is used when:

* `ShuffledRDD` is requested for [dependencies](../rdd/ShuffledRDD.md#getDependencies)
* `SerializerManager` is requested to [dataSerializeStream](#dataSerializeStream), [dataSerializeWithExplicitClassTag](#dataSerializeWithExplicitClassTag) and [dataDeserializeStream](#dataDeserializeStream)
* `SerializedValuesHolder` (of [MemoryStore](../storage/MemoryStore.md)) is requested for a `SerializationStream`

## <span id="dataSerializeStream"> dataSerializeStream

```scala
dataSerializeStream[T: ClassTag](
  blockId: BlockId,
  outputStream: OutputStream,
  values: Iterator[T]): Unit
```

`dataSerializeStream`...FIXME

`dataSerializeStream` is used when:

* `BlockManager` is requested to [doPutIterator](../storage/BlockManager.md#doPutIterator) and [dropFromMemory](../storage/BlockManager.md#dropFromMemory)

## <span id="dataSerializeWithExplicitClassTag"> dataSerializeWithExplicitClassTag

```scala
dataSerializeWithExplicitClassTag(
  blockId: BlockId,
  values: Iterator[_],
  classTag: ClassTag[_]): ChunkedByteBuffer
```

`dataSerializeWithExplicitClassTag`...FIXME

`dataSerializeWithExplicitClassTag` is used when:

* `BlockManager` is requested to [doGetLocalBytes](../storage/BlockManager.md#doGetLocalBytes)
* `SerializerManager` is requested to [dataSerialize](#dataSerialize)

## <span id="dataDeserializeStream"> dataDeserializeStream

```scala
dataDeserializeStream[T](
  blockId: BlockId,
  inputStream: InputStream)
  (classTag: ClassTag[T]): Iterator[T]
```

`dataDeserializeStream`...FIXME

`dataDeserializeStream` is used when:

* `BlockStoreUpdater` is requested to `saveDeserializedValuesToMemoryStore`
* `BlockManager` is requested to [getLocalValues](../storage/BlockManager.md#getLocalValues) and [getRemoteValues](../storage/BlockManager.md#getRemoteValues)
* `MemoryStore` is requested to [putIteratorAsBytes](../storage/MemoryStore.md#putIteratorAsBytes) (when `PartiallySerializedBlock` is requested for a `PartiallyUnrolledIterator`)
