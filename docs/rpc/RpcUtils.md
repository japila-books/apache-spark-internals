= RpcUtils

RpcUtils is an utility for...FIXME

== [[makeDriverRef]] makeDriverRef Method

[source,scala]
----
makeDriverRef(
  name: String,
  conf: SparkConf,
  rpcEnv: RpcEnv): RpcEndpointRef
----

makeDriverRef...FIXME

makeDriverRef is used when:

* scheduler:spark-BarrierTaskContext.md#barrierCoordinator[BarrierTaskContext] is created

* SparkEnv utility is used to core:SparkEnv.md#create[create a SparkEnv] (on executors)

* executor:Executor.md#heartbeatReceiverRef[Executor] is created
