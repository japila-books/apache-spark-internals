== Your first Spark application (using Scala and sbt)

This page gives you the exact steps to develop and run a complete Spark application using http://www.scala-lang.org/[Scala] programming language and http://www.scala-sbt.org/[sbt] as the build tool.

[TIP]
Refer to Quick Start's  http://people.apache.org/~pwendell/spark-nightly/spark-master-docs/latest/quick-start.html#self-contained-applications[Self-Contained Applications] in the official documentation.

The sample application called *SparkMe App* is...FIXME

=== Overview

You're going to use http://www.scala-sbt.org/[sbt] as the project build tool. It uses `build.sbt` for the project's description as well as the dependencies, i.e. the version of Apache Spark and others.

The application's main code is under `src/main/scala` directory, in `SparkMeApp.scala` file.

With the files in a directory, executing `sbt package` results in a package that can be deployed onto a Spark cluster using `spark-submit`.

In this example, you're going to use Spark's local/spark-local.md[local mode].

=== Project's build - build.sbt

Any Scala project managed by sbt uses `build.sbt` as the central place for configuration, including project dependencies denoted as `libraryDependencies`.

*build.sbt*
```
name         := "SparkMe Project"
version      := "1.0"
organization := "pl.japila"

scalaVersion := "2.11.7"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.6.0-SNAPSHOT"  // <1>
resolvers += Resolver.mavenLocal
```
<1> Use the development version of Spark 1.6.0-SNAPSHOT

=== SparkMe Application

The application uses a single command-line parameter (as `args(0)`) that is the file to process. The file is read and the number of lines printed out.

```
package pl.japila.spark

import org.apache.spark.{SparkContext, SparkConf}

object SparkMeApp {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("SparkMe Application")
    val sc = new SparkContext(conf)

    val fileName = args(0)
    val lines = sc.textFile(fileName).cache

    val c = lines.count
    println(s"There are $c lines in $fileName")
  }
}
```

=== sbt version - project/build.properties

sbt (launcher) uses `project/build.properties` file to set (the real) sbt up

```
sbt.version=0.13.9
```

TIP: With the file the build is more predictable as the version of sbt doesn't depend on the sbt launcher.

=== Packaging Application

Execute `sbt package` to package the application.

```
➜  sparkme-app  sbt package
[info] Loading global plugins from /Users/jacek/.sbt/0.13/plugins
[info] Loading project definition from /Users/jacek/dev/sandbox/sparkme-app/project
[info] Set current project to SparkMe Project (in build file:/Users/jacek/dev/sandbox/sparkme-app/)
[info] Compiling 1 Scala source to /Users/jacek/dev/sandbox/sparkme-app/target/scala-2.11/classes...
[info] Packaging /Users/jacek/dev/sandbox/sparkme-app/target/scala-2.11/sparkme-project_2.11-1.0.jar ...
[info] Done packaging.
[success] Total time: 3 s, completed Sep 23, 2015 12:47:52 AM
```

The application uses only classes that comes with Spark so `package` is enough.

In `target/scala-2.11/sparkme-project_2.11-1.0.jar` there is the final application ready for deployment.

=== Submitting Application to Spark (local)

NOTE: The application is going to be deployed to `local[*]`. Change it to whatever cluster you have available (refer to spark-cluster.md[Running Spark in cluster]).

`spark-submit` the SparkMe application and specify the file to process (as it is the only and required input parameter to the application), e.g. `build.sbt` of the project.

NOTE: `build.sbt` is sbt's build definition and is only used as an input file for demonstration purposes. *Any* file is going to work fine.

```
➜  sparkme-app  ~/dev/oss/spark/bin/spark-submit --master "local[*]" --class pl.japila.spark.SparkMeApp target/scala-2.11/sparkme-project_2.11-1.0.jar build.sbt
Using Spark's repl log4j profile: org/apache/spark/log4j-defaults-repl.properties
To adjust logging level use sc.setLogLevel("INFO")
15/09/23 01:06:02 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
15/09/23 01:06:04 WARN MetricsSystem: Using default name DAGScheduler for source because spark.app.id is not set.
There are 8 lines in build.sbt
```

NOTE: Disregard the two above WARN log messages.

You're done. Sincere congratulations!
