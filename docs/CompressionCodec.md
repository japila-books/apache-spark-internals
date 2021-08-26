# CompressionCodec

`CompressionCodec` is an abstraction of <<implementations, IO compression codecs>>.

A concrete CompressionCodec is supposed to <<createCodec, come with a constructor that accepts a single argument being SparkConf>>.

The default compression codec is configured using configuration-properties.md#spark.io.compression.codec[spark.io.compression.codec] configuration property.

== [[implementations]][[shortCompressionCodecNames]] Available CompressionCodecs

[cols="30,10m,60",options="header",width="100%"]
|===
| CompressionCodec
| Alias
| Description

| LZ4CompressionCodec
| lz4
a| [[LZ4CompressionCodec]] https://github.com/lz4/lz4-java[LZ4 compression]

* The default compression codec based on configuration-properties.md#spark.io.compression.codec[spark.io.compression.codec] configuration property

* Uses configuration-properties.md#spark.io.compression.lz4.blockSize[spark.io.compression.lz4.blockSize] configuration property for the block size

| LZFCompressionCodec
| lzf
| [[LZFCompressionCodec]] https://github.com/ning/compress[LZF compression]

| SnappyCompressionCodec
| snappy
a| [[SnappyCompressionCodec]] https://google.github.io/snappy/[Snappy compression]

* Uses configuration-properties.md#spark.io.compression.snappy.blockSize[spark.io.compression.snappy.blockSize] configuration property for the block size

| ZStdCompressionCodec
| zstd
a| [[ZStdCompressionCodec]] https://facebook.github.io/zstd/[ZStandard compression]

* configuration-properties.md#spark.io.compression.zstd.bufferSize[spark.io.compression.zstd.bufferSize] for the buffer size

* configuration-properties.md#spark.io.compression.zstd.level[spark.io.compression.zstd.level] for the compression level

|===

== [[compressedOutputStream]] Compressing Output Stream

[source,scala]
----
compressedOutputStream(
  s: OutputStream): OutputStream
----

`compressedOutputStream` is used when:

* `TorrentBroadcast` is requested to [blockifyObject](broadcast-variables/TorrentBroadcast.md#blockifyObject)

* ReliableCheckpointRDD is requested to writePartitionToCheckpointFile

* EventLoggingListener is requested to spark-history-server:EventLoggingListener.md#start[start]

* GenericAvroSerializer is requested to compress a schema

* SerializerManager is requested to serializer:SerializerManager.md#wrapForCompression[wrap an output stream of a block for compression]

* UnsafeShuffleWriter is requested to shuffle:UnsafeShuffleWriter.md#mergeSpillsWithFileStream[mergeSpillsWithFileStream]

== [[compressedInputStream]] Compressing Input Stream

[source,scala]
----
compressedInputStream(
  s: InputStream): InputStream
----

`compressedInputStream` is used when:

* `TorrentBroadcast` is requested to [unBlockifyObject](broadcast-variables/TorrentBroadcast.md#unBlockifyObject)

* ReliableCheckpointRDD is requested to readCheckpointFile

* EventLoggingListener is requested to spark-history-server:EventLoggingListener.md#openEventLog[openEventLog]

* GenericAvroSerializer is requested to decompress a schema

* SerializerManager is requested to serializer:SerializerManager.md#wrapForCompression[wrap an input stream of a block for compression]

* UnsafeShuffleWriter is requested to shuffle:UnsafeShuffleWriter.md#mergeSpillsWithFileStream[mergeSpillsWithFileStream]

== [[createCodec]] Creating CompressionCodec

[source, scala]
----
createCodec(
  conf: SparkConf): CompressionCodec
createCodec(
  conf: SparkConf,
  codecName: String): CompressionCodec
----

createCodec creates an instance of the compression codec by the given name (using a constructor that accepts a SparkConf.md[SparkConf]).

createCodec uses <<getCodecName, getCodecName>> utility to find the codec name unless specified explicitly.

createCodec finds the class name in the <<shortCompressionCodecNames, shortCompressionCodecNames>> internal lookup table or assumes that the codec name is already a fully-qualified class name.

createCodec throws an IllegalArgumentException exception if a compression codec could not be found:

[source,plaintext]
----
Codec [codecName] is not available. Consider setting spark.io.compression.codec=snappy
----

`createCodec` is used when:

* `TorrentBroadcast` is requested to [setConf](broadcast-variables/TorrentBroadcast.md#setConf)

* ReliableCheckpointRDD is requested to writePartitionToCheckpointFile and readCheckpointFile

* spark-history-server:EventLoggingListener.md[EventLoggingListener] is created and requested to spark-history-server:EventLoggingListener.md#openEventLog[openEventLog]

* GenericAvroSerializer is created

* SerializerManager is created

* UnsafeShuffleWriter is requested to shuffle:UnsafeShuffleWriter.md#mergeSpills[merge spills]

## <span id="getCodecName"> Finding Compression Codec Name

```scala
getCodecName(
  conf: SparkConf): String
```

`getCodecName` takes the name of a compression codec based on configuration-properties.md#spark.io.compression.codec[spark.io.compression.codec] configuration property (using the SparkConf.md[SparkConf]) if available or defaults to `lz4`.

`getCodecName` is used when:

* [SparkContext](SparkContext.md) is created
* CompressionCodec utility is used to [creating a CompressionCodec](#createCodec)

== [[supportsConcatenationOfSerializedStreams]] supportsConcatenationOfSerializedStreams Method

[source, scala]
----
supportsConcatenationOfSerializedStreams(
  codec: CompressionCodec): Boolean
----

supportsConcatenationOfSerializedStreams returns `true` when the given CompressionCodec is one of the <<implementations, build-in ones>>.

supportsConcatenationOfSerializedStreams is used when UnsafeShuffleWriter is requested to shuffle:UnsafeShuffleWriter.md#mergeSpills[merge spills].
