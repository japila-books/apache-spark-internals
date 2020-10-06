== [[RDDStorageInfo]] RDDStorageInfo

[[creating-instance]]
`RDDStorageInfo` contains information about RDD persistence:

* [[id]] RDD id
* [[name]] RDD name
* [[numPartitions]] Number of RDD partitions
* [[numCachedPartitions]] Number of cached RDD partitions
* [[storageLevel]] xref:storage:StorageLevel.adoc[Storage level] ID
* [[memoryUsed]] Memory used
* [[diskUsed]] Disk used
* [[dataDistribution]] Data distribution (as `Seq[RDDDataDistribution]`)
* [[partitions]] Partitions (as `Seq[RDDPartitionInfo]]`)

`RDDStorageInfo` is <<creating-instance, created>> exclusively when `LiveRDD` is requested to xref:webui:spark-core-LiveRDD.adoc#doUpdate[doUpdate] (when requested to link:spark-core-LiveEntity.adoc#write[write]).

`RDDStorageInfo` is used when:

. web UI's `StoragePage` is requested to render an HTML link:spark-webui-StoragePage.adoc#rddRow[table row] and an entire link:spark-webui-StoragePage.adoc#rddTable[table] for RDD details

. REST API's `AbstractApplicationResource` is requested for link:spark-api-AbstractApplicationResource.adoc#rddList[rddList] (at `storage/rdd` path)

. `AppStatusStore` is requested for xref:core:AppStatusStore.adoc#rddList[rddList]
