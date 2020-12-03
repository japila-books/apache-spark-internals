# RpcUtils

## <span id="maxMessageSizeBytes"><span id="MAX_MESSAGE_SIZE_IN_MB"> Maximum Message Size

```scala
maxMessageSizeBytes(
  conf: SparkConf): Int
```

`maxMessageSizeBytes` is the value of [spark.rpc.message.maxSize](../configuration-properties.md#spark.rpc.message.maxSize) configuration property in bytes (by multiplying the value by `1024 * 1024`).

`maxMessageSizeBytes` throws an `IllegalArgumentException` when the value is above `2047` MB:

```text
spark.rpc.message.maxSize should not be greater than 2047 MB
```

`maxMessageSizeBytes` is used when:

* `MapOutputTrackerMaster` is requested for the [maxRpcMessageSize](../scheduler/MapOutputTrackerMaster.md#maxRpcMessageSize)
* `Executor` is requested for the [maxDirectResultSize](../executor/Executor.md#maxDirectResultSize)
* `CoarseGrainedSchedulerBackend` is requested for the [maxRpcMessageSize](../scheduler/CoarseGrainedSchedulerBackend.md#maxRpcMessageSize)

## <span id="makeDriverRef"> makeDriverRef

```scala
makeDriverRef(
  name: String,
  conf: SparkConf,
  rpcEnv: RpcEnv): RpcEndpointRef
```

`makeDriverRef`...FIXME

`makeDriverRef` is used when:

* [BarrierTaskContext](../scheduler/BarrierTaskContext.md#barrierCoordinator) is created

* `SparkEnv` utility is used to [create a SparkEnv](../SparkEnv.md#create) (on executors)

* [Executor](../executor/Executor.md#heartbeatReceiverRef) is created

* `PluginContextImpl` is requested for `driverEndpoint`
