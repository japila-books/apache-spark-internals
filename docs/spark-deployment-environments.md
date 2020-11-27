# Deployment Environments

Spark Deployment Environments (_Run Modes_):

* local/spark-local.md[local]
* spark-cluster.md[clustered]
** spark-standalone.md[Spark Standalone]
** Spark on Apache Mesos
** yarn/README.md[Spark on Hadoop YARN]

A Spark application is composed of the driver and executors that can run locally (on a single JVM) or using cluster resources (like CPU, RAM and disk that are managed by a cluster manager).

NOTE: You can specify where to run the driver using the spark-deploy-mode.md[deploy mode] (using `--deploy-mode` option of spark-submit or `spark.submit.deployMode` Spark property).

== [[master-urls]] Master URLs

Spark supports the following *master URLs* (see https://github.com/apache/spark/blob/master/core/src/main/scala/org/apache/spark/SparkContext.scala#L2583-L2592[private object SparkMasterRegex]):

* `local`, `local[N]` and `local[{asterisk}]` for local/spark-local.md#masterURL[Spark local]
* `local[N, maxRetries]` for local/spark-local.md#masterURL[Spark local-with-retries]
* `local-cluster[N, cores, memory]` for simulating a Spark cluster of `N` executors (threads), `cores` CPUs and `memory` locally (aka _Spark local-cluster_)
* `spark://host:port,host1:port1,...` for connecting to spark-standalone.md[Spark Standalone cluster(s)]
* `mesos://` for spark-mesos/spark-mesos.md[Spark on Mesos cluster]
* `yarn` for yarn/README.md[Spark on YARN]

You can specify the master URL of a Spark application as follows:

1. spark-submit.md[spark-submit's `--master` command-line option],

2. SparkConf.md#spark.master[`spark.master` Spark property],

3. When creating a  SparkContext.md#getOrCreate[`SparkContext` (using `setMaster` method)],

4. When creating a spark-sql-sparksession-builder.md[`SparkSession` (using `master` method of the builder interface)].
