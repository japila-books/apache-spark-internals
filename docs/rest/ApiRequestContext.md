== [[ApiRequestContext]] ApiRequestContext

`ApiRequestContext` is the <<contract, contract>> of...FIXME

[[contract]]
[source, scala]
----
package org.apache.spark.status.api.v1

trait ApiRequestContext {
  // only required methods that have no implementation
  // the others follow
  @Context
  var servletContext: ServletContext = _

  @Context
  var httpRequest: HttpServletRequest = _
}
----

NOTE: `ApiRequestContext` is a `private[v1]` contract.

.ApiRequestContext Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `httpRequest`
| [[httpRequest]] Java Servlets' `HttpServletRequest`

Used when...FIXME

| `servletContext`
| [[servletContext]] Java Servlets' `ServletContext`

Used when...FIXME
|===

[[implementations]]
.ApiRequestContexts
[cols="1,2",options="header",width="100%"]
|===
| ApiRequestContext
| Description

| link:spark-api-ApiRootResource.adoc[ApiRootResource]
| [[ApiRootResource]]

| `ApiStreamingApp`
| [[ApiStreamingApp]]

| link:spark-api-ApplicationListResource.adoc[ApplicationListResource]
| [[ApplicationListResource]]

| link:spark-api-BaseAppResource.adoc[BaseAppResource]
| [[BaseAppResource]]

| `SecurityFilter`
| [[SecurityFilter]]
|===

=== [[uiRoot]] Getting Current UIRoot -- `uiRoot` Method

[source, scala]
----
uiRoot: UIRoot
----

`uiRoot` simply requests `UIRootFromServletContext` to link:spark-api-UIRootFromServletContext.adoc#getUiRoot[get the current UIRoot] (for the given <<servletContext, servletContext>>).

NOTE: `uiRoot` is used when...FIXME
