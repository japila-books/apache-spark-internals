# StorageTab

`StorageTab` is a [SparkUITab](SparkUITab.md) with `storage` URL prefix.

## Creating Instance

`StorageTab` takes the following to be created:

* <span id="parent"> Parent [SparkUI](SparkUI.md)
* <span id="store"> [AppStatusStore](../core/AppStatusStore.md)

`StorageTab` is created when:

* `SparkUI` is requested to [initialize](SparkUI.md#initialize)

## Pages

When [created](#creating-instance), `StorageTab` [attaches](WebUITab.md#attachPage) the following pages:

* [StoragePage](StoragePage.md)
* [RDDPage](RDDPage.md)
