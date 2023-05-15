# AbstractCommandBuilder

`AbstractCommandBuilder` is an [abstraction](#contract) of [launch command builders](#implementations).

## Contract

### Building Command { #buildCommand }

```java
List<String> buildCommand(
  Map<String, String> env)
```

Builds a command to launch a script on command line

See:

* [SparkClassCommandBuilder](SparkClassCommandBuilder.md#buildCommand)
* [SparkSubmitCommandBuilder](spark-submit/SparkSubmitCommandBuilder.md#buildCommand)

Used when:

* `Main` is requested to [build a command](Main.md#buildCommand)

## Implementations

* [SparkClassCommandBuilder](SparkClassCommandBuilder.md)
* [SparkSubmitCommandBuilder](spark-submit/SparkSubmitCommandBuilder.md)
* WorkerCommandBuilder

## <span id="buildJavaCommand"> buildJavaCommand

```java
List<String> buildJavaCommand(
  String extraClassPath)
```

`buildJavaCommand` builds the Java command for a Spark application (which is a collection of elements with the path to `java` executable, JVM options from `java-opts` file, and a class path).

If `javaHome` is set, `buildJavaCommand` adds `[javaHome]/bin/java` to the result Java command. Otherwise, it uses `JAVA_HOME` or, when no earlier checks succeeded, falls through to `java.home` Java's system property.

CAUTION: FIXME Who sets `javaHome` internal property and when?

`buildJavaCommand` loads extra Java options from the `java-opts` file in [configuration directory](#configuration-directory) if the file exists and adds them to the result Java command.

Eventually, `buildJavaCommand` [builds the class path](#buildClassPath) (with the extra class path if non-empty) and adds it as `-cp` to the result Java command.

## <span id="buildClassPath"> buildClassPath

```java
List<String> buildClassPath(
  String appClassPath)
```

`buildClassPath` builds the classpath for a Spark application.

!!! NOTE
    Directories always end up with the OS-specific file separator at the end of their paths.

`buildClassPath` adds the following in that order:

1. `SPARK_CLASSPATH` environment variable
2. The input `appClassPath`
3. The [configuration directory](#getConfDir)
4. (only with `SPARK_PREPEND_CLASSES` set or `SPARK_TESTING` being `1`) Locally compiled Spark classes in `classes`, `test-classes` and Core's jars.
+
CAUTION: FIXME Elaborate on "locally compiled Spark classes".

5. (only with `SPARK_SQL_TESTING` being `1`) ...
+
CAUTION: FIXME Elaborate on the SQL testing case

6. `HADOOP_CONF_DIR` environment variable

7. `YARN_CONF_DIR` environment variable

8. `SPARK_DIST_CLASSPATH` environment variable

NOTE: `childEnv` is queried first before System properties. It is always empty for `AbstractCommandBuilder` (and `SparkSubmitCommandBuilder`, too).

## <span id="loadPropertiesFile"> Loading Properties File

```java
Properties loadPropertiesFile()
```

`loadPropertiesFile` loads Spark settings from a properties file (when specified on the command line) or [spark-defaults.conf](../spark-properties.md#spark-defaults-conf) in the [configuration directory](#configuration-directory).

`loadPropertiesFile` loads the settings from the following files starting from the first and checking every location until the first properties file is found:

1. `propertiesFile` (if specified using `--properties-file` command-line option or set by `AbstractCommandBuilder.setPropertiesFile`).
2. `[SPARK_CONF_DIR]/spark-defaults.conf`
3. `[SPARK_HOME]/conf/spark-defaults.conf`

## <span id="getConfDir"><span id="configuration-directory"> Spark's Configuration Directory

`AbstractCommandBuilder` uses `getConfDir` to compute the current configuration directory of a Spark application.

It uses `SPARK_CONF_DIR` (from `childEnv` which is always empty anyway or as a environment variable) and falls through to `[SPARK_HOME]/conf` (with `SPARK_HOME` from [getSparkHome](#getSparkHome)).

## <span id="getSparkHome"><span id="home-directory"> Spark's Home Directory

`AbstractCommandBuilder` uses `getSparkHome` to compute Spark's home directory for a Spark application.

It uses `SPARK_HOME` (from `childEnv` which is always empty anyway or as a environment variable).

If `SPARK_HOME` is not set, Spark throws a `IllegalStateException`:

```text
Spark home not found; set it explicitly or use the SPARK_HOME environment variable.
```

## Application Resource { #appResource }

```java
String appResource
```

`AbstractCommandBuilder` uses `appResource` variable for the name of an application resource.

`appResource` can be one of the following application resource names:

Identifier | appResource
-----------|------------
 `pyspark-shell-main` | `pyspark-shell-main`
 `sparkr-shell-main` | `sparkr-shell-main`
 `run-example` | [findExamplesAppJar](spark-submit/SparkSubmitCommandBuilder.md#findExamplesAppJar)
 `pyspark-shell` | [buildPySparkShellCommand](spark-submit/SparkSubmitCommandBuilder.md#buildPySparkShellCommand)
 `sparkr-shell` | [buildSparkRCommand](spark-submit/SparkSubmitCommandBuilder.md#buildSparkRCommand)

`appResource` can be specified when:

* `AbstractLauncher` is requested to [setAppResource](AbstractLauncher.md#setAppResource)
* `SparkSubmitCommandBuilder` is [created](spark-submit/SparkSubmitCommandBuilder.md#creating-instance)
* `SparkSubmitCommandBuilder.OptionParser` is requested to handle [known](spark-submit/SparkSubmitCommandBuilder.OptionParser.md#handle) or [unknown](spark-submit/SparkSubmitCommandBuilder.OptionParser.md#handleUnknown) options

`appResource` is used when:

* `SparkLauncher` is requested to [startApplication](SparkLauncher.md#startApplication)
* `SparkSubmitCommandBuilder` is requested to [build a command](spark-submit/SparkSubmitCommandBuilder.md#buildCommand), [buildSparkSubmitArgs](spark-submit/SparkSubmitCommandBuilder.md#buildSparkSubmitArgs)
