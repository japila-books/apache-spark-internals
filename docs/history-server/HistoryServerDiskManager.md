# HistoryServerDiskManager

`HistoryServerDiskManager` is a disk manager for [FsHistoryProvider](FsHistoryProvider.md#diskManager).

## Creating Instance

`HistoryServerDiskManager` takes the following to be created:

* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="path"> Path
* <span id="listing"> [KVStore](../core/KVStore.md)
* <span id="clock"> `Clock`

`HistoryServerDiskManager` is created when:

* `FsHistoryProvider` is created (and initializes a [diskManager](FsHistoryProvider.md#diskManager))

## <span id="initialize"> Initializing

```scala
initialize(): Unit
```

`initialize`...FIXME

`initialize` is used when:

* `FsHistoryProvider` is requested to [startPolling](FsHistoryProvider.md#startPolling)

## <span id="release"> Releasing Application Store

```scala
release(
  appId: String,
  attemptId: Option[String],
  delete: Boolean = false): Unit
```

`release`...FIXME

`release` is used when:

* `FsHistoryProvider` is requested to [onUIDetached](FsHistoryProvider.md#onUIDetached), [cleanAppData](FsHistoryProvider.md#cleanAppData) and [loadDiskStore](FsHistoryProvider.md#loadDiskStore)
