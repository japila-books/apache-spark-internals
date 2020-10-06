== [[StoragePage]] StoragePage

[[prefix]]
`StoragePage` is a spark-webui-WebUIPage.md[WebUIPage] with an empty spark-webui-WebUIPage.md#prefix[prefix].

`StoragePage` is <<creating-instance, created>> exclusively when `StorageTab` is spark-webui-StorageTab.md#creating-instance[created].

[[creating-instance]]
`StoragePage` takes the following when created:

* [[parent]] Parent spark-webui-SparkUITab.md[SparkUITab]
* [[store]] core:AppStatusStore.md[]

=== [[rddRow]] Rendering HTML Table Row for RDD Details -- `rddRow` Internal Method

[source, scala]
----
rddRow(rdd: v1.RDDStorageInfo): Seq[Node]
----

`rddRow`...FIXME

NOTE: `rddRow` is used when...FIXME

=== [[rddTable]] Rendering HTML Table with RDD Details -- `rddTable` Method

[source, scala]
----
rddTable(rdds: Seq[v1.RDDStorageInfo]): Seq[Node]
----

`rddTable`...FIXME

NOTE: `rddTable` is used when...FIXME

=== [[receiverBlockTables]] `receiverBlockTables` Method

[source, scala]
----
receiverBlockTables(blocks: Seq[StreamBlockData]): Seq[Node]
----

`receiverBlockTables`...FIXME

NOTE: `receiverBlockTables` is used when...FIXME

=== [[render]] Rendering Page -- `render` Method

[source, scala]
----
render(request: HttpServletRequest): Seq[Node]
----

NOTE: `render` is part of spark-webui-WebUIPage.md#render[WebUIPage Contract] to...FIXME.

`render` requests the <<store, AppStatusStore>> for core:AppStatusStore.md#rddList[rddList] and <<rddTable, renders an HTML table with their details>> (if available).

`render` requests the <<store, AppStatusStore>> for core:AppStatusStore.md#streamBlocksList[streamBlocksList] and <<receiverBlockTables, renders an HTML table with receiver blocks>> (if available).

In the end, `render` requests `UIUtils` to `headerSparkPage` (with `Storage` title).
