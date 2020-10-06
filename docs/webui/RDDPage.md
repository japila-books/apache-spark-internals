== [[RDDPage]] RDDPage

[[prefix]]
`RDDPage` is a spark-webui-WebUIPage.md[WebUIPage] with *rdd* spark-webui-WebUIPage.md#prefix[prefix].

`RDDPage` is <<creating-instance, created>> exclusively when `StorageTab` is spark-webui-StorageTab.md#creating-instance[created].

[[creating-instance]]
`RDDPage` takes the following when created:

* [[parent]] Parent spark-webui-SparkUITab.md[SparkUITab]
* [[store]] core:AppStatusStore.md[]

=== [[render]] `render` Method

[source, scala]
----
render(request: HttpServletRequest): Seq[Node]
----

NOTE: `render` is part of spark-webui-WebUIPage.md#render[WebUIPage Contract] to...FIXME.

`render`...FIXME
