# Sink

`Sink` is a <<contract, contract>> of *metrics sinks*.

[[contract]]
[source, scala]
----
package org.apache.spark.metrics.sink

trait Sink {
  def start(): Unit
  def stop(): Unit
  def report(): Unit
}
----

NOTE: `Sink` is a `private[spark]` contract.

.Sink Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `start`
| [[start]] Used when...FIXME

| `stop`
| [[stop]] Used when...FIXME

| `report`
| [[report]] Used when...FIXME
|===

[[implementations]]
.Sinks
[cols="1,2",options="header",width="100%"]
|===
| Sink
| Description

| `ConsoleSink`
| [[ConsoleSink]]

| `CsvSink`
| [[CsvSink]]

| `GraphiteSink`
| [[GraphiteSink]]

| `JmxSink`
| [[JmxSink]]

| spark-metrics-MetricsServlet.md[MetricsServlet]
| [[MetricsServlet]]

| `Slf4jSink`
| [[Slf4jSink]]

| `StatsdSink`
| [[StatsdSink]]
|===

NOTE: All known <<implementations, Sinks>> in Spark 2.3 are in `org.apache.spark.metrics.sink` Scala package.
