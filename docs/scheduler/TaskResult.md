# TaskResult

`TaskResult` is an abstraction of task results (of type `T`).

The decision what `TaskResult` type to use is made when `TaskRunner` [finishes running a task](../executor/TaskRunner.md#run-serializedResult).

??? note "Sealed Trait"
    `TaskResult` is a Scala **sealed trait** which means that all of the implementations are in the same compilation unit (a single file).

    ```scala
    sealed trait TaskResult[T]
    ```

## <span id="DirectTaskResult"> DirectTaskResult

`DirectTaskResult` is a `TaskResult` to be serialized and sent over the wire to the driver together with the following:

* <span id="valueBytes"> Value Bytes ([java.nio.ByteBuffer]({{ java.api }}/java.base/java/nio/ByteBuffer.html))
* <span id="accumUpdates"> [Accumulator](../accumulators/AccumulatorV2.md) updates
* <span id="metricPeaks"> Metric Peaks

`DirectTaskResult` is used when the size of a task result is below [spark.driver.maxResultSize](../configuration-properties.md#spark.driver.maxResultSize) and the [maximum size of direct results](../executor/Executor.md#maxDirectResultSize).

## <span id="IndirectTaskResult"> IndirectTaskResult

`IndirectTaskResult` is a "pointer" to a task result that is available in a [BlockManager](../storage/BlockManager.md):

* <span id="IndirectTaskResult-blockId"> [BlockId](../storage/BlockId.md)
* <span id="IndirectTaskResult-size"> Size

`IndirectTaskResult` is a [java.io.Serializable]({{ java.api }}/java.base/java/io/Serializable.html).

## <span id="Externalizable"> Externalizable

`DirectTaskResult` is an `Externalizable` ([Java]({{ java.api }}/java.base/java/io/Externalizable.html)).
