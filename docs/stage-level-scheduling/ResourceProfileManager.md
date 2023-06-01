# ResourceProfileManager

`ResourceProfileManager` manages [ResourceProfiles](#resourceProfileIdToResourceProfile).

## Creating Instance

`ResourceProfileManager` takes the following to be created:

* <span id="sparkConf"> [SparkConf](../SparkConf.md)
* <span id="listenerBus"> [LiveListenerBus](../scheduler/LiveListenerBus.md)

`ResourceProfileManager` is created when:

* `SparkContext` is [created](../SparkContext.md#_resourceProfileManager)

## Accessing ResourceProfileManager

`ResourceProfileManager` is available to other Spark services using [SparkContext](../SparkContext.md#ResourceProfileManager).

## Registered ResourceProfiles { #resourceProfileIdToResourceProfile }

```scala
resourceProfileIdToResourceProfile: HashMap[Int, ResourceProfile]
```

`ResourceProfileManager` creates `resourceProfileIdToResourceProfile` registry of [ResourceProfile](ResourceProfile.md)s by their [ID](ResourceProfile.md#id).

A new `ResourceProfile` is added when [addResourceProfile](#addResourceProfile).

`ResourceProfile`s are resolved (_looked up_) using [resourceProfileFromId](#resourceProfileFromId).

`ResourceProfile`s can be [equivalent](#getEquivalentProfile) when they specify the [same resources](ResourceProfile.md#resourcesEqual).

`resourceProfileIdToResourceProfile` is used when:

* [canBeScheduled](#canBeScheduled)

## Default ResourceProfile { #defaultProfile }

`ResourceProfileManager` [gets or creates the default ResourceProfile](ResourceProfile.md#getOrCreateDefaultProfile) when [created](#creating-instance) and [registers it](#addResourceProfile) immediately.

The default profile is available as [defaultResourceProfile](#defaultResourceProfile).

### Accessing Default ResourceProfile { #defaultResourceProfile }

```scala
defaultResourceProfile: ResourceProfile
```

`defaultResourceProfile` returns the [default ResourceProfile](#defaultProfile).

---

`defaultResourceProfile` is used when:

* `ExecutorAllocationManager` is [created](../dynamic-allocation/ExecutorAllocationManager.md#defaultProfileId)
* `SparkContext` is requested to [requestTotalExecutors](../SparkContext.md#requestTotalExecutors) and [createTaskScheduler](../SparkContext.md#createTaskScheduler)
* `DAGScheduler` is requested to [mergeResourceProfilesForStage](../scheduler/DAGScheduler.md#mergeResourceProfilesForStage)
* `CoarseGrainedSchedulerBackend` is requested to [requestExecutors](../scheduler/CoarseGrainedSchedulerBackend.md#requestExecutors)
* `StandaloneSchedulerBackend` ([Spark Standalone]({{ book.spark_standalone }}/StandaloneSchedulerBackend)) is created
* `KubernetesClusterSchedulerBackend` ([Spark on Kubernetes]({{ book.spark_k8s}}/KubernetesClusterSchedulerBackend)) is created
* `MesosCoarseGrainedSchedulerBackend` (Spark on Mesos) is created

## Registering ResourceProfile { #addResourceProfile }

```scala
addResourceProfile(
  rp: ResourceProfile): Unit
```

`addResourceProfile` [checks if the given ResourceProfile is supported](#isSupported).

`addResourceProfile` registers the given [ResourceProfile](ResourceProfile.md) (in the [resourceProfileIdToResourceProfile](#resourceProfileIdToResourceProfile) registry) unless done earlier (by [ResourceProfile ID](ResourceProfile.md#id)).

With a new `ResourceProfile`, `addResourceProfile` requests the given [ResourceProfile](ResourceProfile.md) for the [limiting resource](ResourceProfile.md#limitingResource) (for no reason but to calculate it upfront) and prints out the following INFO message to the logs:

```text
Added ResourceProfile id: [id]
```

In the end (for a new `ResourceProfile`), `addResourceProfile` requests the [LiveListenerBus](#listenerBus) to [post](../scheduler/LiveListenerBus.md#post) a [SparkListenerResourceProfileAdded](../SparkListenerEvent.md#SparkListenerResourceProfileAdded).

---

`addResourceProfile` is used when:

* [RDD.withResources](../rdd/RDD.md#withResources) operator is used
* `ResourceProfileManager` is created (and registers the [default profile](#defaultProfile))
* `DAGScheduler` is requested to [mergeResourceProfilesForStage](../scheduler/DAGScheduler.md#mergeResourceProfilesForStage)

## Dynamic Allocation { #dynamicEnabled }

`ResourceProfileManager` initializes `dynamicEnabled` flag to be [isDynamicAllocationEnabled](../Utils.md#isDynamicAllocationEnabled) when [created](#creating-instance).

`dynamicEnabled` flag is used when:

* [isSupported](#isSupported)
* [canBeScheduled](#canBeScheduled)

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

`canBeScheduled` asserts that the given `taskRpId` and `executorRpId` are [valid ResourceProfile IDs](#resourceProfileIdToResourceProfile) or throws an `AssertionError`:

```text
Tasks and executors must have valid resource profile id
```

`canBeScheduled` [finds the ResourceProfile](#resourceProfileFromId).

`canBeScheduled` holds positive (`true`) when either holds:

1. The given `taskRpId` and `executorRpId` are the same
1. [Dynamic Allocation](#dynamicEnabled) is disabled and the `ResourceProfile` is a [TaskResourceProfile](TaskResourceProfile.md)

---

`canBeScheduled` is used when:

* `TaskSchedulerImpl` is requested to [resourceOfferSingleTaskSet](../scheduler/TaskSchedulerImpl.md#resourceOfferSingleTaskSet) and [calculateAvailableSlots](../scheduler/TaskSchedulerImpl.md#calculateAvailableSlots)

## Logging

Enable `ALL` logging level for `org.apache.spark.resource.ResourceProfileManager` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.ResourceProfileManager.name = org.apache.spark.resource.ResourceProfileManager
logger.ResourceProfileManager.level = all
```

Refer to [Logging](../spark-logging.md).
