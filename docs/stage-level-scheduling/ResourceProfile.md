# ResourceProfile

`ResourceProfile` is a resource profile that describes [executor](#executorResources) and [task](#taskResources) requirements of an [RDD](../rdd/RDD.md) in [Stage-Level Scheduling](index.md).

`ResourceProfile` can be associated with an `RDD` using [RDD.withResources](../rdd/RDD.md#withResources) method.

The `ResourceProfile` of an `RDD` is available using [RDD.getResourceProfile](#getResourceProfile) method.

## Creating Instance

`ResourceProfile` takes the following to be created:

* <span id="executorResources"> Executor Resources (`Map[String, ExecutorResourceRequest]`)
* <span id="taskResources"> Task Resources (`Map[String, TaskResourceRequest]`)

`ResourceProfile` is created (directly or using [getOrCreateDefaultProfile](#getOrCreateDefaultProfile)) when:

* `DriverEndpoint` is requested to [handle a RetrieveSparkAppConfig message](../scheduler/DriverEndpoint.md#RetrieveSparkAppConfig)
* `ResourceProfileBuilder` utility is requested to [build](ResourceProfileBuilder.md#build)

## Built-In Executor Resources { #allSupportedExecutorResources }

`ResourceProfile` defines the following names as the **Supported Executor Resources** (among the specified [executorResources](#executorResources)):

* `cores`
* `memory`
* `memoryOverhead`
* `pyspark.memory`
* `offHeap`

All other executor resources (names) are considered [Custom Executor Resources](#getCustomExecutorResources).

## Custom Executor Resources { #getCustomExecutorResources }

```scala
getCustomExecutorResources(): Map[String, ExecutorResourceRequest]
```

`getCustomExecutorResources` is the [Executor Resources](#executorResources) that are not [supported executor resources](ResourceProfile.md#allSupportedExecutorResources).

---

`getCustomExecutorResources` is used when:

* `ApplicationDescription` is requested to `resourceReqsPerExecutor`
* `ApplicationInfo` is requested to `createResourceDescForResourceProfile`
* `ResourceProfile` is requested to [calculateTasksAndLimitingResource](#calculateTasksAndLimitingResource)
* `ResourceUtils` is requested to [getOrDiscoverAllResourcesForResourceProfile](ResourceUtils.md#getOrDiscoverAllResourcesForResourceProfile), [warnOnWastedResources](ResourceUtils.md#warnOnWastedResources)

## Limiting Resource { #limitingResource }

```scala
limitingResource(
  sparkConf: SparkConf): String
```

`limitingResource` takes the [_limitingResource](#_limitingResource), if calculated earlier, or [calculateTasksAndLimitingResource](#calculateTasksAndLimitingResource).

---

`limitingResource` is used when:

* `ResourceProfileManager` is requested to [add a new ResourceProfile](ResourceProfileManager.md#addResourceProfile) (to recompute a limiting resource eagerly)
* `ResourceUtils` is requested to [warnOnWastedResources](ResourceUtils.md#warnOnWastedResources) (for reporting purposes only)

### _limitingResource { #_limitingResource }

```scala
_limitingResource: Option[String] = None
```

`ResourceProfile` defines `_limitingResource` variable that is determined (if there is one) while [calculateTasksAndLimitingResource](#calculateTasksAndLimitingResource).

`_limitingResource` can be the following:

* A "special" empty resource identifier (that is assumed `cpus` in [TaskSchedulerImpl](../scheduler/TaskSchedulerImpl.md#calculateAvailableSlots))
* `cpus` built-in task resource identifier
* any [custom resource identifier](#getCustomExecutorResources)

## Default Profile { #defaultProfile }

`ResourceProfile` (Scala object) defines `defaultProfile` internal registry for the default [ResourceProfile](ResourceProfile.md) (per JVM instance).

`defaultProfile` is undefined (`None`) and gets a new `ResourceProfile` when first [requested](#getOrCreateDefaultProfile).

`defaultProfile` can be accessed using [getOrCreateDefaultProfile](#getOrCreateDefaultProfile).

`defaultProfile` is cleared (_removed_) in [clearDefaultProfile](#clearDefaultProfile).

### getOrCreateDefaultProfile { #getOrCreateDefaultProfile }

```scala
getOrCreateDefaultProfile(
  conf: SparkConf): ResourceProfile
```

`getOrCreateDefaultProfile` returns the [default profile](#defaultProfile) (if already defined) or creates a new one.

Unless defined, `getOrCreateDefaultProfile` creates a [ResourceProfile](#creating-instance) with the default [task](#getDefaultTaskResources) and [executor](#getDefaultExecutorResources) resource descriptions and makes it the [defaultProfile](#defaultProfile).

`getOrCreateDefaultProfile` prints out the following INFO message to the logs:

```text
Default ResourceProfile created,
executor resources: [executorResources], task resources: [taskResources]
```

---

`getOrCreateDefaultProfile` is used when:

* `TaskResourceProfile` is requested to [getCustomExecutorResources](TaskResourceProfile.md#getCustomExecutorResources)
* `ResourceProfile` is requested to [getDefaultProfileExecutorResources](#getDefaultProfileExecutorResources)
* `ResourceProfileManager` is [created](ResourceProfileManager.md#defaultProfile)
* `YarnAllocator` (Spark on YARN) is requested to `initDefaultProfile`

### Default Executor Resource Requests { #getDefaultExecutorResources }

```scala
getDefaultExecutorResources(
  conf: SparkConf): Map[String, ExecutorResourceRequest]
```

`getDefaultExecutorResources` creates an [ExecutorResourceRequests](ExecutorResourceRequests.md) with the following:

Property | Configuration Property
---------|----------
 [cores](ExecutorResourceRequests.md#cores)   | [spark.executor.cores](../configuration-properties.md#spark.executor.cores)
 [memory](ExecutorResourceRequests.md#memory) | [spark.executor.memory](../configuration-properties.md#spark.executor.memory)
 [memoryOverhead](ExecutorResourceRequests.md#memoryOverhead) | [spark.executor.memoryOverhead](../configuration-properties.md#spark.executor.memoryOverhead)
 [pysparkMemory](ExecutorResourceRequests.md#pysparkMemory)   | [spark.executor.pyspark.memory](../configuration-properties.md#spark.executor.pyspark.memory)
 [offHeapMemory](ExecutorResourceRequests.md#offHeapMemory)   | [spark.memory.offHeap.size](../Utils.md#executorOffHeapMemorySizeAsMb)

`getDefaultExecutorResources` [finds executor resource requests](ResourceUtils.md#parseAllResourceRequests) (with the `spark.executor` component name in the given [SparkConf](../SparkConf.md)) for [ExecutorResourceRequests](ExecutorResourceRequests.md#resource).

`getDefaultExecutorResources` initializes the [defaultProfileExecutorResources](#defaultProfileExecutorResources) (with the executor resource requests).

In the end, `getDefaultExecutorResources` requests the `ExecutorResourceRequests` for [all the resource requests](ExecutorResourceRequests.md#requests)

### Default Task Resource Requests { #getDefaultTaskResources }

```scala
getDefaultTaskResources(
  conf: SparkConf): Map[String, TaskResourceRequest]
```

`getDefaultTaskResources` creates a new [TaskResourceRequests](TaskResourceRequests.md) with the [cpus](TaskResourceRequests.md#cpus) based on [spark.task.cpus](../configuration-properties.md#spark.task.cpus) configuration property.

`getDefaultTaskResources` [adds task resource requests](ResourceUtils.md#addTaskResourceRequests) (configured in the given [SparkConf](../SparkConf.md) using `spark.task.resource`-prefixed properties).

In the end, `getDefaultTaskResources` requests the `TaskResourceRequests` for the [requests](TaskResourceRequests.md#requests).

## <span id="getResourcesForClusterManager"> getResourcesForClusterManager

```scala
getResourcesForClusterManager(
  rpId: Int,
  execResources: Map[String, ExecutorResourceRequest],
  overheadFactor: Double,
  conf: SparkConf,
  isPythonApp: Boolean,
  resourceMappings: Map[String, String]): ExecutorResourcesOrDefaults
```

`getResourcesForClusterManager` [takes the DefaultProfileExecutorResources](#getDefaultProfileExecutorResources).

`getResourcesForClusterManager` [calculates the overhead memory](#calculateOverHeadMemory) with the following:

* `memoryOverheadMiB` and `executorMemoryMiB` of the `DefaultProfileExecutorResources`
* Given `overheadFactor`

If the given `rpId` resource profile ID is not the default ID (`0`), `getResourcesForClusterManager`...FIXME (_there is so much to "digest"_)

`getResourcesForClusterManager`...FIXME

In the end, `getResourcesForClusterManager` creates a `ExecutorResourcesOrDefaults`.

---

`getResourcesForClusterManager` is used when:

* `BasicExecutorFeatureStep` ([Spark on Kubernetes]({{ book.spark_k8s }}/BasicExecutorFeatureStep#execResources)) is created
* `YarnAllocator` (Spark on YARN) is requested to `createYarnResourceForResourceProfile`

## getDefaultProfileExecutorResources { #getDefaultProfileExecutorResources }

```scala
getDefaultProfileExecutorResources(
  conf: SparkConf): DefaultProfileExecutorResources
```

`getDefaultProfileExecutorResources`...FIXME

---

`getDefaultProfileExecutorResources` is used when:

* `ResourceProfile` is requested to [getResourcesForClusterManager](#getResourcesForClusterManager)
* `YarnAllocator` (Spark on YARN) is requested to `runAllocatedContainers`

## Serializable

`ResourceProfile` is a Java [Serializable]({{ java.api }}/java/io/Serializable.html).

## Logging

Enable `ALL` logging level for `org.apache.spark.resource.ResourceProfile` logger to see what happens inside.

Add the following line to `conf/log4j2.properties`:

```text
logger.ResourceProfile.name = org.apache.spark.resource.ResourceProfile
logger.ResourceProfile.level = all
```

Refer to [Logging](../spark-logging.md).
