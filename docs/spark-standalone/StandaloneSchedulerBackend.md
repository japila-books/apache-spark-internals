# StandaloneSchedulerBackend

`StandaloneSchedulerBackend` is a [CoarseGrainedSchedulerBackend](../scheduler/CoarseGrainedSchedulerBackend.md).

`StandaloneSchedulerBackend` is a `StandaloneAppClientListener`.

## Creating Instance

`StandaloneSchedulerBackend` takes the following to be created:

* <span id="scheduler"> [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md)
* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="masters"> Standalone master URLs

`StandaloneSchedulerBackend` is created when:

* FIXME

## <span id="start"> Starting SchedulerBackend

```scala
start(): Unit
```

`start` is part of the [SchedulerBackend](../scheduler/SchedulerBackend.md#start) abstraction.

`start`...FIXME
