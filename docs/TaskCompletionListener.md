---
tags:
  - DeveloperApi
---

# TaskCompletionListener

`TaskCompletionListener` is an [extension](#contract) of the `EventListener` ([Java]({{ java.api }}/java.base/java/util/EventListener.html)) abstraction for [task listeners](#implementations) that can be notified [on task completion](#onTaskCompletion).

## Contract

### <span id="onTaskCompletion"> onTaskCompletion

```scala
onTaskCompletion(
  context: TaskContext): Unit
```

Used when:

* `TaskContextImpl` is requested to [addTaskCompletionListener](scheduler/TaskContextImpl.md#addTaskCompletionListener) (and a task has already completed) and [markTaskCompleted](scheduler/TaskContextImpl.md#markTaskCompleted)
* `ShuffleFetchCompletionListener` is requested to [onComplete](storage/ShuffleFetchCompletionListener.md#onComplete)
