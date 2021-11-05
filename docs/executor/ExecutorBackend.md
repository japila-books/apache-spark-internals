# ExecutorBackend

`ExecutorBackend` is an [abstraction](#contract) of [executor backends](#implementations) (that [TaskRunner](TaskRunner.md)s use to [send task status updates](#statusUpdate) to a scheduler).

![ExecutorBackend receives notifications from TaskRunners](../images/executor/ExecutorBackend.png)

`ExecutorBackend` acts as a bridge between executors and the driver.

## Contract

### <span id="statusUpdate"> statusUpdate

```scala
statusUpdate(
  taskId: Long,
  state: TaskState,
  data: ByteBuffer): Unit
```

Sending a status update to a scheduler

Used when:

* `TaskRunner` is requested to [run a task](TaskRunner.md#run)

## Implementations

* [CoarseGrainedExecutorBackend](CoarseGrainedExecutorBackend.md)
* [LocalSchedulerBackend](../local/LocalSchedulerBackend.md)
* `MesosExecutorBackend`
