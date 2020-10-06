== [[ExecutorThreadDumpPage]] ExecutorThreadDumpPage

[[prefix]]
`ExecutorThreadDumpPage` is a link:spark-webui-WebUIPage.adoc[WebUIPage] with *threadDump* link:spark-webui-WebUIPage.adoc#prefix[prefix].

`ExecutorThreadDumpPage` is <<creating-instance, created>> exclusively when `ExecutorsTab` is link:spark-webui-ExecutorsTab.adoc#creating-instance[created] (with `spark.ui.threadDumpsEnabled` configuration property enabled).

NOTE: `spark.ui.threadDumpsEnabled` configuration property is enabled (i.e. `true`) by default.

=== [[creating-instance]] Creating ExecutorThreadDumpPage Instance

`ExecutorThreadDumpPage` takes the following when created:

* [[parent]] link:spark-webui-SparkUITab.adoc[SparkUITab]
* [[sc]] Optional xref:ROOT:SparkContext.adoc[]
