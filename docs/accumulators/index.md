# Accumulators

**Accumulators** are shared variables that accumulate values from executors on the driver using associative and commutative "add" operation.

The main abstraction is [AccumulatorV2](AccumulatorV2.md).

Accumulators are registered (_created_) using [SparkContext](../SparkContext.md#register) with or without a name. Only named accumulators are displayed in [web UI](../webui/StagePage.md#accumulators).

![Accumulators in the Spark UI](../images/webui/spark-webui-accumulators.png)

`DAGScheduler` is responsible for [updating accumulators](../scheduler/DAGScheduler.md#updateAccumulators) (from partial values from tasks running on executors every heartbeat).

Accumulators are serializable so they can safely be referenced in the code executed in executors and then safely send over the wire for execution.

```scala
// on the driver
val counter = sc.longAccumulator("counter")

sc.parallelize(1 to 9).foreach { x =>
  // on executors
  counter.add(x) }

// on the driver
println(counter.value)
```

## Further Reading

* [Performance and Scalability of Broadcast in Spark](https://www.mosharaf.com/wp-content/uploads/mosharaf-spark-bc-report-spring10.pdf)
