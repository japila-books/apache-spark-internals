== [[BaseAppResource]] BaseAppResource

`BaseAppResource` is the contract of link:spark-api-ApiRequestContext.adoc[ApiRequestContexts] that can <<withUI, withUI>> and use <<appId, appId>> and <<attemptId, attemptId>> path parameters in URI paths.

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

| link:spark-api-AbstractApplicationResource.adoc[AbstractApplicationResource]
| [[AbstractApplicationResource]]

| `BaseStreamingAppResource`
| [[BaseStreamingAppResource]]

| link:spark-api-StagesResource.adoc[StagesResource]
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
