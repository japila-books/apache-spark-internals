# ResourceProfileBuilder

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

## Creating Instance

`ResourceProfileBuilder` takes no arguments to be created.

## Building ResourceProfile { #build }

```scala
build: ResourceProfile
```

With [_executorResources](#_executorResources) empty, `build` creates a [TaskResourceProfile](TaskResourceProfile.md) (with the [taskResources](#taskResources)). Otherwise, `build` creates a [ResourceProfile](ResourceProfile.md) (with the [executorResources](#executorResources) and the [taskResources](#taskResources)).

### <span id="executorResources"> Executor Resources

```scala
executorResources: Map[String, ExecutorResourceRequest]
```

`executorResources`...FIXME

### <span id="taskResources"> Task Resources

```scala
taskResources: Map[String, TaskResourceRequest]
```

`taskResources`...FIXME
