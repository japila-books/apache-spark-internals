# TransportConf

## Creating Instance

`TransportConf` takes the following to be created:

* [Module Name](#module)
* <span id="conf"> `ConfigProvider`

`TransportConf` is created when:

* `SparkTransportConf` utility is used to [fromSparkConf](SparkTransportConf.md#fromSparkConf)
* `YarnShuffleService` (Spark on YARN) is requested to `serviceInit`

## <span id="module"> Module Name

`TransportConf` is given the name of a module the transport-related configuration properties are for and is as follows (per [SparkTransportConf](SparkTransportConf.md#fromSparkConf)):

* `shuffle`
* `rpc` for [NettyRpcEnv](../rpc/NettyRpcEnv.md#transportConf)
* `files` for [NettyRpcEnv](../rpc/NettyRpcEnv.md#downloadClient)

### <span id="getModuleName"> getModuleName

```java
String getModuleName()
```

`getModuleName` returns the [module name](#module).

## <span id="getConfKey"> getConfKey

```java
String getConfKey(
  String suffix)
```

`getConfKey` creates the key of a configuration property (with the [module](#module) and the given [suffix](#suffixes)):

```text
spark.[module].[suffix]
```

## Suffixes

### <span id="SPARK_NETWORK_IO_MODE_KEY"><span id="io.mode"><span id="ioMode"> io.mode

* `nio` (default)
* `epoll`

### <span id="SPARK_NETWORK_IO_PREFERDIRECTBUFS_KEY"><span id="io.preferDirectBufs"><span id="preferDirectBufs"> io.preferDirectBufs

Controls whether Spark prefers allocating off-heap byte buffers within Netty (`true`) or not (`false`).

Default: `true`

### <span id="SPARK_NETWORK_IO_CONNECTIONTIMEOUT_KEY"><span id="io.connectionTimeout"> io.connectionTimeout

### <span id="SPARK_NETWORK_IO_CONNECTIONCREATIONTIMEOUT_KEY"><span id="io.connectionCreationTimeout"> io.connectionCreationTimeout

### <span id="SPARK_NETWORK_IO_BACKLOG_KEY"><span id="io.backLog"><span id="backLog"> io.backLog

The requested maximum length of the queue of incoming connections

Default: `-1` (no backlog)

### <span id="SPARK_NETWORK_IO_NUMCONNECTIONSPERPEER_KEY"><span id="io.numConnectionsPerPeer"> io.numConnectionsPerPeer

### <span id="SPARK_NETWORK_IO_SERVERTHREADS_KEY"><span id="io.serverThreads"> io.serverThreads

### <span id="SPARK_NETWORK_IO_CLIENTTHREADS_KEY"><span id="io.clientThreads"> io.clientThreads

### <span id="SPARK_NETWORK_IO_RECEIVEBUFFER_KEY"><span id="io.receiveBuffer"> io.receiveBuffer

### <span id="SPARK_NETWORK_IO_SENDBUFFER_KEY"><span id="io.sendBuffer"> io.sendBuffer

### <span id="SPARK_NETWORK_SASL_TIMEOUT_KEY"><span id="sasl.timeout"> sasl.timeout

### <span id="SPARK_NETWORK_IO_MAXRETRIES_KEY"><span id="io.maxRetries"> io.maxRetries

### <span id="SPARK_NETWORK_IO_RETRYWAIT_KEY"><span id="io.retryWait"> io.retryWait

### <span id="SPARK_NETWORK_IO_LAZYFD_KEY"><span id="io.lazyFD"> io.lazyFD

### <span id="SPARK_NETWORK_VERBOSE_METRICS"><span id="io.enableVerboseMetrics"> io.enableVerboseMetrics

### <span id="SPARK_NETWORK_IO_ENABLETCPKEEPALIVE_KEY"><span id="io.enableTcpKeepAlive"> io.enableTcpKeepAlive
