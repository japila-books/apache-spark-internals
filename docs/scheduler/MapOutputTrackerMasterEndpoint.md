# MapOutputTrackerMasterEndpoint

`MapOutputTrackerMasterEndpoint` is an [RpcEndpoint](../rpc/RpcEndpoint.md) for [MapOutputTrackerMaster](MapOutputTrackerMaster.md).

`MapOutputTrackerMasterEndpoint` is registered under the name of **MapOutputTracker** (on the [driver](../SparkEnv.md#create)).

## Creating Instance

`MapOutputTrackerMasterEndpoint` takes the following to be created:

* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)
* <span id="tracker"> [MapOutputTrackerMaster](MapOutputTrackerMaster.md)
* <span id="conf"> [SparkConf](../SparkConf.md)

`MapOutputTrackerMasterEndpoint` is created when:

* `SparkEnv` is [created](../SparkEnv.md#create) (for the driver and executors)

While being created, `MapOutputTrackerMasterEndpoint` prints out the following DEBUG message to the logs:

```text
init
```

## <span id="receiveAndReply"><span id="messages"> Messages

### <span id="GetMapOutputStatuses"> GetMapOutputStatuses

```scala
GetMapOutputStatuses(
  shuffleId: Int)
```

Posted when `MapOutputTrackerWorker` is requested for [shuffle map outputs for a given shuffle ID](MapOutputTrackerWorker.md#getStatuses)

When received, `MapOutputTrackerMasterEndpoint` prints out the following INFO message to the logs:

```text
Asked to send map output locations for shuffle [shuffleId] to [hostPort]
```

In the end, `MapOutputTrackerMasterEndpoint` requests the [MapOutputTrackerMaster](#tracker) to [post](MapOutputTrackerMaster.md#post) a `GetMapOutputMessage` (with the input `shuffleId`). Whatever is returned from `MapOutputTrackerMaster` becomes the response.

### <span id="StopMapOutputTracker"> StopMapOutputTracker

Posted when `MapOutputTrackerMaster` is requested to [stop](MapOutputTrackerMaster.md#stop).

When received, `MapOutputTrackerMasterEndpoint` prints out the following INFO message to the logs:

```text
MapOutputTrackerMasterEndpoint stopped!
```

`MapOutputTrackerMasterEndpoint` confirms the request (by replying `true`) and [stops](../rpc/RpcEndpoint.md#stop).

## Logging

Enable `ALL` logging level for `org.apache.spark.MapOutputTrackerMasterEndpoint` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.MapOutputTrackerMasterEndpoint=ALL
```

Refer to [Logging](../spark-logging.md).
