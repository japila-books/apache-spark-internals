# SparkTransportConf Utility

## <span id="fromSparkConf"> fromSparkConf

```scala
fromSparkConf(
  _conf: SparkConf,
  module: String, // (1)
  numUsableCores: Int = 0,
  role: Option[String] = None): TransportConf // (2)
```

1. The given `module` is `shuffle` most of the time except:
    * `rpc` for [NettyRpcEnv](../rpc/NettyRpcEnv.md#transportConf)
    * `files` for [NettyRpcEnv](../rpc/NettyRpcEnv.md#downloadClient)
2. Only defined in [NettyRpcEnv](../rpc/NettyRpcEnv.md#role) to be either `driver` or `executor`

`fromSparkConf` makes a copy (_clones_) the given [SparkConf](../SparkConf.md).

`fromSparkConf` sets the following configuration properties (for the given `module`):

* `spark.[module].io.serverThreads`
* `spark.[module].io.clientThreads`

The values are taken using the following properties in the order and until one is found (with `suffix` being `serverThreads` or `clientThreads`, respectively):

1. `spark.[role].[module].io.[suffix]`
1. `spark.[module].io.[suffix]`

Unless found, `fromSparkConf` defaults to the default number of threads (based on the given `numUsableCores` and not more than `8`).

In the end, `fromSparkConf` creates a [TransportConf](TransportConf.md) (for the given `module` and the updated `SparkConf`).

`fromSparkConf` is used when:

* `SparkEnv` utility is used to [create a SparkEnv](../SparkEnv.md#create) (with the [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property enabled)
* `ExternalShuffleService` is [created](../external-shuffle-service/ExternalShuffleService.md#transportConf)
* `NettyBlockTransferService` is requested to [init](../storage/NettyBlockTransferService.md#transportConf)
* `NettyRpcEnv` is [created](../rpc/NettyRpcEnv.md#transportConf) and requested for a [downloadClient](../rpc/NettyRpcEnv.md#downloadClient)
* `IndexShuffleBlockResolver` is [created](../shuffle/IndexShuffleBlockResolver.md#transportConf)
* `ShuffleBlockPusher` is requested to [initiateBlockPush](../shuffle/ShuffleBlockPusher.md#initiateBlockPush)
* `BlockManager` is requested to [readDiskBlockFromSameHostExecutor](../storage/BlockManager.md#readDiskBlockFromSameHostExecutor)
