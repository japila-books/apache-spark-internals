== [[BlockStatusListener]] BlockStatusListener Spark Listener

`BlockStatusListener` is a ROOT:SparkListener.md[]s that tracks storage:BlockManager.md[BlockManagers] and the blocks for spark-webui-storage.md[Storage tab] in web UI.

.`BlockStatusListener` Registries
[cols="1,2",options="header",width="100%"]
|===
| Registry | Description
| [[blockManagers]] `blockManagers` | The lookup table for a collection of storage:BlockId.md[] and `BlockUIData` per storage:BlockManagerId.md[]
|===

CAUTION: FIXME When are the events posted?

.`BlockStatusListener` Event Handlers
[cols="1,2",options="header",width="100%"]
|===
| Event Handler | Description

| `onBlockManagerAdded` | Registers a `BlockManager` in <<blockManagers, blockManagers>> internal registry (with no blocks).

| `onBlockManagerRemoved` | Removes a `BlockManager` from <<blockManagers, blockManagers>> internal registry.

| `onBlockUpdated` | Puts an updated `BlockUIData` for `BlockId` for `BlockManagerId` in <<blockManagers, blockManagers>> internal registry.

Ignores updates for unregistered ``BlockManager``s or non-``StreamBlockId``s.

For invalid storage:StorageLevel.md[StorageLevel]s (i.e. they do not use a memory or a disk or no replication) the block is removed.
|===
