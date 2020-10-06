== [[StorageTab]] StorageTab

[[prefix]]
`StorageTab` is a spark-webui-SparkUITab.md[SparkUITab] with *storage* spark-webui-SparkUITab.md#prefix[prefix].

`StorageTab` is <<creating-instance, created>> exclusively when `SparkUI` is spark-webui-SparkUI.md#initialize[initialized].

[[creating-instance]]
`StorageTab` takes the following when created:

* [[parent]] Parent spark-webui-SparkUI.md[SparkUI]
* [[store]] core:AppStatusStore.md[]

When <<creating-instance, created>>, `StorageTab` creates the following pages and spark-webui-WebUITab.md#attachPage[attaches] them immediately:

* spark-webui-StoragePage.md[StoragePage]

* spark-webui-RDDPage.md[RDDPage]
