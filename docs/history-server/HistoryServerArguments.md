== HistoryServerArguments

`HistoryServerArguments` is the command-line parser for the index.md[History Server].

When `HistoryServerArguments` is executed with a single command-line parameter it is assumed to be the event logs directory.

```
$ ./sbin/start-history-server.sh /tmp/spark-events
```

This is however deprecated since Spark 1.1.0 and you should see the following WARN message in the logs:

```
WARN HistoryServerArguments: Setting log directory through the command line is deprecated as of Spark 1.1.0. Please set this through spark.history.fs.logDirectory instead.
```

The same WARN message shows up for `--dir` and `-d` command-line options.

`--properties-file [propertiesFile]` command-line option specifies the file with the custom spark-properties.md[Spark properties].

NOTE: When not specified explicitly, History Server uses the default configuration file, i.e. spark-properties.md#spark-defaults-conf[spark-defaults.conf].

[TIP]
====
Enable `WARN` logging level for `org.apache.spark.deploy.history.HistoryServerArguments` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.deploy.history.HistoryServerArguments=WARN
```

Refer to spark-logging.md[Logging].
====
