# ElementTrackingStore

`ElementTrackingStore` is a [KVStore](KVStore.md).

## Creating Instance

`ElementTrackingStore` takes the following to be created:

* <span id="store"> [KVStore](KVStore.md)
* <span id="conf"> [SparkConf](../SparkConf.md)

`ElementTrackingStore` is created when:

* `AppStatusStore` is requested to [createLiveStore](AppStatusStore.md#createLiveStore)
* `FsHistoryProvider` is requested to [rebuildAppStore](../history-server/FsHistoryProvider.md#rebuildAppStore)
