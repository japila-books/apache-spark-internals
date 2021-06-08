# WebUI

`WebUI` is an [abstraction](#contract) of [UIs](#implementations).

## Contract

### <span id="initialize"> initialize

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

`WebUI` uses `tabs` registry of [WebUITab](WebUITab.md)s.

A tab can be registered (_attached_) and deregistered (_detached_) using [attachTab](#attachTab) and [detachTab](#detachTab), respectively.

## <span id="attachTab"> Attaching Tab

```scala
attachTab(
  tab: WebUITab): Unit
```

`attachTab`...FIXME

## <span id="detachTab"> Detaching Tab

```scala
detachTab(
  tab: WebUITab): Unit
```

`detachTab`...FIXME

## Logging

Since `WebUI` is an abstract class, logging is configured using the logger of the [implementations](#implementations).
