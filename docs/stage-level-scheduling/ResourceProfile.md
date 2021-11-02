# ResourceProfile

`ResourceProfile` is a resource profile (with [executor](#executorResources) and [task](#taskResources) requirements) for [Stage Level Scheduling](index.md).

`ResourceProfile` is a Java [Serializable]({{ java.api }}/java.base/java/io/Serializable.html).

## Creating Instance

`ResourceProfile` takes the following to be created:

* <span id="executorResources"> Executor Resources (`Map[String, ExecutorResourceRequest]`)
* <span id="taskResources"> Task Resources (`Map[String, TaskResourceRequest]`)

`ResourceProfile` is created (directly or using [getOrCreateDefaultProfile](#getOrCreateDefaultProfile)) when:

* `DriverEndpoint` is requested to [handle a RetrieveSparkAppConfig message](../scheduler/DriverEndpoint.md#RetrieveSparkAppConfig)
* `ResourceProfileBuilder` utility is requested to [build](ResourceProfileBuilder.md#build)

## <span id="getOrCreateDefaultProfile"> getOrCreateDefaultProfile

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

### <span id="getDefaultExecutorResources"> getDefaultExecutorResources

```scala
getDefaultExecutorResources(
  conf: SparkConf): Map[String, ExecutorResourceRequest]
```

`getDefaultExecutorResources`...FIXME
