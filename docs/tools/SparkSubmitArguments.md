# SparkSubmitArguments

`SparkSubmitArguments` is a custom `SparkSubmitArgumentsParser` to [handle](#handle) the command-line arguments of [spark-submit](spark-submit.md) script that the [actions](spark-submit.md#actions) use for execution (possibly with the explicit `env` environment).

`SparkSubmitArguments` is created when [launching spark-submit script](#main) with only `args` passed in and later used for printing the arguments in [verbose mode](#verbose-mode).

## Command-Line Options

### <span id="files"> --files

* Configuration Property: [spark.files](../configuration-properties.md#spark.files)
* Configuration Property (Spark on YARN): `spark.yarn.dist.files`

Printed out to standard output for `--verbose` option

When `SparkSubmit` is requested to [prepareSubmitEnvironment](SparkSubmit.md#prepareSubmitEnvironment), the files are:

* [resolveGlobPaths](DependencyUtils.md#resolveGlobPaths)
* [downloadFileList](DependencyUtils.md#downloadFileList)
* [renameResourcesToLocalFS](SparkSubmit.md#renameResourcesToLocalFS)
* [downloadResource](SparkSubmit.md#downloadResource)

## Creating Instance

`SparkSubmitArguments` takes the following to be created:

* <span id="args"> Arguments (`Seq[String]`)
* <span id="env"> Environment Variables (default: `sys.env`)

`SparkSubmitArguments` is created when:

* `SparkSubmit` is requested to [parseArguments](SparkSubmit.md#parseArguments) and [launched as a command-line application](SparkSubmit.md#main)

## <span id="loadEnvironmentArguments"> Loading Spark Properties

```scala
loadEnvironmentArguments(): Unit
```

`loadEnvironmentArguments` loads the Spark properties for the current execution of [spark-submit](spark-submit.md).

`loadEnvironmentArguments` reads command-line options first followed by Spark properties and System's environment variables.

!!! note
    Spark config properties start with `spark.` prefix and can be set using `--conf [key=value]` command-line option.

## <span id="handle"> Handling Options

```scala
handle(
  opt: String,
  value: String): Boolean
```

`handle` parses the input `opt` argument and returns `true` or throws an `IllegalArgumentException` when it finds an unknown `opt`.

`handle` sets the internal properties in the table [Command-Line Options, Spark Properties and Environment Variables](spark-submit.md#options-properties-variables).

## <span id="mergeDefaultSparkProperties"> mergeDefaultSparkProperties

```scala
mergeDefaultSparkProperties(): Unit
```

`mergeDefaultSparkProperties` merges Spark properties from the [default Spark properties file, i.e. `spark-defaults.conf`](../spark-properties.md#spark-defaults-conf) with those specified through `--conf` command-line option.

## <span id="isPython"> isPython Flag

```scala
isPython: Boolean = false
```

`isPython` indicates whether the application resource is a [PySpark application](SparkSubmit.md#isPython) (a Python script or `pyspark` shell).
