= SparkUI

*SparkUI* is the link:spark-webui-WebUI.adoc[web UI] of a Spark application (aka *Application UI*).

SparkUI is <<creating-instance, created>> along with the following:

* link:spark-SparkContext-creating-instance-internals.adoc#_ui[SparkContext] (for a live Spark application with link:spark-webui-properties.adoc#spark.ui.enabled[spark.ui.enabled] configuration property enabled)

* `FsHistoryProvider` is requested for the xref:spark-history-server:FsHistoryProvider.adoc#getAppUI[application UI] (for a live or completed Spark application)

.Creating SparkUI for Live Spark Application
image::spark-webui-SparkUI.png[align="center"]

When <<create, created>> (while `SparkContext` is created for a live Spark application), SparkUI gets the following:

* Live link:spark-SparkContext-creating-instance-internals.adoc#_statusStore[AppStatusStore] (with a xref:core:ElementTrackingStore.adoc[] using an xref:core:InMemoryStore.adoc[] and a xref:core:AppStatusListener.adoc[] for a live Spark application)

* Name of the Spark application that is exactly the value of xref:ROOT:SparkConf.adoc#spark.app.name[spark.app.name] configuration property

* Empty base path

When started, SparkUI binds to <<appUIAddress, appUIAddress>> address that you can control using `SPARK_PUBLIC_DNS` environment variable or link:spark-driver.adoc#spark_driver_host[spark.driver.host] Spark property.

NOTE: With link:spark-webui-properties.adoc#spark.ui.killEnabled[spark.ui.killEnabled] configuration property turned on, SparkUI <<initialize, allows to kill jobs and stages>> (subject to `SecurityManager.checkModifyPermissions` permissions).

SparkUI gets an <<store, AppStatusStore>> that is then used for the following:

* <<initialize, Initializing tabs>>, i.e. link:spark-webui-JobsTab.adoc#creating-instance[JobsTab], link:spark-webui-StagesTab.adoc#creating-instance[StagesTab], link:spark-webui-StorageTab.adoc#creating-instance[StorageTab], link:spark-webui-EnvironmentTab.adoc#creating-instance[EnvironmentTab]

* `AbstractApplicationResource` is requested for link:spark-api-AbstractApplicationResource.adoc#jobsList[jobsList], link:spark-api-AbstractApplicationResource.adoc#oneJob[oneJob], link:spark-api-AbstractApplicationResource.adoc#executorList[executorList], link:spark-api-AbstractApplicationResource.adoc#allExecutorList[allExecutorList], link:spark-api-AbstractApplicationResource.adoc#rddList[rddList], link:spark-api-AbstractApplicationResource.adoc#rddData[rddData], link:spark-api-AbstractApplicationResource.adoc#environmentInfo[environmentInfo]

* `StagesResource` is requested for link:spark-api-StagesResource.adoc#stageList[stageList], link:spark-api-StagesResource.adoc#stageData[stageData], link:spark-api-StagesResource.adoc#oneAttemptData[oneAttemptData], link:spark-api-StagesResource.adoc#taskSummary[taskSummary], link:spark-api-StagesResource.adoc#taskList[taskList]

* SparkUI is requested for the current <<getSparkUser, Spark user>>

* Creating Spark SQL's `SQLTab` (when `SQLHistoryServerPlugin` is requested to `setupUI`)

* Spark Streaming's `BatchPage` is created

[[internal-registries]]
.SparkUI's Internal Properties (e.g. Registries, Counters and Flags)
[cols="1,2",options="header",width="100%"]
|===
| Name
| Description

| `appId`
| [[appId]]
|===

[TIP]
====
Enable `INFO` logging level for `org.apache.spark.ui.SparkUI` logger to see what happens inside.

Add the following line to `conf/log4j.properties`:

```
log4j.logger.org.apache.spark.ui.SparkUI=INFO
```

Refer to link:spark-logging.adoc[Logging].
====

== [[setAppId]] Assigning Unique Identifier of Spark Application -- `setAppId` Method

[source, scala]
----
setAppId(id: String): Unit
----

`setAppId` sets the internal <<appId, appId>>.

NOTE: `setAppId` is used exclusively when `SparkContext` link:spark-SparkContext-creating-instance-internals.adoc#spark.app.id[is initialized].

== [[stop]] Stopping SparkUI -- `stop` Method

[source, scala]
----
stop(): Unit
----

`stop` stops the HTTP server and prints the following INFO message to the logs:

```
INFO SparkUI: Stopped Spark web UI at [appUIAddress]
```

NOTE: `appUIAddress` in the above INFO message is the result of <<appUIAddress, appUIAddress>> method.

== [[appUIAddress]] `appUIAddress` Method

[source, scala]
----
appUIAddress: String
----

`appUIAddress` returns the entire URL of a Spark application's web UI, including `http://` scheme.

Internally, `appUIAddress` uses <<appUIHostPort, appUIHostPort>>.

== [[getSparkUser]] Accessing Spark User -- `getSparkUser` Method

[source, scala]
----
getSparkUser: String
----

`getSparkUser` returns the name of the user a Spark application runs as.

