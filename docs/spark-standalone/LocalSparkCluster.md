# LocalSparkCluster

`LocalSparkCluster` is a single-JVM Spark Standalone cluster that is available as `local-cluster` master URL.

NOTE: `local-cluster` master URL matches `local-cluster[numWorkers,coresPerWorker,memoryPerWorker]` pattern where <<numWorkers, numWorkers>>, <<coresPerWorker, coresPerWorker>> and <<memoryPerWorker, memoryPerWorker>> are all numbers separated by the comma.

`LocalSparkCluster` can be particularly useful to test distributed operation and fault recovery without spinning up a lot of processes.

`LocalSparkCluster` is <<creating-instance, created>> when `SparkContext` is created for *local-cluster* master URL (and so requested to xref:ROOT:SparkContext.md#createTaskScheduler[create the SchedulerBackend and the TaskScheduler]).

[[logging]]
[TIP]
====
Enable `INFO` logging level for `org.apache.spark.deploy.LocalSparkCluster` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.deploy.LocalSparkCluster=INFO
```

Refer to link:spark-logging.md[Logging].
====

=== [[creating-instance]] Creating LocalSparkCluster Instance

`LocalSparkCluster` takes the following when created:

* [[numWorkers]] Number of workers
* [[coresPerWorker]] CPU cores per worker
* [[memoryPerWorker]] Memory per worker
* [[conf]] xref:ROOT:SparkConf.md[SparkConf]

`LocalSparkCluster` initializes the <<internal-registries, internal registries and counters>>.

## <span id="start"> Starting

```scala
start(): Array[String]
```

`start`...FIXME

`start` is used when...FIXME

=== [[stop]] Stopping LocalSparkCluster

[source, scala]
----
stop(): Unit
----

`stop`...FIXME

NOTE: `stop` is used when...FIXME
