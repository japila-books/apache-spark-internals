# PoolPage

`PoolPage` is a [WebUIPage](WebUIPage.md) of [StagesTab](StagesTab.md).

![Details Page for production Pool](../images/webui/spark-webui-pool-details.png)

## Creating Instance

`PoolPage` takes the following to be created:

* <span id="parent"> Parent [StagesTab](StagesTab.md)

## <span id="prefix"> URL Prefix

`PoolPage` uses `pool` [URL prefix](WebUIPage.md#prefix).

## <span id="render"> Rendering Page

```scala
render(
  request: HttpServletRequest): Seq[Node]
```

`render` is part of the [WebUIPage](WebUIPage.md#render) abstraction.

`render` requires `poolname` and `attempt` request parameters.

`render` renders a `Fair Scheduler Pool` page with the [PoolData](../status/AppStatusStore.md#pool) (from the [AppStatusStore](../status/AppStatusStore.md) of the [parent StagesTab](#parent)).

## Introduction

The Fair Scheduler Pool Details page shows information about a [Schedulable pool](../scheduler/Pool.md) and is only available when a Spark application uses the [FAIR](../scheduler/SchedulingMode.md#FAIR) scheduling mode.

### Summary Table

The **Summary** table shows the details of a [Schedulable](../scheduler/Schedulable.md) pool.

![Summary for production Pool](../images/webui/spark-webui-pool-summary.png)

It uses the following columns:

* Pool Name
* Minimum Share
* Pool Weight
* Active Stages (the number of the active stages in a `Schedulable` pool)
* Running Tasks
* SchedulingMode

### Active Stages Table

The **Active Stages** table shows the active stages in a pool.

![Active Stages for production Pool](../images/webui/spark-webui-active-stages.png)
