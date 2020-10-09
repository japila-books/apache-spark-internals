# Plugin Framework

**Plugin Framework** is an API for registering custom extensions (_plugins_) to be executed on the driver and executors.

Plugin Framework uses the following main abstractions:

* [PluginContainer](PluginContainer.md)
* [SparkPlugin](SparkPlugin.md)

Plugin Framework was introduced in [Spark 2.4.4](https://issues.apache.org/jira/browse/SPARK-24918) (that only offered an API for executors) with further changes in [Spark 3.0.0](https://issues.apache.org/jira/browse/SPARK-29396) (to cover the driver).

## Resources

* [Advanced Instrumentation](https://spark.apache.org/docs/latest/monitoring.html#advanced-instrumentation) in the official documentation of Apache Spark
* [Commit for SPARK-29397](https://github.com/apache/spark/commit/d51d228048d519a9a666f48dc532625de13e7587)
* [Spark Plugin Framework in 3.0 - Part 1: Introduction](http://blog.madhukaraphatak.com/spark-plugin-part-1/) by Madhukara Phatak
* [Spark Memory Monitor](https://github.com/squito/spark-memory) by squito
* [SparkPlugins](https://github.com/cerndb/SparkPlugins) by Luca Canali (CERN)
