# CoGroupedRDD

A RDD that cogroups its pair RDD parents. For each key k in parent RDDs, the resulting RDD contains a tuple with the list of values for that key.

Use `RDD.cogroup(...)` to create one.

== [[getDependencies]] getDependencies Method

CAUTION: FIXME

== [[compute]] Computing Partition (in TaskContext)

[source, scala]
----
compute(s: Partition, context: TaskContext): Iterator[(K, Array[Iterable[_]])]
----

compute...FIXME

compute is part of rdd:RDD.md#compute[RDD] abstraction.
