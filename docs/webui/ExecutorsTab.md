== [[ExecutorsTab]] ExecutorsTab

[[prefix]]
`ExecutorsTab` is a spark-webui-SparkUITab.md[SparkUITab] with *executors* spark-webui-SparkUITab.md#prefix[prefix].

`ExecutorsTab` is <<creating-instance, created>> exclusively when `SparkUI` is spark-webui-SparkUI.md#initialize[initialized].

[[creating-instance]]
[[parent]]
`ExecutorsTab` takes the parent spark-webui-SparkUI.md[SparkUI] when created.

When <<creating-instance, created>>, `ExecutorsTab` creates the following pages and spark-webui-WebUITab.md#attachPage[attaches] them immediately:

* spark-webui-ExecutorsPage.md[ExecutorsPage]

* spark-webui-ExecutorThreadDumpPage.md[ExecutorThreadDumpPage]

`ExecutorsTab` uses spark-webui-executors-ExecutorsListener.md[ExecutorsListener] to collect information about executors in a Spark application.
