# BlockManagerMaster

`BlockManagerMaster` runs on the driver and executors to exchange block metadata (status and locations) in a Spark application.

`BlockManagerMaster` uses [BlockManagerMasterEndpoint](BlockManagerMasterEndpoint.md) (registered as **BlockManagerMaster** RPC endpoint on the driver with the endpoint references on executors) for executors to send block status updates and so let the driver keep track of block status and locations.

## Creating Instance

`BlockManagerMaster` takes the following to be created:

* [Driver Endpoint](#driverEndpoint)
* [Heartbeat Endpoint](#driverHeartbeatEndPoint)
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="isDriver"> `isDriver` flag (whether it is created for the driver or executors)

`BlockManagerMaster` is created when:

* `SparkEnv` utility is used to [create a SparkEnv](../SparkEnv.md#create) (and create a [BlockManager](BlockManager.md))

### <span id="driverEndpoint"> Driver Endpoint

`BlockManagerMaster` is given a [RpcEndpointRef](../rpc/RpcEndpointRef.md) of the [BlockManagerMaster RPC Endpoint](BlockManagerMasterEndpoint.md) (on the driver) when [created](#creating-instance).

### <span id="driverHeartbeatEndPoint"> Heartbeat Endpoint

`BlockManagerMaster` is given a [RpcEndpointRef](../rpc/RpcEndpointRef.md) of the [BlockManagerMasterHeartbeat RPC Endpoint](BlockManagerMasterHeartbeatEndpoint.md) (on the driver) when [created](#creating-instance).

The endpoint is used (mainly) when:

* `DAGScheduler` is requested to [executorHeartbeatReceived](../scheduler/DAGScheduler.md#executorHeartbeatReceived)

## <span id="registerBlockManager"> Registering BlockManager (on Executor) with Driver

```scala
registerBlockManager(
  id: BlockManagerId,
  localDirs: Array[String],
  maxOnHeapMemSize: Long,
  maxOffHeapMemSize: Long,
  storageEndpoint: RpcEndpointRef): BlockManagerId
```

`registerBlockManager` prints out the following INFO message to the logs (with the given [BlockManagerId](BlockManagerId.md)):

```text
Registering BlockManager [id]
```

![Registering BlockManager with the Driver](../images/storage/BlockManagerMaster-RegisterBlockManager.png)

`registerBlockManager` notifies the driver (using the [BlockManagerMaster RPC endpoint](#driverEndpoint)) that the [BlockManagerId](BlockManagerId.md) wants to register (and [sends](../rpc/RpcEndpointRef.md#askSync) a blocking [RegisterBlockManager](BlockManagerMasterEndpoint.md#RegisterBlockManager) message).

!!! note
    The input `maxMemSize` is the [total available on-heap and off-heap memory for storage](BlockManager.md#maxMemory) on the `BlockManager`.

`registerBlockManager` waits until a confirmation comes (as a possibly-updated [BlockManagerId](BlockManagerId.md)).

In the end, `registerBlockManager` prints out the following INFO message to the logs and returns the [BlockManagerId](BlockManagerId.md) received.

```text
Registered BlockManager [updatedId]
```

`registerBlockManager` is used when:

* `BlockManager` is requested to [initialize](BlockManager.md#initialize) and [reregister](BlockManager.md#reregister)
* `FallbackStorage` utility is used to [registerBlockManagerIfNeeded](FallbackStorage.md#registerBlockManagerIfNeeded)

## <span id="getLocations-blockid"> Finding Block Locations for Single Block

```scala
getLocations(
  blockId: BlockId): Seq[BlockManagerId]
```

`getLocations` requests the driver (using the [BlockManagerMaster RPC endpoint](#driverEndpoint)) for [BlockManagerId](BlockManagerId.md)s of the given [BlockId](BlockId.md) (and [sends](../rpc/RpcEndpointRef.md#askSync) a blocking [GetLocations](BlockManagerMasterEndpoint.md#GetLocations) message).

`getLocations` is used when:

* `BlockManager` is requested to [fetchRemoteManagedBuffer](BlockManager.md#fetchRemoteManagedBuffer)
* `BlockManagerMaster` is requested to [contains a BlockId](BlockManagerMaster.md#contains)

## <span id="getLocations-array-blockid"> Finding Block Locations for Multiple Blocks

```scala
getLocations(
  blockIds: Array[BlockId]): IndexedSeq[Seq[BlockManagerId]]
```

`getLocations` requests the driver (using the [BlockManagerMaster RPC endpoint](#driverEndpoint)) for [BlockManagerId](BlockManagerId.md)s of the given [BlockId](BlockId.md)s (and [sends](../rpc/RpcEndpointRef.md#askSync) a blocking [GetLocationsMultipleBlockIds](BlockManagerMasterEndpoint.md#GetLocationsMultipleBlockIds) message).

`getLocations` is used when:

* `DAGScheduler` is requested for [BlockManagers (executors) for cached RDD partitions](../scheduler/DAGScheduler.md#getCacheLocs)
* `BlockManager` is requested to [getLocationBlockIds](BlockManager.md#getLocationBlockIds)
* `BlockManager` utility is used to [blockIdsToLocations](BlockManager.md#blockIdsToLocations)

## <span id="contains"> contains

```scala
contains(
  blockId: BlockId): Boolean
```

`contains` is positive (`true`) when there is at least one [executor](#getLocations) with the given [BlockId](BlockId.md).

`contains` is used when:

* `LocalRDDCheckpointData` is requested to [doCheckpoint](../rdd/LocalRDDCheckpointData.md#doCheckpoint)

## Logging

Enable `ALL` logging level for `org.apache.spark.storage.BlockManagerMaster` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.storage.BlockManagerMaster=ALL
```

Refer to [Logging](../spark-logging.md).
