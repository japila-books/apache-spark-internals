# ConsoleProgressBar

`ConsoleProgressBar` shows the progress of active stages to standard error, i.e. `stderr`. It uses [SparkStatusTracker](SparkStatusTracker.md) to poll the status of stages periodically and print out active stages with more than one task. It keeps overwriting itself to hold in one line for at most 3 first concurrent stages at a time.

```text
[Stage 0:====>          (316 + 4) / 1000][Stage 1:>                (0 + 0) / 1000][Stage 2:>                (0 + 0) / 1000]]]
```

The progress includes the stage id, the number of completed, active, and total tasks.

TIP: `ConsoleProgressBar` may be useful when you `ssh` to workers and want to see the progress of active stages.

<<creating-instance, `ConsoleProgressBar` is created>> when [SparkContext](SparkContext.md) is created with [spark.ui.showConsoleProgress](configuration-properties.md#spark.ui.showConsoleProgress) enabled and the logging level of SparkContext.md[org.apache.spark.SparkContext] logger as `WARN` or higher (i.e. less messages are printed out and so there is a "space" for `ConsoleProgressBar`).

[source, scala]
----
import org.apache.log4j._
Logger.getLogger("org.apache.spark.SparkContext").setLevel(Level.WARN)
----

To print the progress nicely `ConsoleProgressBar` uses `COLUMNS` environment variable to know the width of the terminal. It assumes `80` columns.

The progress bar prints out the status after a stage has ran at least `500` milliseconds every spark-webui-properties.md#spark.ui.consoleProgress.update.interval[spark.ui.consoleProgress.update.interval] milliseconds.

NOTE: The initial delay of `500` milliseconds before `ConsoleProgressBar` show the progress is not configurable.

See the progress bar in Spark shell with the following:

[source]
----
$ ./bin/spark-shell --conf spark.ui.showConsoleProgress=true  # <1>

scala> sc.setLogLevel("OFF")  // <2>

import org.apache.log4j._
scala> Logger.getLogger("org.apache.spark.SparkContext").setLevel(Level.WARN)  // <3>

scala> sc.parallelize(1 to 4, 4).map { n => Thread.sleep(500 + 200 * n); n }.count  // <4>
[Stage 2:>                                                          (0 + 4) / 4]
[Stage 2:==============>                                            (1 + 3) / 4]
[Stage 2:=============================>                             (2 + 2) / 4]
[Stage 2:============================================>              (3 + 1) / 4]
----
<1> Make sure `spark.ui.showConsoleProgress` is `true`. It is by default.
<2> Disable (`OFF`) the root logger (that includes Spark's logger)
<3> Make sure `org.apache.spark.SparkContext` logger is at least `WARN`.
<4> Run a job with 4 tasks with 500ms initial sleep and 200ms sleep chunks to see the progress bar.

TIP: https://youtu.be/uEmcGo8rwek[Watch the short video] that show ConsoleProgressBar in action.

You may want to use the following example to see the progress bar in full glory - all 3 concurrent stages in console (borrowed from https://github.com/apache/spark/pull/3029#issuecomment-63244719[a comment to [SPARK-4017\] show progress bar in console #3029]):

```
> ./bin/spark-shell
scala> val a = sc.makeRDD(1 to 1000, 10000).map(x => (x, x)).reduceByKey(_ + _)
scala> val b = sc.makeRDD(1 to 1000, 10000).map(x => (x, x)).reduceByKey(_ + _)
scala> a.union(b).count()
```

=== [[creating-instance]] Creating ConsoleProgressBar Instance

`ConsoleProgressBar` requires a SparkContext.md[SparkContext].

When being created, `ConsoleProgressBar` reads spark-webui-properties.md#spark.ui.consoleProgress.update.interval[spark.ui.consoleProgress.update.interval] configuration property to set up the update interval and `COLUMNS` environment variable for the terminal width (or assumes `80` columns).

`ConsoleProgressBar` starts the internal timer `refresh progress` that does <<refresh, refresh>> and shows progress.

NOTE: `ConsoleProgressBar` is created when [SparkContext](SparkContext.md) is created, [spark.ui.showConsoleProgress](configuration-properties.md#spark.ui.showConsoleProgress) configuration property is enabled, and the logging level of SparkContext.md[org.apache.spark.SparkContext] logger is `WARN` or higher (i.e. less messages are printed out and so there is a "space" for `ConsoleProgressBar`).

NOTE: Once created, `ConsoleProgressBar` is available internally as `_progressBar`.

=== [[finishAll]] `finishAll` Method

CAUTION: FIXME

=== [[stop]] `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` cancels (stops) the internal timer.

NOTE: `stop` is executed when SparkContext.md#stop[`SparkContext` stops].

=== [[refresh]] `refresh` Internal Method

[source, scala]
----
refresh(): Unit
----

`refresh`...FIXME

NOTE: `refresh` is used when...FIXME
