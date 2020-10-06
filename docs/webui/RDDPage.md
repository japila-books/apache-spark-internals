== [[RDDPage]] RDDPage

[[prefix]]
`RDDPage` is a link:spark-webui-WebUIPage.adoc[WebUIPage] with *rdd* link:spark-webui-WebUIPage.adoc#prefix[prefix].

`RDDPage` is <<creating-instance, created>> exclusively when `StorageTab` is link:spark-webui-StorageTab.adoc#creating-instance[created].

[[creating-instance]]
`RDDPage` takes the following when created:

* [[parent]] Parent link:spark-webui-SparkUITab.adoc[SparkUITab]
* [[store]] xref:core:AppStatusStore.adoc[]

=== [[render]] `render` Method

[source, scala]
----
render(request: HttpServletRequest): Seq[Node]
----

NOTE: `render` is part of link:spark-webui-WebUIPage.adoc#render[WebUIPage Contract] to...FIXME.

`render`...FIXME
