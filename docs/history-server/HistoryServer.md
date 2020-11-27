= [[HistoryServer]] HistoryServer -- WebUI For Active And Completed Spark Applications

`HistoryServer` is an extension of the webui:spark-webui-WebUI.md[web UI] for reviewing event logs of running (active) and completed Spark applications with event log collection enabled (based on configuration-properties.md#spark.eventLog.enabled[spark.eventLog.enabled] configuration property).

`HistoryServer` supports custom spark-history-server:configuration-properties.md#HistoryServer[configuration properties].

`HistoryServer` is <<creating-instance, created>> when...FIXME

`HistoryServer` uses the <<loaderServlet, HttpServlet>> to handle requests to `/*` URI that <<doGet, FIXME>>.

[[ApplicationCacheOperations]]
`HistoryServer` is a ApplicationCacheOperations.md[ApplicationCacheOperations].

[[UIRoot]]
`HistoryServer` is a rest-api:spark-api-UIRoot.md[UIRoot].

[[retainedApplications]]
`HistoryServer` uses configuration-properties.md#spark.history.retainedApplications[spark.history.retainedApplications] configuration property (default: `50`) for...FIXME

[[maxApplications]]
`HistoryServer` uses configuration-properties.md#spark.history.ui.maxApplications[spark.history.ui.maxApplications] configuration property (default: `unbounded`) for...FIXME

[[logging]]
[TIP]
====
Enable `ALL` logging level for `org.apache.spark.deploy.history.HistoryServer` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.deploy.history.HistoryServer=ALL
```

Refer to spark-logging.md[Logging].
====

== [[creating-instance]] Creating HistoryServer Instance

`HistoryServer` takes the following to be created:

* [[conf]] SparkConf.md[SparkConf]
* [[provider]] ApplicationHistoryProvider.md[ApplicationHistoryProvider]
* [[securityManager]] `SecurityManager`
* [[port]] Port number

`HistoryServer` initializes the <<internal-properties, internal properties>>.

While being created, `HistoryServer` is requested to <<initialize, initialize>>.

== [[initialize]] Initializing HistoryServer -- `initialize` Method

[source, scala]
----
initialize(): Unit
----

NOTE: `initialize` is part of webui:spark-webui-WebUI.md#initialize[WebUI Contract] to initialize web components.

`initialize`...FIXME

== [[attachSparkUI]] `attachSparkUI` Method

[source, scala]
----
attachSparkUI(
  appId: String,
  attemptId: Option[String],
  ui: SparkUI,
  completed: Boolean): Unit
----

NOTE: `attachSparkUI` is part of ApplicationCacheOperations.md#attachSparkUI[ApplicationCacheOperations Contract] to...FIXME.

`attachSparkUI`...FIXME

== [[main]] Launching HistoryServer Standalone Application -- `main` Method

[source, scala]
----
main(argStrings: Array[String]): Unit
----

`main`...FIXME

== [[getAppUI]] Requesting Spark Application UI -- `getAppUI` Method

[source, scala]
----
getAppUI(appId: String, attemptId: Option[String]): Option[LoadedAppUI]
----

NOTE: `getAppUI` is part of ApplicationCacheOperations.md#getAppUI[ApplicationCacheOperations Contract] to...FIXME.

`getAppUI`...FIXME

== [[withSparkUI]] `withSparkUI` Method

[source, scala]
----
withSparkUI[T](appId: String, attemptId: Option[String])(fn: SparkUI => T): T
----

NOTE: `withSparkUI` is part of spark-api-UIRoot.md#withSparkUI[UIRoot Contract] to...FIXME.

`withSparkUI`...FIXME

== [[loadAppUi]] `loadAppUi` Internal Method

[source, scala]
----
loadAppUi(appId: String, attemptId: Option[String]): Boolean
----

`loadAppUi`...FIXME

NOTE: `loadAppUi` is used exclusively when `HistoryServer` is <<loaderServlet, created>>.

== [[doGet]] `doGet` Method

[source, scala]
----
doGet(req: HttpServletRequest, res: HttpServletResponse): Unit
----

NOTE: `doGet` is part of Java Servlet's https://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServlet.html[HttpServlet] to handle HTTP GET requests.

`doGet`...FIXME

NOTE: `doGet` is used when...FIXME

== [[internal-properties]] Internal Properties

[cols="30m,70",options="header",width="100%"]
|===
| Name
| Description

| appCache
a| [[appCache]] ApplicationCache.md[ApplicationCache] for this `HistoryServer` and <<retainedApplications, retainedApplications>>

Used when...FIXME

| loaderServlet
a| [[loaderServlet]] Java Servlets' https://docs.oracle.com/javaee/7/api/javax/servlet/http/HttpServlet.html[HttpServlet]

Used exclusively when `HistoryServer` is requested to <<initialize, initialize>> (and spark-webui-WebUI.md#attachHandler[attaches the servlet to the web UI] to handle `/*` URI)

|===
