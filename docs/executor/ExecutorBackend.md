# ExecutorBackend

`ExecutorBackend` is an [abstraction](#contract) of [executor backends](#implementations) (that [TaskRunner](TaskRunner.md)s use to [report task status updates](#statusUpdate) to a scheduler).

![ExecutorBackend receives notifications from TaskRunners](../images/executor/ExecutorBackend.png)

`ExecutorBackend` acts as a bridge between executors and the driver.

## Contract

### Reporting Task Status { #statusUpdate }

```scala
statusUpdate(
  taskId: Long,
  state: TaskState,
  data: ByteBuffer): Unit
```

Reports task status of the given task to a scheduler

See:

* [CoarseGrainedExecutorBackend](CoarseGrainedExecutorBackend.md#statusUpdate)

Used when:

* `TaskRunner` is requested to [run a task](TaskRunner.md#run)

## Implementations

* [CoarseGrainedExecutorBackend](CoarseGrainedExecutorBackend.md)
* [LocalSchedulerBackend](../local/LocalSchedulerBackend.md)
* `MesosExecutorBackend`
