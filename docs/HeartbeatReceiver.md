# HeartbeatReceiver RPC Endpoint

`HeartbeatReceiver` is a [ThreadSafeRpcEndpoint](rpc/RpcEndpoint.md#ThreadSafeRpcEndpoint) that is registered on the driver as **HeartbeatReceiver**.

`HeartbeatReceiver` receives [Heartbeat](#Heartbeat) messages from executors for accumulator updates (with task metrics and a Spark application's accumulators) and [pass them along to TaskScheduler](scheduler/TaskScheduler.md#executorHeartbeatReceived).

![HeartbeatReceiver RPC Endpoint and Heartbeats from Executors](images/executor/HeartbeatReceiver-Heartbeat.png)

`HeartbeatReceiver` is registered immediately after a Spark application is started (i.e. when [SparkContext](SparkContext.md) is created).

`HeartbeatReceiver` is a [SparkListener](SparkListener.md) to get notified about [new executors](#onExecutorAdded) or [executors that are no longer available](#onExecutorRemoved).

## Creating Instance

`HeartbeatReceiver` takes the following to be created:

* <span id="sc"> [SparkContext](SparkContext.md)
* <span id="clock"> `Clock` (default: `SystemClock`)

`HeartbeatReceiver` is created when `SparkContext` is [created](SparkContext-creating-instance-internals.md#_heartbeatReceiver)

## <span id="scheduler"> TaskScheduler

`HeartbeatReceiver` manages a reference to [TaskScheduler](scheduler/TaskScheduler.md).

## RPC Messages

### <span id="ExecutorRemoved"> ExecutorRemoved

Attributes:

* Executor ID

Posted when `HeartbeatReceiver` is notified that an [executor is no longer available](#removeExecutor)

When received, `HeartbeatReceiver` removes the executor (from [executorLastSeen](#executorLastSeen) internal registry).

### <span id="ExecutorRegistered"> ExecutorRegistered

Attributes:

* Executor ID

Posted when `HeartbeatReceiver` is notified that a [new executor has been registered](#addExecutor)

When received, `HeartbeatReceiver` registers the executor and the current time (in [executorLastSeen](#executorLastSeen) internal registry).

### <span id="ExpireDeadHosts"> ExpireDeadHosts

No attributes

When received, `HeartbeatReceiver` prints out the following TRACE message to the logs:

```text
Checking for hosts with no recent heartbeats in HeartbeatReceiver.
```

Each executor (in [executorLastSeen](#executorLastSeen) internal registry) is checked whether the time it was last seen is not past [spark.network.timeout](#spark.network.timeout).

For any such executor, `HeartbeatReceiver` prints out the following WARN message to the logs:

```text
Removing executor [executorId] with no recent heartbeats: [time] ms exceeds timeout [timeout] ms
```

`HeartbeatReceiver` [TaskScheduler.executorLost](scheduler/TaskScheduler.md#executorLost) (with `SlaveLost("Executor heartbeat timed out after [timeout] ms"`).

`SparkContext.killAndReplaceExecutor` is asynchronously called for the executor (i.e. on [killExecutorThread](#killExecutorThread)).

The executor is removed from the [executorLastSeen](#executorLastSeen) internal registry.

### <span id="Heartbeat"> Heartbeat

Attributes:

* Executor ID
* [AccumulatorV2](accumulators/AccumulatorV2.md) updates (by task ID)
* [BlockManagerId](storage/BlockManagerId.md)
* `ExecutorMetrics` peaks (by stage and stage attempt IDs)

Posted when `Executor` [informs that it is alive and reports task metrics](executor/Executor.md#reportHeartBeat).

When received, `HeartbeatReceiver` finds the `executorId` executor (in [executorLastSeen](#executorLastSeen) internal registry).

When the executor is found, `HeartbeatReceiver` updates the time the heartbeat was received (in [executorLastSeen](#executorLastSeen) internal registry).

`HeartbeatReceiver` uses the [Clock](#clock) to know the current time.

`HeartbeatReceiver` then submits an asynchronous task to notify `TaskScheduler` that the [heartbeat was received from the executor](scheduler/TaskScheduler.md#executorHeartbeatReceived) (using [TaskScheduler](#scheduler) internal reference). `HeartbeatReceiver` posts a `HeartbeatResponse` back to the executor (with the response from `TaskScheduler` whether the executor has been registered already or not so it may eventually need to re-register).

If however the executor was not found (in [executorLastSeen](#executorLastSeen) internal registry), i.e. the executor was not registered before, you should see the following DEBUG message in the logs and the response is to notify the executor to re-register.

```text
Received heartbeat from unknown executor [executorId]
```

In a very rare case, when [TaskScheduler](#scheduler) is not yet assigned to `HeartbeatReceiver`, you should see the following WARN message in the logs and the response is to notify the executor to re-register.

```text
Dropping [heartbeat] because TaskScheduler is not ready yet
```

### <span id="TaskSchedulerIsSet"> TaskSchedulerIsSet

No attributes

Posted when `SparkContext` [informs that `TaskScheduler` is available](SparkContext-creating-instance-internals.md#TaskSchedulerIsSet).

When received, `HeartbeatReceiver` sets the internal reference to `TaskScheduler`.

## <span id="onExecutorAdded"> onExecutorAdded

```scala
onExecutorAdded(
  executorAdded: SparkListenerExecutorAdded): Unit
```

`onExecutorAdded` [sends an ExecutorRegistered message to itself](#addExecutor).

`onExecutorAdded` is part of the [SparkListener](SparkListener.md#onExecutorAdded) abstraction.

### <span id="addExecutor"> addExecutor

```scala
addExecutor(
  executorId: String): Option[Future[Boolean]]
```

`addExecutor`...FIXME

## <span id="onExecutorRemoved"> onExecutorRemoved

```scala
onExecutorRemoved(
  executorRemoved: SparkListenerExecutorRemoved): Unit
```

`onExecutorRemoved` [removes the executor](#removeExecutor).

`onExecutorRemoved` is part of the [SparkListener](SparkListener.md#onExecutorRemoved) abstraction.

### <span id="removeExecutor"> removeExecutor

```scala
removeExecutor(
  executorId: String): Option[Future[Boolean]]
```

`removeExecutor`...FIXME

## <span id="onStart"> Starting HeartbeatReceiver

```scala
onStart(): Unit
```

`onStart` sends a blocking [ExpireDeadHosts](#ExpireDeadHosts) every [spark.network.timeoutInterval](configuration-properties.md#spark.network.timeoutInterval) on [eventLoopThread](#eventLoopThread).

`onStart` is part of the [RpcEndpoint](rpc/RpcEndpoint.md#onStart) abstraction.

## <span id="onStop"> Stopping HeartbeatReceiver

```scala
onStop(): Unit
```

`onStop` shuts down the [eventLoopThread](#eventLoopThread) and [killExecutorThread](#killExecutorThread) thread pools.

`onStop` is part of the [RpcEndpoint](rpc/RpcEndpoint.md#onStop) abstraction.

## <span id="receiveAndReply"> Handling Two-Way Messages

```scala
receiveAndReply(
  context: RpcCallContext): PartialFunction[Any, Unit]
```

`receiveAndReply`...FIXME

`receiveAndReply` is part of the [RpcEndpoint](rpc/RpcEndpoint.md#receiveAndReply) abstraction.

## Thread Pools

### <span id="killExecutorThread"><span id="kill-executor-thread"> kill-executor-thread

`killExecutorThread` is a daemon [ScheduledThreadPoolExecutor]({{ java.api }}/java.base/java/util/concurrent/ScheduledThreadPoolExecutor.html) with a single thread.

The name of the thread pool is **kill-executor-thread**.

### <span id="eventLoopThread"><span id="heartbeat-receiver-event-loop-thread"> heartbeat-receiver-event-loop-thread

`eventLoopThread` is a daemon [ScheduledThreadPoolExecutor]({{ java.api }}/java.base/java/util/concurrent/ScheduledThreadPoolExecutor.html) with a single thread.

The name of the thread pool is **heartbeat-receiver-event-loop-thread**.

## <span id="expireDeadHosts"> Expiring Dead Hosts

```scala
expireDeadHosts(): Unit
```

`expireDeadHosts`...FIXME

`expireDeadHosts` is used when `HeartbeatReceiver` is requested to [receives an ExpireDeadHosts message](#receiveAndReply).

## Logging

Enable `ALL` logging level for `org.apache.spark.HeartbeatReceiver` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```text
log4j.logger.org.apache.spark.HeartbeatReceiver=ALL
```

Refer to [Logging](spark-logging.md).
