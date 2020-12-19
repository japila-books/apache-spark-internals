# Dynamic Allocation of Executors

**Dynamic Allocation (of Executors)** (_Elastic Scaling_) is a Spark feature that allows for adding or removing [Spark executors](../executor/Executor.md) dynamically to match the workload.

Unlike the "traditional" static allocation where a Spark application reserves CPU and memory resources upfront (irrespective of how much it may eventually use), in dynamic allocation you get as much as needed and no more. It scales the number of executors up and down based on workload, i.e. idle executors are removed, and when there are pending tasks waiting for executors to be launched on, dynamic allocation requests them.

Dynamic allocation is enabled using [spark.dynamicAllocation.enabled](configuration-properties.md#spark.dynamicAllocation.enabled) configuration property. When enabled, it is assumed that the [External Shuffle Service](../external-shuffle-service/ExternalShuffleService.md) is also used (it is not by default as controlled by [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property).

[ExecutorAllocationManager](ExecutorAllocationManager.md) is responsible for dynamic allocation of executors.

Dynamic allocation reports the current state using [ExecutorAllocationManager](ExecutorAllocationManagerSource.md) metric source.

Dynamic Allocation comes with the policy of scaling executors up and down as follows:

1. **Scale Up Policy** requests new executors when there are pending tasks and increases the number of executors exponentially since executors start slow and Spark application may need slightly more.
2. **Scale Down Policy** removes executors that have been idle for [spark.dynamicAllocation.executorIdleTimeout](configuration-properties.md#spark.dynamicAllocation.executorIdleTimeout) seconds.

## <span id="isDynamicAllocationEnabled"> Is Dynamic Allocation Enabled

```scala
isDynamicAllocationEnabled(
  conf: SparkConf): Boolean
```

`isDynamicAllocationEnabled` returns `true` if all the following conditions hold:

* [spark.dynamicAllocation.enabled](configuration-properties.md#spark.dynamicAllocation.enabled) is enabled
* [spark.master](../configuration-properties.md#spark.master) is non-`local`
* [spark.dynamicAllocation.testing](configuration-properties.md#spark.dynamicAllocation.testing) is enabled

Otherwise, `isDynamicAllocationEnabled` returns `false`.

`isDynamicAllocationEnabled` is used when Spark calculates the initial number of executors for [coarse-grained scheduler backends](../scheduler/CoarseGrainedSchedulerBackend.md).

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

* [Dynamic Allocation](https://spark.apache.org/docs/latest/configuration.html#dynamic-allocation) in the documentation of Apache Spark
* [Dynamic allocation](https://docs.cloudera.com/runtime/latest/running-spark-applications/topics/spark-yarn-dynamic-allocation.html) in the documentation of Cloudera Data Platform (CDP)

### Slides

* [Dynamic Allocation in Spark](http://www.slideshare.net/databricks/dynamic-allocation-in-spark) from Databricks
