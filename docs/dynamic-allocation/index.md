# Dynamic Allocation of Executors

**Dynamic Allocation of Executors** (_Dynamic Resource Allocation_ or _Elastic Scaling_) is a Spark service for adding and removing [Spark executors](../executor/Executor.md) dynamically on demand to match workload.

Unlike the "traditional" static allocation where a Spark application reserves CPU and memory resources upfront (irrespective of how much it may eventually use), in dynamic allocation you get as much as needed and no more. It scales the number of executors up and down based on workload, i.e. idle executors are removed, and when there are pending tasks waiting for executors to be launched on, dynamic allocation requests them.

Dynamic Allocation is enabled (and `SparkContext` creates an [ExecutorAllocationManager](../SparkContext-creating-instance-internals.md#ExecutorAllocationManager)) when:

1. [spark.dynamicAllocation.enabled](configuration-properties.md#spark.dynamicAllocation.enabled) configuration property is enabled

1. [spark.master](../configuration-properties.md#spark.master) is non-`local`

1. [SchedulerBackend](../SparkContext.md#schedulerBackend) is an [ExecutorAllocationClient](ExecutorAllocationClient.md)

[ExecutorAllocationManager](ExecutorAllocationManager.md) is the heart of Dynamic Resource Allocation.

When enabled, it is recommended to use the [External Shuffle Service](../external-shuffle-service/index.md).

Dynamic Allocation comes with the policy of scaling executors up and down as follows:

1. **Scale Up Policy** requests new executors when there are pending tasks and increases the number of executors exponentially since executors start slow and Spark application may need slightly more.
2. **Scale Down Policy** removes executors that have been idle for [spark.dynamicAllocation.executorIdleTimeout](configuration-properties.md#spark.dynamicAllocation.executorIdleTimeout) seconds.

## Performance Metrics

[ExecutorAllocationManagerSource](ExecutorAllocationManagerSource.md) metric source is used to report performance metrics.

## SparkContext.killExecutors

[SparkContext.killExecutors](../SparkContext.md#killExecutors) is unsupported with Dynamic Allocation enabled.

## Programmable Dynamic Allocation

`SparkContext` offers a [developer API to scale executors up or down](../SparkContext.md#dynamic-allocation).

## <span id="getDynamicAllocationInitialExecutors"> Getting Initial Number of Executors for Dynamic Allocation

```scala
getDynamicAllocationInitialExecutors(conf: SparkConf): Int
```

`getDynamicAllocationInitialExecutors` first makes sure that <<spark.dynamicAllocation.initialExecutors, spark.dynamicAllocation.initialExecutors>> is equal or greater than <<spark.dynamicAllocation.minExecutors, spark.dynamicAllocation.minExecutors>>.

NOTE: <<spark.dynamicAllocation.initialExecutors, spark.dynamicAllocation.initialExecutors>> falls back to <<spark.dynamicAllocation.minExecutors, spark.dynamicAllocation.minExecutors>> if not set. Why to print the WARN message to the logs?

If not, you should see the following WARN message in the logs:

```text
spark.dynamicAllocation.initialExecutors less than spark.dynamicAllocation.minExecutors is invalid, ignoring its setting, please update your configs.
```

`getDynamicAllocationInitialExecutors` makes sure that executor:Executor.md#spark.executor.instances[spark.executor.instances] is greater than <<spark.dynamicAllocation.minExecutors, spark.dynamicAllocation.minExecutors>>.

NOTE: Both executor:Executor.md#spark.executor.instances[spark.executor.instances] and <<spark.dynamicAllocation.minExecutors, spark.dynamicAllocation.minExecutors>> fall back to `0` when no defined explicitly.

If not, you should see the following WARN message in the logs:

```text
spark.executor.instances less than spark.dynamicAllocation.minExecutors is invalid, ignoring its setting, please update your configs.
```

`getDynamicAllocationInitialExecutors` sets the initial number of executors to be the maximum of:

* [spark.dynamicAllocation.minExecutors](configuration-properties.md#spark.dynamicAllocation.minExecutors)
* [spark.dynamicAllocation.initialExecutors](configuration-properties.md#spark.dynamicAllocation.initialExecutors)
* [spark.executor.instances](../executor/Executor.md#spark.executor.instances)
* `0`

You should see the following INFO message in the logs:

```text
Using initial executors = [initialExecutors], max of spark.dynamicAllocation.initialExecutors, spark.dynamicAllocation.minExecutors and spark.executor.instances
```

`getDynamicAllocationInitialExecutors` is used when `ExecutorAllocationManager` is requested to [set the initial number of executors](ExecutorAllocationManager.md#initialNumExecutors).

## Resources

### Documentation

* [Dynamic Allocation](https://spark.apache.org/docs/latest/configuration.html#dynamic-allocation) in the official documentation of Apache Spark
* [Dynamic allocation](https://docs.cloudera.com/runtime/latest/running-spark-applications/topics/spark-yarn-dynamic-allocation.html) in the documentation of Cloudera Data Platform (CDP)

### Slides

* [Dynamic Allocation in Spark](http://www.slideshare.net/databricks/dynamic-allocation-in-spark) by Databricks
