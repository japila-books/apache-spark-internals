== [[ApplicationCacheOperations]] ApplicationCacheOperations

`ApplicationCacheOperations` is the <<contract, contract>> of...FIXME

[[contract]]
[source, scala]
----
package org.apache.spark.deploy.history

trait ApplicationCacheOperations {
  // only required methods that have no implementation
  // the others follow
  def getAppUI(appId: String, attemptId: Option[String]): Option[LoadedAppUI]
  def attachSparkUI(
    appId: String,
    attemptId: Option[String],
    ui: SparkUI,
    completed: Boolean): Unit
  def detachSparkUI(appId: String, attemptId: Option[String], ui: SparkUI): Unit
}
----

NOTE: `ApplicationCacheOperations` is a `private[history]` contract.

.(Subset of) ApplicationCacheOperations Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `getAppUI`
| [[getAppUI]] spark-webui-SparkUI.md[SparkUI] (the UI of a Spark application)

Used exclusively when `ApplicationCache` is requested for ApplicationCache.md#loadApplicationEntry[loadApplicationEntry]

| `attachSparkUI`
| [[attachSparkUI]]

| `detachSparkUI`
| [[detachSparkUI]]
|===

[[implementations]]
NOTE: HistoryServer.md[HistoryServer] is the one and only known implementation of <<contract, ApplicationCacheOperations contract>> in Apache Spark.
