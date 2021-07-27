# ShuffleReader

`ShuffleReader` is an [abstraction](#contract) of [shuffle block readers](#implementations) that can [read combined key-value records for a reduce task](#read).

## Contract

### <span id="read"> Reading Combined Records (for Reduce Task)

```scala
read(): Iterator[Product2[K, C]]
```

Used when:

* [CoGroupedRDD](../rdd/CoGroupedRDD.md#compute), [ShuffledRDD](../rdd/ShuffledRDD.md#compute), and [SubtractedRDD](../rdd/SubtractedRDD.md#compute) are requested to compute a partition (for a `ShuffleDependency` dependency)
* `ShuffledRowRDD` ([Spark SQL]({{ book.spark_sql }}/ShuffledRowRDD)) is requested to `compute` a partition

## Implementations

* [BlockStoreShuffleReader](BlockStoreShuffleReader.md)
