= ShuffleMetricsSource

*ShuffleMetricsSource* is the xref:metrics:spark-metrics-Source.adoc[metrics source] of a xref:storage:BlockManager.adoc[] for <<metrics, shuffle metrics>>.

ShuffleMetricsSource lives on a Spark executor and is xref:executor:Executor.adoc#creating-instance-BlockManager-shuffleMetricsSource[registered only when a Spark application runs in a non-local / cluster mode].

.Registering ShuffleMetricsSource with "executor" MetricsSystem
image::ShuffleMetricsSource.png[align="center"]

== [[creating-instance]] Creating Instance

ShuffleMetricsSource takes the following to be created:

* <<sourceName, Source Name>>
* <<metricSet, MetricSet>>

ShuffleMetricsSource is created when BlockManager is requested for the xref:storage:BlockManager.adoc#shuffleMetricsSource[shuffle metrics source].

== [[metricSet]] MetricSet

ShuffleMetricsSource is given a Dropwizard Metrics https://metrics.dropwizard.io/3.1.0/apidocs/com/codahale/metrics/MetricSet.html[MetricSet] when <<creating-instance, created>>.

The MetricSet is requested from the xref:storage:ShuffleClient.adoc#shuffleMetrics[ShuffleClient] (of xref:storage:BlockManager.adoc#shuffleClient[BlockManager]).

== [[sourceName]] Source Name

ShuffleMetricsSource is given a name when <<creating-instance, created>> that is one of the following:

* *NettyBlockTransfer* when xref:ROOT:configuration-properties.adoc#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property is off (`false`)

* *ExternalShuffle* when xref:ROOT:configuration-properties.adoc#spark.shuffle.service.enabled[spark.shuffle.service.enabled] configuration property is on (`true`)
