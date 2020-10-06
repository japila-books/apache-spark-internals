# ExecutorAllocationManager -- Allocation Manager for Spark Core

`ExecutorAllocationManager` is responsible for dynamically allocating and removing executor:Executor.md[executors] based on the workload.

It intercepts Spark events using the internal spark-SparkListener-ExecutorAllocationListener.md[ExecutorAllocationListener] that keeps track of the workload (changing the <<internal-registries, internal registries>> that the allocation manager uses for executors management).

It uses spark-service-ExecutorAllocationClient.md[ExecutorAllocationClient], scheduler:LiveListenerBus.md[], and ROOT:SparkConf.md[SparkConf] (that are all passed in when `ExecutorAllocationManager` is created).

`ExecutorAllocationManager` is created when spark-SparkContext-creating-instance-internals.md#ExecutorAllocationManager[`SparkContext` is created and dynamic allocation of executors is enabled].

NOTE: `SparkContext` expects that `SchedulerBackend` follows the spark-service-ExecutorAllocationClient.md#contract[ExecutorAllocationClient contract] when dynamic allocation of executors is enabled.

[[internal-properties]]
.ExecutorAllocationManager's Internal Properties
[cols="1,1,2",options="header",width="100%"]
|===
| Name
| Initial Value
| Description

| [[executorAllocationManagerSource]] executorAllocationManagerSource
| spark-service-ExecutorAllocationManagerSource.md[ExecutorAllocationManagerSource]
| FIXME

| tasksPerExecutorForFullParallelism
|
a| [[tasksPerExecutorForFullParallelism]]
|===

[[internal-registries]]
.ExecutorAllocationManager's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[executorsPendingToRemove]] `executorsPendingToRemove`
| Internal cache with...FIXME

Used when...FIXME

| [[removeTimes]] `removeTimes`
| Internal cache with...FIXME

Used when...FIXME

| [[executorIds]] `executorIds`
| Internal cache with...FIXME

Used when...FIXME

| [[initialNumExecutors]] `initialNumExecutors`
| FIXME

| [[numExecutorsTarget]] `numExecutorsTarget`
| FIXME

| [[numExecutorsToAdd]] `numExecutorsToAdd`
| FIXME

| [[initializing]] `initializing`
| Flag whether...FIXME

Starts enabled (i.e. `true`).

|===

[TIP]
====
Enable `INFO` logging level for `org.apache.spark.ExecutorAllocationManager` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.ExecutorAllocationManager=INFO
```

Refer to spark-logging.md[Logging].
====

=== [[addExecutors]] `addExecutors` Method

CAUTION: FIXME

=== [[removeExecutor]] `removeExecutor` Method

CAUTION: FIXME

=== [[maxNumExecutorsNeeded]] `maxNumExecutorsNeeded` Method

CAUTION: FIXME

=== [[start]] Starting `ExecutorAllocationManager` -- `start` Method

[source, scala]
----
start(): Unit
----

`start` registers spark-SparkListener-ExecutorAllocationListener.md[ExecutorAllocationListener] (with scheduler:LiveListenerBus.md[]) to monitor scheduler events and make decisions when to add and remove executors. It then immediately starts <<spark-dynamic-executor-allocation, spark-dynamic-executor-allocation allocation executor>> that is responsible for the <<schedule, scheduling>> every `100` milliseconds.

NOTE: `100` milliseconds for the period between successive <<schedule, scheduling>> is fixed, i.e. not configurable.

It spark-service-ExecutorAllocationClient.md#requestTotalExecutors[requests executors] using the input spark-service-ExecutorAllocationClient.md[ExecutorAllocationClient]. It requests ROOT:spark-dynamic-allocation.md#spark.dynamicAllocation.initialExecutors[spark.dynamicAllocation.initialExecutors].

NOTE: `start` is called while spark-SparkContext-creating-instance-internals.md#ExecutorAllocationManager[SparkContext is being created] (for ROOT:spark-dynamic-allocation.md[]).

=== [[schedule]] Scheduling Executors -- `schedule` Method

[source, scala]
----
schedule(): Unit
----

`schedule` calls <<updateAndSyncNumExecutorsTarget, updateAndSyncNumExecutorsTarget>> to...FIXME

It then go over <<removeTimes, removeTimes>> to remove expired executors, i.e. executors for which expiration time has elapsed.

=== [[updateAndSyncNumExecutorsTarget]] `updateAndSyncNumExecutorsTarget` Method

[source, scala]
----
updateAndSyncNumExecutorsTarget(now: Long): Int
----

`updateAndSyncNumExecutorsTarget`...FIXME

If `ExecutorAllocationManager` is <<initializing, initializing>> it returns `0`.

=== [[reset]] Resetting `ExecutorAllocationManager` -- `reset` Method

[source, scala]
----
reset(): Unit
----

`reset` resets `ExecutorAllocationManager` to its initial state, i.e.

1. <<initializing, initializing>> is enabled (i.e. `true`).
2. The <<numExecutorsTarget, currently-desired number of executors>> is set to <<initialNumExecutors, the initial value>>.
3. The <<numExecutorsToAdd, numExecutorsToAdd>> is set to `1`.
4. All <<executorsPendingToRemove, executor pending to remove>> are cleared.
5. All <<removeTimes, ???>> are cleared.

=== [[stop]] Stopping `ExecutorAllocationManager` -- `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` shuts down <<spark-dynamic-executor-allocation, spark-dynamic-executor-allocation allocation executor>>.

NOTE: `stop` waits 10 seconds for the termination to be complete.

=== [[creating-instance]] Creating ExecutorAllocationManager Instance

`ExecutorAllocationManager` takes the following when created:

* [[client]] spark-service-ExecutorAllocationClient.md[ExecutorAllocationClient]
* [[listenerBus]] scheduler:LiveListenerBus.md[]
* [[conf]] ROOT:SparkConf.md[SparkConf]

`ExecutorAllocationManager` initializes the <<internal-registries, internal registries and counters>>.

=== [[validateSettings]] Validating Configuration of Dynamic Allocation -- `validateSettings` Internal Method

[source, scala]
----
validateSettings(): Unit
----

`validateSettings` makes sure that the ROOT:spark-dynamic-allocation.md#settings[settings for dynamic allocation] are correct.

`validateSettings` validates the following and throws a `SparkException` if not set correctly.

. <<spark.dynamicAllocation.minExecutors, spark.dynamicAllocation.minExecutors>> must be positive

. <<spark.dynamicAllocation.maxExecutors, spark.dynamicAllocation.maxExecutors>> must be `0` or greater

. <<spark.dynamicAllocation.minExecutors, spark.dynamicAllocation.minExecutors>> must be less than or equal to <<spark.dynamicAllocation.maxExecutors, spark.dynamicAllocation.maxExecutors>>

. <<spark.dynamicAllocation.executorIdleTimeout, spark.dynamicAllocation.executorIdleTimeout>> must be greater than `0`

. ROOT:configuration-properties.md#spark.shuffle.service.enabled[spark.shuffle.service.enabled] must be enabled.

. The number of tasks per core, i.e. executor:Executor.md#spark.executor.cores[spark.executor.cores] divided by ROOT:configuration-properties.md#spark.task.cpus[spark.task.cpus], is not zero.

NOTE: `validateSettings` is used when <<creating-instance, `ExecutorAllocationManager` is created>>.

=== [[spark-dynamic-executor-allocation]] spark-dynamic-executor-allocation Allocation Executor

`spark-dynamic-executor-allocation` allocation executor is a...FIXME

It is started...

It is stopped...
