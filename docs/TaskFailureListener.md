---
tags:
  - DeveloperApi
---

# TaskFailureListener

`TaskFailureListener` is an [extension](#contract) of the `EventListener` ([Java]({{ java.api }}/java.base/java/util/EventListener.html)) abstraction for [task listeners](#implementations) that can be notified [on task failure](#onTaskFailure).

## Contract

### <span id="onTaskFailure"> onTaskFailure

```scala
onTaskFailure(
  context: TaskContext,
  error: Throwable): Unit
```

Used when:

* `TaskContextImpl` is requested to [addTaskFailureListener](scheduler/TaskContextImpl.md#addTaskFailureListener) (and a task has already failed) and [markTaskFailed](scheduler/TaskContextImpl.md#markTaskFailed)
