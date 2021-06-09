# EnvironmentTab

![Environment Tab in Web UI](../images/webui/spark-webui-environment.png)

## Review Me

[[prefix]]
`EnvironmentTab` is a spark-webui-SparkUITab.md[SparkUITab] with *environment* spark-webui-SparkUITab.md#prefix[prefix].

`EnvironmentTab` is <<creating-instance, created>> exclusively when `SparkUI` is spark-webui-SparkUI.md#initialize[initialized].

[[creating-instance]]
`EnvironmentTab` takes the following when created:

* [[parent]] Parent spark-webui-SparkUI.md[SparkUI]
* [[store]] core:AppStatusStore.md[]

When created, `EnvironmentTab` creates the spark-webui-EnvironmentPage.md#creating-instance[EnvironmentPage] page and spark-webui-WebUITab.md#attachPage[attaches] it immediately.
