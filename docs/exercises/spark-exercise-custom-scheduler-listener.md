== Exercise: Developing Custom SparkListener to monitor DAGScheduler in Scala

The example shows how to develop a custom Spark Listener. You should read SparkListener.md[] first to understand the motivation for the example.

=== Requirements

1. https://www.jetbrains.com/idea/[IntelliJ IDEA] (or eventually http://www.scala-sbt.org/[sbt] alone if you're adventurous).
2. Access to Internet to download Apache Spark's dependencies.

=== Setting up Scala project using IntelliJ IDEA

Create a new project `custom-spark-listener`.

Add the following line to `build.sbt` (the main configuration file for the sbt project) that adds the dependency on Apache Spark.

```
libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.1"
```

`build.sbt` should look as follows:

[source, scala]
----
name := "custom-spark-listener"
organization := "pl.jaceklaskowski.spark"
version := "1.0"

scalaVersion := "2.11.8"

libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.1"
----

=== Custom Listener - pl.jaceklaskowski.spark.CustomSparkListener

Create a Scala class -- `CustomSparkListener` -- for your custom `SparkListener`. It should be under `src/main/scala` directory (create one if it does not exist).

The aim of the class is to intercept scheduler events about jobs being started and tasks completed.

[source,scala]
----
package pl.jaceklaskowski.spark

import org.apache.spark.scheduler.{SparkListenerStageCompleted, SparkListener, SparkListenerJobStart}

class CustomSparkListener extends SparkListener {
  override def onJobStart(jobStart: SparkListenerJobStart) {
    println(s"Job started with ${jobStart.stageInfos.size} stages: $jobStart")
  }

  override def onStageCompleted(stageCompleted: SparkListenerStageCompleted): Unit = {
    println(s"Stage ${stageCompleted.stageInfo.stageId} completed with ${stageCompleted.stageInfo.numTasks} tasks.")
  }
}
----

=== Creating deployable package

Package the custom Spark listener. Execute `sbt package` command in the `custom-spark-listener` project's main directory.

```
$ sbt package
[info] Loading global plugins from /Users/jacek/.sbt/0.13/plugins
[info] Loading project definition from /Users/jacek/dev/workshops/spark-workshop/solutions/custom-spark-listener/project
[info] Updating {file:/Users/jacek/dev/workshops/spark-workshop/solutions/custom-spark-listener/project/}custom-spark-listener-build...
[info] Resolving org.fusesource.jansi#jansi;1.4 ...
[info] Done updating.
[info] Set current project to custom-spark-listener (in build file:/Users/jacek/dev/workshops/spark-workshop/solutions/custom-spark-listener/)
[info] Updating {file:/Users/jacek/dev/workshops/spark-workshop/solutions/custom-spark-listener/}custom-spark-listener...
[info] Resolving jline#jline;2.12.1 ...
[info] Done updating.
[info] Compiling 1 Scala source to /Users/jacek/dev/workshops/spark-workshop/solutions/custom-spark-listener/target/scala-2.11/classes...
[info] Packaging /Users/jacek/dev/workshops/spark-workshop/solutions/custom-spark-listener/target/scala-2.11/custom-spark-listener_2.11-1.0.jar ...
[info] Done packaging.
[success] Total time: 8 s, completed Oct 27, 2016 11:23:50 AM
```

You should find the result jar file with the custom scheduler listener ready under `target/scala-2.11` directory, e.g. `target/scala-2.11/custom-spark-listener_2.11-1.0.jar`.

=== Activating Custom Listener in Spark shell

Start ../spark-shell.md[spark-shell] with additional configurations for the extra custom listener and the jar that includes the class.

```
$ spark-shell \
  --conf spark.logConf=true \
  --conf spark.extraListeners=pl.jaceklaskowski.spark.CustomSparkListener \
  --driver-class-path target/scala-2.11/custom-spark-listener_2.11-1.0.jar
```

Create a ../spark-sql-Dataset.md#implicits[Dataset] and execute an action like `show` to start a job as follows:

```
scala> spark.read.text("README.md").count
[CustomSparkListener] Job started with 2 stages: SparkListenerJobStart(1,1473946006715,WrappedArray(org.apache.spark.scheduler.StageInfo@71515592, org.apache.spark.scheduler.StageInfo@6852819d),{spark.rdd.scope.noOverride=true, spark.rdd.scope={"id":"14","name":"collect"}, spark.sql.execution.id=2})
[CustomSparkListener] Stage 1 completed with 1 tasks.
[CustomSparkListener] Stage 2 completed with 1 tasks.
res0: Long = 7
```

The lines with `[CustomSparkListener]` came from your custom Spark listener. Congratulations! The exercise's over.

=== BONUS Activating Custom Listener in Spark Application

TIP: Read SparkContext.md#addSparkListener[Registering SparkListener].

=== Questions

1. What are the pros and cons of using the command line version vs inside a Spark application?
