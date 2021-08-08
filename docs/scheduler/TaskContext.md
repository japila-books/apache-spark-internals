# TaskContext

`TaskContext` is an [abstraction](#contract) of [task contexts](#implementations).

## Contract

### <span id="addTaskCompletionListener"> addTaskCompletionListener

```scala
addTaskCompletionListener[U](
  f: (TaskContext) => U): TaskContext
addTaskCompletionListener(
  listener: TaskCompletionListener): TaskContext
```

Registers a [TaskCompletionListener](../TaskCompletionListener.md)

```scala
val rdd = sc.range(0, 5, numSlices = 1)

import org.apache.spark.TaskContext
val printTaskInfo = (tc: TaskContext) => {
  val msg = s"""|-------------------
                |partitionId:   ${tc.partitionId}
                |stageId:       ${tc.stageId}
                |attemptNum:    ${tc.attemptNumber}
                |taskAttemptId: ${tc.taskAttemptId}
                |-------------------""".stripMargin
  println(msg)
}

rdd.foreachPartition { _ =>
  val tc = TaskContext.get
  tc.addTaskCompletionListener(printTaskInfo)
}
```

### <span id="addTaskFailureListener"> addTaskFailureListener

```scala
addTaskFailureListener(
  f: (TaskContext, Throwable) => Unit): TaskContext
addTaskFailureListener(
  listener: TaskFailureListener): TaskContext
```

Registers a [TaskFailureListener](../TaskFailureListener.md)

```scala
val rdd = sc.range(0, 2, numSlices = 2)

import org.apache.spark.TaskContext
val printTaskErrorInfo = (tc: TaskContext, error: Throwable) => {
  val msg = s"""|-------------------
                |partitionId:   ${tc.partitionId}
                |stageId:       ${tc.stageId}
                |attemptNum:    ${tc.attemptNumber}
                |taskAttemptId: ${tc.taskAttemptId}
                |error:         ${error.toString}
                |-------------------""".stripMargin
  println(msg)
}

val throwExceptionForOddNumber = (n: Long) => {
  if (n % 2 == 1) {
    throw new Exception(s"No way it will pass for odd number: $n")
  }
}

// FIXME It won't work.
rdd.map(throwExceptionForOddNumber).foreachPartition { _ =>
  val tc = TaskContext.get
  tc.addTaskFailureListener(printTaskErrorInfo)
}

// Listener registration matters.
rdd.mapPartitions { (it: Iterator[Long]) =>
  val tc = TaskContext.get
  tc.addTaskFailureListener(printTaskErrorInfo)
  it
}.map(throwExceptionForOddNumber).count
```

### <span id="fetchFailed"> fetchFailed

```scala
fetchFailed: Option[FetchFailedException]
```

Used when:

* `TaskRunner` is requested to [run](../executor/TaskRunner.md#run)

### <span id="getKillReason"> getKillReason

```scala
getKillReason(): Option[String]
```

### <span id="getLocalProperty"> getLocalProperty

```scala
getLocalProperty(
  key: String): String
```

Looks up a [local property](../SparkContext.md#localProperties) by `key`

### <span id="getMetricsSources"> getMetricsSources

```scala
getMetricsSources(
  sourceName: String): Seq[Source]
```

Looks up [Source](../metrics/Source.md)s by name

### <span id="isCompleted"> isCompleted

```scala
isCompleted(): Boolean
```

### <span id="isInterrupted"> isInterrupted

```scala
isInterrupted(): Boolean
```

### <span id="killTaskIfInterrupted"> killTaskIfInterrupted

```scala
killTaskIfInterrupted(): Unit
```

### <span id="registerAccumulator"> Registering Accumulator

```scala
registerAccumulator(
  a: AccumulatorV2[_, _]): Unit
```

Registers a [AccumulatorV2](../accumulators/AccumulatorV2.md)

Used when:

* `AccumulatorV2` is requested to [deserialize itself](../accumulators/AccumulatorV2.md#readObject)

### <span id="resources"> resources

```scala
resources(): Map[String, ResourceInformation]
```

Resources allocated to the task

### <span id="taskMetrics"> taskMetrics

```scala
taskMetrics(): TaskMetrics
```

[TaskMetrics](../executor/TaskMetrics.md)

### others

!!! important
    There are other methods, but don't seem very interesting.

## Implementations

* [BarrierTaskContext](BarrierTaskContext.md)
* [TaskContextImpl](TaskContextImpl.md)

## <span id="Serializable"> Serializable

`TaskContext` is a `Serializable` ([Java]({{ java.api }}/java.base/java/io/Serializable.html)).

## <span id="get"> Accessing TaskContext

```scala
get(): TaskContext
```

`get` returns the thread-local `TaskContext` instance.

```scala
import org.apache.spark.TaskContext
val tc = TaskContext.get
```

```scala
val rdd = sc.range(0, 3, numSlices = 3)

assert(rdd.partitions.size == 3)

rdd.foreach { n =>
  import org.apache.spark.TaskContext
  val tc = TaskContext.get
  val msg = s"""|-------------------
                |partitionId:   ${tc.partitionId}
                |stageId:       ${tc.stageId}
                |attemptNum:    ${tc.attemptNumber}
                |taskAttemptId: ${tc.taskAttemptId}
                |-------------------""".stripMargin
  println(msg)
}
```
