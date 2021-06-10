# RDDStorageInfo

[[creating-instance]]
`RDDStorageInfo` contains information about RDD persistence:

* [[id]] RDD id
* [[name]] RDD name
* [[numPartitions]] Number of RDD partitions
* [[numCachedPartitions]] Number of cached RDD partitions
* [[storageLevel]] storage:StorageLevel.md[Storage level] ID
* [[memoryUsed]] Memory used
* [[diskUsed]] Disk used
* [[dataDistribution]] Data distribution (as `Seq[RDDDataDistribution]`)
* [[partitions]] Partitions (as `Seq[RDDPartitionInfo]]`)

`RDDStorageInfo` is <<creating-instance, created>> exclusively when `LiveRDD` is requested to [doUpdate](../status/LiveRDD.md#doUpdate) (when requested to [write](../status/LiveEntity.md#write)).

`RDDStorageInfo` is used when:

. web UI's `StoragePage` is requested to render an HTML spark-webui-StoragePage.md#rddRow[table row] and an entire spark-webui-StoragePage.md#rddTable[table] for RDD details

. REST API's `AbstractApplicationResource` is requested for spark-api-AbstractApplicationResource.md#rddList[rddList] (at `storage/rdd` path)

. `AppStatusStore` is requested for core:AppStatusStore.md#rddList[rddList]
