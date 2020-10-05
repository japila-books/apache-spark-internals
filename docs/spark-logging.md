# Logging

Spark uses [log4j](http://logging.apache.org/log4j) for logging.

## <span id="levels"> Logging Levels

The valid logging levels are [log4j's Levels](http://logging.apache.org/log4j/2.x/log4j-api/apidocs/index.html) (from most specific to least):

* `OFF` (most specific, no logging)
* `FATAL` (most specific, little data)
* `ERROR`
* `WARN`
* `INFO`
* `DEBUG`
* `TRACE` (least specific, a lot of data)
* `ALL` (least specific, all data)

## conf/log4j.properties

You can set up the default logging for Spark shell in `conf/log4j.properties`. Use `conf/log4j.properties.template` as a starting point.

## <span id="setting-default-log-level"> Setting Default Log Level Programatically

Refer to [Setting Default Log Level Programatically](SparkContext.md#setting-default-log-level) in [SparkContext -- Entry Point to Spark Core](SparkContext.md).

## <span id="setting-log-levels-applications"> Setting Log Levels in Spark Applications

In standalone Spark applications or while in [Spark Shell](tools/spark-shell.md) session, use the following:

```text
import org.apache.log4j.{Level, Logger}

Logger.getLogger(classOf[RackResolver]).getLevel
Logger.getLogger("org").setLevel(Level.OFF)
Logger.getLogger("akka").setLevel(Level.OFF)
```

## sbt

When running a Spark application from within sbt using `run` task, you can use the following `build.sbt` to configure logging levels:

```text
fork in run := true
javaOptions in run ++= Seq(
  "-Dlog4j.debug=true",
  "-Dlog4j.configuration=log4j.properties")
outputStrategy := Some(StdoutOutput)
```

With the above configuration `log4j.properties` file should be on CLASSPATH which can be in `src/main/resources` directory (that is included in CLASSPATH by default).

When `run` starts, you should see the following output in sbt:

```text
[spark-activator]> run
[info] Running StreamingApp
log4j: Trying to find [log4j.properties] using context classloader sun.misc.Launcher$AppClassLoader@1b6d3586.
log4j: Using URL [file:/Users/jacek/dev/oss/spark-activator/target/scala-2.11/classes/log4j.properties] for automatic log4j configuration.
log4j: Reading configuration from URL file:/Users/jacek/dev/oss/spark-activator/target/scala-2.11/classes/log4j.properties
```

## Disabling Logging

Use the following `conf/log4j.properties` to disable logging completely:

```text
log4j.logger.org=OFF
```
