== [[UIRoot]] UIRoot -- Contract for Root Contrainers of Application UI Information

`UIRoot` is the <<contract, contract>> of the <<implementations, root containers for application UI information>>.

[[contract]]
[source, scala]
----
package org.apache.spark.status.api.v1

trait UIRoot {
  // only required methods that have no implementation
  // the others follow
  def withSparkUI[T](appId: String, attemptId: Option[String])(fn: SparkUI => T): T
  def getApplicationInfoList: Iterator[ApplicationInfo]
  def getApplicationInfo(appId: String): Option[ApplicationInfo]
  def securityManager: SecurityManager
}
----

NOTE: `UIRoot` is a `private[spark]` contract.

.UIRoot Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `getApplicationInfo`
| [[getApplicationInfo]] Used when...FIXME

| `getApplicationInfoList`
| [[getApplicationInfoList]] Used when...FIXME

| `securityManager`
| [[securityManager]] Used when...FIXME

| `withSparkUI`
| [[withSparkUI]] Used exclusively when `BaseAppResource` is requested spark-api-BaseAppResource.md#withUI[withUI]
|===

[[implementations]]
.UIRoots
[cols="1,2",options="header",width="100%"]
|===
| UIRoot
| Description

| spark-history-server:HistoryServer.md[HistoryServer]
| [[HistoryServer]] Application UI for active and completed Spark applications (i.e. Spark applications that are still running or have already finished)

| spark-webui-SparkUI.md[SparkUI]
| [[SparkUI]] Application UI for an active Spark application (i.e. a Spark application that is still running)
|===

=== [[writeEventLogs]] `writeEventLogs` Method

[source, scala]
----
writeEventLogs(appId: String, attemptId: Option[String], zipStream: ZipOutputStream): Unit
----

`writeEventLogs`...FIXME

NOTE: `writeEventLogs` is used when...FIXME
