# TaskResourceProfile

`TaskResourceProfile` is a [ResourceProfile](ResourceProfile.md).

## Creating Instance

`TaskResourceProfile` takes the following to be created:

* <span id="taskResources"> [Task Resources](ResourceProfile.md#taskResources)

`TaskResourceProfile` is created when:

* `ResourceProfileBuilder` is requested to [build a ResourceProfile](ResourceProfileBuilder.md#build)
* `DAGScheduler` is requested to [merge ResourceProfiles](../scheduler/DAGScheduler.md#mergeResourceProfiles)

## getCustomExecutorResources { #getCustomExecutorResources }

??? note "ResourceProfile"

    ```scala
    getCustomExecutorResources(): Map[String, ExecutorResourceRequest]
    ```

    `getCustomExecutorResources` is part of the [ResourceProfile](ResourceProfile.md#getCustomExecutorResources) abstraction.

`getCustomExecutorResources`...FIXME
