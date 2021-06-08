# WebUI

`WebUI` is an [abstraction](#contract) of [UIs](#implementations).

## Contract

### <span id="initialize"> Initializing

```scala
initialize(): Unit
```

Initializes components of the UI

Used by the [implementations](#implementations) themselves.

!!! NOTE
    `initialize` does not add anything special to the Scala type hierarchy but a common name to use across [WebUI](#implementations)s.
    In other words, `initialize` does not participate in any design pattern or a type hierarchy and serves no purpose of being part of the contract.

## Implementations

* [HistoryServer](../history-server/HistoryServer.md)
* MasterWebUI (Spark Standalone)
* MesosClusterUI (Spark on Mesos)
* [SparkUI](SparkUI.md)
* WorkerWebUI (Spark Standalone)

## Creating Instance

`WebUI` takes the following to be created:

* <span id="securityManager"> `SecurityManager`
* <span id="sslOptions"> `SSLOptions`
* <span id="port"> Port
* <span id="conf"> [SparkConf](../SparkConf.md)
* <span id="basePath"> Base Path (default: empty)
* <span id="name"> Name (default: empty)

??? note "Abstract Class"
    `WebUI` is an abstract class and cannot be created directly. It is created indirectly for the [concrete WebUIs](#implementations).

## <span id="tabs"><span id="getTabs"> Tabs

`WebUI` uses `tabs` registry for [WebUITab](WebUITab.md)s (that have been [attached](#attachTab)).

Tabs can be [attached](#attachTab) and [detached](#detachTab).

### <span id="attachTab"> Attaching Tab

```scala
attachTab(
  tab: WebUITab): Unit
```

`attachTab` [attaches](#attachPage) the [pages](WebUITab.md#pages) of the given [WebUITab](WebUITab.md) (and adds it to the [tabs](#tabs)).

### <span id="detachTab"> Detaching Tab

```scala
detachTab(
  tab: WebUITab): Unit
```

`detachTab` [detaches](#detachPage) the [pages](WebUITab.md#pages) of the given [WebUITab](WebUITab.md) (and removes it from the [tabs](#tabs)).

## <span id="pageToHandlers"> Pages

`WebUI` uses `pageToHandlers` registry for [WebUIPage](WebUIPage.md)s and their associated `ServletContextHandler`s.

Pages can be [attached](#attachPage) and [detached](#detachPage).

### <span id="attachPage"> Attaching Page

```scala
attachPage(
  page: WebUIPage): Unit
```

`attachPage`...FIXME

`attachPage` is used when:

* `WebUI` is requested to [attach a tab](#attachTab)
* _others_

### <span id="detachPage"> Detaching Page

```scala
detachPage(
  page: WebUIPage): Unit
```

`detachPage` removes the given [WebUIPage](WebUIPage.md) from the UI (the [pageToHandlers](#pageToHandlers) registry) with all of the handlers.

`detachPage` is used when:

* `WebUI` is requested to [detach a tab](#detachTab)

## Logging

Since `WebUI` is an abstract class, logging is configured using the logger of the [implementations](#implementations).
