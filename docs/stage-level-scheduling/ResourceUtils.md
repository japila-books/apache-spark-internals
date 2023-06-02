# ResourceUtils

## Registering Task Resource Requests (from SparkConf) { #addTaskResourceRequests }

```scala
addTaskResourceRequests(
  sparkConf: SparkConf,
  treqs: TaskResourceRequests): Unit
```

`addTaskResourceRequests` registers all task resource requests in the given [SparkConf](../SparkConf.md) with the given [TaskResourceRequests](TaskResourceRequests.md).

---

`addTaskResourceRequests` [listResourceIds](#listResourceIds) with `spark.task` component name in the given [SparkConf](../SparkConf.md).

For every [ResourceID](ResourceID.md) discovered, `addTaskResourceRequests` does the following:

1. [Finds all the settings](../SparkConf.md#getAllWithPrefix) with the [confPrefix](ResourceID.md#confPrefix)
1. Looks up `amount` setting (or throws a `SparkException`)
1. [Registers](TaskResourceRequests.md#resource) the [resourceName](ResourceID.md#resourceName) with the `amount` in the given [TaskResourceRequests](TaskResourceRequests.md)

---

`addTaskResourceRequests` is used when:

* `ResourceProfile` is requested for the [default task resource requests](ResourceProfile.md#getDefaultTaskResources)

## Listing All Configured Resources { #listResourceIds }

```scala
listResourceIds(
  sparkConf: SparkConf,
  componentName: String): Seq[ResourceID]
```

`listResourceIds` requests the given [SparkConf](../SparkConf.md) to [find all Spark settings with the keys with the prefix](../SparkConf.md#getAllWithPrefix) of the following pattern:

```text
[componentName].resource.
```

??? note "Internals"
    `listResourceIds` gets resource-related settings (from [SparkConf](../SparkConf.md)) with the prefix removed (e.g., `spark.my_component.resource.gpu.amount` becomes just `gpu.amount`).

    ```scala title="Example"
    // Use the following to start spark-shell
    // ./bin/spark-shell -c spark.my_component.resource.gpu.amount=5
    
    val sparkConf = sc.getConf

    // Component names must start with `spark.` prefix
    // Spark assumes valid Spark settings start with `spark.` prefix
    val componentName = "spark.my_component"

    // this is copied verbatim from ResourceUtils.listResourceIds
    // Note that `resource` is hardcoded
    sparkConf.getAllWithPrefix(s"$componentName.resource.").foreach(println)

    // (gpu.amount,5)
    ```

`listResourceIds` asserts that resource settings include a `.` (dot) to separate their resource names from configs or throws the following `SparkException`:

```text
You must specify an amount config for resource: [key] config: [componentName].resource.[key]
```

??? note "SPARK-43947"
    Although the exception says `You must specify an amount config for resource`, only the dot is checked.

    ```text
    // Use the following to start spark-shell
    // 1. No amount config specified
    // 2. spark.driver is a Spark built-in resource
    // ./bin/spark-shell -c spark.driver.resource.gpu=5
    ```

    Reported as [SPARK-43947](https://issues.apache.org/jira/browse/SPARK-43947).

In the end, `listResourceIds` creates a [ResourceID](ResourceID.md) for every resource (with the given`componentName` and resource names discovered).

---

`listResourceIds` is used when:

* `ResourceUtils` is requested to [parseAllResourceRequests](#parseAllResourceRequests), [addTaskResourceRequests](#addTaskResourceRequests), [parseResourceRequirements](#parseResourceRequirements), [parseAllocatedOrDiscoverResources](#parseAllocatedOrDiscoverResources)

## parseAllResourceRequests { #parseAllResourceRequests }

```scala
parseAllResourceRequests(
  sparkConf: SparkConf,
  componentName: String): Seq[ResourceRequest]
```

`parseAllResourceRequests`...FIXME

When | componentName
-----|--------------
 [ResourceProfile](ResourceProfile.md#getDefaultExecutorResources) | `spark.executor`
 [ResourceUtils](#getOrDiscoverAllResources) |
 `KubernetesUtils` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesUtils)) |

---

`parseAllResourceRequests` is used when:

* `ResourceProfile` is requested for the [default executor resource requests](ResourceProfile.md#getDefaultExecutorResources)
* `ResourceUtils` is requested to [getOrDiscoverAllResources](#getOrDiscoverAllResources)
* `KubernetesUtils` ([Spark on Kubernetes]({{ book.spark_k8s }}/KubernetesUtils)) is requested to `buildResourcesQuantities`

## getOrDiscoverAllResources { #getOrDiscoverAllResources }

```scala
getOrDiscoverAllResources(
  sparkConf: SparkConf,
  componentName: String,
  resourcesFileOpt: Option[String]): Map[String, ResourceInformation]
```

`getOrDiscoverAllResources`...FIXME

When | componentName | resourcesFileOpt
-----|---------------|-----------------
 `SparkContext` | `spark.driver` | [spark.driver.resourcesFile](../configuration-properties.md#spark.driver.resourcesFile)
 `Worker` ([Spark Standalone]({{ book.spark_standalone }}/Worker)) | `spark.worker` | [spark.worker.resourcesFile](../configuration-properties.md#spark.worker.resourcesFile)

---

`getOrDiscoverAllResources` is used when:

* `SparkContext` is created (and initializes [_resources](../SparkContext.md#_resources))
* `Worker` ([Spark Standalone]({{ book.spark_standalone }}/Worker)) is requested to `setupWorkerResources`

### parseAllocatedOrDiscoverResources { #parseAllocatedOrDiscoverResources }

```scala
parseAllocatedOrDiscoverResources(
  sparkConf: SparkConf,
  componentName: String,
  resourcesFileOpt: Option[String]): Seq[ResourceAllocation]
```

`parseAllocatedOrDiscoverResources`...FIXME

## parseResourceRequirements (Spark Standalone) { #parseResourceRequirements }

```scala
parseResourceRequirements(
  sparkConf: SparkConf,
  componentName: String): Seq[ResourceRequirement]
```

`parseResourceRequirements`...FIXME

!!! note "componentName"
    `componentName` seems to be always `spark.driver` for the use cases that seems to be [Spark Standalone]({{ book.spark_standalone }}) only.

---

`parseResourceRequirements` is used when:

* `ClientEndpoint` ([Spark Standalone]({{ book.spark_standalone }}/ClientEndpoint)) is requested to `onStart`
* `StandaloneSubmitRequestServlet` ([Spark Standalone]({{ book.spark_standalone }}/StandaloneRestServer#StandaloneSubmitRequestServlet)) is requested to `buildDriverDescription`
