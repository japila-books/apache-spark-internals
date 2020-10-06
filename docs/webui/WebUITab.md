== [[WebUITab]] WebUITab -- Contract of Tabs in Web UI

`WebUITab` represents a <<implementations, tab>> in web UI with a <<name, name>> and <<pages, pages>>.

`WebUITab` can be:

* spark-webui-WebUI.md#attachTab[attached] or spark-webui-WebUI.md#detachTab[detached] from a `WebUI`

* spark-webui-WebUITab.md#attachPage[attached] to a `WebUITab`

[[pages]]
`WebUITab` is simply a collection of spark-webui-WebUIPage.md[WebUIPages] that can be <<attachPage, attached>> to the tab.

[[name]]
`WebUITab` has a name (and defaults to <<prefix, prefix>> capitalized).

[[implementations]]
NOTE: spark-webui-SparkUITab.md[SparkUITab] is the one and only implementation of `WebUITab` contract.

NOTE: `WebUITab` is a `private[spark]` contract.

=== [[attachPage]] Attaching Page to Tab -- `attachPage` Method

[source, scala]
----
attachPage(page: WebUIPage): Unit
----

`attachPage` prepends the spark-webui-WebUIPage.md#prefix[page prefix] (of the input `WebUIPage`) with the <<prefix, tab prefix>> (with no ending slash, i.e. `/`, if the page prefix is undefined).

In the end, `attachPage` adds the `WebUIPage` to <<pages, pages>> registry.

NOTE: `attachPage` is used when spark-webui-SparkUITab.md#implementations[web UI tabs] register their pages.

=== [[basePath]] Requesting Base URI Path -- `basePath` Method

[source, scala]
----
basePath: String
----

`basePath` requests the <<parent, parent WebUI>> for the spark-webui-WebUI.md#basePath[base path].

NOTE: `basePath` is used when...FIXME

=== [[headerTabs]] Requesting Header Tabs -- `headerTabs` Method

[source, scala]
----
headerTabs: Seq[WebUITab]
----

`headerTabs` requests the <<parent, parent WebUI>> for the spark-webui-WebUI.md#headerTabs[header tabs].

NOTE: `headerTabs` is used exclusively when `UIUtils` is requested to spark-webui-UIUtils.md#headerSparkPage[headerSparkPage].

=== [[creating-instance]] Creating WebUITab Instance

`WebUITab` takes the following when created:

* [[parent]] Parent spark-webui-WebUI.md[WebUI]
* [[prefix]] Prefix

`WebUITab` initializes the <<internal-registries, internal registries and counters>>.

NOTE: `WebUITab` is a Scala abstract class and cannot be created directly, but only as one of the <<implementations, implementations>>.
