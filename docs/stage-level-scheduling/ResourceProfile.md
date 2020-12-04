# ResourceProfile

`ResourceProfile` is a resource profile (with [executor](#executorResources) and [task](#taskResources) requirements) for **Stage Level Scheduling**.

`ResourceProfile` is a Java [Serializable]({{ java.api }}/java.base/java/io/Serializable.html).

## Creating Instance

`ResourceProfile` takes the following to be created:

* <span id="executorResources"> Executor Resources (`Map[String, ExecutorResourceRequest]`)
* <span id="taskResources"> Task Resources (`Map[String, TaskResourceRequest]`)

`ResourceProfile` is created (directly or using [getOrCreateDefaultProfile](#getOrCreateDefaultProfile)) when:

* `DriverEndpoint` is requested to [handle a RetrieveSparkAppConfig message](../scheduler/DriverEndpoint.md#RetrieveSparkAppConfig)
* `ResourceProfileBuilder` utility is requested to [build](ResourceProfileBuilder.md#build)

## <span id="getOrCreateDefaultProfile"> getOrCreateDefaultProfile Utility

```scala
getOrCreateDefaultProfile(
  conf: SparkConf): ResourceProfile
```

`getOrCreateDefaultProfile`...FIXME

`getOrCreateDefaultProfile` is used when:

* `DriverEndpoint` is requested to [handle a RetrieveSparkAppConfig message](../scheduler/DriverEndpoint.md#RetrieveSparkAppConfig)
