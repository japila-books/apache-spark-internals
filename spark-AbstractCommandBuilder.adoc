== [[AbstractCommandBuilder]] AbstractCommandBuilder

`AbstractCommandBuilder` is the base command builder for  link:spark-submit-SparkSubmitCommandBuilder.adoc[SparkSubmitCommandBuilder] and `SparkClassCommandBuilder` specialized command builders.

`AbstractCommandBuilder` expects that command builders define `buildCommand`.

.`AbstractCommandBuilder` Methods
[cols="1,2",options="header",width="100%"]
|===
| Method | Description
| `buildCommand` | The only abstract method that subclasses have to define.
| <<buildJavaCommand, buildJavaCommand>> |
| <<getConfDir, getConfDir>> |
| <<loadPropertiesFile, loadPropertiesFile>> | Loads the configuration file for a Spark application, be it the user-specified properties file or `spark-defaults.conf` file under the Spark configuration directory.
|===

=== [[buildJavaCommand]] `buildJavaCommand` Internal Method

[source, java]
----
List<String> buildJavaCommand(String extraClassPath)
----

`buildJavaCommand` builds the Java command for a Spark application (which is a collection of elements with the path to `java` executable, JVM options from `java-opts` file, and a class path).

If `javaHome` is set, `buildJavaCommand` adds `[javaHome]/bin/java` to the result Java command. Otherwise, it uses `JAVA_HOME` or, when no earlier checks succeeded, falls through to `java.home` Java's system property.

CAUTION: FIXME Who sets `javaHome` internal property and when?

`buildJavaCommand` loads extra Java options from the `java-opts` file in <<configuration-directory, configuration directory>> if the file exists and adds them to the result Java command.

Eventually, `buildJavaCommand` <<buildClassPath, builds the class path>> (with the extra class path if non-empty) and adds it as `-cp` to the result Java command.

=== [[buildClassPath]] `buildClassPath` method

[source, java]
----
List<String> buildClassPath(String appClassPath)
----

`buildClassPath` builds the classpath for a Spark application.

NOTE: Directories always end up with the OS-specific file separator at the end of their paths.

`buildClassPath` adds the following in that order:

1. `SPARK_CLASSPATH` environment variable
2. The input `appClassPath`
3. The link:spark-AbstractCommandBuilder.adoc#getConfDir[configuration directory]
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

=== [[loadPropertiesFile]] Loading Properties File -- `loadPropertiesFile` Internal Method

[source, java]
----
Properties loadPropertiesFile()
----

`loadPropertiesFile` is part of `AbstractCommandBuilder` _private_ API that loads Spark settings from a properties file (when specified on the command line) or link:spark-properties.adoc#spark-defaults-conf[spark-defaults.conf] in the <<configuration-directory, configuration directory>>.

It loads the settings from the following files starting from the first and checking every location until the first properties file is found:

1. `propertiesFile` (if specified using `--properties-file` command-line option or set by `AbstractCommandBuilder.setPropertiesFile`).
2. `[SPARK_CONF_DIR]/spark-defaults.conf`
3. `[SPARK_HOME]/conf/spark-defaults.conf`

NOTE: `loadPropertiesFile` reads a properties file using `UTF-8`.

=== [[getConfDir]][[configuration-directory]] Spark's Configuration Directory -- `getConfDir` Internal Method

`AbstractCommandBuilder` uses `getConfDir` to compute the current configuration directory of a Spark application.

It uses `SPARK_CONF_DIR` (from `childEnv` which is always empty anyway or as a environment variable) and falls through to `[SPARK_HOME]/conf` (with `SPARK_HOME` from <<AbstractCommandBuilder-getSparkHome, `getSparkHome` internal method>>).

=== [[getSparkHome]][[home-directory]] Spark's Home Directory -- `getSparkHome` Internal Method

`AbstractCommandBuilder` uses `getSparkHome` to compute Spark's home directory for a Spark application.

It uses `SPARK_HOME` (from `childEnv` which is always empty anyway or as a environment variable).

If `SPARK_HOME` is not set, Spark throws a `IllegalStateException`:

```
Spark home not found; set it explicitly or use the SPARK_HOME environment variable.
```
