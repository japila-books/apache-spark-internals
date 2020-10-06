== [[LiveRDD]] LiveRDD

`LiveRDD` is a spark-core-LiveEntity.md[LiveEntity] that...FIXME

`LiveRDD` is <<creating-instance, created>> exclusively when `AppStatusListener` is requested to core:AppStatusListener.md#onStageSubmitted[handle onStageSubmitted event]

[[creating-instance]]
[[info]]
`LiveRDD` takes a storage:RDDInfo.md[RDDInfo] when created.

=== [[doUpdate]] `doUpdate` Method

[source, scala]
----
doUpdate(): Any
----

NOTE: `doUpdate` is part of spark-core-LiveEntity.md#doUpdate[LiveEntity Contract] to...FIXME.

`doUpdate`...FIXME
