# spark-shell shell script

**Spark shell** is an interactive environment where you can learn how to make the most out of Apache Spark quickly and conveniently.

!!! tip
    Spark shell is particularly helpful for fast interactive prototyping.

Under the covers, Spark shell is a standalone Spark application written in Scala that offers environment with auto-completion (using `TAB` key) where you can run ad-hoc queries and get familiar with the features of Spark (that help you in developing your own standalone Spark applications). It is a very convenient tool to explore the many things available in Spark with immediate feedback. It is one of the many reasons why spark-overview.md#why-spark[Spark is so helpful for tasks to process datasets of any size].

There are variants of Spark shell for different languages: `spark-shell` for Scala, `pyspark` for Python and `sparkR` for R.

You can start Spark shell using `spark-shell` script.

```text
$ ./bin/spark-shell
scala>
```

`spark-shell` is an extension of Scala REPL with automatic instantiation of spark-sql-SparkSession.md[SparkSession] as `spark` (and SparkContext.md[] as `sc`).

```text
scala> :type spark
org.apache.spark.sql.SparkSession

// Learn the current version of Spark in use
scala> spark.version
res0: String = 2.1.0-SNAPSHOT
```

`spark-shell` imports Scala SQL's implicits and `sql` method.

```text
scala> :imports
 1) import spark.implicits._       (59 terms, 38 are implicit)
 2) import spark.sql               (1 terms)
```

!!! note
    When you execute `spark-shell` you actually execute spark-submit/index.md[Spark submit] as follows:

    ```text
    org.apache.spark.deploy.SparkSubmit --class org.apache.spark.repl.Main --name Spark shell spark-shell
    ```
    
    Set `SPARK_PRINT_LAUNCH_COMMAND` to see the entire command to be executed.
    Refer to [Print Launch Command of Spark Scripts](../tips-and-tricks/index.md#SPARK_PRINT_LAUNCH_COMMAND)

## Using Spark shell

You start Spark shell using `spark-shell` script (available in `bin` directory).

```text
$ ./bin/spark-shell
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
WARN ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
Spark context Web UI available at http://10.47.71.138:4040
Spark context available as 'sc' (master = local[*], app id = local-1477858597347).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.1.0-SNAPSHOT
      /_/

Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_112)
Type in expressions to have them evaluated.
Type :help for more information.

scala>
```

Spark shell creates an instance of spark-sql-SparkSession.md[SparkSession] under the name `spark` for you (so you don't have to know the details how to do it yourself on day 1).

```text
scala> :type spark
org.apache.spark.sql.SparkSession
```

Besides, there is also `sc` value created which is an instance of [SparkContext](../SparkContext.md).

```text
scala> :type sc
org.apache.spark.SparkContext
```

To close Spark shell, you press `Ctrl+D` or type in `:q` (or any subset of `:quit`).

```text
scala> :q
```
