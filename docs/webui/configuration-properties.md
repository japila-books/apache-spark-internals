# web UI Configuration Properties

## <span id="CUSTOM_EXECUTOR_LOG_URL"><span id="spark.ui.custom.executor.log.url"> spark.ui.custom.executor.log.url

Specifies custom spark executor log url for supporting external log service instead of using cluster managers' application log urls in the Spark UI. Spark will support some path variables via patterns which can vary on cluster manager. Please check the documentation for your cluster manager to see which patterns are supported, if any. This configuration replaces original log urls in event log, which will be also effective when accessing the application on history server. The new log urls must be permanent, otherwise you might have dead link for executor log urls.

Used when:

* `DriverEndpoint` is created (and initializes an [ExecutorLogUrlHandler](../scheduler/DriverEndpoint.md#logUrlHandler))

## <span id="spark.ui.enabled"> spark.ui.enabled

Controls whether the web UI is started for the Spark application

Default: `true`

## <span id="spark.ui.port"><span id="UI_PORT"> spark.ui.port

The port the [web UI](index.md) of a Spark application binds to

Default: `4040`

If multiple `SparkContext`s attempt to run on the same host (as different Spark applications), they will bind to successive ports beginning with `spark.ui.port` (until `spark.port.maxRetries`).

Used when:

* `SparkUI` utility is used to [get the UI port](SparkUI.md#getUIPort)

## <span id="spark.ui.prometheus.enabled"><span id="UI_PROMETHEUS_ENABLED"> spark.ui.prometheus.enabled

**internal** Expose executor metrics at `/metrics/executors/prometheus`

Default: `false`

Used when:

* `SparkUI` is requested to [initialize](SparkUI.md#initialize)

## Review Me

[[properties]]
.web UI Configuration Properties
[cols="1,1,2",options="header",width="100%"]
|===
| Name
| Default Value
| Description

| [[spark.ui.allowFramingFrom]] `spark.ui.allowFramingFrom`
|
| Defines the URL to use in `ALLOW-FROM` in `X-Frame-Options` header (as described in http://tools.ietf.org/html/rfc7034).

Used exclusively when `JettyUtils` is requested to spark-webui-JettyUtils.md#createServlet[create an HttpServlet].

| [[spark.ui.consoleProgress.update.interval]] `spark.ui.consoleProgress.update.interval`
| `200` (ms)
| Update interval, i.e. how often to show the progress.

| [[spark.ui.killEnabled]] `spark.ui.killEnabled`
| `true`
| Enables jobs and stages to be killed from the web UI (`true`) or not (`false`).

Used exclusively when `SparkUI` is requested to spark-webui-SparkUI.md#initialize[initialize] (and registers the redirect handlers for `/jobs/job/kill` and `/stages/stage/kill` URIs)

| [[spark.ui.retainedDeadExecutors]] `spark.ui.retainedDeadExecutors`
| `100`
|

| [[spark.ui.timeline.executors.maximum]] `spark.ui.timeline.executors.maximum`
| `1000`
| The maximum number of entries in <<executorEvents, executorEvents>> registry.

| [[spark.ui.timeline.tasks.maximum]] `spark.ui.timeline.tasks.maximum`
| `1000`
|
|===
