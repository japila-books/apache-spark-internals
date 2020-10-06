= SparkTransportConf

*SparkTransportConf* is...FIXME

== [[fromSparkConf]] Creating TransportConf

[source,scala]
----
fromSparkConf(
  _conf: SparkConf,
  module: String,
  numUsableCores: Int = 0): TransportConf
----

fromSparkConf...FIXME

fromSparkConf is used when...FIXME

== [[defaultNumThreads]] Calculating Default Number of Threads

[source, scala]
----
defaultNumThreads(
  numUsableCores: Int): Int
----

defaultNumThreads calculates the default number of threads for both the Netty client and server thread pools that is 8 maximum or `numUsableCores` is smaller. If `numUsableCores` is not specified, defaultNumThreads uses the number of processors available to the Java virtual machine.

NOTE: 8 is the maximum number of threads for Netty and is not configurable.

NOTE: defaultNumThreads uses ++https://docs.oracle.com/javase/8/docs/api/java/lang/Runtime.html#availableProcessors--++[Java's Runtime for the number of processors in JVM].
