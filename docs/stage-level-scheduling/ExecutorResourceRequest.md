# ExecutorResourceRequest

## Creating Instance

`ExecutorResourceRequest` takes the following to be created:

* <span id="resourceName"> Resource Name
* <span id="amount"> Amount
* <span id="discoveryScript"> Discovery Script
* <span id="vendor"> Vendor

`ExecutorResourceRequest` is created when:

* `ExecutorResourceRequests` is requested to [memory](ExecutorResourceRequests.md#memory), [offHeapMemory](ExecutorResourceRequests.md#offHeapMemory), [memoryOverhead](ExecutorResourceRequests.md#memoryOverhead), [pysparkMemory](ExecutorResourceRequests.md#pysparkMemory), [cores](ExecutorResourceRequests.md#cores) and [resource](ExecutorResourceRequests.md#resource)
* `JsonProtocol` utility is used to [executorResourceRequestFromJson](../history-server/JsonProtocol.md#executorResourceRequestFromJson)

## Serializable

`ExecutorResourceRequest` is a `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)).
