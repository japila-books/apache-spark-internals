# External Shuffle Service

**External Shuffle Service** is a Spark service to serve RDD and shuffle blocks outside and for [Executor](../executor/Executor.md)s.

[ExternalShuffleService](ExternalShuffleService.md) can be started as a [command-line application](ExternalShuffleService.md#launch) or automatically as part of a worker node in a Spark cluster (e.g. [Standalone Worker](../spark-standalone/Worker.md#shuffleService)).

External Shuffle Service is enabled in a Spark application using [spark.shuffle.service.enabled](configuration-properties.md#spark.shuffle.service.enabled) configuration property.
