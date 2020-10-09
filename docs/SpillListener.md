# SpillListener

`SpillListener` is a [SparkListener](SparkListener.md) that intercepts (_listens to_) the following events for detecting spills in jobs:

* [onTaskEnd](#onTaskEnd)
* [onStageCompleted](#onStageCompleted)

`SpillListener` is used for testing only.

## Creating Instance

`SpillListener` takes no input arguments to be created.

`SpillListener` is created when `TestUtils` is requested to `assertSpilled` and `assertNotSpilled`.

## <span id="onTaskEnd"> onTaskEnd Callback

```scala
onTaskEnd(
  taskEnd: SparkListenerTaskEnd): Unit
```

`onTaskEnd`...FIXME

`onTaskEnd` is part of the [SparkListener](SparkListener.md#onTaskEnd) abstraction.

## <span id="onStageCompleted"> onStageCompleted Callback

```scala
onStageCompleted(
  stageComplete: SparkListenerStageCompleted): Unit
```

`onStageCompleted`...FIXME

`onStageCompleted` is part of the [SparkListener](SparkListener.md#onStageCompleted) abstraction.
