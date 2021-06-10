# LiveRDD

`LiveRDD` is a [LiveEntity](LiveEntity.md) that...FIXME

`LiveRDD` is <<creating-instance, created>> exclusively when `AppStatusListener` is requested to [handle onStageSubmitted event](../status/AppStatusListener.md#onStageSubmitted)

[[creating-instance]]
[[info]]
`LiveRDD` takes a storage:RDDInfo.md[RDDInfo] when created.

## <span id="doUpdate"> doUpdate

```scala
doUpdate(): Any
```

`doUpdate` is part of the [LiveEntity](LiveEntity.md#doUpdate) abstraction.

`doUpdate`...FIXME
