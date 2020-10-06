== web UI Configuration Properties

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

| [[spark.ui.enabled]] `spark.ui.enabled`
| `true`
| The flag to control whether the web UI is started (`true`) or not (`false`).

| [[spark.ui.port]] `spark.ui.port`
| `4040`
| The port web UI binds to.

If multiple ``SparkContext``s attempt to run on the same host (it is not possible to have two or more Spark contexts on a single JVM, though), they will bind to successive ports beginning with `spark.ui.port`.

| [[spark.ui.killEnabled]] `spark.ui.killEnabled`
| `true`
| Enables jobs and stages to be killed from the web UI (`true`) or not (`false`).

Used exclusively when `SparkUI` is requested to spark-webui-SparkUI.md#initialize[initialize] (and registers the redirect handlers for `/jobs/job/kill` and `/stages/stage/kill` URIs)

| [[spark.ui.retainedDeadExecutors]] `spark.ui.retainedDeadExecutors`
| `100`
| The maximum number of entries in spark-webui-executors-ExecutorsListener.md#executorToTaskSummary[executorToTaskSummary] (in `ExecutorsListener`) and spark-webui-StorageStatusListener.md#deadExecutorStorageStatus[deadExecutorStorageStatus] (in `StorageStatusListener`) internal registries.

| [[spark.ui.showConsoleProgress]] `spark.ui.showConsoleProgress`
| `true`
| Controls whether to create spark-sparkcontext-ConsoleProgressBar.md[ConsoleProgressBar] (`true`) or not (`false`).

| [[spark.ui.timeline.executors.maximum]] `spark.ui.timeline.executors.maximum`
| `1000`
| The maximum number of entries in <<executorEvents, executorEvents>> registry.

| [[spark.ui.timeline.tasks.maximum]] `spark.ui.timeline.tasks.maximum`
| `1000`
|
|===
