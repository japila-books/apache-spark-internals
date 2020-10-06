== Actions

*Actions* are spark-rdd-operations.md[RDD operations] that produce non-RDD values. They materialize a value in a Spark program. In other words, a RDD operation that returns a value of any type but `RDD[T]` is an action.

```
action: RDD => a value
```

NOTE: Actions are synchronous. You can use <<AsyncRDDActions, AsyncRDDActions>> to release a calling thread while calling actions.

They trigger execution of <<transformations, RDD transformations>> to return values. Simply put, an action evaluates the spark-rdd-lineage.md[RDD lineage graph].

You can think of actions as a valve and until action is fired, the data to be processed is not even in the pipes, i.e. transformations. Only actions can materialize the entire processing pipeline with real data.

Actions are one of two ways to send data from executor:Executor.md[executors] to the spark-driver.md[driver] (the other being spark-accumulators.md[accumulators]).

Actions in http://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.rdd.RDD[org.apache.spark.rdd.RDD]:

* `aggregate`
* `collect`
* `count`
* `countApprox*`
* `countByValue*`
* `first`
* `fold`
* `foreach`
* `foreachPartition`
* `max`
* `min`
* `reduce`
* spark-io.md#saving-rdds-to-files[saveAs* actions], e.g. `saveAsTextFile`, `saveAsHadoopFile`
* `take`
* `takeOrdered`
* `takeSample`
* `toLocalIterator`
* `top`
* `treeAggregate`
* `treeReduce`

Actions run spark-scheduler-ActiveJob.md[jobs] using ROOT:SparkContext.md#runJob[SparkContext.runJob] or directly scheduler:DAGScheduler.md#runJob[DAGScheduler.runJob].

[source,scala]
----
scala> words.count  // <1>
res0: Long = 502
----
<1> `words` is an RDD of `String`.

TIP: You should cache RDDs you work with when you want to execute two or more actions on it for a better performance. Refer to spark-rdd-caching.md[RDD Caching and Persistence].

Before calling an action, Spark does closure/function cleaning (using `SparkContext.clean`) to make it ready for serialization and sending over the wire to executors. Cleaning can throw a `SparkException` if the computation cannot be cleaned.

NOTE: Spark uses `ClosureCleaner` to clean closures.

=== [[AsyncRDDActions]] AsyncRDDActions

`AsyncRDDActions` class offers asynchronous actions that you can use on RDDs (thanks to the implicit conversion `rddToAsyncRDDActions` in RDD class). The methods return a <<FutureAction, FutureAction>>.

The following asynchronous methods are available:

* `countAsync`
* `collectAsync`
* `takeAsync`
* `foreachAsync`
* `foreachPartitionAsync`

=== [[FutureAction]] FutureActions

CAUTION: FIXME
