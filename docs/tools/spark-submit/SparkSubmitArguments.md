# SparkSubmitArguments

`SparkSubmitArguments` is created  for `SparkSubmit` to [parseArguments](SparkSubmit.md#parseArguments).

`SparkSubmitArguments` is a custom `SparkSubmitArgumentsParser` to [handle](#handle) the command-line arguments of [spark-submit](index.md) script that the [actions](index.md#actions) use for execution (possibly with the explicit `env` environment).

`SparkSubmitArguments` is created when [launching spark-submit script](#main) with only `args` passed in and later used for printing the arguments in [verbose mode](#verbose-mode).

## Creating Instance

`SparkSubmitArguments` takes the following to be created:

* <span id="args"> Arguments (`Seq[String]`)
* <span id="env"> Environment Variables (default: `sys.env`)

`SparkSubmitArguments` is created when:

* `SparkSubmit` is requested to [parseArguments](SparkSubmit.md#parseArguments)

## Action

```scala
action: SparkSubmitAction
```

`action` is used by [SparkSubmit](SparkSubmit.md) to determine what to do when [executed](SparkSubmit.md#doSubmit).

`action` can be one of the following `SparkSubmitAction`s:

Action | Description
-------|------------
 `SUBMIT` | The default action if none specified
 `KILL` | Indicates [--kill](SparkSubmitOptionParser.md#KILL_SUBMISSION) switch
 `REQUEST_STATUS` | Indicates [--status](SparkSubmitOptionParser.md#STATUS) switch
 `PRINT_VERSION` | Indicates [--version](SparkSubmitOptionParser.md#VERSION) switch

`action` is undefined (`null`) by default (when `SparkSubmitAction` is [created](#creating-instance)).

`action` is validated when [validateArguments](#validateArguments).

## Command-Line Options

### <span id="files"> --files

* Configuration Property: [spark.files](../../configuration-properties.md#spark.files)
* Configuration Property (Spark on YARN): `spark.yarn.dist.files`

Printed out to standard output for `--verbose` option

When `SparkSubmit` is requested to [prepareSubmitEnvironment](SparkSubmit.md#prepareSubmitEnvironment), the files are:

* [resolveGlobPaths](../DependencyUtils.md#resolveGlobPaths)
* [downloadFileList](../DependencyUtils.md#downloadFileList)
* [renameResourcesToLocalFS](SparkSubmit.md#renameResourcesToLocalFS)
* [downloadResource](SparkSubmit.md#downloadResource)

## <span id="loadEnvironmentArguments"> Loading Spark Properties

```scala
loadEnvironmentArguments(): Unit
```

`loadEnvironmentArguments` loads the Spark properties for the current execution of [spark-submit](index.md).

`loadEnvironmentArguments` reads command-line options first followed by Spark properties and System's environment variables.

!!! note
    Spark config properties start with `spark.` prefix and can be set using `--conf [key=value]` command-line option.

## Option Handling { #handle }

??? note "SparkSubmitOptionParser"

    ```scala
    handle(
      opt: String,
      value: String): Boolean
    ```

    `handle` is part of the [SparkSubmitOptionParser](SparkSubmitOptionParser.md#handle) abstraction.

`handle` parses the input `opt` argument and assigns the given `value` to corresponding properties.

In the end, `handle` returns whether it was executed for any [action](#action) but [PRINT_VERSION](#action).

 User Option (`opt`) | Property
----|---------
 `--kill` | [action](#action)
 `--name` | [name](#name)
 `--status` | [action](#action)
 `--version` | [action](#action)
 ... | ...

## <span id="mergeDefaultSparkProperties"> mergeDefaultSparkProperties

```scala
mergeDefaultSparkProperties(): Unit
```

`mergeDefaultSparkProperties` merges Spark properties from the [default Spark properties file, i.e. `spark-defaults.conf`](../../spark-properties.md#spark-defaults-conf) with those specified through `--conf` command-line option.

## isPython { #isPython }

```scala
isPython: Boolean = false
```

`isPython` indicates whether the application resource is a [PySpark application](SparkSubmit.md#isPython) (a Python script or [pyspark](../pyspark.md) shell).

`isPython` is [isPython](SparkSubmit.md#isPython) when `SparkSubmitArguments` is requested to [handle a unknown option](#handleUnknown).

### Client Deploy Mode

With [isPython](#isPython) flag enabled, [SparkSubmit](SparkSubmit.md#prepareSubmitEnvironment) determines the [mainClass](#mainClass) (and the [childArgs](#childArgs)) based on the [primaryResource](#primaryResource).

primaryResource | mainClass
----------------|----------
 `pyspark-shell` | `org.apache.spark.api.python.PythonGatewayServer` ([PySpark]({{ book.pyspark }}/PythonGatewayServer/))
 _anything else_ | `org.apache.spark.deploy.PythonRunner` ([PySpark]({{ book.pyspark }}/PythonRunner/))
