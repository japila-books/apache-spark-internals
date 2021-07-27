# CoGroupedRDD

`CoGroupedRDD[K]` is an [RDD](RDD.md) that cogroups the [parent RDDs](#rdds).

```scala
RDD[(K, Array[Iterable[_]])]
```

For each key `k` in parent RDDs, the resulting RDD contains a tuple with the list of values for that key.

## Creating Instance

`CoGroupedRDD` takes the following to be created:

* <span id="rdds"> Key-Value [RDD](RDD.md)s (`Seq[RDD[_ <: Product2[K, _]]]`)
* <span id="part"> [Partitioner](Partitioner.md)

`CoGroupedRDD` is created when:

* [RDD.cogroup](PairRDDFunctions.md#cogroup) operator is used
