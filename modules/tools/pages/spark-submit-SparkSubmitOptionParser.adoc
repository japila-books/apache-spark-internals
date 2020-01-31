== [[SparkSubmitOptionParser]] `SparkSubmitOptionParser` -- spark-submit's Command-Line Parser

`SparkSubmitOptionParser` is the parser of link:spark-submit.adoc[spark-submit]'s command-line options.

.`spark-submit` Command-Line Options
[cols="1,2",options="header",width="100%"]
|===
| Command-Line Option | Description
| `--archives` |
| `--class` | The main class to run (as `mainClass` internal attribute).
| `--conf [prop=value]` or `-c [prop=value]` | All ``=``-separated values end up in `conf` potentially overriding existing settings. Order on command-line matters.
| `--deploy-mode`| `deployMode` internal property
| `--driver-class-path`| `spark.driver.extraClassPath` in `conf` -- the driver class path
| `--driver-cores`|
| `--driver-java-options`| `spark.driver.extraJavaOptions` in `conf` -- the driver VM options
| `--driver-library-path`| `spark.driver.extraLibraryPath` in `conf` -- the driver native library path
| `--driver-memory` | `spark.driver.memory` in `conf`
| `--exclude-packages` |
| `--executor-cores` |
| `--executor-memory` |
| `--files` |
| `--help` or `-h` | The option is added to `sparkArgs`
| `--jars` |
| `--keytab` |
| `--kill` | The option and a value are added to `sparkArgs`
| `--master` | `master` internal property
| `--name` |
| `--num-executors` |
| `--packages` |
| `--principal` |
| `--properties-file [FILE]` | `propertiesFile` internal property. Refer to link:spark-submit.adoc#properties-file[Custom Spark Properties File -- `--properties-file` command-line option].
| `--proxy-user` |
| `--py-files` |
| `--queue` |
| `--repositories` |
| `--status` | The option and a value are added to `sparkArgs`
| `--supervise` |
| `--total-executor-cores` |
| `--usage-error` | The option is added to `sparkArgs`
| `--verbose` or `-v` |
| `--version` | The option is added to `sparkArgs`
|===

=== [[callbacks]] SparkSubmitOptionParser Callbacks

`SparkSubmitOptionParser` is supposed to be overriden for the following capabilities (as callbacks).

.Callbacks
[cols="1,3",options="header",width="100%"]
|===
| Callback | Description
| `handle` | Executed when an option with an argument is parsed.
| `handleUnknown` | Executed when an unrecognized option is parsed.
| `handleExtraArgs` | Executed for the command-line arguments that `handle` and `handleUnknown` callbacks have not processed.
|===

`SparkSubmitOptionParser` belongs to `org.apache.spark.launcher` Scala package and `spark-launcher` Maven/sbt module.

NOTE: `org.apache.spark.launcher.SparkSubmitArgumentsParser` is a custom `SparkSubmitOptionParser`.

=== [[parse]] Parsing Command-Line Arguments -- `parse` Method

[source, scala]
----
final void parse(List<String> args)
----

`parse` parses a list of command-line arguments.

`parse` calls `handle` callback whenever it finds a known command-line option or a switch (a command-line option with no parameter). It calls `handleUnknown` callback for unrecognized command-line options.

`parse` keeps processing command-line arguments until `handle` or `handleUnknown` callback return `false` or all command-line arguments have been consumed.

Ultimately, `parse` calls `handleExtraArgs` callback.
