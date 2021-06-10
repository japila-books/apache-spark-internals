# StorageTab

`StorageTab` is a [SparkUITab](SparkUITab.md) with `storage` [URL prefix](SparkUITab.md#prefix).

![Storage Tab in Web UI](../images/webui/spark-webui-storage.png)

## Creating Instance

`StorageTab` takes the following to be created:

* <span id="parent"> Parent [SparkUI](SparkUI.md)
* <span id="store"> [AppStatusStore](../status/AppStatusStore.md)

`StorageTab` is created when:

* `SparkUI` is requested to [initialize](SparkUI.md#initialize)

## Pages

When [created](#creating-instance), `StorageTab` [attaches](WebUITab.md#attachPage) the following pages (with a reference to itself and the [AppStatusStore](#store)):

* [StoragePage](StoragePage.md)
* [RDDPage](RDDPage.md)
