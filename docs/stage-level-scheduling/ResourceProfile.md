# ResourceProfile

`ResourceProfile` is a resource profile (with [executor](#executorResources) and [task](#taskResources) requirements) for [Stage Level Scheduling](index.md).

`ResourceProfile` is associated with an `RDD` using [withResources](../rdd/RDD.md#withResources) operator.

## Creating Instance

`ResourceProfile` takes the following to be created:

* <span id="executorResources"> Executor Resources (`Map[String, ExecutorResourceRequest]`)
* <span id="taskResources"> Task Resources (`Map[String, TaskResourceRequest]`)

`ResourceProfile` is created (directly or using [getOrCreateDefaultProfile](#getOrCreateDefaultProfile)) when:

* `DriverEndpoint` is requested to [handle a RetrieveSparkAppConfig message](../scheduler/DriverEndpoint.md#RetrieveSparkAppConfig)
* `ResourceProfileBuilder` utility is requested to [build](ResourceProfileBuilder.md#build)

## Serializable

`ResourceProfile` is a Java [Serializable]({{ java.api }}/java/io/Serializable.html).

## <span id="defaultProfile"> Default Profile

`ResourceProfile` (object) defines `defaultProfile` internal registry with the default `ResourceProfile` (per JVM instance).

`defaultProfile` is `None` (undefined) by default and gets a new `ResourceProfile` in [getOrCreateDefaultProfile](#getOrCreateDefaultProfile).

`defaultProfile` is available using [getOrCreateDefaultProfile](#getOrCreateDefaultProfile).

`defaultProfile` is cleared (_removed_) in [clearDefaultProfile](#clearDefaultProfile).

### <span id="getOrCreateDefaultProfile"> getOrCreateDefaultProfile

```scala
getOrCreateDefaultProfile(
  conf: SparkConf): ResourceProfile
```

`getOrCreateDefaultProfile` returns the [default profile](#defaultProfile) (if defined) or creates a new one.

If undefined, `getOrCreateDefaultProfile` creates a [ResourceProfile](#creating-instance) with the default [task](#getDefaultTaskResources) and [executor](#getDefaultExecutorResources) resources and makes it the [defaultProfile](#defaultProfile).

`getOrCreateDefaultProfile` prints out the following INFO message to the logs:

```text
Default ResourceProfile created,
executor resources: [executorResources], task resources: [taskResources]
```

`getOrCreateDefaultProfile` is used when:

* `ResourceProfile` utility is used to [getDefaultProfileExecutorResources](#getDefaultProfileExecutorResources)
* `ResourceProfileManager` is [created](ResourceProfileManager.md#defaultProfile)
* `YarnAllocator` (Spark on YARN) is requested to `initDefaultProfile`

### <span id="getDefaultExecutorResources"> Default Executor Resources

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

`getResourcesForClusterManager` is used when:

* `BasicExecutorFeatureStep` ([Spark on Kubernetes]({{ book.spark_k8s }}/BasicExecutorFeatureStep#execResources)) is created
* `YarnAllocator` (Spark on YARN) is requested to `createYarnResourceForResourceProfile`
