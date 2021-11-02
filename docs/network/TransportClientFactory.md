# TransportClientFactory

## Creating Instance

`TransportClientFactory` takes the following to be created:

* <span id="context"> [TransportContext](TransportContext.md)
* <span id="clientBootstraps"> `TransportClientBootstrap`s

`TransportClientFactory` is created when:

* `TransportContext` is requested for a [TransportClientFactory](TransportContext.md#createClientFactory)

## Configuration Properties

While being [created](#creating-instance), `TransportClientFactory` requests the given [TransportContext](#context) for the [TransportConf](TransportContext.md#getConf) that is used to access the values of the following (configuration) properties:

* [io.numConnectionsPerPeer](TransportConf.md#numConnectionsPerPeer)
* [io.mode](TransportConf.md#ioMode)
* [io.mode](TransportConf.md#clientThreads)
* [io.preferDirectBufs](TransportConf.md#preferDirectBufs)
* [io.retryWait](TransportConf.md#ioRetryWaitTimeMs)
* [spark.network.sharedByteBufAllocators.enabled](TransportConf.md#sharedByteBufAllocators)
* [spark.network.io.preferDirectBufs](TransportConf.md#preferDirectBufsForSharedByteBufAllocators)
* [Module Name](TransportConf.md#getModuleName)

## <span id="createClient"> Creating TransportClient

```java
TransportClient createClient(
  String remoteHost,
  int remotePort) // (1)
TransportClient createClient(
  String remoteHost,
  int remotePort,
  boolean fastFail)
TransportClient createClient(
  InetSocketAddress address)
```

1. Turns `fastFail` off

`createClient` prints out the following DEBUG message to the logs:

```text
Creating new connection to [address]
```

`createClient` creates a Netty `Bootstrap` and initializes it.

`createClient` requests the Netty `Bootstrap` to connect.

If successful, `createClient` prints out the following DEBUG message and requests the [TransportClientBootstraps](#clientBootstraps) to `doBootstrap`.

```text
Connection to [address] successful, running bootstraps...
```

In the end, `createClient` prints out the following INFO message:

```text
Successfully created connection to [address] after [t] ms ([t] ms spent in bootstraps)
```
