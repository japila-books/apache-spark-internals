# Executor

Spark applications start one or more [Executor](Executor.md)s for [executing tasks](Executor.md#launchTask).

By default (in **Static Allocation of Executors**) executors run for the entire lifetime of a Spark application (unlike in [Dynamic Allocation](../dynamic-allocation/index.md)).

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
