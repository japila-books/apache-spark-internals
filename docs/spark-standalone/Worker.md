# Worker

`Worker` is a logical worker node in a Spark Standalone cluster.

`Worker` can be [launched from command line](#launch).

## <span id="ENDPOINT_NAME"> Worker RPC Endpoint

`Worker` is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) and is registered under **Worker** name (when [launched as a command-line application](#launch) and requested to [set up an RPC environment](#startRpcEnvAndEndpoint)).

## <span id="launch"> Launching Standalone Worker

`Worker` can be launched as a standalone application using [spark-class](../tools/spark-class.md).

```text
./bin/spark-class org.apache.spark.deploy.worker.Worker
```

!!! note
    At least one [master URL](#master) is required.

### <span id="main"> main Entry Point

```scala
main(
  args: Array[String]): Unit
```

`main` is the entry point of `Worker` standalone application.

`main` prints out the following INFO message to the logs:

```text
Started daemon with process name: [processName]
```

`main` registers signal handlers for `TERM`, `HUP`, `INT` signals.

`main` parses [command-line options](#options) (using `WorkerArguments`) and [initializes an RpcEnv](#startRpcEnvAndEndpoint).

`main` asserts that:

1. [External shuffle service](../external-shuffle-service/index.md) is not used (based on [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property)
1. Number of worker instances is `1` (based on `SPARK_WORKER_INSTANCES` environment variable)

`main` throws an `IllegalArgumentException` when the above does not hold:

```text
Starting multiple workers on one host is failed because we may launch no more than one external shuffle service on each host, please set spark.shuffle.service.enabled to false or set SPARK_WORKER_INSTANCES to 1 to resolve the conflict.
```

In the end, `main` requests the `RpcEnv` to be notified when [terminated](../rpc/RpcEnv.md#awaitTermination).

## <span id="options"> Command-Line Options

`Worker` supports command-line options.

```text
Usage: Worker [options] <master>

Master must be a URL of the form spark://hostname:port

Options:
  -c CORES, --cores CORES  Number of cores to use
  -m MEM, --memory MEM     Amount of memory to use (e.g. 1000M, 2G)
  -d DIR, --work-dir DIR   Directory to run apps in (default: SPARK_HOME/work)
  -i HOST, --ip IP         Hostname to listen on (deprecated, please use --host or -h)
  -h HOST, --host HOST     Hostname to listen on
  -p PORT, --port PORT     Port to listen on (default: random)
  --webui-port PORT        Port for web UI (default: 8081)
  --properties-file FILE   Path to a custom Spark properties file.
                           Default is conf/spark-defaults.conf.
```

### cores

### host

### ip

### <span id="master"><span id="masters"> Master URLs

**(required)** Comma-separated standalone Master's URLs in the form:

```text
spark://host1:port1,host2:port2,...
```

### memory

### port

### properties-file

### webui-port

### work-dir

## Creating Instance

`Worker` takes the following to be created:

* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)
* <span id="webUiPort"> web UI's Port
* <span id="cores"> Number of CPU cores
* <span id="memory"> Memory
* <span id="masterRpcAddresses"> [RpcAddress](../rpc/RpcAddress.md)es of [Master](Master.md)s
* <span id="endpointName"> Endpoint Name
* <span id="workDirPath"> Work Dir Path (default: `null`)
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="securityMgr"> `SecurityManager`
* <span id="resourceFileOpt"> Optional Resource File (default: (undefined))
* <span id="externalShuffleServiceSupplier"> Supplier of [ExternalShuffleService](../external-shuffle-service/ExternalShuffleService.md) (default: `null`)

`Worker` is created when:

* `Worker` utility is requested to [startRpcEnvAndEndpoint](Worker.md#startRpcEnvAndEndpoint)

## <span id="shuffleService"> ExternalShuffleService

`Worker` initializes an [ExternalShuffleService](../external-shuffle-service/ExternalShuffleService.md) (directly or indirectly using a [Supplier](#externalShuffleServiceSupplier) if given).

`ExternalShuffleService` is [started](../external-shuffle-service/ExternalShuffleService.md#startIfEnabled) when `Worker` is requested to [startExternalShuffleService](#startExternalShuffleService).

`ExternalShuffleService` is used as follows:

* Informed about an [application removed](../external-shuffle-service/ExternalShuffleService.md#applicationRemoved) when `Worker` handles a [WorkDirCleanup](#WorkDirCleanup) message or [maybeCleanupApplication](#maybeCleanupApplication)

* Informed about an [executor removed](../external-shuffle-service/ExternalShuffleService.md#executorRemoved) when `Worker` is requested to [handleExecutorStateChanged](#handleExecutorStateChanged)

`ExternalShuffleService` is [stopped](../external-shuffle-service/ExternalShuffleService.md#stop) when `Worker` is requested to [stop](#stop).

## <span id="startRpcEnvAndEndpoint"> Starting Up RPC Environment

```scala
startRpcEnvAndEndpoint(
  host: String,
  port: Int,
  webUiPort: Int,
  cores: Int,
  memory: Int,
  masterUrls: Array[String],
  workDir: String,
  workerNumber: Option[Int] = None,
  conf: SparkConf = new SparkConf,
  resourceFileOpt: Option[String] = None): RpcEnv
```

`startRpcEnvAndEndpoint` creates an [RpcEnv](../rpc/RpcEnv.md#create) with the name `sparkWorker` and the given `host` and `port`.

`startRpcEnvAndEndpoint` [translates the given masterUrls to RpcAddresses](../rpc/RpcAddress.md#fromSparkURL).

`startRpcEnvAndEndpoint` creates a [Worker](#creating-instance) and requests the `RpcEnv` to [set it up as an RPC endpoint](../rpc/RpcEnv.md#setupEndpoint) under the [Worker](#ENDPOINT_NAME) name.

`startRpcEnvAndEndpoint` is used when:

* `LocalSparkCluster` is requested to [start](LocalSparkCluster.md#start)
* `Worker` standalone application is [launched](#main)

## <span id="onStart"> onStart

```scala
onStart(): Unit
```

`onStart` is part of the [RpcEndpoint](../rpc/RpcEndpoint.md#onStart) abstraction.

`onStart`...FIXME

### <span id="createWorkDir"> Creating Work Directory

```scala
createWorkDir(): Unit
```

`createWorkDir` sets <<workDir, workDir>> to be either <<workDirPath, workDirPath>> if defined or <<sparkHome, sparkHome>> with `work` subdirectory.

In the end, `createWorkDir` creates <<workDir, workDir>> directory (including any necessary but nonexistent parent directories).

`createWorkDir` reports...FIXME

## Messages

### <span id="ApplicationFinished"> ApplicationFinished

### <span id="DriverStateChanged"> DriverStateChanged

### <span id="ExecutorStateChanged"> ExecutorStateChanged

```scala
ExecutorStateChanged(
  appId: String,
  execId: Int,
  state: ExecutorState,
  message: Option[String],
  exitStatus: Option[Int])
```

Message Handler: [handleExecutorStateChanged](#handleExecutorStateChanged)

Posted when:

* `ExecutorRunner` is requested to [killProcess](ExecutorRunner.md#killProcess) and [fetchAndRunExecutor](ExecutorRunner.md#fetchAndRunExecutor)

### <span id="KillDriver"> KillDriver

### <span id="KillExecutor"> KillExecutor

### <span id="LaunchDriver"> LaunchDriver

### <span id="LaunchExecutor"> LaunchExecutor

### <span id="MasterChanged"> MasterChanged

### <span id="ReconnectWorker"> ReconnectWorker

### <span id="RegisterWorkerResponse"> RegisterWorkerResponse

### <span id="ReregisterWithMaster"> ReregisterWithMaster

### <span id="RequestWorkerState"> RequestWorkerState

### <span id="SendHeartbeat"> SendHeartbeat

### <span id="WorkDirCleanup"> WorkDirCleanup

## <span id="handleExecutorStateChanged"> handleExecutorStateChanged

```scala
handleExecutorStateChanged(
  executorStateChanged: ExecutorStateChanged): Unit
```

`handleExecutorStateChanged`...FIXME

`handleExecutorStateChanged` is used when:

* `Worker` is requested to handle [ExecutorStateChanged](#ExecutorStateChanged) message

## <span id="maybeCleanupApplication"> maybeCleanupApplication

```scala
maybeCleanupApplication(
  id: String): Unit
```

`maybeCleanupApplication`...FIXME

`maybeCleanupApplication` is used when:

* `Worker` is requested to [handle a ApplicationFinished message](#ApplicationFinished) and [handleExecutorStateChanged](#handleExecutorStateChanged)

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.worker.Worker` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.worker.Worker=ALL
```

Refer to [Logging](../spark-logging.md).
