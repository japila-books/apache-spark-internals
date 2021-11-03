# PrometheusServlet

`PrometheusServlet` is a [metrics sink](Sink.md) that comes with a [ServletContextHandler](#getHandlers) to serve [metrics snapshots](#getMetricsSnapshot) in [Prometheus](https://prometheus.io/) format.

## Creating Instance

`PrometheusServlet` takes the following to be created:

* <span id="property"> `Properties`
* <span id="registry"> `MetricRegistry` ([Dropwizard Metrics]({{ codahale.api }}/com/codahale/metrics/MetricRegistry.html))

`PrometheusServlet` is created when:

* `MetricsSystem` is requested to [register metric sinks](#registerSinks) (with `sink.prometheusServlet` configuration)

## <span id="ServletContextHandler"> ServletContextHandler

`PrometheusServlet` creates a `ServletContextHandler` to be registered at the path configured by `path` [property](#property).

The `ServletContextHandler` handles `text/plain` content type.

When executed, the `ServletContextHandler` gives a [metrics snapshot](#getMetricsSnapshot).

### <span id="getMetricsSnapshot"> Metrics Snapshot

```scala
getMetricsSnapshot(
  request: HttpServletRequest): String
```

`getMetricsSnapshot`...FIXME

## <span id="getHandlers"> getHandlers

```scala
getHandlers(
  conf: SparkConf): Array[ServletContextHandler]
```

`getHandlers` is the [ServletContextHandler](#ServletContextHandler).

`getHandlers` is used when:

* `MetricsSystem` is requested for [servlet handlers](MetricsSystem.md#getServletHandlers)
