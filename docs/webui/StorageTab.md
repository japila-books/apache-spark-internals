== [[StorageTab]] StorageTab

[[prefix]]
`StorageTab` is a link:spark-webui-SparkUITab.adoc[SparkUITab] with *storage* link:spark-webui-SparkUITab.adoc#prefix[prefix].

`StorageTab` is <<creating-instance, created>> exclusively when `SparkUI` is link:spark-webui-SparkUI.adoc#initialize[initialized].

[[creating-instance]]
`StorageTab` takes the following when created:

* [[parent]] Parent link:spark-webui-SparkUI.adoc[SparkUI]
* [[store]] xref:core:AppStatusStore.adoc[]

When <<creating-instance, created>>, `StorageTab` creates the following pages and link:spark-webui-WebUITab.adoc#attachPage[attaches] them immediately:

* link:spark-webui-StoragePage.adoc[StoragePage]

* link:spark-webui-RDDPage.adoc[RDDPage]
