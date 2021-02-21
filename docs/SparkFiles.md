# SparkFiles

`SparkFiles` is an utility to work with files added using [SparkContext.addFile](SparkContext.md#addFile).

## <span id="get"> Absolute Path of Added File

```scala
get(
  filename: String): String
```

`get` gets the absolute path of the given file in the [root directory](#getRootDirectory).

## <span id="getRootDirectory"> Root Directory

```scala
getRootDirectory(): String
```

`getRootDirectory` requests the current `SparkEnv` for [driverTmpDir](SparkEnv.md#driverTmpDir) (if defined) or defaults to the current directory (`.`).

`getRootDirectory` is used when:

* `SparkContext` is requested to [addFile](SparkContext.md#addFile)
* `Executor` is requested to [updateDependencies](executor/Executor.md#updateDependencies)
* `SparkFiles` utility is requested to [get the absolute path of a file](#get)
