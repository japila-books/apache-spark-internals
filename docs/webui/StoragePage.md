# StoragePage

`StoragePage` is a [WebUIPage](WebUIPage.md) of [StorageTab](StorageTab.md).

## Creating Instance

`StoragePage` takes the following to be created:

* <span id="parent"> Parent [SparkUITab](SparkUITab.md)
* <span id="store"> [AppStatusStore](../core/AppStatusStore.md)

`StoragePage` is created when:

* [StorageTab](StorageTab.md) is created

## <span id="render"> Rendering Page

```scala
render(
  request: HttpServletRequest): Seq[Node]
```

`render` is part of the [WebUIPage](WebUIPage.md#render) abstraction.

`render` renders a `Storage` page with the [RDDs](../core/AppStatusStore.md#rddList) and [streaming blocks](../core/AppStatusStore.md#streamBlocksList) (from the [AppStatusStore](#store)).

## <span id="rddHeader"> RDD Table's Headers

`StoragePage` uses the following headers and tooltips for the RDD table.

Header   | Tooltip
---------|----------
 ID |
 RDD Name | Name of the persisted RDD
 Storage Level | StorageLevel displays where the persisted RDD is stored, format of the persisted RDD (serialized or de-serialized) and replication factor of the persisted RDD
 Cached Partitions | Number of partitions cached
 Fraction Cached | Fraction of total partitions cached
 Size in Memory | Total size of partitions in memory
 Size on Disk | Total size of partitions on the disk
