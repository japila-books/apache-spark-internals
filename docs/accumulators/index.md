# Accumulators

*Accumulators* are variables that are "added" to through an associative and commutative "add" operation. They act as a container for accumulating partial values across multiple tasks (running on executors). They are designed to be used safely and efficiently in parallel and distributed Spark computations and are meant for distributed counters and sums (e.g. executor:TaskMetrics.md[task metrics]).

You can create built-in accumulators for SparkContext.md#creating-accumulators[longs, doubles, or collections] or register custom accumulators using the SparkContext.md#register[SparkContext.register] methods. You can create accumulators with or without a name, but only <<named, named accumulators>> are displayed in spark-webui-StagePage.md#accumulators[web UI] (under Stages tab for a given stage).

.Accumulators in the Spark UI
image::spark-webui-accumulators.png[align="center"]

Accumulator are write-only variables for executors. They can be added to by executors and read by the driver only.

```
executor1: accumulator.add(incByExecutor1)
executor2: accumulator.add(incByExecutor2)

driver:  println(accumulator.value)
```

Accumulators are not thread-safe. They do not really have to since the scheduler:DAGScheduler.md#updateAccumulators[DAGScheduler.updateAccumulators] method that the driver uses to update the values of accumulators after a task completes (successfully or with a failure) is only executed on a scheduler:DAGScheduler.md#eventProcessLoop[single thread that runs scheduling loop]. Beside that, they are write-only data structures for workers that have their own local accumulator reference whereas accessing the value of an accumulator is only allowed by the driver.

Accumulators are serializable so they can safely be referenced in the code executed in executors and then safely send over the wire for execution.

[source, scala]
----
val counter = sc.longAccumulator("counter")
sc.parallelize(1 to 9).foreach(x => counter.add(x))
----

Internally, SparkContext.md#longAccumulator[longAccumulator], SparkContext.md#doubleAccumulator[doubleAccumulator], and SparkContext.md#collectionAccumulator[collectionAccumulator] methods create the built-in typed accumulators and call SparkContext.md#register[SparkContext.register].

TIP: Read the official documentation about http://spark.apache.org/docs/latest/programming-guide.html#accumulators[Accumulators].

[[internal-registries]]
.AccumulatorV2's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[metadata]] `metadata`
| <<AccumulatorMetadata, AccumulatorMetadata>>

Used when...FIXME

| [[atDriverSide]] `atDriverSide`
| Flag whether...FIXME

Used when...FIXME
|===

=== [[merge]] `merge` Method

CAUTION: FIXME

=== [[AccumulatorV2]] AccumulatorV2

[source, scala]
----
abstract class AccumulatorV2[IN, OUT]
----

`AccumulatorV2` parameterized class represents an accumulator that accumulates `IN` values to produce `OUT` result.

==== [[register]] Registering Accumulator -- `register` Method

[source, scala]
----
register(
  sc: SparkContext,
  name: Option[String] = None,
  countFailedValues: Boolean = false): Unit
----

`register` creates a <<metadata, AccumulatorMetadata>> metadata object for the accumulator (with a [new unique identifier](AccumulatorContext.md#newId)) that is then used to [register the accumulator with](AccumulatorContext.md#register).

In the end, `register` core:ContextCleaner.md#registerAccumulatorForCleanup[registers the accumulator for cleanup] (only when SparkContext.md#cleaner[`ContextCleaner` is defined in the `SparkContext`]).

`register` reports a `IllegalStateException` if <<metadata, metadata>> is already defined (which means that `register` was called already).

```
Cannot register an Accumulator twice.
```

NOTE: `register` is a `private[spark]` method.

[NOTE]
====
`register` is used when:

* `SparkContext` SparkContext.md#register[registers accumulators]
* `TaskMetrics` executor:TaskMetrics.md#register[registers the internal accumulators]
* spark-sql-SQLMetric.md[SQLMetrics] creates metrics.
====

=== [[AccumulatorMetadata]] AccumulatorMetadata

`AccumulatorMetadata` is a container object with the metadata of an accumulator:

* [[id]] Accumulator ID
* [[name]] (optional) name
* [[countFailedValues]] Flag whether to include the latest value of an accumulator on failure

NOTE: `countFailedValues` is used exclusively when scheduler:Task.md#collectAccumulatorUpdates[`Task` collects the latest values of accumulators] (irrespective of task status -- a success or a failure).

=== [[named]] Named Accumulators

An accumulator can have an optional name that you can specify when SparkContext.md#creating-accumulators[creating an accumulator].

[source, scala]
----
val counter = sc.longAccumulator("counter")
----

## AccumulableInfo

`AccumulableInfo` represents an update to a [AccumulatorV2](AccumulatorV2.md).

* <span id="AccumulableInfo-id"> Accumulator ID
* <span id="AccumulableInfo-name"> Name
* <span id="AccumulableInfo-update"> Partial Update
* <span id="AccumulableInfo-value"> Partial Value
* <span id="AccumulableInfo-internal"> `internal` flag
* <span id="AccumulableInfo-countFailedValues"> `countFailedValues` flag
* <span id="AccumulableInfo-metadata"> Metadata (default: `None`)

`AccumulableInfo` is used to transfer accumulator updates from executors to the driver every executor heartbeat or when a task finishes.

=== When are Accumulators Updated?

=== [[examples]] Examples

==== [[example-distributed-counter]] Example: Distributed Counter

Imagine you are requested to write a distributed counter. What do you think about the following solutions? What are the pros and cons of using it?

[source, scala]
----
val ints = sc.parallelize(0 to 9, 3)

var counter = 0
ints.foreach { n =>
  println(s"int: $n")
  counter = counter + 1
}
println(s"The number of elements is $counter")
----

How would you go about doing the calculation using accumulators?

==== [[example1]] Example: Using Accumulators in Transformations and Guarantee Exactly-Once Update

CAUTION: FIXME Code with failing transformations (tasks) that update accumulator (`Map`) with `TaskContext` info.

==== [[example2]] Example: Custom Accumulator

CAUTION: FIXME Improve the earlier example

==== [[example3]] Example: Distributed Stopwatch

NOTE: This is _almost_ a raw copy of org.apache.spark.ml.util.DistributedStopwatch.

[source, scala]
----
class DistributedStopwatch(sc: SparkContext, val name: String) {

  val elapsedTime: Accumulator[Long] = sc.accumulator(0L, s"DistributedStopwatch($name)")

  override def elapsed(): Long = elapsedTime.value

  override protected def add(duration: Long): Unit = {
    elapsedTime += duration
  }
}
----

=== [[i-want-more]] Further reading or watching

* http://www.cs.berkeley.edu/~agearh/cs267.sp10/files/mosharaf-spark-bc-report-spring10.pdf[Performance and Scalability of Broadcast in Spark]
