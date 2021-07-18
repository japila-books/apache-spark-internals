# BlockManagerStorageEndpoint

`BlockManagerStorageEndpoint` is an [IsolatedRpcEndpoint](../rpc/RpcEndpoint.md#IsolatedRpcEndpoint).

## Creating Instance

`BlockManagerStorageEndpoint` takes the following to be created:

* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)
* <span id="blockManager"> [BlockManager](BlockManager.md)
* <span id="mapOutputTracker"> [MapOutputTracker](../scheduler/MapOutputTracker.md)

`BlockManagerStorageEndpoint` is created when:

* `BlockManager` is [created](BlockManager.md#storageEndpoint)

## Messages

### <span id="DecommissionBlockManager"> DecommissionBlockManager

When received, `receiveAndReply` requests the [BlockManager](#blockManager) to [decommissionSelf](BlockManager.md#decommissionSelf).

`DecommissionBlockManager` is sent out when `BlockManager` is requested to [decommissionBlockManager](BlockManager.md#decommissionBlockManager).
