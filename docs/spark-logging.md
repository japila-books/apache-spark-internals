# Spark Logging

Apache Spark uses [Apache Log4j 2](https://logging.apache.org/log4j/2.x/index.html) for logging.

## conf/log4j2.properties

The default logging for Spark applications is in `conf/log4j2.properties`.

Use `conf/log4j2.properties.template` as a starting point.

## <span id="levels"> Logging Levels

The valid logging levels are [log4j's Levels](https://logging.apache.org/log4j/2.x/log4j-api/apidocs/org/apache/logging/log4j/Level.html) (from most specific to least):

Name | Description
-----|-------------
 `OFF` | No events will be logged
 `FATAL` | A fatal event that will prevent the application from continuing
 `ERROR` | An error in the application, possibly recoverable
 `WARN` | An event that might possible lead to an error
 `INFO` | An event for informational purposes
 `DEBUG` | A general debugging event
 `TRACE` | A fine-grained debug message, typically capturing the flow through the application
 `ALL` | All events should be logged

The names of the logging levels are case-insensitive.

## Turn Logging Off

The following sample `conf/log4j2.properties` turns all logging of Apache Spark (and Apache Hadoop) off.

```text
# Set to debug or trace if log4j initialization fails
status = warn

# Name of the configuration
name = exploring-internals

# Console appender configuration
appender.console.type = Console
appender.console.name = consoleLogger
appender.console.layout.type = PatternLayout
appender.console.layout.pattern = %d{YYYY-MM-dd HH:mm:ss} [%t] %-5p %c:%L - %m%n
appender.console.target = SYSTEM_OUT

rootLogger.level = off
rootLogger.appenderRef.stdout.ref = consoleLogger

logger.spark.name = org.apache.spark
logger.spark.level = off

logger.hadoop.name = org.apache.hadoop
logger.hadoop.level = off
```

## <span id="setting-default-log-level"> Setting Default Log Level Programatically

[Setting Default Log Level Programatically](SparkContext.md#setting-default-log-level)

## <span id="setting-log-levels-applications"> Setting Log Levels in Spark Applications

In standalone Spark applications or while in [Spark Shell](tools/spark-shell.md) session, use the following:

```text
import org.apache.log4j.{Level, Logger}

Logger.getLogger(classOf[RackResolver]).getLevel
Logger.getLogger("org").setLevel(Level.OFF)
```
