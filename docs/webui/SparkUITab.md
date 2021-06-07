== [[SparkUITab]] SparkUITab

`SparkUITab` is the <<contract, contract>> of spark-webui-WebUITab.md[WebUITab] extensions with two additional properties:

* <<appName, appName>>
* <<appSparkVersion, appSparkVersion>>

[[contract]]
[source, scala]
----
package org.apache.spark.ui

abstract class SparkUITab(parent: SparkUI, prefix: String)
  extends WebUITab(parent, prefix) {
  def appName: String
  def appSparkVersion: String
}
----

NOTE: `SparkUITab` is a `private[spark]` contract.

.SparkUITab Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `appName`
| [[appName]] Used when...FIXME

| `appSparkVersion`
| [[appSparkVersion]] Used when...FIXME
|===

[[implementations]]
.SparkUITabs
[cols="1,2",options="header",width="100%"]
|===
| SparkUITab
| Description

| spark-webui-EnvironmentTab.md[EnvironmentTab]
| [[EnvironmentTab]]

| spark-webui-ExecutorsTab.md[ExecutorsTab]
| [[ExecutorsTab]]

| [JobsTab](JobsTab.md)
| [[JobsTab]]

| spark-webui-StagesTab.md[StagesTab]
| [[StagesTab]]

| spark-webui-StorageTab.md[StorageTab]
| [[StorageTab]]

| `SQLTab`
| [[SQLTab]] Used in Spark SQL module

| `StreamingTab`
| [[StreamingTab]] Used in Spark Streaming module

| `ThriftServerTab`
| [[ThriftServerTab]] Used in Spark Thrift Server
|===
