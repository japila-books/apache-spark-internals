# AllStagesPage

`AllStagesPage` is a [WebUIPage](WebUIPage.md) of [StagesTab](StagesTab.md).

![Stages Tab in web UI for FAIR scheduling mode (with pools only)](../images/webui/spark-webui-stages-alljobs.png)

![Stages Tab in web UI for FAIR scheduling mode (with pools and stages)](../images/webui/spark-webui-stages.png)

## Creating Instance

`AllStagesPage` takes the following to be created:

* <span id="parent"> Parent [StagesTab](StagesTab.md)

## <span id="render"> Rendering Page

```scala
render(
  request: HttpServletRequest): Seq[Node]
```

`render` is part of the [WebUIPage](WebUIPage.md#render) abstraction.

`render` renders a `Stages for All Jobs` page with the [stages](../status/AppStatusStore.md#stageList) and [application summary](../status/AppStatusStore.md#appSummary) (from the [AppStatusStore](../status/AppStatusStore.md) of the [parent StagesTab](#parent)).

## <span id="headers"> Stage Headers

`AllStagesPage` uses the following headers and tooltips for the Stages table.

Header   | Tooltip
---------|----------
 Stage Id |
 Pool Name |
 Description |
 Submitted |
 Duration | Elapsed time since the stage was submitted until execution completion of all its tasks.
 Tasks: Succeeded/Total |
 Input | Bytes read from Hadoop or from Spark storage.
 Output | Bytes written to Hadoop.
 Shuffle Read | Total shuffle bytes and records read (includes both data read locally and data read from remote executors).
 Shuffle Write | Bytes and records written to disk in order to be read by a shuffle in a future stage.
 Failure Reason | Bytes and records written to disk in order to be read by a shuffle in a future stage.
