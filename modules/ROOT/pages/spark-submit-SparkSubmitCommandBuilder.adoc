== [[SparkSubmitCommandBuilder]] `SparkSubmitCommandBuilder` Command Builder

`SparkSubmitCommandBuilder` is used to build a command that link:spark-submit.adoc#main[spark-submit] and link:spark-SparkLauncher.adoc[SparkLauncher] use to launch a Spark application.

`SparkSubmitCommandBuilder` uses the first argument to distinguish between shells:

1. `pyspark-shell-main`
2. `sparkr-shell-main`
3. `run-example`

CAUTION: FIXME Describe `run-example`

`SparkSubmitCommandBuilder` parses command-line arguments using `OptionParser` (which is a link:spark-submit-SparkSubmitOptionParser.adoc[SparkSubmitOptionParser]). `OptionParser` comes with the following methods:

1. `handle` to handle the known options (see the table below). It sets up `master`, `deployMode`, `propertiesFile`, `conf`, `mainClass`, `sparkArgs` internal properties.

2. `handleUnknown` to handle unrecognized options that _usually_ lead to `Unrecognized option` error message.

3. `handleExtraArgs` to handle extra arguments that are considered a Spark application's arguments.

NOTE: For `spark-shell` it assumes that the application arguments are after ``spark-submit``'s arguments.

=== [[buildCommand]] `SparkSubmitCommandBuilder.buildCommand` / `buildSparkSubmitCommand`

[source, java]
----
public List<String> buildCommand(Map<String, String> env)
----

NOTE: `buildCommand` is part of the link:spark-AbstractCommandBuilder.adoc[AbstractCommandBuilder] public API.

`SparkSubmitCommandBuilder.buildCommand` simply passes calls on to <<buildSparkSubmitCommand, buildSparkSubmitCommand>> private method (unless it was executed for `pyspark` or `sparkr` scripts which we are not interested in in this document).

==== [[buildSparkSubmitCommand]] `buildSparkSubmitCommand` Internal Method

[source, java]
----
private List<String> buildSparkSubmitCommand(Map<String, String> env)
----

`buildSparkSubmitCommand` starts by <<getEffectiveConfig, building so-called effective config>>. When in <<isClientMode, client mode>>, `buildSparkSubmitCommand` adds link:spark-driver.adoc#spark_driver_extraClassPath[spark.driver.extraClassPath] to the result Spark command.

NOTE: Use `spark-submit` to have link:spark-driver.adoc#spark_driver_extraClassPath[spark.driver.extraClassPath] in effect.

`buildSparkSubmitCommand` link:spark-AbstractCommandBuilder.adoc#buildJavaCommand[builds the first part of the Java command] passing in the extra classpath (only for `client` deploy mode).

CAUTION: FIXME Add `isThriftServer` case.

`buildSparkSubmitCommand` appends `SPARK_SUBMIT_OPTS` and `SPARK_JAVA_OPTS` environment variables.

(only for `client` deploy mode) ...

CAUTION: FIXME Elaborate on the client deply mode case.

`addPermGenSizeOpt` case...elaborate

CAUTION: FIXME Elaborate on `addPermGenSizeOpt`

`buildSparkSubmitCommand` appends `org.apache.spark.deploy.SparkSubmit` and the command-line arguments (using <<buildSparkSubmitArgs, buildSparkSubmitArgs>>).

==== [[buildSparkSubmitArgs]] `buildSparkSubmitArgs` method

[source, java]
----
List<String> buildSparkSubmitArgs()
----

`buildSparkSubmitArgs` builds a list of command-line arguments for link:spark-submit.adoc[spark-submit].

`buildSparkSubmitArgs` uses a link:spark-submit-SparkSubmitOptionParser.adoc[SparkSubmitOptionParser] to add the command-line arguments that `spark-submit` recognizes (when it is executed later on and uses the very same `SparkSubmitOptionParser` parser to parse command-line arguments).

.`SparkSubmitCommandBuilder` Properties and Corresponding `SparkSubmitOptionParser` Attributes
[options="header",width="100%"]
|===
| `SparkSubmitCommandBuilder` Property | `SparkSubmitOptionParser` Attribute
| `verbose` | `VERBOSE`
| `master` | `MASTER [master]`
| `deployMode` | `DEPLOY_MODE [deployMode]`
| `appName` | `NAME [appName]`
| `conf` | `CONF [key=value]*`
| `propertiesFile` | `PROPERTIES_FILE [propertiesFile]`
| `jars` | `JARS [comma-separated jars]`
| `files` | `FILES [comma-separated files]`
| `pyFiles` | `PY_FILES [comma-separated pyFiles]`
| `mainClass` | `CLASS [mainClass]`
| `sparkArgs` | `sparkArgs` (passed straight through)
| `appResource` | `appResource` (passed straight through)
| `appArgs` | `appArgs` (passed straight through)
|===

