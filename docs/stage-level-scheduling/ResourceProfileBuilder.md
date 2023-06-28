# ResourceProfileBuilder

`ResourceProfileBuilder` is a fluent API for Spark developers to [build ResourceProfiles](#build) (to associate with an RDD).

??? note "Available in Scala and Python APIs"
    `ResourceProfileBuilder` is available in Scala and Python APIs.

## Creating Instance

`ResourceProfileBuilder` takes no arguments to be created.

## Building ResourceProfile { #build }

```scala
build: ResourceProfile
```

`build` creates a [ResourceProfile](ResourceProfile.md):

* [TaskResourceProfile](TaskResourceProfile.md) when [_executorResources](#_executorResources) are undefined
* [ResourceProfile](ResourceProfile.md) with the [executorResources](#executorResources) and the [taskResources](#taskResources)

### Executor Resources { #executorResources }

```scala
executorResources: Map[String, ExecutorResourceRequest]
```

`executorResources`...FIXME

### <span id="_taskResources"> Task Resources { #taskResources }

```scala
taskResources: Map[String, TaskResourceRequest]
```

`taskResources` is [TaskResourceRequest](TaskResourceRequest.md)s specified by users (by their resource names)

`taskResources` are specified using [require](#require) method.

`taskResources` can be removed using [clearTaskResourceRequests](#clearTaskResourceRequests) method.

`taskResources` can be printed out using [toString](#toString) method.

`taskResources` is used when:

* `ResourceProfileBuilder` is requested to [build a ResourceProfile](#build)

## Demo

```scala
import org.apache.spark.resource.ResourceProfileBuilder
val rp1 = new ResourceProfileBuilder()

import org.apache.spark.resource.ExecutorResourceRequests
val execReqs = new ExecutorResourceRequests().cores(4).resource("gpu", 4)

import org.apache.spark.resource.ExecutorResourceRequests
val taskReqs = new TaskResourceRequests().cpus(1).resource("gpu", 1)

rp1.require(execReqs).require(taskReqs)
val rprof1 = rp1.build
```

```scala
val rpManager = sc.resourceProfileManager // (1)!
rpManager.addResourceProfile(rprof1)
```

1. NOTE: `resourceProfileManager` is `private[spark]`
