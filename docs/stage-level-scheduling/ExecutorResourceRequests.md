# ExecutorResourceRequests

`ExecutorResourceRequests` is a set of [ExecutorResourceRequest](ExecutorResourceRequest.md)s for Spark developers to (programmatically) specify resources for an RDD to be applied at stage level:

* `cores`
* `memory`
* `memoryOverhead`
* `offHeap`
* `pyspark.memory`
* [custom resource](#resource)

## Creating Instance

`ExecutorResourceRequests` takes no arguments to be created.

`ExecutorResourceRequests` is created when:

* `ResourceProfile` utility is used to [get the default executor resource requests (for tasks)](ResourceProfile.md#getDefaultExecutorResources)

## Serializable

`ExecutorResourceRequests` is a `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)).

## <span id="resource"> resource

```scala
resource(
  resourceName: String,
  amount: Long,
  discoveryScript: String = "",
  vendor: String = ""): this.type
```

`resource` creates a [ExecutorResourceRequest](ExecutorResourceRequest.md) and registers it under `resourceName`.

`resource` is used when:

* `ResourceProfile` utility is used for the [default executor resources](ResourceProfile.md#getDefaultExecutorResources)

## <span id="toString"> Text Representation

`ExecutorResourceRequests` presents itself as:

```text
Executor resource requests: [_executorResources]
```

## Demo

```scala
import org.apache.spark.resource.ExecutorResourceRequests
val executorResources = new ExecutorResourceRequests()
  .memory("2g")
  .memoryOverhead("512m")
  .cores(8)
  .resource(
    resourceName = "my-custom-resource",
    amount = 1,
    discoveryScript = "/this/is/path/to/discovery/script.sh",
    vendor = "pl.japila")
```

```text
scala> println(executorResources)
Executor resource requests: {memoryOverhead=name: memoryOverhead, amount: 512, script: , vendor: , memory=name: memory, amount: 2048, script: , vendor: , cores=name: cores, amount: 8, script: , vendor: , my-custom-resource=name: my-custom-resource, amount: 1, script: /this/is/path/to/discovery/script.sh, vendor: pl.japila}
```
