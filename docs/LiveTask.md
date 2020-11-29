# LiveTask

`LiveTask` is an [LiveEntity](webui/LiveEntity.md).

## Creating Instance

`LiveTask` takes the following to be created:

* <span id="info"> [TaskInfo](scheduler/TaskInfo.md)
* <span id="stageId"> Stage ID
* <span id="stageAttemptId"> Stage Attempt ID
* <span id="lastUpdateTime"> Last Update Time

`LiveTask` is created when:

* `AppStatusListener` is requested to [onTaskStart](AppStatusListener.md#onTaskStart)

## <span id="doUpdate"> doUpdate

```scala
doUpdate(): Any
```

`doUpdate`...FIXME

`doUpdate` is part of the [LiveEntity](webui/LiveEntity.md#doUpdate) abstraction.
