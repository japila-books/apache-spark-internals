---
tags:
  - DeveloperApi
---

# PartitionEvaluatorFactory

`PartitionEvaluatorFactory[T, U]` is an [abstraction](#contract) of [PartitionEvaluator factories](#implementations).

`PartitionEvaluatorFactory` is a `Serializable` ([Java]({{ java.api }}/java/io/Serializable.html)).

## Contract

### Creating PartitionEvaluator { #createEvaluator }

```scala
createEvaluator(): PartitionEvaluator[T, U]
```

Creates a [PartitionEvaluator](PartitionEvaluator.md)

Used when:

* `MapPartitionsWithEvaluatorRDD` is requested to [compute a partition](rdd/MapPartitionsWithEvaluatorRDD.md#compute)
* `ZippedPartitionsWithEvaluatorRDD` is requested to [compute a partition](rdd/ZippedPartitionsWithEvaluatorRDD.md#compute)

## Implementations

!!! note
    No built-in implementations available in Spark Core (but [Spark SQL]({{ book.spark_sql }})).
