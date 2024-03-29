# SparkSubmitCommandBuilder

`SparkSubmitCommandBuilder` is an [AbstractCommandBuilder](../AbstractCommandBuilder.md).

`SparkSubmitCommandBuilder` is used to build a command that [spark-submit](index.md#main) and [SparkLauncher](../SparkLauncher.md) use to launch a Spark application.

`SparkSubmitCommandBuilder` uses the first argument to distinguish the shells:

1. `pyspark-shell-main`
2. `sparkr-shell-main`
3. `run-example`

`SparkSubmitCommandBuilder` parses command-line arguments using `OptionParser` (which is a spark-submit-SparkSubmitOptionParser.md[SparkSubmitOptionParser]). `OptionParser` comes with the following methods:

1. `handle` to handle the known options (see the table below). It sets up `master`, `deployMode`, `propertiesFile`, `conf`, `mainClass`, `sparkArgs` internal properties.

2. `handleUnknown` to handle unrecognized options that _usually_ lead to `Unrecognized option` error message.

3. `handleExtraArgs` to handle extra arguments that are considered a Spark application's arguments.

!!! NOTE
    For `spark-shell` it assumes that the application arguments are after ``spark-submit``'s arguments.

## <span id="PYSPARK_SHELL"> pyspark-shell-main Application Resource { #pyspark-shell-main }

When `bin/pyspark` shell script (and `bin\pyspark2.cmd`) are launched, they use [bin/spark-submit](index.md) with `pyspark-shell-main` application resource as the first argument (followed by `--name "PySparkShell"` option among the others).

`pyspark-shell-main` is used when:

* `SparkSubmitCommandBuilder` is [created](#creating-instance) and then requested to [build a command](#buildCommand) ([buildPySparkShellCommand](#buildPySparkShellCommand) actually)

## Building Command { #buildCommand }

??? note "AbstractCommandBuilder"

    ```java
    List<String> buildCommand(
      Map<String, String> env)
    ```

    `buildCommand` is part of the [AbstractCommandBuilder](../AbstractCommandBuilder.md#buildCommand) abstraction.

`buildCommand` branches off based on the [application resource](../AbstractCommandBuilder.md#appResource).

Application Resource | Command Builder
---------------------|----------------
 [pyspark-shell-main](#pyspark-shell-main) (but not [isSpecialCommand](#isSpecialCommand)) | [buildPySparkShellCommand](#buildPySparkShellCommand)
 `sparkr-shell-main` (but not [isSpecialCommand](#isSpecialCommand)) | [buildSparkRCommand](#buildSparkRCommand)
 _anything else_ | [buildSparkSubmitCommand](#buildSparkSubmitCommand)

### buildPySparkShellCommand { #buildPySparkShellCommand }

```java
List<String> buildPySparkShellCommand(
  Map<String, String> env)
```

??? note "appArgs expected to be empty"
    `buildPySparkShellCommand` makes sure that:

    * There are no [appArgs](#appArgs)
    * If there are [appArgs](#appArgs) the first argument is not a Python script (a file with `.py` extension)

`buildPySparkShellCommand` sets the [application resource](../AbstractCommandBuilder.md#appResource) as `pyspark-shell`.

??? note "pyspark-shell-main redefined to pyspark-shell"
    `buildPySparkShellCommand` is executed when requested for a [command](#buildCommand) with `pyspark-shell-main` application resource that is re-defined (_reset_) to `pyspark-shell` now.

`buildPySparkShellCommand` [constructEnvVarArgs](#constructEnvVarArgs) with the given `env` and `PYSPARK_SUBMIT_ARGS`.

`buildPySparkShellCommand` defines an internal `pyargs` collection for the parts of the shell command to execute.

`buildPySparkShellCommand` stores the Python executable (in `pyargs`) to be the first specified in the following order:

* `spark.pyspark.driver.python` configuration property
* `spark.pyspark.python` configuration property
* `PYSPARK_DRIVER_PYTHON` environment variable
* `PYSPARK_PYTHON` environment variable
* `python3`

`buildPySparkShellCommand` sets the environment variables (for the Python executable to use), if specified.

Environment Variable | Configuration Property
---------------------|-----------------------
 `PYSPARK_PYTHON` | `spark.pyspark.python`
 `SPARK_REMOTE` | [remote](../AbstractCommandBuilder.md#remote) option or `spark.remote`

In the end, `buildPySparkShellCommand` copies all the options from `PYSPARK_DRIVER_PYTHON_OPTS`, if specified.

### buildSparkSubmitCommand { #buildSparkSubmitCommand }

```java
List<String> buildSparkSubmitCommand(
  Map<String, String> env)
```

`buildSparkSubmitCommand` starts by [building so-called effective config](#getEffectiveConfig). When in [client mode](#isClientMode), `buildSparkSubmitCommand` adds [spark.driver.extraClassPath](../../driver.md#spark_driver_extraClassPath) to the result Spark command.

`buildSparkSubmitCommand` [builds the first part of the Java command](../AbstractCommandBuilder.md#buildJavaCommand) passing in the extra classpath (only for `client` deploy mode).

??? FIXME "Add `isThriftServer` case"

`buildSparkSubmitCommand` appends `SPARK_SUBMIT_OPTS` and `SPARK_JAVA_OPTS` environment variables.

(only for `client` deploy mode) ...

??? FIXME "Elaborate on the client deply mode case"

`addPermGenSizeOpt` case...elaborate

??? FIXME "Elaborate on `addPermGenSizeOpt`"

`buildSparkSubmitCommand` appends `org.apache.spark.deploy.SparkSubmit` and the command-line arguments (using [buildSparkSubmitArgs](#buildSparkSubmitArgs)).

## <span id="buildSparkSubmitArgs"> buildSparkSubmitArgs

```java
List<String> buildSparkSubmitArgs()
```

`buildSparkSubmitArgs` builds a list of command-line arguments for [spark-submit](index.md).

`buildSparkSubmitArgs` uses a [SparkSubmitOptionParser](SparkSubmitOptionParser.md) to add the command-line arguments that `spark-submit` recognizes (when it is executed later on and uses the very same `SparkSubmitOptionParser` parser to parse command-line arguments).

`buildSparkSubmitArgs` is used when:

* `InProcessLauncher` is requested to `startApplication`
* `SparkLauncher` is requested to [createBuilder](../SparkLauncher.md#createBuilder)
* `SparkSubmitCommandBuilder` is requested to [buildSparkSubmitCommand](#buildSparkSubmitCommand) and [constructEnvVarArgs](#constructEnvVarArgs)

## SparkSubmitCommandBuilder Properties and SparkSubmitOptionParser Attributes

SparkSubmitCommandBuilder Property | SparkSubmitOptionParser Attribute
---------|---------
 `verbose` | `VERBOSE`
 `master` | `MASTER [master]`
 `deployMode` | `DEPLOY_MODE [deployMode]`
 `appName` | `NAME [appName]`
 `conf` | `CONF [key=value]*`
 `propertiesFile` | `PROPERTIES_FILE [propertiesFile]`
 `jars` | `JARS [comma-separated jars]`
 `files` | `FILES [comma-separated files]`
 `pyFiles` | `PY_FILES [comma-separated pyFiles]`
 `mainClass` | `CLASS [mainClass]`
 `sparkArgs` | `sparkArgs` (passed straight through)
 `appResource` | `appResource` (passed straight through)
 `appArgs` | `appArgs` (passed straight through)

<!---
## Review Me

==== [[getEffectiveConfig]] `getEffectiveConfig` Internal Method

[source, java]
----
Map<String, String> getEffectiveConfig()
----

`getEffectiveConfig` internal method builds `effectiveConfig` that is `conf` with the Spark properties file loaded (using spark-AbstractCommandBuilder.md#loadPropertiesFile[loadPropertiesFile] internal method) skipping keys that have already been loaded (it happened when the command-line options were parsed in <<SparkSubmitCommandBuilder, handle>> method).

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

`OptionParser` is a custom spark-submit-SparkSubmitOptionParser.md[SparkSubmitOptionParser] that `SparkSubmitCommandBuilder` uses to parse command-line arguments. It defines all the spark-submit-SparkSubmitOptionParser.md#callbacks[SparkSubmitOptionParser callbacks], i.e. <<OptionParser-handle, handle>>, <<OptionParser-handleUnknown, handleUnknown>>, and <<OptionParser-handleExtraArgs, handleExtraArgs>>, for command-line argument handling.

==== [[OptionParser-handle]] OptionParser's `handle` Callback

[source, scala]
----
boolean handle(String opt, String value)
----

`OptionParser` comes with a custom `handle` callback (from the spark-submit-SparkSubmitOptionParser.md#callbacks[SparkSubmitOptionParser callbacks]).

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

It may also set `allowsMixedArguments` and `appResource` if the execution is for one of the special classes, i.e. spark-shell.md[spark-shell], `SparkSQLCLIDriver`, or spark-sql-thrift-server.md[HiveThriftServer2].
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

If `allowsMixedArguments` is enabled, `handleUnknown` simply adds the input `opt` to `appArgs` and allows for further spark-submit-SparkSubmitOptionParser.md#parse[parsing of the argument list].

CAUTION: FIXME Where's `allowsMixedArguments` enabled?

If `isExample` is enabled, `handleUnknown` sets `mainClass` to be `org.apache.spark.examples.[opt]` (unless the input `opt` has already the package prefix) and stops further spark-submit-SparkSubmitOptionParser.md#parse[parsing of the argument list].

CAUTION: FIXME Where's `isExample` enabled?

Otherwise, `handleUnknown` sets `appResource` and stops further spark-submit-SparkSubmitOptionParser.md#parse[parsing of the argument list].

==== [[OptionParser-handleExtraArgs]] OptionParser's `handleExtraArgs` Method

[source, scala]
----
void handleExtraArgs(List<String> extra)
----

`handleExtraArgs` adds all the `extra` arguments to `appArgs`.
-->
