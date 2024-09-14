# Running Spark Applications on Windows

Running Spark applications on Windows in general is no different than running it on other operating systems like Linux or macOS.

!!! note
    A Spark application could be [spark-shell](../tools/spark-shell.md) or your own custom Spark application.

What makes a very important difference between the operating systems is Apache Hadoop that is used internally in Spark for file system access.

You may run into few minor issues when you are on Windows due to the way Hadoop works with Windows' POSIX-incompatible NTFS filesystem.

!!! note
    You are not required to install Apache Hadoop to develop or run Spark applications.

!!! tip
    Read the Apache Hadoop project's [Problems running Hadoop on Windows](https://cwiki.apache.org/confluence/display/HADOOP2/WindowsProblems).

Among the issues is the infamous `java.io.IOException` while running Spark Shell (below a stacktrace from Spark 2.0.2 on Windows 10 so the line numbers may be different in your case).

```text
16/12/26 21:34:11 ERROR Shell: Failed to locate the winutils binary in the hadoop binary path
java.io.IOException: Could not locate executable null\bin\winutils.exe in the Hadoop binaries.
  at org.apache.hadoop.util.Shell.getQualifiedBinPath(Shell.java:379)
  at org.apache.hadoop.util.Shell.getWinUtilsPath(Shell.java:394)
  at org.apache.hadoop.util.Shell.<clinit>(Shell.java:387)
  at org.apache.hadoop.hive.conf.HiveConf$ConfVars.findHadoopBinary(HiveConf.java:2327)
  at org.apache.hadoop.hive.conf.HiveConf$ConfVars.<clinit>(HiveConf.java:365)
  at org.apache.hadoop.hive.conf.HiveConf.<clinit>(HiveConf.java:105)
  at java.lang.Class.forName0(Native Method)
  at java.lang.Class.forName(Class.java:348)
  at org.apache.spark.util.Utils$.classForName(Utils.scala:228)
  at org.apache.spark.sql.SparkSession$.hiveClassesArePresent(SparkSession.scala:963)
  at org.apache.spark.repl.Main$.createSparkSession(Main.scala:91)
```

!!! note
    You need to have Administrator rights on your laptop.
    All the following commands must be executed in a command-line window (`cmd`) ran as Administrator (i.e., using **Run as administrator** option while executing `cmd`).

Download `winutils.exe` binary from [steveloughran/winutils](https://github.com/steveloughran/winutils) Github repository.

!!! note
    Select the version of Hadoop the Spark distribution was compiled with, e.g. use `hadoop-2.7.1` for Spark 2 ([here is the direct link to `winutils.exe` binary](https://github.com/steveloughran/winutils/blob/master/hadoop-2.7.1/bin/winutils.exe)).

Save `winutils.exe` binary to a directory of your choice (e.g., `c:\hadoop\bin`).

Set `HADOOP_HOME` to reflect the directory with `winutils.exe` (without `bin`).

```text
set HADOOP_HOME=c:\hadoop
```

Set `PATH` environment variable to include `%HADOOP_HOME%\bin` as follows:

```text
set PATH=%HADOOP_HOME%\bin;%PATH%
```

!!! tip
    Define `HADOOP_HOME` and `PATH` environment variables in Control Panel so any Windows program would use them.

Create `C:\tmp\hive` directory.

!!! note
    `c:\tmp\hive` directory is the default value of [`hive.exec.scratchdir` configuration property](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties#ConfigurationProperties-hive.exec.scratchdir) in Hive 0.14.0 and later and Spark uses a custom build of Hive 1.2.1.

    You can change `hive.exec.scratchdir` configuration property to another directory as described in [Changing `hive.exec.scratchdir` Configuration Property](#changing-hive.exec.scratchdir) in this document.

Execute the following command in `cmd` that you started using the option **Run as administrator**.

```text
winutils.exe chmod -R 777 C:\tmp\hive
```

Check the permissions (that is one of the commands that are executed under the covers):

```text
winutils.exe ls -F C:\tmp\hive
```

Open `spark-shell` and observe the output (perhaps with few WARN messages that you can simply disregard).

As a verification step, execute the following line to display the content of a `DataFrame`:

```text
scala> spark.range(1).withColumn("status", lit("All seems fine. Congratulations!")).show(false)
+---+--------------------------------+
|id |status                          |
+---+--------------------------------+
|0  |All seems fine. Congratulations!|
+---+--------------------------------+
```

!!! note
    Disregard WARN messages when you start `spark-shell`. They are harmless.

    ```text
    16/12/26 22:05:41 WARN General: Plugin (Bundle) "org.datanucleus" is already registered. Ensure you dont have multiple JAR versions of
    the same plugin in the classpath. The URL "file:/C:/spark-2.0.2-bin-hadoop2.7/jars/datanucleus-core-3.2.10.jar" is already registered,
    and you are trying to register an identical plugin located at URL "file:/C:/spark-2.0.2-bin-hadoop2.7/bin/../jars/datanucleus-core-
    3.2.10.jar."
    16/12/26 22:05:41 WARN General: Plugin (Bundle) "org.datanucleus.api.jdo" is already registered. Ensure you dont have multiple JAR
    versions of the same plugin in the classpath. The URL "file:/C:/spark-2.0.2-bin-hadoop2.7/jars/datanucleus-api-jdo-3.2.6.jar" is already
    registered, and you are trying to register an identical plugin located at URL "file:/C:/spark-2.0.2-bin-
    hadoop2.7/bin/../jars/datanucleus-api-jdo-3.2.6.jar."
    16/12/26 22:05:41 WARN General: Plugin (Bundle) "org.datanucleus.store.rdbms" is already registered. Ensure you dont have multiple JAR
    versions of the same plugin in the classpath. The URL "file:/C:/spark-2.0.2-bin-hadoop2.7/bin/../jars/datanucleus-rdbms-3.2.9.jar" is
    already registered, and you are trying to register an identical plugin located at URL "file:/C:/spark-2.0.2-bin-
    hadoop2.7/jars/datanucleus-rdbms-3.2.9.jar."
    ```

If you see the above output, you're done! You should now be able to run Spark applications on your Windows. Congrats! 👏👏👏

## Changing hive.exec.scratchdir { #changing-hive.exec.scratchdir }

Create a `hive-site.xml` file with the following content:

```xml
<configuration>
  <property>
    <name>hive.exec.scratchdir</name>
    <value>/tmp/mydir</value>
    <description>Scratch space for Hive jobs</description>
  </property>
</configuration>
```

Start a Spark application (e.g., `spark-shell`) with `HADOOP_CONF_DIR` environment variable set to the directory with `hive-site.xml`.

```text
HADOOP_CONF_DIR=conf ./bin/spark-shell
```
