# SparkUI

`SparkUI` is a [WebUI](WebUI.md) of Spark applications.

![Welcome Page of web UI &mdash; Jobs Tab](../images/webui/spark-webui-jobs.png)

## Creating Instance

`SparkUI` takes the following to be created:

* <span id="store"> [AppStatusStore](../status/AppStatusStore.md)
* <span id="sc"> [SparkContext](../SparkContext.md)
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="securityManager"> `SecurityManager`
* <span id="appName"> Application Name
* <span id="basePath"> Base Path
* <span id="startTime"> Start Time
* <span id="appSparkVersion"> Spark Version

While being created, `SparkUI` [initializes itself](#initialize).

`SparkUI` is created using [create](#create) utility.

### <span id="getUIPort"> UI Port

```scala
getUIPort(
  conf: SparkConf): Int
```

`getUIPort` requests the [SparkConf](../SparkConf.md) for the value of [spark.ui.port](configuration-properties.md#spark.ui.port) configuration property.

`getUIPort` is used when:

* `SparkUI` is [created](#creating-instance)

## <span id="create"> Creating SparkUI

```scala
create(
  sc: Option[SparkContext],
  store: AppStatusStore,
  conf: SparkConf,
  securityManager: SecurityManager,
  appName: String,
  basePath: String,
  startTime: Long,
  appSparkVersion: String): SparkUI
```

`create` creates a new `SparkUI` with `appSparkVersion` being the current Spark version.

`create` is used when:

* `SparkContext` is [created](../SparkContext-creating-instance-internals.md#_ui) (with the [spark.ui.enabled](configuration-properties.md#spark.ui.enabled) configuration property turned on)
* `FsHistoryProvider` (Spark History Server) is requested for the [web UI of a Spark application](../history-server/FsHistoryProvider.md#getAppUI)

## <span id="initialize"> Initializing

```scala
initialize(): Unit
```

`initialize` is part of the [WebUI](WebUI.md#initialize) abstraction.

`initialize` creates and attaches the following tabs:

1. [JobsTab](JobsTab.md)
1. [StagesTab](StagesTab.md)
1. [StorageTab](StorageTab.md)
1. [EnvironmentTab](EnvironmentTab.md)
1. [ExecutorsTab](ExecutorsTab.md)

`initialize` [attaches itself](../rest/ApiRootResource.md#getServletHandler) as the [UIRoot](#UIRoot).

`initialize` [attaches the PrometheusResource](PrometheusResource.md#getServletHandler) for executor metrics based on [spark.ui.prometheus.enabled](configuration-properties.md#spark.ui.prometheus.enabled) configuration property.

## <span id="UIRoot"> UIRoot

`SparkUI` is an [UIRoot](../rest/UIRoot.md)

## Review Me

SparkUI is <<creating-instance, created>> along with the following:

* [SparkContext](../SparkContext.md) is created (for a live Spark application with spark-webui-properties.md#spark.ui.enabled[spark.ui.enabled] configuration property enabled)

* `FsHistoryProvider` is requested for the spark-history-server:FsHistoryProvider.md#getAppUI[application UI] (for a live or completed Spark application)

.Creating SparkUI for Live Spark Application
image::spark-webui-SparkUI.png[align="center"]

When <<create, created>> (while `SparkContext` is created for a live Spark application), SparkUI gets the following:

* Live [AppStatusStore](../SparkContext-creating-instance-internals.md#_statusStore) (with a [ElementTrackingStore](../status/ElementTrackingStore.md) using an core:InMemoryStore.md[] and a [AppStatusListener](../status/AppStatusListener.md) for a live Spark application)

* Name of the Spark application that is exactly the value of SparkConf.md#spark.app.name[spark.app.name] configuration property

* Empty base path

When started, SparkUI binds to <<appUIAddress, appUIAddress>> address that you can control using `SPARK_PUBLIC_DNS` environment variable or spark-driver.md#spark_driver_host[spark.driver.host] Spark property.

NOTE: With spark-webui-properties.md#spark.ui.killEnabled[spark.ui.killEnabled] configuration property turned on, SparkUI <<initialize, allows to kill jobs and stages>> (subject to `SecurityManager.checkModifyPermissions` permissions).

SparkUI gets an <<store, AppStatusStore>> that is then used for the following:

* <<initialize, Initializing tabs>>, i.e. JobsTab.md#creating-instance[JobsTab], spark-webui-StagesTab.md#creating-instance[StagesTab], spark-webui-StorageTab.md#creating-instance[StorageTab], spark-webui-EnvironmentTab.md#creating-instance[EnvironmentTab]

* `AbstractApplicationResource` is requested for spark-api-AbstractApplicationResource.md#jobsList[jobsList], spark-api-AbstractApplicationResource.md#oneJob[oneJob], spark-api-AbstractApplicationResource.md#executorList[executorList], spark-api-AbstractApplicationResource.md#allExecutorList[allExecutorList], spark-api-AbstractApplicationResource.md#rddList[rddList], spark-api-AbstractApplicationResource.md#rddData[rddData], spark-api-AbstractApplicationResource.md#environmentInfo[environmentInfo]

* `StagesResource` is requested for spark-api-StagesResource.md#stageList[stageList], spark-api-StagesResource.md#stageData[stageData], spark-api-StagesResource.md#oneAttemptData[oneAttemptData], spark-api-StagesResource.md#taskSummary[taskSummary], spark-api-StagesResource.md#taskList[taskList]

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

Refer to spark-logging.md[Logging].
====

== [[setAppId]] Assigning Unique Identifier of Spark Application -- `setAppId` Method

[source, scala]
----
setAppId(id: String): Unit
----

`setAppId` sets the internal <<appId, appId>>.

`setAppId` is used when [SparkContext](../SparkContext.md) is created.

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

`createLiveUI` is used when [SparkContext](../SparkContext.md) is created.

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

`create` creates a SparkUI backed by a core:AppStatusStore.md[].

Internally, `create` simply creates a new <<creating-instance, SparkUI>> (with the predefined Spark version).

`create` is used when:

* [SparkContext](../SparkContext.md) is created
* `FsHistoryProvider` is requested to spark-history-server:FsHistoryProvider.md#getAppUI[getAppUI] (for a Spark application that already finished)

## Creating Instance

SparkUI takes the following when created:

* [[store]] core:AppStatusStore.md[]
* [[sc]] SparkContext.md[]
* [[conf]] SparkConf.md[SparkConf]
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

NOTE: `initialize` is part of spark-webui-WebUI.md#initialize[WebUI Contract] to initialize web components.

`initialize` creates and <<attachTab, attaches>> the following tabs (with the reference to the SparkUI and its <<store, AppStatusStore>>):

. spark-webui-StagesTab.md[StagesTab]
. spark-webui-StorageTab.md[StorageTab]
. spark-webui-EnvironmentTab.md[EnvironmentTab]
. spark-webui-ExecutorsTab.md[ExecutorsTab]

In the end, `initialize` creates and spark-webui-WebUI.md#attachHandler[attaches] the following `ServletContextHandlers`:

. spark-webui-JettyUtils.md#createStaticHandler[Creates a static handler] for serving files from a static directory, i.e. `/static` to serve static files from `org/apache/spark/ui/static` directory (on CLASSPATH)

. spark-api-ApiRootResource.md#getServletHandler[Creates the /api/* context handler] for the spark-api.md[Status REST API]

. spark-webui-JettyUtils.md#createRedirectHandler[Creates a redirect handler] to redirect `/jobs/job/kill` to `/jobs/` and request the `JobsTab` to execute [handleKillRequest](JobsTab.md#handleKillRequest) before redirection

. spark-webui-JettyUtils.md#createRedirectHandler[Creates a redirect handler] to redirect `/stages/stage/kill` to `/stages/` and request the `StagesTab` to execute spark-webui-StagesTab.md#handleKillRequest[handleKillRequest] before redirection
