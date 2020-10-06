== [[SparkSubmitArguments]] `SparkSubmitArguments` -- spark-submit's Command-Line Argument Parser

`SparkSubmitArguments` is a custom `SparkSubmitArgumentsParser` to <<handle, handle>> the command-line arguments of spark-submit.md[`spark-submit` script] that the spark-submit.md#actions[actions] (i.e. spark-submit.md#submit[submit], spark-submit.md#kill[kill] and spark-submit.md#status[status]) use for their execution (possibly with the explicit `env` environment).

NOTE: `SparkSubmitArguments` is created when <<main, launching `spark-submit` script>> with only `args` passed in and later used for printing the arguments in <<verbose-mode, verbose mode>>.

=== [[loadEnvironmentArguments]] Calculating Spark Properties -- `loadEnvironmentArguments` internal method

[source, scala]
----
loadEnvironmentArguments(): Unit
----

`loadEnvironmentArguments` calculates the Spark properties for the current execution of spark-submit.md[spark-submit].

`loadEnvironmentArguments` reads command-line options first followed by Spark properties and System's environment variables.

NOTE: Spark config properties start with `spark.` prefix and can be set using `--conf [key=value]` command-line option.

=== [[handle]] `handle` Method

[source, scala]
----
protected def handle(opt: String, value: String): Boolean
----

`handle` parses the input `opt` argument and returns `true` or throws an `IllegalArgumentException` when it finds an unknown `opt`.

`handle` sets the internal properties in the table spark-submit.md#options-properties-variables[Command-Line Options, Spark Properties and Environment Variables].

=== [[mergeDefaultSparkProperties]] `mergeDefaultSparkProperties` Internal Method

[source, scala]
----
mergeDefaultSparkProperties(): Unit
----

`mergeDefaultSparkProperties` merges Spark properties from the spark-properties.md#spark-defaults-conf[default Spark properties file, i.e. `spark-defaults.conf`] with those specified through `--conf` command-line option.
