== [[StorageStatusListener]] StorageStatusListener -- Spark Listener for Tracking BlockManagers

`StorageStatusListener` is a ROOT:SparkListener.md[] that uses <<SparkListener-callbacks, SparkListener callbacks>> to track status of every storage:BlockManager.md[BlockManager] in a Spark application.

`StorageStatusListener` is created and registered when `SparkUI` spark-webui-SparkUI.md#create[is created]. It is later used to create spark-webui-executors-ExecutorsListener.md[ExecutorsListener] and spark-webui-StorageListener.md[StorageListener] Spark listeners.

[[SparkListener-callbacks]]
.StorageStatusListener's SparkListener Callbacks (in alphabetical order)
[cols="1,2",options="header",width="100%"]
|===
| Callback
| Description

| [[onBlockManagerAdded]] `onBlockManagerAdded`
| Adds an executor id with spark-blockmanager-StorageStatus.md[StorageStatus] (with storage:BlockManager.md[BlockManager] and maximum memory on the executor) to <<executorIdToStorageStatus, executorIdToStorageStatus>> internal registry.

Removes any other `BlockManager` that may have been registered for the executor earlier in <<deadExecutorStorageStatus, deadExecutorStorageStatus>> internal registry.

| `onBlockManagerRemoved`
| Removes an executor from <<executorIdToStorageStatus, executorIdToStorageStatus>> internal registry and adds the removed spark-blockmanager-StorageStatus.md[StorageStatus] to <<deadExecutorStorageStatus, deadExecutorStorageStatus>> internal registry.

Removes the oldest spark-blockmanager-StorageStatus.md[StorageStatus] when the number of entries in <<deadExecutorStorageStatus, deadExecutorStorageStatus>> is bigger than spark-webui-properties.md#spark.ui.retainedDeadExecutors[spark.ui.retainedDeadExecutors].

| `onBlockUpdated`
| Updates spark-blockmanager-StorageStatus.md[StorageStatus] for an executor in <<executorIdToStorageStatus, executorIdToStorageStatus>> internal registry, i.e. removes a block for storage:StorageLevel.md[`NONE` storage level] and updates otherwise.

| [[onUnpersistRDD]] `onUnpersistRDD`
| <<updateStorageStatus-unpersistedRDD, Removes the RDD blocks>> for an unpersisted RDD (on every `BlockManager` registered as spark-blockmanager-StorageStatus.md[StorageStatus] in <<executorIdToStorageStatus, executorIdToStorageStatus>> internal registry).
|===

[[internal-registries]]
.StorageStatusListener's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[deadExecutorStorageStatus]] `deadExecutorStorageStatus`
| Collection of spark-blockmanager-StorageStatus.md[StorageStatus] of removed/inactive `BlockManagers`.

Accessible using <<deadStorageStatusList, deadStorageStatusList>> method.

Adds an element when `StorageStatusListener` <<onBlockManagerRemoved, handles a BlockManager being removed>> (possibly removing one element from the head when the number of elements are above spark-webui-properties.md#spark.ui.retainedDeadExecutors[spark.ui.retainedDeadExecutors] property).

Removes an element when `StorageStatusListener` <<onBlockManagerAdded, handles a new BlockManager>> (per executor) so the executor is not longer dead.

| [[executorIdToStorageStatus]] `executorIdToStorageStatus`
| Lookup table of spark-blockmanager-StorageStatus.md[StorageStatus] per executor (including the driver).

Adds an entry when `StorageStatusListener` <<onBlockManagerAdded, handles a new BlockManager>>.

Removes an entry when `StorageStatusListener` <<onBlockManagerRemoved, handles a BlockManager being removed>>.

Updates `StorageStatus` of an executor when `StorageStatusListener` <<updateStorageStatus-unpersistedRDD, handles StorageStatus updates>>.
|===

=== [[updateStorageStatus-executor]] Updating Storage Status For Executor -- `updateStorageStatus` Method

CAUTION: FIXME

=== [[storageStatusList]] Active BlockManagers (on Executors) -- `storageStatusList` Method

[source, scala]
----
storageStatusList: Seq[StorageStatus]
----

`storageStatusList` gives a collection of spark-blockmanager-StorageStatus.md[StorageStatus] (from <<executorIdToStorageStatus, executorIdToStorageStatus>> internal registry).

[NOTE]
====
`storageStatusList` is used when:

* `StorageStatusListener` <<updateStorageStatus-unpersistedRDD, removes the RDD blocks for an unpersisted RDD>>
* `ExecutorsListener` does spark-webui-executors-ExecutorsListener.md#activeStorageStatusList[activeStorageStatusList]
* `StorageListener` does spark-webui-StorageListener.md#activeStorageStatusList[activeStorageStatusList]
====

=== [[deadStorageStatusList]] `deadStorageStatusList` Method

[source, scala]
----
deadStorageStatusList: Seq[StorageStatus]
----

`deadStorageStatusList` gives <<deadExecutorStorageStatus, deadExecutorStorageStatus>> internal registry.

NOTE: `deadStorageStatusList` is used when `ExecutorsListener` spark-webui-executors-ExecutorsListener.md#deadStorageStatusList[is requested for inactive/dead BlockManagers].

=== [[updateStorageStatus-unpersistedRDD]] Removing RDD Blocks for Unpersisted RDD -- `updateStorageStatus` Internal Method

[source, scala]
----
updateStorageStatus(unpersistedRDDId: Int)
----

`updateStorageStatus` takes <<storageStatusList, active BlockManagers>>.

`updateStorageStatus` then spark-blockmanager-StorageStatus.md#rddBlocksById[finds RDD blocks] for `unpersistedRDDId` RDD (for every `BlockManager`) and spark-blockmanager-StorageStatus.md#removeBlock[removes the blocks].

NOTE: `storageStatusList` is used exclusively when `StorageStatusListener` <<onUnpersistRDD, is notified that an RDD was unpersisted>>.
