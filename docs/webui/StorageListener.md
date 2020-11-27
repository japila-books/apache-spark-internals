= StorageListener

StorageListener is a webui:spark-webui-BlockStatusListener.md[BlockStatusListener] that uses <<SparkListener-callbacks, SparkListener callbacks>> to track changes in the persistence status of RDD blocks in a Spark application.

[[SparkListener-callbacks]]
.StorageListener's SparkListener Callbacks (in alphabetical order)
[width="100%",cols="1,2",options="header"]
|===
| Callback
| Description

| <<onBlockUpdated, onBlockUpdated>>
| Updates <<_rddInfoMap, _rddInfoMap>> with the update to a single block.

| <<onStageCompleted, onStageCompleted>>
| Removes storage:RDDInfo.md[RDDInfo] instances from <<_rddInfoMap, _rddInfoMap>> that participated in the completed stage as well as the ones that are no longer cached.

| <<onStageSubmitted, onStageSubmitted>>
| Updates <<_rddInfoMap, _rddInfoMap>> registry with the names of every storage:RDDInfo.md[RDDInfo] in the submitted stage, possibly adding new storage:RDDInfo.md[RDDInfo] instances if they were not registered yet.

| <<onUnpersistRDD, onUnpersistRDD>>
| Removes an storage:RDDInfo.md[RDDInfo] from <<_rddInfoMap, _rddInfoMap>> registry for the unpersisted RDD.

|===

[[internal-registries]]
.StorageListener's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[_rddInfoMap]] `_rddInfoMap`
| storage:RDDInfo.md[RDDInfo] instances per IDs

Used when...FIXME
|===

== [[creating-instance]] Creating StorageListener Instance

StorageListener takes the following when created:

* [[storageStatusListener]] spark-webui-StorageStatusListener.md[StorageStatusListener]

StorageListener initializes the <<internal-registries, internal registries and counters>>.

NOTE: StorageListener is created when `SparkUI` spark-webui-SparkUI.md#create[is created].

== [[activeStorageStatusList]] Finding Active BlockManagers -- `activeStorageStatusList` Method

[source, scala]
----
activeStorageStatusList: Seq[StorageStatus]
----

`activeStorageStatusList` requests <<storageStatusListener, StorageStatusListener>> for spark-webui-StorageStatusListener.md#storageStatusList[active BlockManagers (on executors)].

[NOTE]
====
`activeStorageStatusList` is used when:

* `AllRDDResource` does `rddList` and `getRDDStorageInfo`
* StorageListener <<updateRDDInfo, updates registered RDDInfos (with block updates from BlockManagers)>>
====

== [[onBlockUpdated]] Intercepting Block Status Update Events -- `onBlockUpdated` Callback

[source, scala]
----
onBlockUpdated(blockUpdated: SparkListenerBlockUpdated): Unit
----

`onBlockUpdated` creates a `BlockStatus` (from the input `SparkListenerBlockUpdated`) and <<updateRDDInfo, updates registered RDDInfos (with block updates from BlockManagers)>> (passing in storage:BlockId.md[] and `BlockStatus` as a single-element collection of updated blocks).

NOTE: `onBlockUpdated` is part of SparkListener.md#onBlockUpdated[SparkListener contract] to announce that there was a change in a block status (on a `BlockManager` on an executor).

== [[onStageCompleted]] Intercepting Stage Completed Events -- `onStageCompleted` Callback

[source, scala]
----
onStageCompleted(stageCompleted: SparkListenerStageCompleted): Unit
----

`onStageCompleted` finds the identifiers of the RDDs that have participated in the completed stage and removes them from <<_rddInfoMap, _rddInfoMap>> registry as well as the RDDs that are no longer cached.

NOTE: `onStageCompleted` is part of SparkListener.md#onStageCompleted[SparkListener contract] to announce that a stage has finished.

== [[onStageSubmitted]] Intercepting Stage Submitted Events -- `onStageSubmitted` Callback

[source, scala]
----
onStageSubmitted(stageSubmitted: SparkListenerStageSubmitted): Unit
----

`onStageSubmitted` updates <<_rddInfoMap, _rddInfoMap>> registry with the names of every storage:RDDInfo.md[RDDInfo] in `stageSubmitted`, possibly adding new storage:RDDInfo.md[RDDInfo] instances if they were not registered yet.

NOTE: `onStageSubmitted` is part of SparkListener.md#onStageSubmitted[SparkListener contract] to announce that the missing tasks of a stage were submitted for execution.

== [[onUnpersistRDD]] Intercepting Unpersist RDD Events -- `onUnpersistRDD` Callback

[source, scala]
----
onUnpersistRDD(unpersistRDD: SparkListenerUnpersistRDD): Unit
----

`onUnpersistRDD` removes the storage:RDDInfo.md[RDDInfo] from <<_rddInfoMap, _rddInfoMap>> registry for the unpersisted RDD (from `unpersistRDD`).

NOTE: `onUnpersistRDD` is part of SparkListener.md#onUnpersistRDD[SparkListener contract] to announce that an RDD has been unpersisted.

== [[updateRDDInfo]] Updating Registered RDDInfos (with Block Updates from BlockManagers)

[source, scala]
----
updateRDDInfo(updatedBlocks: Seq[(BlockId, BlockStatus)]): Unit
----

`updateRDDInfo` finds the RDDs for the input `updatedBlocks` (for storage:BlockId.md[]s).

NOTE: `updateRDDInfo` finds `BlockIds` that are storage:BlockId.md#RDDBlockId[RDDBlockIds].

`updateRDDInfo` takes `RDDInfo` entries (in <<_rddInfoMap, _rddInfoMap>> registry) for which there are blocks in the input `updatedBlocks` and <<StorageUtils.updateRddInfo, updates RDDInfos (using StorageStatus)>> (from <<activeStorageStatusList, activeStorageStatusList>>).

NOTE: `updateRDDInfo` is used exclusively when StorageListener <<onBlockUpdated, gets notified about a change in a block status (on a `BlockManager` on an executor)>>.

== [[StorageUtils.updateRddInfo]] Updating RDDInfos (using StorageStatus) -- `StorageUtils.updateRddInfo` Method

[source, scala]
----
updateRddInfo(rddInfos: Seq[RDDInfo], statuses: Seq[StorageStatus]): Unit
----

CAUTION: FIXME

[NOTE]
====
`updateRddInfo` is used when:

* `SparkContext` SparkContext.md#getRDDStorageInfo[is requested for storage status of cached RDDs]
* StorageListener <<updateRDDInfo, updates registered RDDInfos (with block updates from BlockManagers)>>
====
