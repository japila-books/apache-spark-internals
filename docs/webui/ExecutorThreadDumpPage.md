# ExecutorThreadDumpPage

## Review Me

[[prefix]]
`ExecutorThreadDumpPage` is a spark-webui-WebUIPage.md[WebUIPage] with *threadDump* spark-webui-WebUIPage.md#prefix[prefix].

`ExecutorThreadDumpPage` is <<creating-instance, created>> exclusively when `ExecutorsTab` is spark-webui-ExecutorsTab.md#creating-instance[created] (with `spark.ui.threadDumpsEnabled` configuration property enabled).

NOTE: `spark.ui.threadDumpsEnabled` configuration property is enabled (i.e. `true`) by default.

=== [[creating-instance]] Creating ExecutorThreadDumpPage Instance

`ExecutorThreadDumpPage` takes the following when created:

* [[parent]] spark-webui-SparkUITab.md[SparkUITab]
* [[sc]] Optional SparkContext.md[]
