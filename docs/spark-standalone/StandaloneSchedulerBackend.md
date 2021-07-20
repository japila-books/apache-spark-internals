# StandaloneSchedulerBackend

`StandaloneSchedulerBackend` is a [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md).

## Creating Instance

`StandaloneSchedulerBackend` takes the following to be created:

* <span id="scheduler"> [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md)
* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="masters"> Standalone master URLs

`StandaloneSchedulerBackend` is created when:

* `SparkContext` is requested for a [SchedulerBackend and TaskScheduler](../SparkContext.md#createTaskScheduler) (for `spark://` and `local-cluster` master URLs)

## <span id="StandaloneAppClientListener"> StandaloneAppClientListener

`StandaloneSchedulerBackend` is a [StandaloneAppClientListener](StandaloneAppClientListener.md).

## <span id="start"> Starting SchedulerBackend

```scala
start(): Unit
```

`start` is part of the [SchedulerBackend](../scheduler/SchedulerBackend.md#start) abstraction.

`start`...FIXME

`start` creates a [StandaloneAppClient](#StandaloneAppClient) and requests it to [start](StandaloneAppClient.md#start).

`start`...FIXME

## <span id="executorDecommissioned"> executorDecommissioned

```scala
executorDecommissioned(
  fullId: String,
  decommissionInfo: ExecutorDecommissionInfo): Unit
```

`executorDecommissioned` is part of the [StandaloneAppClientListener](StandaloneAppClientListener.md#executorDecommissioned) abstraction.

`executorDecommissioned`...FIXME

## <span id="client"><span id="StandaloneAppClient"> StandaloneAppClient

`StandaloneSchedulerBackend` creates a [StandaloneAppClient](StandaloneAppClient.md) (with itself as a [StandaloneAppClientListener](#StandaloneAppClientListener)) when requested to [start](#start).

`StandaloneAppClient` is [started](StandaloneAppClient.md#start) with [StandaloneSchedulerBackend](#start).

`StandaloneAppClient` is [stopped](StandaloneAppClient.md#stop) with [StandaloneSchedulerBackend](#stop).

`StandaloneAppClient` is used for the following:

* [doRequestTotalExecutors](#doRequestTotalExecutors)
* [doKillExecutors](#doKillExecutors)
