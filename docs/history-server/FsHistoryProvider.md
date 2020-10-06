= FsHistoryProvider

*FsHistoryProvider* is the default ApplicationHistoryProvider.md[ApplicationHistoryProvider] for index.md[Spark History Server].

FsHistoryProvider is <<creating-instance, created>> exclusively when `HistoryServer` is HistoryServer.md#main[started] as a standalone application and `spark.history.provider` configuration property was not defined.

[TIP]
====
Enable `INFO` or `DEBUG` logging levels for `org.apache.spark.deploy.history.FsHistoryProvider` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.deploy.history.FsHistoryProvider=DEBUG
```

Refer to spark-logging.md[Logging].
====

== [[rebuildAppStore]] `rebuildAppStore` Internal Method

[source, scala]
----
rebuildAppStore(
  store: KVStore,
  eventLog: FileStatus,
  lastUpdated: Long): Unit
----

`rebuildAppStore`...FIXME

NOTE: `rebuildAppStore` is used when...FIXME

== [[getAppUI]] `getAppUI` Method

[source, scala]
----
getAppUI(appId: String, attemptId: Option[String]): Option[LoadedAppUI]
----

NOTE: `getAppUI` is part of ApplicationHistoryProvider.md#getAppUI[ApplicationHistoryProvider Contract] to...FIXME.

`getAppUI`...FIXME

== [[creating-instance]] Creating FsHistoryProvider Instance

FsHistoryProvider takes the following when created:

* [[conf]] ROOT:SparkConf.md[SparkConf]
* [[clock]] `Clock` (default: `SystemClock`)

FsHistoryProvider initializes the <<internal-registries, internal registries and counters>>.
