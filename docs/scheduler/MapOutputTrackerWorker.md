# MapOutputTrackerWorker

`MapOutputTrackerWorker` is the [MapOutputTracker](MapOutputTracker.md) for executors.

`MapOutputTrackerWorker` uses Java's thread-safe [java.util.concurrent.ConcurrentHashMap]({{ java.api }}/java.base/java/util/concurrent/ConcurrentHashMap.html) for [mapStatuses](MapOutputTracker.md#mapStatuses) internal cache and any lookup cache miss triggers a fetch from the driver's [MapOutputTrackerMaster](MapOutputTrackerMaster.md).

== [[getStatuses]] Finding Shuffle Map Outputs

[source, scala]
----
getStatuses(
  shuffleId: Int): Array[MapStatus]
----

`getStatuses` finds MapStatus.md[MapStatuses] for the input `shuffleId` in the <<mapStatuses, mapStatuses>> internal cache and, when not available, fetches them from a remote MapOutputTrackerMaster.md[MapOutputTrackerMaster] (using RPC).

Internally, `getStatuses` first queries the <<mapStatuses, `mapStatuses` internal cache>> and returns the map outputs if found.

If not found (in the `mapStatuses` internal cache), you should see the following INFO message in the logs:

```
Don't have map outputs for shuffle [id], fetching them
```

If some other process fetches the map outputs for the `shuffleId` (as recorded in `fetching` internal registry), `getStatuses` waits until it is done.

When no other process fetches the map outputs, `getStatuses` registers the input `shuffleId` in `fetching` internal registry (of shuffle map outputs being fetched).

You should see the following INFO message in the logs:

```
Doing the fetch; tracker endpoint = [trackerEndpoint]
```

`getStatuses` sends a `GetMapOutputStatuses` RPC remote message for the input `shuffleId` to the trackerEndpoint expecting a `Array[Byte]`.

NOTE: `getStatuses` requests shuffle map outputs remotely within a timeout and with retries. Refer to rpc:RpcEndpointRef.md[RpcEndpointRef].

`getStatuses` <<deserializeMapStatuses, deserializes the map output statuses>> and records the result in the <<mapStatuses, `mapStatuses` internal cache>>.

You should see the following INFO message in the logs:

```
Got the output locations
```

`getStatuses` removes the input `shuffleId` from `fetching` internal registry.

You should see the following DEBUG message in the logs:

```
Fetching map output statuses for shuffle [id] took [time] ms
```

If `getStatuses` could not find the map output locations for the input `shuffleId` (locally and remotely), you should see the following ERROR message in the logs and throws a `MetadataFetchFailedException`.

```
Missing all output locations for shuffle [id]
```

NOTE: `getStatuses` is used when MapOutputTracker <<getMapSizesByExecutorId, getMapSizesByExecutorId>> and <<getStatistics, computes statistics for `ShuffleDependency`>>.

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.MapOutputTrackerWorker` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.MapOutputTrackerWorker=ALL
----

Refer to spark-logging.md[Logging].
