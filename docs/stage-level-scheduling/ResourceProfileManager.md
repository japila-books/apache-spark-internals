# ResourceProfileManager

## Creating Instance

`ResourceProfileManager` takes the following to be created:

* <span id="sparkConf"> [SparkConf](../SparkConf.md)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)

`ResourceProfileManager` is created when:

* `SparkContext` is [created](../SparkContext.md#_resourceProfileManager)

## Accessing ResourceProfileManager

`ResourceProfileManager` is available to other Spark services using [SparkContext](../SparkContext.md#ResourceProfileManager).

## Default Profile { #defaultProfile }

`ResourceProfileManager` [gets or creates a (default) profile](ResourceProfile.md#getOrCreateDefaultProfile) when [created](#creating-instance) and [registers it](#addResourceProfile) immediately.

### defaultResourceProfile { #defaultResourceProfile }

```scala
defaultResourceProfile: ResourceProfile
```

`defaultResourceProfile` returns the [defaultProfile](#defaultProfile).

---

`defaultResourceProfile` is used when:

* `ExecutorAllocationManager` is [created](../dynamic-allocation/ExecutorAllocationManager.md#defaultProfileId)
* `SparkContext` is requested to [requestTotalExecutors](../SparkContext.md#requestTotalExecutors) and [createTaskScheduler](../SparkContext.md#createTaskScheduler)
* `DAGScheduler` is requested to [mergeResourceProfilesForStage](../scheduler/DAGScheduler.md#mergeResourceProfilesForStage)
* `CoarseGrainedSchedulerBackend` is requested to [requestExecutors](../scheduler/CoarseGrainedSchedulerBackend.md#requestExecutors)
* `StandaloneSchedulerBackend` ([Spark Standalone]({{ book.spark_standalone }}/StandaloneSchedulerBackend)) is created
* `KubernetesClusterSchedulerBackend` ([Spark on Kubernetes]({{ book.spark_k8s}}/KubernetesClusterSchedulerBackend)) is created
* `MesosCoarseGrainedSchedulerBackend` (Spark on Mesos) is created

## addResourceProfile { #addResourceProfile }

```scala
addResourceProfile(
  rp: ResourceProfile): Unit
```

`addResourceProfile` [check if the given ResourceProfile is supported](#isSupported).

`addResourceProfile` checks whether the given [ResourceProfile](ResourceProfile.md) hasn't been added already.

If not, `addResourceProfile` requests the given [ResourceProfile](ResourceProfile.md) to [limitingResource](#limitingResource) and prints out the following INFO message to the logs:

```text
Added ResourceProfile id: [id]
```

In the end, `addResourceProfile` requests the [LiveListenerBus](#listenerBus) to [post](../scheduler/LiveListenerBus.md#post) a [SparkListenerResourceProfileAdded](../SparkListenerEvent.md#SparkListenerResourceProfileAdded).

---

`addResourceProfile` is used when:

* `RDD` is requested to [withResources](../rdd/RDD.md#withResources)
* `ResourceProfileManager` is [created](#defaultProfile)
* `DAGScheduler` is requested to [mergeResourceProfilesForStage](../scheduler/DAGScheduler.md#mergeResourceProfilesForStage)

## isSupported { #isSupported }

```scala
isSupported(
  rp: ResourceProfile): Boolean
```

`isSupported`...FIXME

## canBeScheduled { #canBeScheduled }

```scala
canBeScheduled(
  taskRpId: Int,
  executorRpId: Int): Boolean
```

`canBeScheduled`...FIXME

---

`canBeScheduled` is used when:

* `TaskSchedulerImpl` is requested to [resourceOfferSingleTaskSet](../scheduler/TaskSchedulerImpl.md#resourceOfferSingleTaskSet) and [calculateAvailableSlots](../scheduler/TaskSchedulerImpl.md#calculateAvailableSlots)
