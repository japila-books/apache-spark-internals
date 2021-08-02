# Master

`Master` is the manager of a [Spark Standalone](index.md) cluster.

`Master` can be [launched from command line](#launch).

## <span id="restServerBoundPort"><span id="restServer"><span id="restServerEnabled"> StandaloneRestServer

`Master` can start [StandaloneRestServer](StandaloneRestServer.md) when enabled using [spark.master.rest.enabled](configuration-properties.md#spark.master.rest.enabled) configuration property.

`StandaloneRestServer` is requested to [start](StandaloneRestServer.md#start) in [onStart](#onStart) and [stop](StandaloneRestServer.md#stop) in [onStop](#onStop)

## <span id="ENDPOINT_NAME"> Master RPC Endpoint

`Master` is a [ThreadSafeRpcEndpoint](../rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) and is registered under **Master** name (when [launched as a command-line application](#launch) and requested to [start up an RPC environment](#startRpcEnvAndEndpoint)).

## <span id="launch"> Launching Standalone Master

`Master` can be launched as a standalone application using [spark-class](../tools/spark-class.md).

```text
./bin/spark-class org.apache.spark.deploy.master.Master
```

### <span id="main"> main Entry Point

```scala
main(
  argStrings: Array[String]): Unit
```

`main` is the entry point of the `Master` standalone application.

`main` prints out the following INFO message to the logs:

```text
Started daemon with process name: [processName]
```

`main` registers signal handlers for `TERM`, `HUP`, `INT` signals.

`main` parses [command-line options](#options) (using `MasterArguments`) and [initializes an RpcEnv](#startRpcEnvAndEndpoint).

In the end, `main` requests the `RpcEnv` to be notified when [terminated](../rpc/RpcEnv.md#awaitTermination).

## <span id="options"> Command-Line Options

`Master` supports command-line options.

```text
Usage: Master [options]

Options:
  -i HOST, --ip HOST     Hostname to listen on (deprecated, please use --host or -h)
  -h HOST, --host HOST   Hostname to listen on
  -p PORT, --port PORT   Port to listen on (default: 7077)
  --webui-port PORT      Port for web UI (default: 8080)
  --properties-file FILE Path to a custom Spark properties file.
                         Default is conf/spark-defaults.conf.
```

### host

### ip

### port

### properties-file

### webui-port

## Creating Instance

`Master` takes the following to be created:

* <span id="rpcEnv"> [RpcEnv](../rpc/RpcEnv.md)
* <span id="address"> [RpcAddress](../rpc/RpcAddress.md)
* <span id="webUiPort"> web UI's Port
* <span id="securityMgr"> `SecurityManager`
* <span id="conf"> [SparkConf](../SparkConf.md)

`Master` is created when:

* `Master` utility is requested to [start up RPC environment](Master.md#startRpcEnvAndEndpoint)

## <span id="startRpcEnvAndEndpoint"> Starting Up RPC Environment

```scala
startRpcEnvAndEndpoint(
  host: String,
  port: Int,
  webUiPort: Int,
  conf: SparkConf): (RpcEnv, Int, Option[Int])
```

`startRpcEnvAndEndpoint` creates a [RPC Environment](../rpc/RpcEnv.md#create) with **sparkMaster** name (and the input arguments) and registers [Master](#creating-instance) endpoint with **Master** name.

In the end, `startRpcEnvAndEndpoint` sends `BoundPortsResponse` message (synchronously) to the Master endpoint and returns the [RpcEnv](../rpc/RpcEnv.md) with the ports of the [web UI](#webUi) and the [REST Server](#restServerBoundPort).

![sparkMaster - the RPC Environment for Spark Standalone's master](../images/sparkMaster-rpcenv.png)

`startRpcEnvAndEndpoint` is used when:

* `LocalSparkCluster` is requested to [start](LocalSparkCluster.md#start)
* `Master` standalone application is [launched](#main)

## <span id="spreadOutApps"> spreadOutApps

`Master` uses [spark.deploy.spreadOut](configuration-properties.md#spark.deploy.spreadOut) configuration property when requested to [startExecutorsOnWorkers](#startExecutorsOnWorkers).

## <span id="schedule"> Scheduling Resources Among Waiting Applications

```scala
schedule(): Unit
```

`schedule`...FIXME

`schedule` is used when:

* `Master` is requested to [schedule resources among waiting applications](#schedule)

### <span id="startExecutorsOnWorkers"> startExecutorsOnWorkers

```scala
startExecutorsOnWorkers(): Unit
```

`startExecutorsOnWorkers`...FIXME

## WebUI

`MasterWebUI` is the Web UI server for the standalone master. Master starts Web UI to listen to `http://[master's hostname]:webUIPort` (e.g. `http://localhost:8080`).

```text
Successfully started service 'MasterUI' on port 8080.
Started MasterWebUI at http://192.168.1.4:8080
```

## States

Master can be in the following states:

* `STANDBY` - the initial state while `Master` is initializing
* `ALIVE` - start scheduling resources among applications
* `RECOVERING`
* `COMPLETING_RECOVERY`

## <span id="LeaderElectable"> LeaderElectable

`Master` is `LeaderElectable`.

## To be Reviewed

Application ids follows the pattern `app-yyyyMMddHHmmss`.

`Master` can be <<main, started>> and stopped using link:spark-standalone-master-scripts.md[custom management scripts for standalone Master].

### REST Server

The standalone Master starts the REST Server service for alternative application submission that is supposed to work across Spark versions. It is enabled by default (see <<settings, spark.master.rest.enabled>>) and used by link:spark-submit.md[spark-submit] for the link:spark-standalone.md#deployment-modes[standalone cluster mode], i.e. `--deploy-mode` is `cluster`.

`RestSubmissionClient` is the client.

The server includes a JSON representation of `SubmitRestProtocolResponse` in the HTTP body.

The following INFOs show up when the Master Endpoint starts up (`Master#onStart` is called) with REST Server enabled:

```
INFO Utils: Successfully started service on port 6066.
INFO StandaloneRestServer: Started REST server for submitting applications on port 6066
```

### Recovery Mode

A standalone Master can run with *recovery mode* enabled and be able to recover state among the available swarm of masters. By default, there is no recovery, i.e. no persistence and no election.

NOTE: Only a master can schedule tasks so having one always on is important for cases where you want to launch new tasks. Running tasks are unaffected by the state of the master.

Master uses `spark.deploy.recoveryMode` to set up the recovery mode (see <<settings, spark.deploy.recoveryMode>>).

The Recovery Mode enables <<leader-election, election of the leader master>> among the masters.

TIP: Check out the exercise link:exercises/spark-exercise-standalone-master-ha.md[Spark Standalone - Using ZooKeeper for High-Availability of Master].

### RPC Messages

Master communicates with drivers, executors and configures itself using *RPC messages*.

The following message types are accepted by master (see `Master#receive` or `Master#receiveAndReply` methods):

* `ElectedLeader` for <<leader-election, Leader Election>>
* `CompleteRecovery`
* `RevokedLeadership`
* <<RegisterApplication, RegisterApplication>>
* `ExecutorStateChanged`
* `DriverStateChanged`
* `Heartbeat`
* `MasterChangeAcknowledged`
* `WorkerSchedulerStateResponse`
* `UnregisterApplication`
* `CheckForWorkerTimeOut`
* `RegisterWorker`
* `RequestSubmitDriver`
* `RequestKillDriver`
* `RequestDriverStatus`
* `RequestMasterState`
* `BoundPortsRequest`
* `RequestExecutors`
* `KillExecutors`

#### RegisterApplication event

A *RegisterApplication* event is sent by link:spark-standalone.md#AppClient[AppClient] to the standalone Master. The event holds information about the application being deployed (`ApplicationDescription`) and the driver's endpoint reference.

`ApplicationDescription` describes an application by its name, maximum number of cores, executor's memory, command, appUiUrl, and user with optional eventLogDir and eventLogCodec for Event Logs, and the number of cores per executor.

CAUTION: FIXME Finish

A standalone Master receives `RegisterApplication` with a `ApplicationDescription` and the driver's xref:rpc:RpcEndpointRef.md[RpcEndpointRef].

```
INFO Registering app " + description.name
```

Application ids in Spark Standalone are in the format of `app-[yyyyMMddHHmmss]-[4-digit nextAppNumber]`.

Master keeps track of the number of already-scheduled applications (`nextAppNumber`).

ApplicationDescription (AppClient) --> ApplicationInfo (Master) - application structure enrichment

`ApplicationSource` metrics + `applicationMetricsSystem`

```
INFO Registered app " + description.name + " with ID " + app.id
```

CAUTION: FIXME `persistenceEngine.addApplication(app)`

`schedule()` schedules the currently available resources among waiting apps.

FIXME When is `schedule()` method called?

It's only executed when the Master is in `RecoveryState.ALIVE` state.

Worker in `WorkerState.ALIVE` state can accept applications.

A driver has a state, i.e. `driver.state` and when it's in `DriverState.RUNNING` state the driver has been assigned to a worker for execution.

#### LaunchDriver RPC message

WARNING: It seems a dead message. Disregard it for now.

A *LaunchDriver* message is sent by an active standalone Master to a worker to launch a driver.

.Master finds a place for a driver (posts LaunchDriver)
image::spark-standalone-master-worker-LaunchDriver.png[align="center"]

You should see the following INFO in the logs right before the message is sent out to a worker:

```
INFO Launching driver [driver.id] on worker [worker.id]
```

The message holds information about the id and name of the driver.

A driver can be running on a single worker while a worker can have many drivers running.

When a worker receives a `LaunchDriver` message, it prints out the following INFO:

```
INFO Asked to launch driver [driver.id]
```

It then creates a `DriverRunner` and starts it. It starts a separate JVM process.

Workers' free memory and cores are considered when assigning some to waiting drivers (applications).

CAUTION: FIXME Go over `waitingDrivers`...

### Internals of org.apache.spark.deploy.master.Master

When `Master` starts, it first creates the xref:ROOT:SparkConf.md#default-configuration[default SparkConf configuration] whose values it then overrides using  <<environment-variables, environment variables>> and <<command-line-options, command-line options>>.

A fully-configured master instance requires `host`, `port` (default: `7077`), `webUiPort` (default: `8080`) settings defined.

TIP: When in troubles, consult link:spark-tips-and-tricks.md[Spark Tips and Tricks] document.

It starts <<rpcenv, RPC Environment>> with necessary endpoints and lives until the RPC environment terminates.

### Worker Management

Master uses `master-forward-message-thread` to schedule a thread every `spark.worker.timeout` to check workers' availability and remove timed-out workers.

It is that Master sends `CheckForWorkerTimeOut` message to itself to trigger verification.

When a worker hasn't responded for `spark.worker.timeout`, it is assumed dead and the following WARN message appears in the logs:

```
WARN Removing [worker.id] because we got no heartbeat in [spark.worker.timeout] seconds
```

### System Environment Variables

Master uses the following system environment variables (directly or indirectly):

* `SPARK_LOCAL_HOSTNAME` - the custom host name
* `SPARK_LOCAL_IP` - the custom IP to use when `SPARK_LOCAL_HOSTNAME` is not set
* `SPARK_MASTER_HOST` (not `SPARK_MASTER_IP` as used in `start-master.sh` script above!) - the master custom host
* `SPARK_MASTER_PORT` (default: `7077`) - the master custom port
* `SPARK_MASTER_IP` (default: `hostname` command's output)
* `SPARK_MASTER_WEBUI_PORT` (default: `8080`) - the port of the master's WebUI. Overriden by `spark.master.ui.port` if set in the properties file.
* `SPARK_PUBLIC_DNS` (default: hostname) - the custom master hostname for WebUI's http URL and master's address.
* `SPARK_CONF_DIR` (default: `$SPARK_HOME/conf`) - the directory of the default properties file link:spark-properties.md#spark-defaults-conf[spark-defaults.conf] from which all properties that start with `spark.` prefix are loaded.

### Settings

Master uses the following properties:

* `spark.cores.max` (default: `0`) - total expected number of cores. When set, an application could get executors of different sizes (in terms of cores).
* `spark.dead.worker.persistence` (default: `15`)
* `spark.deploy.retainedApplications` (default: `200`)
* `spark.deploy.retainedDrivers` (default: `200`)
* `spark.deploy.recoveryMode` (default: `NONE`) - possible modes: `ZOOKEEPER`, `FILESYSTEM`, or `CUSTOM`. Refer to <<recovery-mode, Recovery Mode>>.
* `spark.deploy.recoveryMode.factory` - the class name of the custom `StandaloneRecoveryModeFactory`.
* `spark.deploy.recoveryDirectory` (default: empty) - the directory to persist recovery state
* link:spark-standalone.md#spark.deploy.spreadOut[spark.deploy.spreadOut] to perform link:spark-standalone.md#round-robin-scheduling[round-robin scheduling across the nodes].
* `spark.deploy.defaultCores` (default: `Int.MaxValue`, i.e. unbounded) - the number of maxCores for applications that don't specify it.
* `spark.worker.timeout` (default: `60`) - time (in seconds) when no heartbeat from a worker means it is lost. See <<worker-management, Worker Management>>.
