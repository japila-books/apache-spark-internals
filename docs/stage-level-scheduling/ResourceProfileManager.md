# ResourceProfileManager

## Creating Instance

`ResourceProfileManager` takes the following to be created:

* <span id="sparkConf"> [SparkConf](../SparkConf.md)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)

`ResourceProfileManager` is created when:

* `SparkContext` is [created](../SparkContext.md#_resourceProfileManager)

## <span id="defaultProfile"> Default Profile

`ResourceProfileManager` [finds the default profile](ResourceProfile.md#getOrCreateDefaultProfile) when created and [registers it](#addResourceProfile) immediately.

## <span id="addResourceProfile"> addResourceProfile

```scala
addResourceProfile(
  rp: ResourceProfile): Unit
```

`addResourceProfile`...FIXME

`addResourceProfile` is used when:

* `RDD` is requested to [withResources](../rdd/RDD.md#withResources)
* `ResourceProfileManager` is [created](#defaultProfile)
* `DAGScheduler` is requested to [mergeResourceProfilesForStage](../scheduler/DAGScheduler.md#mergeResourceProfilesForStage)
