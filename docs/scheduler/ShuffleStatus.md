= [[ShuffleStatus]] ShuffleStatus

*ShuffleStatus* is a registry of shuffle map outputs (of a shuffle stage).

ShuffleStatus is managed by scheduler:MapOutputTrackerMaster.md#shuffleStatuses[MapOutputTrackerMaster] to keep track of shuffle map outputs across shuffle stages.

== [[creating-instance]][[numPartitions]] Creating Instance

ShuffleStatus takes a single number of partitions to be created.

== [[addMapOutput]] Registering Shuffle Map Output

[source, scala]
----
addMapOutput(
  mapId: Int,
  status: MapStatus): Unit
----

addMapOutput...FIXME

addMapOutput is used when MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#registerMapOutput[register a shuffle map output].

== [[removeMapOutput]] Deregistering Shuffle Map Output

[source, scala]
----
removeMapOutput(
  mapId: Int,
  bmAddress: BlockManagerId): Unit
----

removeMapOutput...FIXME

removeMapOutput is used when MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#unregisterMapOutput[unregister a shuffle map output].

== [[serializedMapStatus]] Serializing Shuffle Map Output Statuses

[source, scala]
----
serializedMapStatus(
  broadcastManager: BroadcastManager,
  isLocal: Boolean,
  minBroadcastSize: Int): Array[Byte]
----

serializedMapStatus...FIXME

serializedMapStatus is used when MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#run[send the map output locations of a shuffle] (on the MessageLoop dispatcher thread).

== [[findMissingPartitions]] Finding Missing Partitions

[source, scala]
----
findMissingPartitions(): Seq[Int]
----

findMissingPartitions...FIXME

findMissingPartitions is used when MapOutputTrackerMaster is requested for scheduler:MapOutputTrackerMaster.md#findMissingPartitions[missing partitions (that need to be computed)].

== [[invalidateSerializedMapOutputStatusCache]] Invalidating Serialized Map Output Status Cache

[source, scala]
----
invalidateSerializedMapOutputStatusCache(): Unit
----

invalidateSerializedMapOutputStatusCache...FIXME

invalidateSerializedMapOutputStatusCache is used when:

* ShuffleStatus is requested to <<addMapOutput, addMapOutput>>, <<removeMapOutput, removeMapOutput>>, <<removeOutputsByFilter, removeOutputsByFilter>>

* MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#unregisterShuffle[unregister a shuffle]

== [[removeOutputsByFilter]] Deregistering Shuffle Map Outputs by Filter

[source, scala]
----
removeOutputsByFilter(
  f: (BlockManagerId) => Boolean): Unit
----

removeOutputsByFilter...FIXME

removeOutputsByFilter is used when:

* ShuffleStatus is requested to <<removeOutputsOnExecutor, removeOutputsOnExecutor>>, <<removeOutputsOnHost, removeOutputsOnHost>>

* MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#unregisterAllMapOutput[unregister all map outputs of a given shuffle stage]

== [[removeOutputsOnExecutor]] Deregistering Shuffle Map Outputs Associated with Executor

[source, scala]
----
removeOutputsOnExecutor(
  execId: String): Unit
----

removeOutputsOnExecutor...FIXME

removeOutputsOnExecutor is used when MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#removeOutputsOnExecutor[delete shuffle outputs associated with an executor].

== [[removeOutputsOnHost]] Deregistering Shuffle Map Outputs Associated with Host

[source, scala]
----
removeOutputsOnHost(
  host: String): Unit
----

removeOutputsOnHost...FIXME

removeOutputsOnHost is used when MapOutputTrackerMaster is requested to scheduler:MapOutputTrackerMaster.md#removeOutputsOnHost[delete shuffle outputs associated with a host].
