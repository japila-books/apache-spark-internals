== [[BaseAppResource]] BaseAppResource

`BaseAppResource` is the contract of spark-api-ApiRequestContext.md[ApiRequestContexts] that can <<withUI, withUI>> and use <<appId, appId>> and <<attemptId, attemptId>> path parameters in URI paths.

[[path-params]]
.BaseAppResource's Path Parameters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `appId`
| [[appId]] `@PathParam("appId")`

Used when...FIXME

| `attemptId`
| [[attemptId]] `@PathParam("attemptId")`

Used when...FIXME
|===

[[implementations]]
.BaseAppResources
[cols="1,2",options="header",width="100%"]
|===
| BaseAppResource
| Description

| spark-api-AbstractApplicationResource.md[AbstractApplicationResource]
| [[AbstractApplicationResource]]

| `BaseStreamingAppResource`
| [[BaseStreamingAppResource]]

| spark-api-StagesResource.md[StagesResource]
| [[StagesResource]]
|===

NOTE: `BaseAppResource` is a `private[v1]` contract.

=== [[withUI]] `withUI` Method

[source, scala]
----
withUI[T](fn: SparkUI => T): T
----

`withUI`...FIXME

NOTE: `withUI` is used when...FIXME
