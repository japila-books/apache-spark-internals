# AppStatusStore

`AppStatusStore` stores the state of a Spark application in a [data store](#store) (listening to state changes using [AppStatusListener](#listener)).

## Creating Instance

`AppStatusStore` takes the following to be created:

* <span id="store"> [KVStore](../core/KVStore.md)
* <span id="listener"> [AppStatusListener](../status/AppStatusListener.md)

`AppStatusStore` is created using [createLiveStore](#createLiveStore) utility.

![AppStatusStore in Spark Application](../images/core/AppStatusStore-createLiveStore.png)

## <span id="createLiveStore"> Creating In-Memory Store for Live Spark Application

```scala
createLiveStore(
  conf: SparkConf,
  appStatusSource: Option[AppStatusSource] = None): AppStatusStore
```

`createLiveStore` creates an [ElementTrackingStore](ElementTrackingStore.md) (with [InMemoryStore](../core/InMemoryStore.md) and the [SparkConf](../SparkConf.md)).

`createLiveStore` creates an [AppStatusListener](../status/AppStatusListener.md) (with the `ElementTrackingStore`, [live](../status/AppStatusListener.md#live) flag on and the `AppStatusSource`).

In the end, creates an [AppStatusStore](#creating-instance) (with the `ElementTrackingStore` and `AppStatusListener`).

`createLiveStore` is used when:

* `SparkContext` is [created](../SparkContext-creating-instance-internals.md#_statusStore)

## <span id="SparkContext"> Accessing AppStatusStore

`AppStatusStore` is available using [SparkContext](../SparkContext.md#statusStore).

## <span id="SparkStatusTracker"> SparkStatusTracker

`AppStatusStore` is used to create [SparkStatusTracker](../SparkStatusTracker.md).

## <span id="SparkUI"> SparkUI

`AppStatusStore` is used to create [SparkUI](../webui/SparkUI.md).

## <span id="rddList"> RDDs

```scala
rddList(
  cachedOnly: Boolean = true): Seq[v1.RDDStorageInfo]
```

`rddList` requests the [KVStore](#store) for (a [view](../core/KVStore.md#view) over) `RDDStorageInfo`s (cached or not based on the given `cachedOnly` flag).

`rddList` is used when:

* `AbstractApplicationResource` is requested for the [RDDs](../rest/AbstractApplicationResource.md#rddList)
* `StageTableBase` is created (and renders a stage table for [AllStagesPage](../webui/AllStagesPage.md), [JobPage](../webui/JobPage.md) and [PoolPage](../webui/PoolPage.md))
* `StoragePage` is requested to [render](../webui/StoragePage.md#render)

## <span id="streamBlocksList"> Streaming Blocks

```scala
streamBlocksList(): Seq[StreamBlockData]
```

`streamBlocksList` requests the [KVStore](#store) for (a [view](../core/KVStore.md#view) over) `StreamBlockData`s.

`streamBlocksList` is used when:

* `StoragePage` is requested to [render](../webui/StoragePage.md#render)

## <span id="stageList"> Stages

```scala
stageList(
  statuses: JList[v1.StageStatus]): Seq[v1.StageData]
```

`stageList` requests the [KVStore](#store) for (a [view](../core/KVStore.md#view) over) `StageData`s.

`stageList` is used when:

* `SparkStatusTracker` is requested for [active stage IDs](../SparkStatusTracker.md#getActiveStageIds)
* `StagesResource` is requested for [stages](../rest/StagesResource.md#stages)
* `AllStagesPage` is requested to [render](../webui/AllStagesPage.md#render)

## <span id="jobsList"> Jobs

```scala
jobsList(
  statuses: JList[JobExecutionStatus]): Seq[v1.JobData]
```

`jobsList` requests the [KVStore](#store) for (a [view](../core/KVStore.md#view) over) `JobData`s.

`jobsList` is used when:

* `SparkStatusTracker` is requested for [getJobIdsForGroup](../SparkStatusTracker.md#getJobIdsForGroup) and [getActiveJobIds](../SparkStatusTracker.md#getActiveJobIds)
* `AbstractApplicationResource` is requested for [jobs](../rest/AbstractApplicationResource.md#jobsList)
* `AllJobsPage` is requested to [render](../webui/AllJobsPage.md#render)

## <span id="executorList"> Executors

```scala
executorList(
  activeOnly: Boolean): Seq[v1.ExecutorSummary]
```

`executorList` requests the [KVStore](#store) for (a [view](../core/KVStore.md#view) over) `ExecutorSummary`s.

`executorList` is used when:

* FIXME

## <span id="appSummary"> Application Summary

```scala
appSummary(): AppSummary
```

`appSummary` requests the [KVStore](#store) to [read](../core/KVStore.md#read) the `AppSummary`.

`appSummary` is used when:

* `AllJobsPage` is requested to [render](../webui/AllJobsPage.md#render)
* `AllStagesPage` is requested to [render](../webui/AllStagesPage.md#render)
