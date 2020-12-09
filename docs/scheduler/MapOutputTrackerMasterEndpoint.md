# MapOutputTrackerMasterEndpoint

*MapOutputTrackerMasterEndpoint* is a rpc:RpcEndpoint.md[RpcEndpoint] for scheduler:MapOutputTrackerMaster.md[MapOutputTrackerMaster] to <<receiveAndReply, handle>> the following messages:

* <<GetMapOutputStatuses, GetMapOutputStatuses>>
* <<StopMapOutputTracker, StopMapOutputTracker>>

== [[creating-instance]] Creating Instance

MapOutputTrackerMasterEndpoint takes the following to be created:

* [[rpcEnv]] rpc:RpcEnv.md[]
* [[tracker]] scheduler:MapOutputTrackerMaster.md[MapOutputTrackerMaster]
* [[conf]] SparkConf.md[SparkConf]

While being created, MapOutputTrackerMasterEndpoint prints out the following DEBUG message to the logs:

```
init
```

== [[messages]][[receiveAndReply]] Messages

=== [[GetMapOutputStatuses]] GetMapOutputStatuses

[source, scala]
----
GetMapOutputStatuses(shuffleId: Int)
----

When received, MapOutputTrackerMasterEndpoint prints out the following INFO message to the logs:

[source,plaintext]
----
Asked to send map output locations for shuffle [shuffleId] to [hostPort]
----

MapOutputTrackerMasterEndpoint requests the <<tracker, MapOutputTrackerMaster>> to scheduler:MapOutputTrackerMaster.md#post[post a GetMapOutputMessage].

GetMapOutputStatuses is posted when MapOutputTrackerWorker is requested for scheduler:MapOutputTrackerWorker.md#getStatuses[shuffle map outputs for a given shuffle ID].

=== [[StopMapOutputTracker]] StopMapOutputTracker

[source, scala]
----
StopMapOutputTracker
----

When StopMapOutputTracker arrives, you should see the following INFO message in the logs:

```
INFO MapOutputTrackerMasterEndpoint stopped!
```

MapOutputTrackerMasterEndpoint confirms the request (by replying `true`) and rpc:RpcEndpoint.md#stop[stops itself] (and stops accepting messages).

StopMapOutputTracker is posted when MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#stop[stop].

== [[logging]] Logging

Enable `ALL` logging level for `org.apache.spark.MapOutputTrackerMasterEndpoint` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

[source]
----
log4j.logger.org.apache.spark.MapOutputTrackerMasterEndpoint=ALL
----

Refer to spark-logging.md[Logging].
