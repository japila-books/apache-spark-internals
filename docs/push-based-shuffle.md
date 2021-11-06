# Push-Based Shuffle

**Push-Based Shuffle** is a new feature of Apache Spark 3.2.0 (cf. [SPARK-30602](https://issues.apache.org/jira/browse/SPARK-30602)) to improve shuffle efficiency.

Push-based shuffle is enabled using [spark.shuffle.push.enabled](configuration-properties.md#spark.shuffle.push.enabled) configuration property and [can only be used](Utils.md#isPushBasedShuffleEnabled) in a Spark application submitted to YARN cluster manager, with external shuffle service enabled, IO encryption disabled, and relocation of serialized objects supported.
