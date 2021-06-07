== [[WebUIPage]] WebUIPage -- Contract of Pages in Web UI

`WebUIPage` is the <<contract, contract>> of <<implementations, web pages>> of a spark-webui-WebUI.md[WebUI] that can be rendered in <<render, HTML>> and <<renderJson, JSON>>.

`WebUIPage` can be:

* spark-webui-WebUI.md#attachPage[attached] or spark-webui-WebUI.md#detachPage[detached] from a `WebUI`

* spark-webui-WebUITab.md#attachPage[attached] to a `WebUITab`

[[prefix]]
`WebUIPage` has a prefix that...FIXME

[[contract]]
[source, scala]
----
package org.apache.spark.ui

abstract class WebUIPage(var prefix: String) {
  def render(request: HttpServletRequest): Seq[Node]
  def renderJson(request: HttpServletRequest): JValue = JNothing
}
----

NOTE: `WebUIPage` is a `private[spark]` contract.

.WebUIPage Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `render`
| [[render]] Used exclusively when `WebUI` is requested to spark-webui-WebUI.md#attachPage[attach a page] (and...FIXME)

| `renderJson`
| [[renderJson]] Used when...FIXME
|===

[[implementations]]
.WebUIPages
[cols="1,2",options="header",width="100%"]
|===
| WebUIPage
| Description

| `AllExecutionsPage`
| [[AllExecutionsPage]] Used in Spark SQL module

| [AllJobsPage](AllJobsPage.md)
| [[AllJobsPage]]

| spark-webui-AllStagesPage.md[AllStagesPage]
| [[AllStagesPage]]

| spark-standalone-webui-ApplicationPage.md[ApplicationPage]
| [[ApplicationPage]] Used in Spark Standalone cluster manager

| `BatchPage`
| [[BatchPage]] Used in Spark Streaming module

| `DriverPage`
| [[DriverPage]] Used in Spark on Mesos module

| spark-webui-EnvironmentPage.md[EnvironmentPage]
| [[EnvironmentPage]]

| `ExecutionPage`
| [[ExecutionPage]] Used in Spark SQL module

| spark-webui-ExecutorsPage.md[ExecutorsPage]
| [[ExecutorsPage]]

| spark-webui-executors.md#ExecutorThreadDumpPage[ExecutorThreadDumpPage]
| [[ExecutorThreadDumpPage]]

| `HistoryPage`
| [[HistoryPage]] Used in Spark History Server module

| spark-webui-jobs.md[JobPage]
| [[JobPage]]

| `LogPage`
| [[LogPage]] Used in Spark Standalone cluster manager

| `MasterPage`
| [[MasterPage]] Used in Spark Standalone cluster manager

| `MesosClusterPage`
| [[MesosClusterPage]] Used in Spark on Mesos module

| spark-webui-PoolPage.md[PoolPage]
| [[PoolPage]]

| spark-webui-RDDPage.md[RDDPage]
| [[RDDPage]]

| spark-webui-StagePage.md[StagePage]
| [[StagePage]]

| spark-webui-StoragePage.md[StoragePage]
| [[StoragePage]]

| `StreamingPage`
| [[StreamingPage]] Used in Spark Streaming module

| `ThriftServerPage`
| [[ThriftServerPage]] Used in Spark Thrift Server module

| `ThriftServerSessionPage`
| [[ThriftServerSessionPage]] Used in Spark Thrift Server module

| `WorkerPage`
| [[WorkerPage]] Used in Spark Standalone cluster manager
|===
