# Worker

`Worker` is a logical node in a Spark Standalone cluster.

`Worker` is a standalone application that can be [launched from command line](#launching-standalone-worker).

`Worker` is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint).

## Launching Standalone Worker

`Worker` can be launched as a standalone application using [spark-class](../tools/spark-class.md).

```text
spark-class org.apache.spark.deploy.worker.Worker
```

### <span id="main"> main Entry Point

```scala
main(
  args: Array[String]): Unit
```

`main` is the entry point of `Worker` standalone application.

`main`...FIXME

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

## <span id="startRpcEnvAndEndpoint"> Starting Worker RPC Endpoint

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

`startRpcEnvAndEndpoint` creates a xref:rpc:index.md#create[RpcEnv] for the input `host` and `port`.

`startRpcEnvAndEndpoint` <<creating-instance, creates a Worker RPC endpoint>> (for the RPC environment and the input `webUiPort`, `cores`, `memory`, `masterUrls`, `workDir` and `conf`).

`startRpcEnvAndEndpoint` requests the `RpcEnv` to xref:rpc:index.md#setupEndpoint[register the Worker RPC endpoint] under the name <<ENDPOINT_NAME, Worker>>.

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

## Logging

Enable `ALL` logging level for `org.apache.spark.deploy.worker.Worker` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.deploy.worker.Worker=ALL
```

Refer to [Logging](../spark-logging.md).

## To be Reviewed

[[ENDPOINT_NAME]]
`Worker` is a xref:rpc:RpcEndpoint.md#ThreadSafeRpcEndpoint[ThreadSafeRpcEndpoint] that uses *Worker* for the RPC endpoint name when <<startRpcEnvAndEndpoint, registered>>.

[[internal-registries]]
.Worker's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[workDir]] `workDir`
| Working directory of the executors that the `Worker` manages

Initialized when `Worker` is requested to <<createWorkDir, createWorkDir>> (when `Worker` RPC Endpoint is requested to <<onStart, start>> on a RPC environment).

Used when `Worker` is requested to <<handleRegisterResponse, handleRegisterResponse>> and <<receive, receives>> a `WorkDirCleanup` message.

Used when `Worker` is requested to <<onStart, onStart>> (to create a `WorkerWebUI`), <<receive, receives>> `LaunchExecutor` or `LaunchDriver` messages.
|===
