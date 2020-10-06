= Spark History Server

*Spark History Server* is the web UI of Spark applications with event log collection enabled (based on ROOT:configuration-properties.md#spark.eventLog.enabled[spark.eventLog.enabled] configuration property).

.History Server's web UI
image::spark-history-server-webui.png[align="center"]

Spark History Server is an extension of Spark's webui:index.md[web UI].

Spark History Server can be started using <<start_history_server_sh, start-history-server.sh>> and stopped using <<stop_history_server_sh, stop-history-server.sh>> shell scripts.

Spark History Server supports custom spark-history-server:configuration-properties.md#HistoryServer[configuration properties] that can be defined using `--properties-file [propertiesFile]` command-line option. The properties file can have any valid ``spark.``-prefixed Spark property.

[source,plaintext]
----
$ ./sbin/start-history-server.sh --properties-file history.properties
----

If not specified explicitly, Spark History Server uses the default configuration file, i.e. ROOT:spark-properties.md#spark-defaults-conf[spark-defaults.conf].

Spark History Server can replay events from event log files recorded by EventLoggingListener.md[EventLoggingListener].

[[logging]]
[TIP]
====
Enable `ALL` logging level for `org.apache.spark.deploy.history` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.deploy.history=INFO
```

Refer to ROOT:spark-logging.md[Logging].
====

== [[start_history_server_sh]] Starting History Server -- `start-history-server.sh` Shell Script

`$SPARK_HOME/sbin/start-history-server.sh` shell script (where `SPARK_HOME` is the directory of your Spark installation) is used to start a Spark History Server instance.

[source,plaintext]
----
$ ./sbin/start-history-server.sh
starting org.apache.spark.deploy.history.HistoryServer, logging to .../spark/logs/spark-jacek-org.apache.spark.deploy.history.HistoryServer-1-japila.out
----

Internally, `start-history-server.sh` script starts HistoryServer.md[org.apache.spark.deploy.history.HistoryServer] standalone application (using `spark-daemon.sh` shell script).

[source,plaintext]
----
$ ./bin/spark-class org.apache.spark.deploy.history.HistoryServer
----

TIP: Using the more explicit approach with `spark-class` to start Spark History Server could be easier to trace execution by seeing the logs printed out to the standard output and hence terminal directly.

When started, `start-history-server.sh` prints out the following INFO message to the logs:

```
Started daemon with process name: [processName]
```

`start-history-server.sh` registers signal handlers (using `SignalUtils`) for `TERM`, `HUP`, `INT` to log their execution:

```
RECEIVED SIGNAL [signal]
```

`start-history-server.sh` inits security if enabled (based on ROOT:configuration-properties.md#spark.history.kerberos.enabled[spark.history.kerberos.enabled] configuration property).

CAUTION: FIXME Describe `initSecurity`

`start-history-server.sh` creates a `SecurityManager`.

`start-history-server.sh` creates a ApplicationHistoryProvider.md[ApplicationHistoryProvider] (based on ROOT:configuration-properties.md#spark.history.provider[spark.history.provider] configuration property).

In the end, `start-history-server.sh` creates a HistoryServer.md[HistoryServer] and requests it to bind to the port (based on ROOT:configuration-properties.md#spark.history.ui.port[spark.history.ui.port] configuration property).

[TIP]
====
The host's IP can be specified using `SPARK_LOCAL_IP` environment variable (defaults to `0.0.0.0`).
====

`start-history-server.sh` prints out the following INFO message to the logs:

```
Bound HistoryServer to [host], and started at [webUrl]
```

`start-history-server.sh` registers a shutdown hook to call `stop` on the `HistoryServer` instance.

TIP: Use <<stop_history_server, stop-history-server.sh>> shell script to to stop a running History Server.

== [[stop_history_server_sh]] Stopping History Server -- `stop-history-server.sh` Shell Script

`$SPARK_HOME/sbin/stop-history-server.sh` shell script (where `SPARK_HOME` is the directory of your Spark installation) is used to stop a running instance of Spark History Server.

[source,plaintext]
----
$ ./sbin/stop-history-server.sh
stopping org.apache.spark.deploy.history.HistoryServer
----
