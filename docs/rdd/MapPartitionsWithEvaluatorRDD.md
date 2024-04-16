# MapPartitionsWithEvaluatorRDD

`MapPartitionsWithEvaluatorRDD` is an [RDD](RDD.md).

## Creating Instance

`MapPartitionsWithEvaluatorRDD` takes the following to be created:

* <span id="prev"> Previous [RDD](RDD.md)
* <span id="evaluatorFactory"> [PartitionEvaluatorFactory](../PartitionEvaluatorFactory.md)

`MapPartitionsWithEvaluatorRDD` is created when:

* [RDD.mapPartitionsWithEvaluator](RDD.md#mapPartitionsWithEvaluator) operator is used
* [RDDBarrier.mapPartitionsWithEvaluator](../barrier-execution-mode/RDDBarrier.md#mapPartitionsWithEvaluator) operator is used

## Computing Partition { #compute }

??? note "RDD"

    ```scala
    compute(
      split: Partition,
      context: TaskContext): Iterator[U]
    ```

    `compute` is part of the [RDD](RDD.md#compute) abstraction.

`compute` requests the [PartitionEvaluatorFactory](#evaluatorFactory) to [create a PartitionEvaluator](../PartitionEvaluatorFactory.md#createEvaluator).

`compute` requests the [first parent RDD](RDD.md#firstParent) to [iterator](RDD.md#iterator).

In the end, `compute` requests the [PartitionEvaluator](../PartitionEvaluator.md) to [evaluate the partition](../PartitionEvaluator.md#eval).
