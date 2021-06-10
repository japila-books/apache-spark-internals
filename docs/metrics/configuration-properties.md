# Configuration Properties

## <span id="spark.metrics.appStatusSource.enabled"><span id="METRICS_APP_STATUS_SOURCE_ENABLED"> spark.metrics.appStatusSource.enabled

Enables Dropwizard/Codahale metrics with the status of a live Spark application

Default: `false`

Used when:

* `AppStatusSource` utility is used to [create an AppStatusSource](../status/AppStatusSource.md#createSource)

## <span id="spark.metrics.conf"> spark.metrics.conf

The metrics configuration file

Default: `metrics.properties`

## <span id="spark.metrics.namespace"> spark.metrics.namespace

Root namespace for metrics reporting

Default: [Spark Application ID](../SparkConf.md#spark.app.id) (i.e. `spark.app.id` configuration property)

Since a Spark application's ID changes with every execution of a Spark application, a custom namespace can be specified for an easier metrics reporting.

Used when `MetricsSystem` is requested for a [metrics source identifier](MetricsSystem.md#buildRegistryName) (_metrics namespace_)
