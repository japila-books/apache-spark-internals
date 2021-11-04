# Executor

[Executor](Executor.md) is a process used for executing [Task](../scheduler/Task.md)s.

Executors _typically_ run for the entire lifetime of a Spark application which is called **static allocation of executors** (but you could also opt in for [dynamic allocation](../dynamic-allocation/index.md)).

Executors are managed by [ExecutorBackend](ExecutorBackend.md).

Executors [reports heartbeat and partial metrics for active tasks](Executor.md#startDriverHeartbeater) to the [HeartbeatReceiver RPC Endpoint](Executor.md#heartbeatReceiverRef) on the driver.

![HeartbeatReceiver's Heartbeat Message Handler](../images/executor/HeartbeatReceiver-Heartbeat.png)

Executors provide in-memory storage for `RDD`s that are cached in Spark applications (via [BlockManager](../storage/BlockManager.md)).

When started, an executor first registers itself with the driver that establishes a communication channel directly to the driver to accept tasks for execution.

![Launching tasks on executor using TaskRunners](../images/executor/executor-taskrunner-executorbackend.png)

[Executor offers](Executor.md#resource-offers) are described by executor id and the host on which an executor runs.

Executors can run multiple tasks over their lifetime, both in parallel and sequentially, and track [running tasks](Executor.md#runningTasks).

Executors use an [Executor task launch worker thread pool](Executor.md#threadPool) for [launching tasks](Executor.md#launchTask).

Executors send [metrics](Executor.md#metrics) (and heartbeats) using the [Heartbeat Sender Thread](Executor.md#heartbeater).
