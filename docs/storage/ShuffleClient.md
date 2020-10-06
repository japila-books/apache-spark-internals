= ShuffleClient

ShuffleClient is the <<contract, contract>> of <<implementations, clients>> that can <<fetchBlocks, fetch shuffle block files>>.

ShuffleClient can optionally be <<init, initialized>> with an `appId` (that actually does nothing by default)

ShuffleClient has <<shuffleMetrics, shuffle-related Spark metrics>> that are used when `BlockManager` is requested for a storage:BlockManager.md#shuffleMetricsSource[shuffle-related Spark metrics source] (only when `Executor` is executor:Executor.md#creating-instance[created] for a non-local / cluster mode).

[[contract]]
[source, java]
----
package org.apache.spark.network.shuffle;

abstract class ShuffleClient implements Closeable {
  // only required methods that have no implementation
  // the others follow
  abstract void fetchBlocks(
      String host,
      int port,
      String execId,
      String[] blockIds,
      BlockFetchingListener listener,
      TempFileManager tempFileManager);
}
----

.(Subset of) ShuffleClient Contract
[cols="1,2",options="header",width="100%"]
|===
| Method
| Description

| `fetchBlocks`
| [[fetchBlocks]] Fetches a sequence of blocks from a remote block manager node asynchronously

Used exclusively when `ShuffleBlockFetcherIterator` is requested to storage:ShuffleBlockFetcherIterator.md#sendRequest[sendRequest]
|===

[[implementations]]
.ShuffleClients
[cols="1,2",options="header",width="100%"]
|===
| ShuffleClient
| Description

| storage:BlockTransferService.md[]
| [[BlockTransferService]]

| storage:ExternalShuffleClient.md[]
| [[ExternalShuffleClient]]
|===

== [[init]] init Method

[source, java]
----
void init(
  String appId)
----

`init` does nothing by default.

[NOTE]
====
`init` is used when:

* `BlockManager` is requested to storage:BlockManager.md#initialize[initialize]

* Spark on Mesos' `MesosCoarseGrainedSchedulerBackend` is requested to `registered`
====

== [[shuffleMetrics]] Shuffle Metrics

[source, java]
----
MetricSet shuffleMetrics()
----

`shuffleMetrics` returns an empty Dropwizard Metrics' https://metrics.dropwizard.io/3.1.0/apidocs/com/codahale/metrics/MetricSet.html[MetricSet] by default.

NOTE: `shuffleMetrics` is used exclusively when `BlockManager` is requested for a storage:BlockManager.md#shuffleMetricsSource[shuffle-related Spark metrics source] (only when `Executor` is executor:Executor.md#creating-instance[created] for a non-local / cluster mode).