Internally, `getSparkUser` requests `user.name` System property from link:spark-webui-EnvironmentListener.adoc[EnvironmentListener] Spark listener.

NOTE: `getSparkUser` is used...FIXME

== [[createLiveUI]] `createLiveUI` Method

[source, scala]
----
createLiveUI(
  sc: SparkContext,
  conf: SparkConf,
  listenerBus: SparkListenerBus,
  jobProgressListener: JobProgressListener,
  securityManager: SecurityManager,
  appName: String,
  startTime: Long): SparkUI
----

`createLiveUI` creates a SparkUI for a live running Spark application.

Internally, `createLiveUI` simply forwards the call to <<create, create>>.

NOTE: `createLiveUI` is called when link:spark-SparkContext-creating-instance-internals.adoc#ui[`SparkContext` is created] (and link:spark-webui-properties.adoc#spark.ui.enabled[spark.ui.enabled] is enabled).

== [[createHistoryUI]] `createHistoryUI` Method

CAUTION: FIXME

== [[appUIHostPort]] `appUIHostPort` Method

[source, scala]
----
appUIHostPort: String
----

`appUIHostPort` returns the Spark application's web UI which is the public hostname and port, excluding the scheme.

NOTE: <<appUIAddress, appUIAddress>> uses `appUIHostPort` and adds `http://` scheme.

== [[getAppName]] `getAppName` Method

[source, scala]
----
getAppName: String
----

`getAppName` returns the name of the Spark application (of a SparkUI instance).

NOTE: `getAppName` is used when...FIXME

== [[create]] Creating SparkUI Instance -- `create` Factory Method

[source, scala]
----
create(
  sc: Option[SparkContext],
  store: AppStatusStore,
  conf: SparkConf,
  securityManager: SecurityManager,
  appName: String,
  basePath: String = "",
  startTime: Long,
  appSparkVersion: String = org.apache.spark.SPARK_VERSION): SparkUI
----

`create` creates a SparkUI backed by a xref:core:AppStatusStore.adoc[].

Internally, `create` simply creates a new <<creating-instance, SparkUI>> (with the predefined Spark version).

[NOTE]
====
`create` is used when:

* `SparkContext` is link:spark-SparkContext-creating-instance-internals.adoc#_ui[created] (for a running Spark application)

* `FsHistoryProvider` is requested to xref:spark-history-server:FsHistoryProvider.adoc#getAppUI[getAppUI] (for a Spark application that already finished)
====

== [[creating-instance]] Creating SparkUI Instance

SparkUI takes the following when created:

* [[store]] xref:core:AppStatusStore.adoc[]
* [[sc]] xref:ROOT:SparkContext.adoc[]
* [[conf]] xref:ROOT:SparkConf.adoc[SparkConf]
* [[securityManager]] `SecurityManager`
* [[appName]] Application name
* [[basePath]] `basePath`
* [[startTime]] Start time
* [[appSparkVersion]] `appSparkVersion`

SparkUI initializes the <<internal-registries, internal registries and counters>> and <<initialize, the tabs and handlers>>.

== [[initialize]] Attaching Tabs and Context Handlers -- `initialize` Method

[source, scala]
----
initialize(): Unit
----

NOTE: `initialize` is part of link:spark-webui-WebUI.adoc#initialize[WebUI Contract] to initialize web components.

`initialize` creates and <<attachTab, attaches>> the following tabs (with the reference to the SparkUI and its <<store, AppStatusStore>>):

. link:spark-webui-JobsTab.adoc[JobsTab]
. link:spark-webui-StagesTab.adoc[StagesTab]
. link:spark-webui-StorageTab.adoc[StorageTab]
. link:spark-webui-EnvironmentTab.adoc[EnvironmentTab]
. link:spark-webui-ExecutorsTab.adoc[ExecutorsTab]

In the end, `initialize` creates and link:spark-webui-WebUI.adoc#attachHandler[attaches] the following `ServletContextHandlers`:

. link:spark-webui-JettyUtils.adoc#createStaticHandler[Creates a static handler] for serving files from a static directory, i.e. `/static` to serve static files from `org/apache/spark/ui/static` directory (on CLASSPATH)

. link:spark-webui-JettyUtils.adoc#createRedirectHandler[Creates a redirect handler] to redirect `/` to `/jobs/` (and so the link:spark-webui-jobs.adoc[Jobs tab] is the welcome tab when you open the web UI)

. link:spark-api-ApiRootResource.adoc#getServletHandler[Creates the /api/* context handler] for the link:spark-api.adoc[Status REST API]

. link:spark-webui-JettyUtils.adoc#createRedirectHandler[Creates a redirect handler] to redirect `/jobs/job/kill` to `/jobs/` and request the `JobsTab` to execute link:spark-webui-JobsTab.adoc#handleKillRequest[handleKillRequest] before redirection

. link:spark-webui-JettyUtils.adoc#createRedirectHandler[Creates a redirect handler] to redirect `/stages/stage/kill` to `/stages/` and request the `StagesTab` to execute link:spark-webui-StagesTab.adoc#handleKillRequest[handleKillRequest] before redirection
