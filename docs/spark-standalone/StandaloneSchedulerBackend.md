# StandaloneSchedulerBackend

`StandaloneSchedulerBackend` is a [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md).

`StandaloneSchedulerBackend` is a [StandaloneAppClientListener](StandaloneAppClientListener.md).

## Creating Instance

`StandaloneSchedulerBackend` takes the following to be created:

* <span id="scheduler"> [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md)
* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="masters"> Standalone master URLs

`StandaloneSchedulerBackend` is created when:

* `SparkContext` is requested for a [SchedulerBackend and TaskScheduler](../SparkContext.md#createTaskScheduler) (for `spark://` and `local-cluster` master URLs)

## <span id="start"> Starting SchedulerBackend

```scala
start(): Unit
```

`start` is part of the [SchedulerBackend](../scheduler/SchedulerBackend.md#start) abstraction.

`start`...FIXME

## <span id="executorDecommissioned"> executorDecommissioned

```scala
executorDecommissioned(
  fullId: String,
  decommissionInfo: ExecutorDecommissionInfo): Unit
```

`executorDecommissioned` is part of the [StandaloneAppClientListener](StandaloneAppClientListener.md#executorDecommissioned) abstraction.

`executorDecommissioned`...FIXME
