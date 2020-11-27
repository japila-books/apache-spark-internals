== [[Source]] Source -- Contract of Metrics Sources

`Source` is a <<contract, contract>> of *metrics sources*.

[[contract]]
[source, scala]
----
package org.apache.spark.metrics.source

trait Source {
  def sourceName: String
  def metricRegistry: MetricRegistry
}
----

NOTE: `Source` is a `private[spark]` contract.

.Source Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `sourceName`
| [[sourceName]] Used when...FIXME

| `metricRegistry`
| [[metricRegistry]] Dropwizard Metrics' https://metrics.dropwizard.io/3.1.0/apidocs/com/codahale/metrics/MetricRegistry.html[MetricRegistry]

Used when...FIXME
|===

[[implementations]]
.Sources
[cols="1,2",options="header",width="100%"]
|===
| Source
| Description

| `ApplicationSource`
| [[ApplicationSource]]

| [BlockManagerSource](../storage/BlockManagerSource.md)
| [[BlockManagerSource]]

| `CacheMetrics`
| [[CacheMetrics]]

| `CodegenMetrics`
| [[CodegenMetrics]]

| [DAGSchedulerSource](../scheduler/DAGSchedulerSource.md)
| [[DAGSchedulerSource]]

| [ExecutorAllocationManagerSource](../dynamic-allocation/ExecutorAllocationManagerSource.md)
| [[ExecutorAllocationManagerSource]]

| executor:ExecutorSource.md[]
| [[ExecutorSource]]

| `ExternalShuffleServiceSource`
| [[ExternalShuffleServiceSource]]

| `HiveCatalogMetrics`
| [[HiveCatalogMetrics]]

| metrics:JvmSource.md[JvmSource]
| [[JvmSource]]

| `LiveListenerBusMetrics`
| [[LiveListenerBusMetrics]]

| `MasterSource`
| [[MasterSource]]

| `MesosClusterSchedulerSource`
| [[MesosClusterSchedulerSource]]

| storage:ShuffleMetricsSource.md[]
| [[ShuffleMetricsSource]]

| `StreamingSource`
| [[StreamingSource]]

| `WorkerSource`
| [[WorkerSource]]
|===
