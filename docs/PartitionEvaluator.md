---
tags:
  - DeveloperApi
---

# PartitionEvaluator

`PartitionEvaluator[T, U]` is an [abstraction](#contract) of [partition evaluators](#implementations) that can [compute (_evaluate_) one or more RDD partitions](#eval).

## Contract

### Evaluate Partitions { #eval }

```scala
eval(
  partitionIndex: Int,
  inputs: Iterator[T]*): Iterator[U]
```

Used when:

* `MapPartitionsWithEvaluatorRDD` is requested to [compute a partition](rdd/MapPartitionsWithEvaluatorRDD.md#compute)
* `ZippedPartitionsWithEvaluatorRDD` is requested to [compute a partition](rdd/ZippedPartitionsWithEvaluatorRDD.md#compute)

## Implementations

!!! note
    No built-in implementations available in Spark Core (but [Spark SQL]({{ book.spark_sql }})).