==== [[getEffectiveConfig]] `getEffectiveConfig` Internal Method

[source, java]
----
Map<String, String> getEffectiveConfig()
----

`getEffectiveConfig` internal method builds `effectiveConfig` that is `conf` with the Spark properties file loaded (using link:spark-AbstractCommandBuilder.adoc#loadPropertiesFile[loadPropertiesFile] internal method) skipping keys that have already been loaded (it happened when the command-line options were parsed in <<SparkSubmitCommandBuilder, handle>> method).

NOTE: Command-line options (e.g. `--driver-class-path`) have higher precedence than their corresponding Spark settings in a Spark properties file (e.g. `spark.driver.extraClassPath`). You can therefore control the final settings by overriding Spark settings on command line using the command-line options.
charset and trims white spaces around values.

==== [[isClientMode]] `isClientMode` Internal Method

[source, java]
----
private boolean isClientMode(Map<String, String> userProps)
----

`isClientMode` checks `master` first (from the command-line options) and then `spark.master` Spark property. Same with `deployMode` and `spark.submit.deployMode`.

CAUTION: FIXME Review `master` and `deployMode`. How are they set?

`isClientMode` responds positive when no explicit master and `client` deploy mode set explicitly.

=== [[OptionParser]] OptionParser

`OptionParser` is a custom link:spark-submit-SparkSubmitOptionParser.adoc[SparkSubmitOptionParser] that `SparkSubmitCommandBuilder` uses to parse command-line arguments. It defines all the link:spark-submit-SparkSubmitOptionParser.adoc#callbacks[SparkSubmitOptionParser callbacks], i.e. <<OptionParser-handle, handle>>, <<OptionParser-handleUnknown, handleUnknown>>, and <<OptionParser-handleExtraArgs, handleExtraArgs>>, for command-line argument handling.

==== [[OptionParser-handle]] OptionParser's `handle` Callback

[source, scala]
----
boolean handle(String opt, String value)
----

`OptionParser` comes with a custom `handle` callback (from the link:spark-submit-SparkSubmitOptionParser.adoc#callbacks[SparkSubmitOptionParser callbacks]).

.`handle` Method
[options="header",width="100%"]
|===
| Command-Line Option | Property / Behaviour
| `--master` | `master`
| `--deploy-mode` | `deployMode`
| `--properties-file` | `propertiesFile`
| `--driver-memory` | Sets `spark.driver.memory` (in `conf`)
| `--driver-java-options` | Sets `spark.driver.extraJavaOptions` (in `conf`)
| `--driver-library-path` | Sets `spark.driver.extraLibraryPath` (in `conf`)
| `--driver-class-path` | Sets `spark.driver.extraClassPath` (in `conf`)
| `--conf` | Expects a `key=value` pair that it puts in `conf`
| `--class` | Sets `mainClass` (in `conf`).

It may also set `allowsMixedArguments` and `appResource` if the execution is for one of the special classes, i.e. link:spark-shell.adoc[spark-shell], `SparkSQLCLIDriver`, or link:spark-sql-thrift-server.adoc[HiveThriftServer2].
| `--kill` \| `--status` | Disables `isAppResourceReq` and adds itself with the value to `sparkArgs`.
| `--help` \| `--usage-error` | Disables `isAppResourceReq` and adds itself to `sparkArgs`.
| `--version` | Disables `isAppResourceReq` and adds itself to `sparkArgs`.
| _anything else_ | Adds an element to `sparkArgs`
|===

==== [[OptionParser-handleUnknown]] OptionParser's `handleUnknown` Method

[source, scala]
----
boolean handleUnknown(String opt)
----

If `allowsMixedArguments` is enabled, `handleUnknown` simply adds the input `opt` to `appArgs` and allows for further link:spark-submit-SparkSubmitOptionParser.adoc#parse[parsing of the argument list].

CAUTION: FIXME Where's `allowsMixedArguments` enabled?

If `isExample` is enabled, `handleUnknown` sets `mainClass` to be `org.apache.spark.examples.[opt]` (unless the input `opt` has already the package prefix) and stops further link:spark-submit-SparkSubmitOptionParser.adoc#parse[parsing of the argument list].

CAUTION: FIXME Where's `isExample` enabled?

Otherwise, `handleUnknown` sets `appResource` and stops further link:spark-submit-SparkSubmitOptionParser.adoc#parse[parsing of the argument list].

==== [[OptionParser-handleExtraArgs]] OptionParser's `handleExtraArgs` Method

[source, scala]
----
void handleExtraArgs(List<String> extra)
----

`handleExtraArgs` adds all the `extra` arguments to `appArgs`.
