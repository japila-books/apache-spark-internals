# StandaloneAppClient

## Creating Instance

`StandaloneAppClient` takes the following to be created:

* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)
* <span id="masterUrls"> Master URLs
* <span id="appDescription"> `ApplicationDescription`
* <span id="listener"> [StandaloneAppClientListener](StandaloneAppClientListener.md)
* <span id="conf"> [SparkConf](../SparkConf.md)

`StandaloneAppClient` is created when:

* `StandaloneSchedulerBackend` is requested to [start](StandaloneSchedulerBackend.md#start)

## <span id="start"> Starting

```scala
start(): Unit
```

`start` registers a [ClientEndpoint](ClientEndpoint.md) under the name **AppClient** (and saves it as the [RpcEndpointRef](#endpoint)).

`start` is used when:

* `StandaloneSchedulerBackend` is requested to [start](StandaloneSchedulerBackend.md#start)

## <span id="stop"> Stopping

```scala
stop(): Unit
```

`stop`...FIXME

`stop` is used when:

* `StandaloneSchedulerBackend` is requested to [stop](StandaloneSchedulerBackend.md#stop)
