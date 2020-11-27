== [[TaskResult]] TaskResults -- DirectTaskResult and IndirectTaskResult

`TaskResult` models a task result. It has exactly two concrete implementations:

1. <<DirectTaskResult, DirectTaskResult>> is the `TaskResult` to be serialized and sent over the wire to the driver together with the result bytes and accumulators.
2. <<IndirectTaskResult, IndirectTaskResult>> is the `TaskResult` that is just a pointer to a task result in a `BlockManager`.

The decision of the concrete `TaskResult` is made when a executor:TaskRunner.md#run[`TaskRunner` finishes running a task and checks the size of the result].

NOTE: The types are `private[spark]`.

=== [[DirectTaskResult]] `DirectTaskResult` Task Result

[source, scala]
----
DirectTaskResult[T](
  var valueBytes: ByteBuffer,
  var accumUpdates: Seq[AccumulatorV2[_, _]])
extends TaskResult[T] with Externalizable
----

`DirectTaskResult` is the <<TaskResult, TaskResult>> of scheduler:Task.md#run[running a task] (that is later executor:TaskRunner.md#run[returned serialized to the driver]) when the size of the task's result is smaller than configuration-properties.md#spark.driver.maxResultSize[spark.driver.maxResultSize] and executor:Executor.md#spark.task.maxDirectResultSize[spark.task.maxDirectResultSize] (or scheduler:CoarseGrainedSchedulerBackend.md#spark.rpc.message.maxSize[spark.rpc.message.maxSize] whatever is smaller).

NOTE: `DirectTaskResult` is Java's https://docs.oracle.com/javase/8/docs/api/java/io/Externalizable.html[java.io.Externalizable].

=== [[IndirectTaskResult]] `IndirectTaskResult` Task Result

[source, scala]
----
IndirectTaskResult[T](blockId: BlockId, size: Int)
extends TaskResult[T] with Serializable
----

`IndirectTaskResult` is a <<TaskResult, TaskResult>> that...

NOTE: `IndirectTaskResult` is Java's https://docs.oracle.com/javase/8/docs/api/java/io/Serializable.html[java.io.Serializable].
