= ShuffleMetricsSource

*ShuffleMetricsSource* is the metrics:spark-metrics-Source.md[metrics source] of a storage:BlockManager.md[] for <<metrics, shuffle metrics>>.

ShuffleMetricsSource lives on a Spark executor and is executor:Executor.md#creating-instance-BlockManager-shuffleMetricsSource[registered only when a Spark application runs in a non-local / cluster mode].

.Registering ShuffleMetricsSource with "executor" MetricsSystem
image::ShuffleMetricsSource.png[align="center"]

== [[creating-instance]] Creating Instance

ShuffleMetricsSource takes the following to be created:

* <<sourceName, Source Name>>
* <<metricSet, MetricSet>>

ShuffleMetricsSource is created when BlockManager is requested for the storage:BlockManager.md#shuffleMetricsSource[shuffle metrics source].

== [[sourceName]] Source Name

ShuffleMetricsSource is given a name when <<creating-instance, created>> that is one of the following:

* **NettyBlockTransfer** when [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property is off (`false`)

* **ExternalShuffle** when [spark.shuffle.service.enabled](../external-shuffle-service/configuration-properties.md#spark.shuffle.service.enabled) configuration property is on (`true`)
