# MetricsConfig

`MetricsConfig` is the configuration of the [MetricsSystem](MetricsSystem.md) (i.e. metrics [sources](Source.md) and [sinks](Sink.md)).

`MetricsConfig` is <<creating-instance, created>> when [MetricsSystem](MetricsSystem.md#creating-instance) is.

`MetricsConfig` uses *metrics.properties* as the default metrics configuration file. It is configured using spark-metrics-properties.md#spark.metrics.conf[spark.metrics.conf] configuration property. The file is first loaded from the path directly before using Spark's CLASSPATH.

`MetricsConfig` accepts a metrics configuration using ``spark.metrics.conf.``-prefixed configuration properties.

Spark comes with `conf/metrics.properties.template` file that is a template of metrics configuration.

`MetricsConfig` <<setDefaultProperties, makes sure>> that the <<default-properties, default metrics properties>> are always defined.

[[default-properties]]
.MetricsConfig's Default Metrics Properties
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `*.sink.servlet.class`
| `org.apache.spark.metrics.sink.MetricsServlet`

| `*.sink.servlet.path`
| `/metrics/json`

| `master.sink.servlet.path`
| `/metrics/master/json`

| `applications.sink.servlet.path`
| `/metrics/applications/json`
|===

[NOTE]
====
The order of precedence of metrics configuration settings is as follows:

. <<default-properties, Default metrics properties>>
. spark-metrics-properties.md#spark.metrics.conf[spark.metrics.conf] configuration property or `metrics.properties` configuration file
. ``spark.metrics.conf.``-prefixed Spark properties
====

[[creating-instance]]
[[conf]]
`MetricsConfig` takes a SparkConf.md[SparkConf] when created.

[[internal-registries]]
.MetricsConfig's Internal Registries and Counters
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| [[properties]] `properties`
| https://docs.oracle.com/javase/8/docs/api/java/util/Properties.html[java.util.Properties] with metrics properties

Used to <<initialize, initialize>> per-subsystem's <<perInstanceSubProperties, perInstanceSubProperties>>.

| [[perInstanceSubProperties]] `perInstanceSubProperties`
| Lookup table of metrics properties per subsystem
|===

=== [[initialize]] Initializing MetricsConfig -- `initialize` Method

[source, scala]
----
initialize(): Unit
----

`initialize` <<setDefaultProperties, sets the default properties>> and <<loadPropertiesFromFile, loads configuration properties from a configuration file>> (that is defined using spark-metrics-properties.md#spark.metrics.conf[spark.metrics.conf] configuration property).

`initialize` takes all Spark properties that start with *spark.metrics.conf.* prefix from <<conf, SparkConf>> and adds them to <<properties, properties>> (without the prefix).

In the end, `initialize` splits <<perInstanceSubProperties, configuration per Spark subsystem>> with the default configuration (denoted as `*`) assigned to all subsystems afterwards.

NOTE: `initialize` accepts `*` (star) for the default configuration or any combination of lower- and upper-case letters for Spark subsystem names.

NOTE: `initialize` is used exclusively when `MetricsSystem` is [created](MetricsSystem.md#creating-instance).

=== [[setDefaultProperties]] `setDefaultProperties` Internal Method

[source, scala]
----
setDefaultProperties(prop: Properties): Unit
----

`setDefaultProperties` sets the <<default-properties, default properties>> (in the input `prop`).

NOTE: `setDefaultProperties` is used exclusively when `MetricsConfig` <<initialize, is initialized>>.

=== [[loadPropertiesFromFile]] Loading Custom Metrics Configuration File or metrics.properties -- `loadPropertiesFromFile` Method

[source, scala]
----
loadPropertiesFromFile(path: Option[String]): Unit
----

`loadPropertiesFromFile` tries to open the input `path` file (if defined) or the default metrics configuration file *metrics.properties* (on CLASSPATH).

If either file is available, `loadPropertiesFromFile` loads the properties (to <<properties, properties>> registry).

In case of exceptions, you should see the following ERROR message in the logs followed by the exception.

```
ERROR Error loading configuration file [file]
```

NOTE: `loadPropertiesFromFile` is used exclusively when `MetricsConfig` <<initialize, is initialized>>.

=== [[subProperties]] Grouping Properties Per Subsystem -- `subProperties` Method

[source, scala]
----
subProperties(prop: Properties, regex: Regex): mutable.HashMap[String, Properties]
----

`subProperties` takes `prop` properties and destructures keys given `regex`. `subProperties` takes the matching prefix (of a key per `regex`) and uses it as a new key with the value(s) being the matching suffix(es).

[source, scala]
----
driver.hello.world => (driver, (hello.world))
----

NOTE: `subProperties` is used when `MetricsConfig` <<initialize, is initialized>> (to apply the default metrics configuration) and when `MetricsSystem` [registers metrics sources](MetricsSystem.md#registerSources) and [sinks](MetricsSystem.md#registerSinks).

=== [[getInstance]] `getInstance` Method

[source, scala]
----
getInstance(inst: String): Properties
----

`getInstance`...FIXME

NOTE: `getInstance` is used when...FIXME
