# InMemoryStore

`InMemoryStore` is a [KVStore](KVStore.md).

## Creating Instance

`InMemoryStore` takes no arguments to be created.

`InMemoryStore` is created when:

* `FsHistoryProvider` is [created](../history-server/FsHistoryProvider.md#listing) and requested to [createInMemoryStore](../history-server/FsHistoryProvider.md#createInMemoryStore)
* `AppStatusStore` utility is used to [create an AppStatusStore for a live Spark application](../status/AppStatusStore.md#createLiveStore)
