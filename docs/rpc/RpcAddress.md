# RpcAddress

`RpcAddress` is a logical address of an RPC system, with hostname and port.

`RpcAddress` can be encoded as a **Spark URL** in the format of `spark://host:port`.

## Creating Instance

`RpcAddress` takes the following to be created:

* <span id="host"> Host
* <span id="port"> Port

## <span id="fromSparkURL"> Creating RpcAddress based on Spark URL

```scala
fromSparkURL(
  sparkUrl: String): RpcAddress
```

`fromSparkURL` [extract a host and a port](../Utils.md#extractHostPortFromSparkUrl) from the input Spark URL and creates an [RpcAddress](#creating-instance).

`fromSparkURL` is used when:

* `StandaloneAppClient` (Spark Standalone) is created
* `ClientApp` (Spark Standalone) is requested to `start`
* `Worker` (Spark Standalone) is requested to `startRpcEnvAndEndpoint`
