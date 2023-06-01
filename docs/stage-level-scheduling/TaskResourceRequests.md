# TaskResourceRequests

`TaskResourceRequests` is a convenience API to work with [TaskResourceRequests](#_taskResources) (and hence the name 😉).

`TaskResourceRequests` can be defined as [required](ResourceProfileBuilder.md#require) using [ResourceProfileBuilder](ResourceProfileBuilder.md).

`TaskResourceRequests` can be specified using [configuration properties](ResourceUtils.md#addTaskResourceRequests) (using `spark.task` prefix).

Resource Name | Registerer
--------------|-----------
 `cpus` | [cpus](#cpus)
 user-defined name | [resource](#resource), [addRequest](#addRequest)

## Creating Instance

`TaskResourceRequests` takes no arguments to be created.

`TaskResourceRequests` is created when:

* `ResourceProfile` is requested for the [default task resource requests](ResourceProfile.md#getDefaultTaskResources)

## Serializable

`TaskResourceRequests` is `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)).

## cpus

```scala
cpus(
  amount: Int): this.type
```

`cpus` registers a [TaskResourceRequest](TaskResourceRequest.md) with `cpus` resource name and the given `amount` (in the [_taskResources](#_taskResources) registry) under the name `cpus`.

!!! note "Fluent API"
    `cpus` is part of the fluent API of (and hence this strange-looking `this.type` return type).

---

`cpus` is used when:

* `ResourceProfile` is requested for the [default task resource requests](#getDefaultTaskResources)

## _taskResources { #_taskResources }

```scala
_taskResources: ConcurrentHashMap[String, TaskResourceRequest]
```

`_taskResources` is a collection of [TaskResourceRequest](TaskResourceRequest.md)s by their resource name.

`_taskResources` is available as [requests](#requests).

## requests

```scala
requests: Map[String, TaskResourceRequest]
```

`requests` returns the [_taskResources](#_taskResources) (converted to Scala).

---

`requests` is used when:

* `ResourceProfile` is requested for the [default task resource requests](#getDefaultTaskResources)
* `ResourceProfileBuilder` is requested to [require](ResourceProfileBuilder.md#require)
* `TaskResourceRequests` is requested for the [string representation](#toString)
