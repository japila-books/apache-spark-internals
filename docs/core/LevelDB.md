# LevelDB

`LevelDB` is a [KVStore](KVStore.md) for [FsHistoryProvider](../history-server/FsHistoryProvider.md).

## Creating Instance

`LevelDB` takes the following to be created:

* <span id="path"> Path
* <span id="serializer"> `KVStoreSerializer`

`LevelDB` is created when:

* `KVUtils` utility is used to `open` (a LevelDB store)
