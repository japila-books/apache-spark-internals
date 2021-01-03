# ClientArguments

`ClientArguments` represents a [KubernetesClientApplication](KubernetesClientApplication.md) to start.

## Creating Instance

`ClientArguments` takes the following to be created:

* <span id="mainAppResource"> `MainAppResource`
* <span id="mainClass"> Name of the main class of a Spark application to run
* <span id="driverArgs"> Driver Arguments

`ClientArguments` is created (via [fromCommandLineArgs](#fromCommandLineArgs) utility) when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)

## <span id="fromCommandLineArgs"> fromCommandLineArgs Utility

```scala
fromCommandLineArgs(
  args: Array[String]): ClientArguments
```

`fromCommandLineArgs` slices the input `args` into key-value pairs and creates a [ClientArguments](#creating-instance) as follows:

* `--primary-java-resource`, `--primary-py-file` or `--primary-r-file` keys are used for the [MainAppResource](#mainAppResource)
* `--main-class` for the [name of the main class](#mainClass)
* `--arg` for the [driver arguments](#driverArgs)

!!! important
    The [main class](#mainClass) must be specified via `--main-class` or `fromCommandLineArgs` throws an `IllegalArgumentException`.

`fromCommandLineArgs` is used when:

* `KubernetesClientApplication` is requested to [start](KubernetesClientApplication.md#start)
