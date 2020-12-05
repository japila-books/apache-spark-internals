# ExecutorData

`ExecutorData` is a metadata of an executor:

* <span id="executorEndpoint"> Executor's [RPC Endpoint](../rpc/RpcEndpointRef.md)
* <span id="executorAddress"> Executor's [RpcAddress](../rpc/RpcAddress.md)
* <span id="executorHost"> Executor's Host
* <span id="freeCores"> Executor's Free Cores
* <span id="totalCores"> Executor's Total Cores
* <span id="logUrlMap"> Executor's Log URLs (`Map[String, String]`)
* <span id="attributes"> Executor's Attributes (`Map[String, String]`)
* <span id="resourcesInfo"> Executor's Resources Info (`Map[String, ExecutorResourceInfo]`)
* <span id="resourceProfileId"> Executor's [ResourceProfile](../stage-level-scheduling/ResourceProfile.md) ID

`ExecutorData` is created for every executor registered (when `DriverEndpoint` is requested to handle a [RegisterExecutor](DriverEndpoint.md#RegisterExecutor) message).

`ExecutorData` is used by `CoarseGrainedSchedulerBackend` to track [registered executors](CoarseGrainedSchedulerBackend.md#executorDataMap).

!!! note
    `ExecutorData` is posted as part of [SparkListenerExecutorAdded](../SparkListenerEvent.md#SparkListenerExecutorAdded) event by [DriverEndpoint](DriverEndpoint.md#RegisterExecutor) every time an executor is registered.
